/* -*- c-file-style: "java"; indent-tabs-mode: nil -*-
 * 
 * distcc -- A simple distributed compiler system
 *
 * Copyright (C) 2002, 2003, 2004 by Martin Pool
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 */

/*
 * Send a compilation request to a remote server.
 */


#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/time.h>

#include "distcc.h"
#include "trace.h"
#include "rpc.h"
#include "exitcode.h"
#include "util.h"
#include "clinet.h"
#include "hosts.h"
#include "exec.h"
#include "lock.h"
#include "compile.h"
#include "bulk.h"


/*
 * TODO: If cpp finishes early and fails then perhaps break out of
 * trying to connect.
 *
 * TODO: If we abort, perhaps kill the SSH child rather than closing
 * the socket.  Closing while a lot of stuff has been written through
 * might make us block until the other side reads all the data.
 */

/**
 * Open a connection using either a TCP socket or SSH.  Return input
 * and output file descriptors (which may or may not be different.)
 **/
static int dcc_remote_connect(struct dcc_hostdef *host,
                              int *to_net_fd,
                              int *from_net_fd,
                              pid_t *ssh_pid)
{
    int ret;
    
    if (host->mode == DCC_MODE_TCP) {
        *ssh_pid = 0;
        if ((ret = dcc_connect_by_name(host->hostname, host->port,
                                       to_net_fd)) != 0)
            return ret;
        *from_net_fd = *to_net_fd;
        return 0;
    } else if (host->mode == DCC_MODE_SSH) {
        if ((ret = dcc_ssh_connect(NULL, host->user, host->hostname,
                                   host->ssh_command,
                                   from_net_fd, to_net_fd,
                                   ssh_pid)))
            return ret;
        return 0;
    } else {
        rs_log_crit("impossible host mode");
        return EXIT_DISTCC_FAILED;
    }
}


static int dcc_wait_for_cpp(pid_t cpp_pid,
                            int *status,
                            const char *input_fname)
{
    int ret;
    
    if (cpp_pid) {
        dcc_note_state(DCC_PHASE_CPP, NULL, NULL);
        /* Wait for cpp to finish (if not already done), check the
         * result, then send the .i file */
        
        if ((ret = dcc_collect_child("cpp", cpp_pid, status)))
            return ret;

        /* Although cpp failed, there is no need to try running the command
         * locally, because we'd presumably get the same result.  Therefore
         * critique the command and log a message and return an indication
         * that compilation is complete. */
        if (dcc_critique_status(*status, "cpp", input_fname, dcc_hostdef_local, 0))
            return 0;
    }
    return 0;
}


/* Send a request across to the already-open server.
 *
 * CPP_PID is the PID of the preprocessor running in the background.
 * We wait for it to complete before reading its output.
 */
static int
dcc_send_header(int net_fd,
                char **argv,
                struct dcc_hostdef *host)
{
    int ret;

    tcp_cork_sock(net_fd, 1);

    if ((ret = dcc_x_req_header(net_fd, host->protover))
        || (ret = dcc_x_argv(net_fd, argv)))
        return ret;

    return 0;
}


/**
 * Pass a compilation across the network.
 *
 * When this function is called, the preprocessor has already been
 * started in the background.  It may have already completed, or it
 * may still be running.  The goal is that preprocessing will overlap
 * with setting up the network connection, which may take some time
 * but little CPU.
 *
 * If this function fails, compilation will be retried on the local
 * machine.
 *
 * @param argv Compiler command to run.
 *
 * @param cpp_fname Filename of preprocessed source.  May not be complete yet,
 * depending on @p cpp_pid.
 *
 * @param output_fname File that the object code should be delivered to.
 * 
 * @param cpp_pid If nonzero, the pid of the preprocessor.  Must be
 * allowed to complete before we send the input file.
 *
 * @param host Definition of host to send this job to.
 *
 * @param status on return contains the wait-status of the remote
 * compiler.
 *
 * Returns 0 on success, otherwise error.  Returning nonzero does not
 * necessarily imply the remote compiler itself succeeded, only that
 * there were no communications problems.
 */
int dcc_compile_remote(char **argv, 
                       char *input_fname,
                       char *cpp_fname,
                       char *output_fname,
                       pid_t cpp_pid,
                       struct dcc_hostdef *host,
                       int *status)
{
    int to_net_fd, from_net_fd;
    int ret;
    pid_t ssh_pid = 0;
    int ssh_status;
    off_t doti_size;
    struct timeval before, after;

    if (gettimeofday(&before, NULL))
        rs_log_warning("gettimeofday failed");

    dcc_note_execution(host, argv);
    dcc_note_state(DCC_PHASE_CONNECT, input_fname, host->hostname);

    /* For ssh support, we need to allow for separate fds writing to and
     * reading from the network, because our connection to the ssh client may
     * be over pipes, which are one-way connections. */

    *status = 0;
    if ((ret = dcc_remote_connect(host, &to_net_fd, &from_net_fd, &ssh_pid)))
        goto out;
    
    dcc_note_state(DCC_PHASE_SEND, NULL, NULL);

    /* This waits for cpp and puts its status in *status.  If cpp failed, then
     * the connection will have been dropped and we need not bother trying to
     * get any response from the server. */
    ret = dcc_send_header(to_net_fd, argv, host);

    ret = dcc_wait_for_cpp(cpp_pid, status, input_fname);
    
    dcc_unlock_cpp_lock();
    
    if (ret)
        goto out;
    
    if ((ret = dcc_x_file(to_net_fd, cpp_fname, "DOTI", host->compr, &doti_size)))
        goto out;

    rs_trace("client finished sending request to server");
    tcp_cork_sock(to_net_fd, 0);
    /* but it might not have been read in by the server yet; there's
     * 100kB or more of buffers in the two kernels. */

    /* OK, now all of the source has at least made it into the
     * client's TCP transmission queue, sometime soon the server will
     * start compiling it.  */
    dcc_note_state(DCC_PHASE_COMPILE, NULL, host->hostname);

    if (to_net_fd != from_net_fd) {
        /* in ssh mode, we can start closing down early */
        dcc_close(to_net_fd);
    }

    /* If cpp failed, just abandon the connection, without trying to
     * receive results. */
    if (ret == 0 && *status == 0) {
        ret = dcc_retrieve_results(from_net_fd, status, output_fname,
                                   host);
    }

    /* Close socket so that the server can terminate, rather than
     * making it wait until we've finished our work. */
    dcc_close(from_net_fd);

    if (gettimeofday(&after, NULL)) {
        rs_log_warning("gettimeofday failed");
    } else {
        double secs, rate;
        
        dcc_calc_rate(doti_size, &before, &after, &secs, &rate);
        rs_log(RS_LOG_INFO|RS_LOG_NONAME,
               "%lu bytes from %s compiled on %s in %.4fs, rate %.0fkB/s",
               (unsigned long) doti_size, input_fname, host->hostname,
               secs, rate);
    }
   
  out:
    /* Collect the SSH child.  Strictly this is unnecessary; it might slow the
     * client down a little when things could otherwise be proceeding in the
     * background.  But it helps make sure that we don't assume we succeeded
     * when something possibly went wrong, and it allows us to account for the
     * cost of the ssh child. */
    if (ssh_pid) {
        dcc_collect_child("ssh", ssh_pid, &ssh_status); /* ignore failure */
    }
    
    return ret;
}


int dcc_show_host_version(char *host)
{
    int to_net_fd, from_net_fd;
    int ret;
    pid_t ssh_pid = 0;
    int ssh_status;
    off_t doti_size;
    char *info;
    struct dcc_hostdef *hostlist, *hostdef;
    int n_hosts;
    char *argv[] = { "--host-info", NULL };

    if ((ret = dcc_parse_hosts(host, "command line", &hostlist, &n_hosts)) != 0) {
        rs_log_error("bad host argument: %s", host);
    } else {
        hostdef = hostlist;
        while (hostdef && strcmp(hostdef->hostname, host) != 0)
            hostdef = hostdef->next;
        if (!hostdef) {
            rs_log_error("couldn't find %s in host list", host);
            ret = EXIT_BAD_ARGUMENTS;
        }
    }
    
    if (!ret && (ret = dcc_remote_connect(hostdef, &to_net_fd, &from_net_fd, &ssh_pid)) != 0) {
        rs_log_error("couldn't connect to %s", host);
        printf("ERROR=%d\n", errno);
    }
    
    if (!ret && (ret = dcc_send_header(to_net_fd, argv, hostdef)) != 0) {
        rs_log_error("failed to send request");
        printf("ERROR=%d\n", errno);
    }
    
    if (to_net_fd != from_net_fd) {
        /* in ssh mode, we can start closing down early */
        dcc_close(to_net_fd);
    }
    
    if (ret == 0) {
        ret = dcc_r_result_header(from_net_fd, hostdef->protover);
        if (ret == 0) {
            ret = dcc_r_token_string(from_net_fd, "HINF", &info);
        }
        if (ret != 0) {
            rs_log_error("failed to read result");
            printf("ERROR=%d\n", errno);
        }
    }
    
    /* Close socket so that the server can terminate, rather than
        * making it wait until we've finished our work. */
    dcc_close(from_net_fd);
    if (ret == 0)
        printf("%s\n", info);
    return ret;
}



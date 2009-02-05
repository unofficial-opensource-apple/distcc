/* -*- c-file-style: "java"; indent-tabs-mode: nil; fill-column: 78; -*-
 * 
 * distcc -- A simple distributed compiler system
 *
 * Copyright (C) 2002, 2003 by Martin Pool <mbp@samba.org>
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


                /* "Just like distributed.net, only useful!" */

/**
 * @file
 *
 * distcc volunteer server.  Accepts and serves requests to compile
 * files.
 *
 * May be run from inetd (default if stdin is a socket), or as a
 * daemon by itself.  
 *
 * distcc has an adequate but perhaps not optimal system for deciding
 * where to send files.  The general principle is that the server
 * should say how many jobs it is willing to accept, rather than the
 * client having to know.  This is probably good in two ways: it
 * allows for people in the future to impose limits on how much work
 * their contributed machine will do, and secondly it seems better to
 * put this information in one place rather than on every client.
 **/

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <syslog.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/param.h>
#include <sys/socket.h>

#include <netinet/in.h>
#include <netinet/tcp.h>

#ifdef HAVE_ARPA_NAMESER_H
#  include <arpa/nameser.h>
#endif

#include <arpa/inet.h>


#include "exitcode.h"
#include "distcc.h"
#include "trace.h"
#include "util.h"
#include "dopt.h"
#include "srvnet.h"
#include "daemon.h"
#include "types.h"


/* for trace.c */
char const *rs_program_name = "distccd";


static int dcc_inetd_server(void);
static void dcc_setup_real_log(void);


/* -*- c-file-style: "java"; indent-tabs-mode: nil; fill-column: 78 -*-
* 
* distcc -- A simple distributed compiler system
*
* Copyright (C) 2003, 2005 by Apple Computer, Inc.
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


/**
* @file
 *
 * Registration functions for the server process (distccd) for zeroconfiguration
 * feature.
 **/


#include <arpa/inet.h>
#include <inttypes.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <dns_sd.h>
#include <sys/socket.h>
#include <ifaddrs.h>




static DNSServiceRef zcRegRef    = NULL;
static pthread_t     zcRegThread;
static int           zcPort;

// Bonjour registration


/**
* Handle registration messages from the mDNSResponder.
 * Otherwise, log <code>name</code> to the console.
 **/
static void dcc_reg_reply(const DNSServiceRef     ref,
                               const DNSServiceFlags     flags,
                               const DNSServiceErrorType errorCode,
                               const char               *aName,
                               const char               *aRegType,
                               const char               *aDomain,
                               void               *aContext)
{
    if ( errorCode ) {
        rs_log_error("Aborting zeroconfiguration registration due to error: %d", errorCode);
        pthread_exit(NULL);
    } else {
        rs_log_info("Registered and active as \"%s.%s%s\"", aName, aRegType, aDomain);
    }
}


/**
* Invoke <code>DNSServiceRegister</code>.
 * Invoke <code>DNSServiceDiscoveryProcessResult</code> until an error is
 * encountered.
 * Invoke <code>apple_zc_reg_cleanup</code> and terminate the thread upon error.
 **/
static void dcc_actually_register(void *listen_addr_ptr)
{
    char *listen_addr = (char *)listen_addr_ptr;
    char *service = getenv("DISTCCD_SERVICE_NAME");
    int interface = 0;

    if (listen_addr != NULL) {
         struct ifaddrs *first, *curr;
         struct in_addr addr;
         struct sockaddr  *ifa_addr;
         inet_aton(listen_addr, &addr);
         if (getifaddrs(&first) == 0) {
             curr = first;
             while (curr && interface == 0) {
                 if (curr->ifa_addr->sa_family == AF_INET) {
                     struct sockaddr_in *in_addr = (struct sockaddr_in *)curr->ifa_addr;
                     if (memcmp(&addr, &in_addr->sin_addr, sizeof(struct in_addr)) == 0)
                         interface = if_nametoindex(curr->ifa_name);
                 }
                 curr = curr->ifa_next;
             }
             freeifaddrs(first);
         }
     }

    if (service == NULL)
        service = "_xcodedistcc._tcp.";
    DNSServiceErrorType exitValue = DNSServiceRegister(&zcRegRef,
                                                       0,
                                                       0,
                                                       NULL,
                                                       service,
                                                       "",
                                                       NULL,
                                                       htons(zcPort),
                                                       0,
                                                       NULL,
                                                       (DNSServiceRegisterReply)dcc_reg_reply,
                                                       NULL);
        
    if ( exitValue == kDNSServiceErr_NoError ) {
        // Continue processing incoming messages.
        // This might not terminate until the process terminates.
        while ( 1 ) {
            exitValue = DNSServiceProcessResult(zcRegRef);
            
            if ( exitValue != kDNSServiceErr_NoError ) {
                rs_log_error("Unable to handle zeroconfiguration replies: %d", exitValue);
                break;
            }
        }
    } else {
        rs_log_error("Unable to register for zeroconfiguration: %d", exitValue);
    }
    
    // Doubtful we'll ever get here.
    pthread_exit(NULL);
}


void dcc_register_bonjour(int servicePort)
{
    zcPort = servicePort;
    /*  Spawn a separate thread using to handle replies from the mDNSResponder. */
    if ( pthread_create(&zcRegThread, NULL,
                        (void *(*)(void *))dcc_actually_register,
                        opt_listen_addr) ) {
        rs_log_error("Unable to create thread for zeroconfiguration");
    }
}



/**
 * Errors during startup (e.g. bad options) need to be reported somewhere,
 * although we have not yet parsed the options to work out where the user
 * wants them.
 *
 * In inetd mode, we can't write to stderr because that will corrupt the
 * stream, so if it looks like stderr is a socket we go to syslog instead.
 **/
static int dcc_setup_startup_log(void)
{
    rs_trace_set_level(RS_LOG_INFO);
    if (!is_a_socket(STDERR_FILENO)) {
        rs_add_logger(rs_logger_file, RS_LOG_DEBUG, 0, STDERR_FILENO);
    } else {
        openlog("distccd", LOG_PID, LOG_DAEMON);
        rs_add_logger(rs_logger_syslog, RS_LOG_DEBUG, NULL, 0);
    }

    return 0;
}


static int dcc_should_be_inetd(void)
{
    /* Work out if we ought to serve stdin or be a standalone daemon */
    if (opt_inetd_mode)
        return 1;
    else if (opt_daemon_mode)
        return 0;
    else if (is_a_socket(STDIN_FILENO)) {
        rs_log_info("stdin is socket; assuming --inetd mode");
        return 1;
    } else if (isatty(STDIN_FILENO)) {
        rs_log_info("stdin is a tty; assuming --daemon mode");
        return 0;
    } else {
        rs_log_info("stdin is neither a tty nor a socket; assuming --daemon mode");
        return 0;
    }
}


static int dcc_setup_daemon_path(void)
{
    int ret;
    const char *path;

    if ((path = getenv("DISTCCD_PATH")) != NULL) {
        if ((ret = dcc_set_path(path)))
            return ret;

        return 0;
    } else {
        path = getenv("PATH");
        rs_log_info("daemon's PATH is %s", path ? path : "(NULL)");
        return 0;
    }
}


/**
 * distcc daemon.  May run from inetd, or standalone.  Accepts
 * requests from clients to compile files.
 **/
int main(int argc, char *argv[])
{
    int ret;
    const char *tmp;

    dcc_setup_startup_log();

    if (distccd_parse_options(argc, (const char **) argv))
        dcc_exit(EXIT_DISTCC_FAILED);

    dcc_register_bonjour(arg_port);

    /* check this before redirecting the logs, so that it's really obvious */
    if (!dcc_should_be_inetd())
        /*
        if (opt_allowed == NULL) {
            rs_log_error("--allow option is now mandatory; "
                         "you must specify which clients are allowed to connect");
            ret = EXIT_BAD_ARGUMENTS;
            goto out;
        }
         */

    if ((ret = dcc_set_lifetime()) != 0)
        dcc_exit(ret);
    
    /* do this before giving away root */
    if (nice(opt_niceness) == -1) {
        rs_log_warning("nice %d failed: %s", opt_niceness,
                       strerror(errno));
        /* continue anyhow */
    }

    if ((ret = dcc_discard_root()) != 0)
        dcc_exit(ret);

    /* Discard privileges before opening log so that if it's created, it has
     * the right ownership. */
    dcc_setup_real_log();

    /* Do everything from root directory.  Allows start directory to be
     * unmounted, should make accidental writing of local files cause a
     * failure... */
    if ((ret = dcc_get_tmp_top(&tmp)))
        goto out;
    
    if (chdir(tmp) == -1) {
        rs_log_error("failed to chdir to %s: %s", tmp, strerror(errno));
        ret = EXIT_IO_ERROR;
        goto out;
    } else {
        rs_trace("chdir to %s", tmp);
    }

    if ((ret = dcc_setup_daemon_path()))
        goto out;

    if (dcc_should_be_inetd())
        ret = dcc_inetd_server();
    else
        ret = dcc_standalone_server();
    
    out:
    dcc_exit(ret);
}


/**
 * If a --lifetime options was specified, set up a timer that will kill the
 * daemon when it expires.
 **/
int dcc_set_lifetime(void)
{
    if (opt_lifetime) {
        alarm(opt_lifetime);
/*         rs_trace("set alarm for %+d seconds", opt_lifetime); */
    }
    return 0;
}


/**
 * Set log to the final destination after options have been read.
 **/
static void dcc_setup_real_log(void)
{
    int fd;

    /* Even in inetd mode, we might want to log to stderr, because that will
     * work OK for ssh connections. */
    
    if (opt_log_stderr) {
        rs_remove_all_loggers();
        rs_add_logger(rs_logger_file, RS_LOG_DEBUG, 0, STDERR_FILENO);
        return;
    }
    
    if (arg_log_file) {
        /* Don't remove loggers yet, in case this fails and needs to go to the
         * default. */
        if ((fd = open(arg_log_file, O_CREAT|O_APPEND|O_WRONLY, 0666)) == -1) {
            rs_log_error("failed to open %s: %s", arg_log_file,
                         strerror(errno));
            /* continue and use syslog */
        } else {
            rs_remove_all_loggers();
            rs_add_logger(rs_logger_file, RS_LOG_DEBUG, NULL, fd);
            return;
        }
    }
    
    rs_remove_all_loggers();
    openlog("distccd", LOG_PID, LOG_DAEMON);
    rs_add_logger(rs_logger_syslog, RS_LOG_DEBUG, NULL, 0);
}


int dcc_log_daemon_started(const char *role)
{
    rs_log_info("%s started (%s %s, built %s %s)",
                role,
                PACKAGE_VERSION,
                GNU_HOST, 
                __DATE__, __TIME__);

    return 0;
}


/**
 * Serve a single file on stdin, and then exit.
 **/
static int dcc_inetd_server(void)
{
    int ret, close_ret;
    struct dcc_sockaddr_storage ss;
    struct sockaddr *psa = (struct sockaddr *) &ss;
    socklen_t len = sizeof ss;
    
    dcc_log_daemon_started("inetd server");

    if ((getpeername(STDIN_FILENO, psa, &len) == -1)) {
        /* This can fail with ENOTSOCK if e.g. sshd has started us on a pipe,
         * not on a socket.  I think it's harmless. */
        rs_log_notice("failed to get peer name: %s", strerror(errno));
        psa = NULL;             /* make sure we don't refer to uninitialized mem */
        len = 0;
    }

    ret = dcc_service_job(STDIN_FILENO, STDOUT_FILENO, psa, len);

    close_ret = dcc_close(STDIN_FILENO);

    if (ret)
        return ret;
    else
        return close_ret;
}


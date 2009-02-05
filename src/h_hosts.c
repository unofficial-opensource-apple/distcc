/* -*- c-file-style: "java"; indent-tabs-mode: nil -*-
 * 
 * distcc -- A simple distributed compiler system
 * $Header: /cvs/karma/distcc/src/h_hosts.c,v 1.1.1.1 2005/05/06 05:09:42 deatley Exp $ 
 *
 * Copyright (C) 2002 by Martin Pool <mbp@samba.org>
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
 * Test harness for hosts.c.
 *
 * Precondition: DISTCC_HOSTS set in the environment.
 *
 * Action: calls the environment parser.
 *
 * Output: on the first line, the number of hosts.  Then, one per
 * line, either
 *
 * "ssh" USER HOST COMMAND
 * "tcp" HOST PORT
 **/


#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <errno.h>
#include <time.h>

#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "distcc.h"
#include "trace.h"
#include "util.h"
#include "hosts.h"
#include "exitcode.h"

const char *rs_program_name = "h_hosts";

int main(int UNUSED(argc), char **argv)
{
    struct dcc_hostdef *list, *e;
    int nhosts, i;
    int ret;

    if (argv[1] && !strcmp(argv[1], "-v")) {
        rs_trace_set_level(RS_LOG_DEBUG);
    }
    
    if ((ret = dcc_parse_hosts_env(&list, &nhosts)) != 0) {
        rs_log_error("failed to parse \"%s\"", getenv("DISTCC_HOSTS"));
        exit(ret);
    }

    printf("%d\n", nhosts);
    for (i = 0, e = list; i < nhosts; i++, e = e->next) {
        if (!e) {
            rs_log_error("entry %d is NULL", i);
            exit(1);
        }

        printf("%4d ", e->n_slots);
        
        if (e->mode == DCC_MODE_LOCAL) {
            printf("LOCAL\n");
        } else if (e->mode == DCC_MODE_SSH) {
            printf("SSH %s %s %s\n",
                   e->user        ? e->user        : "(no-user)",
                   e->hostname    ? e->hostname    : "(no-hostname)",
                   e->ssh_command ? e->ssh_command : "(no-command)");
        } else if (e->mode == DCC_MODE_TCP) {
            printf("TCP %s %d\n",
                   e->hostname    ? e->hostname    : "(no-hostname)",
                   e->port);
        } else {
            printf("BOGUS %d\n", e->mode);
        }
    }
    if (e) {
        rs_log_error("extra entries in list!");
        exit(EXIT_BAD_HOSTSPEC);
    }
    
    exit(0);
}

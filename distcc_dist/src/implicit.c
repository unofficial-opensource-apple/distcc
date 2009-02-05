/* -*- c-file-style: "java"; indent-tabs-mode: nil -*-
 * 
 * distcc -- A simple distributed compiler system
 *
 * Copyright (C) 2002, 2003, 2004 by Martin Pool <mbp@samba.org>
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


                /* "I do not trouble myself to be understood. I see
                 * that the elementary laws never apologize."
                 *         -- Whitman, "Song of Myself".             */



#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>

#include "distcc.h"
#include "trace.h"
#include "exitcode.h"
#include "util.h"
#include "implicit.h"



/**
 * @file
 *
 * Handle invocations where the compiler name is implied rather than
 * specified.  That is, "distcc -c foo.c".
 *
 * This method of invocation is less transparent than the masquerade system,
 * and less explicit than giving the real compiler name.  But it is pretty
 * simple, and is retained for that reason.
 *
 * This is used on the client only.  The compiler name is always passed (as
 * argv[0]) to the server.
 *
 * The current implementation determines that no compiler name has been
 * specified by checking whether the first argument is either an option, or a
 * source or object file name.  If not, it is assumed to be the name of the
 * compiler to use.
 *
 * At the moment the default compiler name is always "cc", but this could
 * change to come from an environment variable.  That's not supported at the
 * moment, and may never be.  If you need that level of control, using a
 * different invocation method is recommended.
 **/


/**
 * Find the compiler for non-masquerade use.
 * 
 * If we're invoked with no compiler name, insert one.
 *
 * We can tell there's no compiler name because argv[1] will be either
 * a source filename or an object filename or an option.  I don't
 * think anything else is possible.
 **/
int dcc_find_compiler(char **argv, char ***out_argv)
{
    if (argv[1][0] == '-'
        || dcc_is_source(argv[1])
        || dcc_is_object(argv[1])) {
        dcc_copy_argv(argv, out_argv, 0);

        /* change "distcc -c foo.c" -> "cc -c foo.c" */
        (*out_argv)[0] = strdup("cc");
        return 0;
    } else {
        /* skip "distcc", point to "gcc -c foo.c"  */
        *out_argv = argv+1;
        return 0;
    }
}

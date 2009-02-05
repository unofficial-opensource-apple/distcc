#! /usr/bin/env python2.2

# distcc/benchmark -- automated system for testing distcc correctness
# and performance on various source trees.

# Copyright (C) 2002, 2003 by Martin Pool

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA


# Unlike the main distcc test suite, this program *does* require you
# to manually set up servers on your choice of machines on the
# network, and make sure that they all have appropriate compilers
# installed.  The performance measurements obviously depend on the
# network and hardware available.

# It also depends on you having the necessary dependencies to build
# the software.  If you regularly build software on Linux you should
# be OK.  Some things (the GIMP) will be harder than others.

# On some platforms, it may be impossible to build some targets -- for
# example, Linux depends on having a real-mode x86 assembler, which
# probably isn't installed on Solaris.

# Note that running this program will potentially download many
# megabytes of test data.


# TODO: Support applying patches after unpacking, before building.
# For example, they might be needed to fix -j bugs in the Makefile.

# TODO: In stats, show ratio of build time to slowest build time.  (Or
# to first one run?)

# TODO: Allow choice of which compiler and make options to use.

# TODO: Try building something large in C++.

# TODO: Set CXX as well.

# TODO: Add option to run tests repeatedly and show mean and std. dev.

# TODO: Perhaps add option to do "make clean" -- this might be faster
# than unzipping and configuring every time.  But perhaps also less
# reproducible.

# TODO: Add option to run tests on different sets or orderings of
# machines.


import re, os, sys, time
from getopt import getopt

from Summary import Summary
from Project import Project, trees
from compiler import CompilerSpec
from Build import Build
import actions, compiler

import ProjectDefs         # this adds a lot of definitions to 'trees'


def error(msg):
    sys.stderr.write(msg + "\n")


def list_projects():
    names = trees.keys()
    names.sort()
    for n in names:
        print n

        
def find_project(name):
    """
    Return the nearest unique match for name.
    """
    best_match = None
    for pn in trees.keys():
        if pn.startswith(name):
            if best_match:
                raise ValueError, "ambiguous prefix %s" % name
            else:
                best_match = pn
                
    if not best_match:
        raise ValueError, "nothing matches %s" % name
    else:
        return trees[best_match]



def show_help():
    print """Usage: benchmark.py [OPTION]... [PROJECT]...
Test distcc relative performance building different projects.
By default, all known projects are built.

Options:
  --help                     show brief help message
  --list-projects            show defined projects
  -c, --compiler=COMPILER    specify one compiler to use
  -n N                       repeat compilation N times
"""
    actions.action_help()


# This is for developer use only and not documented; unless you're
# careful the results will just be confusing.

#   -a, --actions=ACTIONS      comma-separated list of action phases
#                              to perform
            


######################################################################
def main():
    """Run the benchmark per arguments"""
    sum = Summary()
    options, args = getopt(sys.argv[1:], 'a:c:n:',
                           ['list-projects', 'actions=', 'help', 'compiler='])
    opt_actions = actions.default_actions
    set_compilers = []
    opt_repeats = 1

    for opt, optarg in options:
        if opt == '--help':
            show_help()
            return
        elif opt == '--list-projects':
            list_projects()
            return
        elif opt == '--actions' or opt == '-a':
            opt_actions = actions.parse_opt_actions(optarg)
        elif opt == '--compiler' or opt == '-c':
            set_compilers.append(compiler.parse_opt(optarg))
        elif opt == '-n':
            opt_repeats = int(optarg)

    if not set_compilers:
        set_compilers = compiler.default_compilers()

    # Find named projects, or run all by default
    if args:
        chosen_projects = [find_project(name) for name in args]
    else:
        chosen_projects = trees.values()

    for proj in chosen_projects:
        proj.pre_actions(opt_actions)
        for comp in set_compilers:
            build = Build(proj, comp, opt_repeats)
            build.build_actions(opt_actions, sum)

    sum.print_table()

if __name__ == '__main__':
    main()
    

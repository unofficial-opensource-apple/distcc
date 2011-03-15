# Top-level Makefile(.in) for distcc

# Copyright (C) 2002, 2003, 2004 by Martin Pool

# Note that distcc no longer uses automake, but this file is still
# structured in a somewhat similar way.

## VARIABLES

PACKAGE = distcc
VERSION = 3.1-toolwhip.1
PACKAGE_TARNAME = distcc
SHELL = /bin/sh

# These autoconf variables may contain recursive Make expansions, and
# so they have to be done here rather than written into config.h.

CFLAGS = -g -O2 -MD -W -Wall -Wimplicit -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings -Waggregate-return -Wstrict-prototypes -Wmissing-prototypes -Wnested-externs -Wmissing-declarations -Wuninitialized -D_THREAD_SAFE 
WERROR_CFLAGS = -Werror
PYTHON_CFLAGS = -Wno-missing-prototypes -Wno-missing-declarations -Wno-write-strings -Wp,-U_FORTIFY_SOURCE
POPT_CFLAGS = -Wno-unused
POPT_INCLUDES = -I"$(srcdir)/popt"

LDFLAGS = 
CC = gcc
CPP = gcc -E
# We add a few cppflags.  -Isrc is so that config.h can be found in the build
# directory.  It is before I"$(srcdir)/src" to reflect VPATH semantics.
CPPFLAGS =  -DHAVE_CONFIG_H -D_GNU_SOURCE ${DIR_DEFS} \
	   -Isrc -I"$(srcdir)/src" -I"$(srcdir)/lzo" $(POPT_INCLUDES)
PYTHON_SETUP_CFLAGS = -g -O2  -W -Wall -Wimplicit -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings -Waggregate-return -Wstrict-prototypes -Wmissing-prototypes -Wnested-externs -Wmissing-declarations -Wuninitialized -D_THREAD_SAFE 

srcdir = /private/tmp/submission/58098/distcc/distcc_dist
top_srcdir = /private/tmp/submission/58098/distcc/distcc_dist
builddir = .
top_builddir = .
VPATH = /private/tmp/submission/58098/distcc/distcc_dist
prefix = /usr
exec_prefix = ${prefix}

bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
libexecdir = ${exec_prefix}/libexec
datarootdir = ${prefix}/share
datadir = ${datarootdir}
sysconfdir = ${prefix}/etc
sharedstatedir = ${prefix}/com
localstatedir = ${prefix}/var
libdir = ${exec_prefix}/lib
mandir = ${datarootdir}/man
includedir = ${prefix}/include
oldincludedir = /usr/include
docdir = ${datadir}/doc/distcc
pkgdatadir = $(datadir)/distcc

include_server_builddir = $(builddir)/_include_server

# These must be done from here, not from autoconf, because they can 
# contain variable expansions written in Make syntax.  Ew.
DIR_DEFS = -DSYSCONFDIR="\"${sysconfdir}\"" -DPKGDATADIR="\"${pkgdatadir}\"" \
           -DPREFIXDIR="\"${prefix}\""

# arguments to pkgconfig
GNOME_PACKAGES = 
GNOME_CFLAGS = 
GNOME_LIBS = 

LIBS =  

DESTDIR = $(DSTROOT)

INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL} 
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_SCRIPT = ${INSTALL}

# We use python for two tasks in distcc: running the unittests, and
# running the include-server.  The latter requires python 2.4 or
# higher, while the former only requires python 2.2.  So it's possible
# a particular machine will be able to run one but not the other.
# Thus we have two variables.
TEST_PYTHON = /usr/bin/python2.5
INCLUDESERVER_PYTHON = /usr/bin/python2.5

# RESTRICTED_PATH is a colon separated list of directory names.  It
# contains the locations of 'make', 'sh', 'gcc', and 'python' for use
# in installation tests.  This path is used to avoid confusion caused
# by distcc masquerades on the normal path.  See the
# 'maintainer-check-no-set-path' target.
RESTRICTED_PATH = /usr/local/bin:/bin:/usr/bin

# The DISTCC_INSTALLATION variable is a colon separated list of
# directory names of possible locations for the installation to be
# checked.  Change the value of this variable to ${exec_prefix}/bin to check the
# installation at the location determined by 'configure'.
DISTCC_INSTALLATION = $(RESTRICTED_PATH)

dist_files =							\
	src/config.h.in						\
	$(dist_lzo)						\
	$(dist_contrib)						\
	$(dist_patches)						\
	$(dist_common)						\
	$(MEN)							\
	$(pkgdoc_DOCS)						\
	$(example_DOCS)						\
	$(popt_EXTRA) $(popt_SRC) $(popt_HEADERS)		\
	$(SRC) $(HEADERS)					\
	$(test_SOURCE)						\
	$(bench_PY)						\
	$(include_server_PY)                                    \
	$(dist_include_server_SH)                               \
	$(include_server_SRC)                                   \
	$(check_include_server_DATA)                            \
	$(check_include_server_PY)                              \
	$(conf_files)                                           \
	$(default_files)                                        \
	$(dist_extra)						\
	$(gnome_data)

dist_dirs = m4 include_server/test_data

dist_lzo = lzo/minilzo.c lzo/minilzo.h lzo/lzoconf.h lzo/.stamp-conf.in

dist_contrib = contrib/distcc-absolutify	\
	contrib/distcc.sh		\
	contrib/distccd-init		\
	contrib/dmake			\
	contrib/make-j			\
	contrib/netpwd			\
	contrib/stage-cc-wrapper.patch	\
	contrib/redhat/init		\
	contrib/redhat/logrotate		\
	contrib/redhat/sysconfig		\
	contrib/redhat/xinetd

dist_include_server_SH = \
	pump.in

bench_PY = bench/Build.py \
	bench/Project.py \
	bench/ProjectDefs.py \
	bench/Summary.py \
	bench/actions.py \
	bench/benchmark.py \
	bench/buildutil.py \
	bench/compiler.py \
	bench/statistics.py

pkgdoc_DOCS = AUTHORS COPYING NEWS \
	README README.pump \
	INSTALL \
	TODO \
	doc/protocol-1.txt doc/status-1.txt \
	doc/protocol-2.txt \
	doc/reporting-bugs.txt \
	survey.txt

example_DOCS = \
	doc/example/init doc/example/init-suse	\
	doc/example/logrotate				\
	doc/example/xinetd				\

include_server_PY = \
	include_server/__init__.py \
	include_server/basics.py \
	include_server/cache_basics.py \
	include_server/compiler_defaults.py \
	include_server/compress_files.py \
	include_server/headermap.py \
	include_server/include_analyzer.py \
	include_server/include_analyzer_memoizing_node.py \
	include_server/include_server.py \
	include_server/macro_eval.py \
	include_server/mirror_path.py \
	include_server/parse_command.py \
	include_server/parse_file.py \
	include_server/run.py \
	include_server/setup.py \
	include_server/statistics.py

include_server_SRC = \
	include_server/c_extensions/distcc_pump_c_extensions_module.c

# These are included in the distribution but not installed anywhere.
dist_extra =							\
	README.packaging ChangeLog \
	packaging/RedHat/rpm.spec \
	packaging/RedHat/logrotate.d/distcc \
	packaging/RedHat/init.d/distcc \
	packaging/RedHat/xinetd.d/distcc \
	packaging/deb.sh \
	packaging/rpm.sh \
	packaging/googlecode_upload.py


mkinstalldirs = $(SHELL) $(srcdir)/mkinstalldirs
man1dir = $(mandir)/man1
man8dir = $(mandir)/man8

test_SOURCE = test/comfychair.py \
	test/onetest.py \
	test/testdistcc.py \
	find_c_extension.sh

dist_common = Makefile.in install-sh configure configure.ac \
	config.guess config.sub mkinstalldirs autogen.sh

# It seems a bit unnecessary to ship patches in the released tarballs.
# People who are so keen as to apply unsupported patches ought to use
# CVS, or at least get them from the list.
dist_patches = 

TAR = tar
GZIP_BIN = gzip
# This is set on the environment, and automatically read by gzip.
# This way we always get best compression, even when gzip is run in a
# script we call, rather than being called by us directly.
GZIP = -9v
BZIP2_BIN = bzip2

distdir = $(PACKAGE_TARNAME)-$(VERSION)
tarball = $(PACKAGE_TARNAME)-$(VERSION).tar
tarball_bz2 = $(tarball).bz2
tarball_gz = $(tarball).gz
tarball_sig_bz2 = $(tarball_bz2).asc
tarball_sig_gz = $(tarball_gz).asc
distnews = $(PACKAGE_TARNAME)-$(VERSION).NEWS

rpm_glob_pattern = "$(PACKAGE)"*[-_.]"$(VERSION)"[-_.]*.deb
deb_glob_pattern = "$(PACKAGE)"*[-_.]"$(VERSION)"[-_.]*.rpm

common_obj = src/arg.o src/argutil.o					\
	src/cleanup.o src/compress.o					\
	src/trace.o src/util.o src/io.o src/exec.o			\
	src/rpc.o src/tempfile.o src/bulk.o src/help.o src/filename.o	\
	src/lock.o							\
	src/netutil.o							\
	src/pump.o							\
	src/sendfile.o							\
	src/safeguard.o src/snprintf.o src/timeval.o			\
	src/dotd.o 							\
	src/hosts.o src/hostfile.o					\
	src/implicit.o src/loadfile.o					\
	lzo/minilzo.o                                                   \
	src/xci_utils.o					\
	

distcc_obj = src/backoff.o						\
	src/climasq.o src/clinet.o src/clirpc.o				\
	src/compile.o src/cpp.o						\
	src/distcc.o							\
	src/emaillog.o							\
	src/remote.o							\
	src/ssh.o src/state.o src/strip.o				\
	src/timefile.o src/traceenv.o					\
	src/include_server_if.o						\
	src/where.o							\
						\
							\
	$(common_obj)

distccd_obj = src/access.o						\
	src/daemon.o  src/dopt.o src/dparent.o src/dsignal.o		\
	src/ncpus.o							\
	src/prefork.o							\
	src/stringmap.o							\
	src/serve.o src/setuid.o src/srvnet.o src/srvrpc.o src/state.o	\
	src/stats.o							\
	src/fix_debug_info.o						\
	src/xci_headermap.o src/xci_versinfo.o src/xci_zeroconf.o				\
							\
	$(common_obj) $(popt_OBJS)

lsdistcc_obj = src/lsdistcc.o 						\
	src/clinet.o src/io.o src/netutil.o src/trace.o src/util.o 	\
	src/rslave.o src/snprintf.o                                     \
	lzo/minilzo.o

# Objects that need to be linked in to build monitors
mon_obj =								\
	src/cleanup.o							\
	src/filename.o							\
	src/io.o							\
	src/mon.o							\
	src/netutil.o							\
	src/argutil.o							\
	src/rpc.o							\
	src/snprintf.o src/state.o 					\
	src/tempfile.o src/trace.o src/traceenv.o			\
	src/util.o

gnome_obj = src/history.o src/mon-gnome.o				\
	src/renderer.o

h_exten_obj = src/h_exten.o $(common_obj)
h_issource_obj = src/h_issource.o $(common_obj)
h_repsubstr_obj = src/h_repsubstr.o $(common_obj)
h_scanargs_obj = src/h_scanargs.o $(common_obj)
h_hosts_obj = src/h_hosts.o $(common_obj)
h_argvtostr_obj = src/h_argvtostr.o $(common_obj)
h_strip_obj = src/h_strip.o $(common_obj) src/strip.o
h_parsemask_obj = src/h_parsemask.o $(common_obj) src/access.o
h_sa2str_obj = src/h_sa2str.o $(common_obj) src/srvnet.o src/access.o
h_ccvers_obj = src/h_ccvers.o $(common_obj)
h_dotd_obj = src/h_dotd.o $(common_obj)
h_fix_debug_info = src/h_fix_debug_info.o $(common_obj)
h_compile_obj = src/h_compile.o $(common_obj) src/compile.o src/timefile.o \
                src/backoff.o src/emaillog.o src/remote.o src/clinet.o \
	        src/clirpc.o src/include_server_if.o src/state.o src/where.o \
		src/ssh.o src/strip.o src/cpp.o

# All source files, for the purposes of building the distribution
SRC =	src/stats.c							\
	src/access.c src/arg.c src/argutil.c				\
	src/backoff.c src/bulk.c					\
	src/cleanup.c							\
	src/climasq.c src/clinet.c src/clirpc.c src/compile.c		\
	src/compress.c src/cpp.c					\
	src/daemon.c src/distcc.c src/dsignal.c				\
	src/dopt.c src/dparent.c src/exec.c src/filename.c		\
	src/h_argvtostr.c						\
	src/h_exten.c src/h_hosts.c src/h_issource.c src/h_parsemask.c	\
	src/h_sa2str.c src/h_scanargs.c src/h_strip.c			\
	src/h_dotd.c src/h_compile.c h_repsubstr.c                      \
	src/help.c src/history.c src/hosts.c src/hostfile.c		\
	src/implicit.c src/io.c						\
	src/loadfile.c src/lock.c 					\
	src/mon.c src/mon-notify.c src/mon-text.c			\
	src/mon-gnome.c							\
	src/ncpus.c src/netutil.c					\
	src/prefork.c src/pump.c					\
	src/remote.c src/renderer.c src/rpc.c				\
	src/safeguard.c src/sendfile.c src/setuid.c src/serve.c		\
	src/snprintf.c src/state.c					\
	src/srvnet.c src/srvrpc.c src/ssh.c 				\
	src/stringmap.c src/strip.c					\
	src/tempfile.c src/timefile.c                     		\
	src/timeval.c src/traceenv.c					\
	src/trace.c src/util.c src/where.c				\
	src/lsdistcc.c src/rslave.c					\
	src/dotd.c src/include_server_if.c				\
	src/emaillog.c							\
	src/fix_debug_info.c						\
	src/xci_headermap.c src/xci_utils.c src/xci_versinfo.c		\
	src/xci_zeroconf.c						\
	src/zeroconf.c src/zeroconf-reg.c src/gcc-id.c


HEADERS = src/stats.h							\
	src/access.h							\
	src/bulk.h src/byte_swapping.h					\
	src/clinet.h src/compile.h					\
	src/daemon.h							\
	src/distcc.h src/dopt.h src/exitcode.h				\
	src/fix_debug_info.h						\
	src/hosts.h src/implicit.h					\
	src/mon.h							\
	src/netutil.h							\
	src/renderer.h src/rpc.h					\
	src/snprintf.h src/state.h		 			\
	src/stringmap.h							\
	src/timefile.h src/timeval.h src/trace.h			\
	src/types.h							\
	src/util.h							\
	src/exec.h src/lock.h src/where.h src/srvnet.h			\
	src/rslave.h							\
	src/dotd.h src/include_server_if.h				\
	src/emaillog.h							\
	src/va_copy.h							\
	src/xci.h							\
	src/zeroconf.h

conf_dir = packaging/RedHat/conf
conf_files = $(conf_dir)/hosts \
	     $(conf_dir)/clients.allow \
	     $(conf_dir)/commands.allow.sh
default_dir = packaging/RedHat/default
default_files = $(default_dir)/distcc

man1_MEN = man/distcc.1 man/distccd.1 man/distccmon-text.1 \
           man/pump.1 man/include_server.1
man_HTML = man/distcc_1.html man/distccd_1.html man/distccmon_text_1.html \
	   man/pump_1.html man/include_server_1.html
MEN = $(man1_MEN)

gnome_data = gnome/distccmon-gnome-icon.png	\
	gnome/distccmon-gnome.desktop

popt_OBJS=popt/findme.o  popt/popt.o  popt/poptconfig.o \
	popt/popthelp.o popt/poptparse.o

popt_SRC=popt/findme.c  popt/popt.c  popt/poptconfig.c			 \
	popt/popthelp.c popt/poptparse.c

popt_HEADERS = popt/findme.h popt/popt.h popt/poptint.h popt/system.h

popt_EXTRA = popt/README.popt popt/.stamp-conf.in


# You might think that distccd ought to be in sbin, because it's a
# daemon.  It is a grey area.  However, the Linux Filesystem Hierarchy
# Standard (FHS 2.2) says that sbin is for programs "used exclusively
# by the system administrator".  

# distccd will often be used by non-root users, and when we support
# ssh it will be somewhat important that it be found in their default
# path.  Therefore on balance it seems better to put it in bin/.  

# Package maintainers can override this if absolutely necessary, but I
# would prefer that they do not. -- mbp

bin_PROGRAMS = \
	distcc \
	distccd \
	distccmon-text \
	lsdistcc \
	 

check_PROGRAMS = \
	h_argvtostr \
	h_exten \
	h_fix_debug_info \
	h_hosts \
	h_issource \
	h_repsubstr \
	h_parsemask \
	h_sa2str \
	h_scanargs \
	h_strip \
	h_dotd \
	h_compile

check_include_server_PY = \
	include_server/c_extensions_test.py \
	include_server/include_server_test.py \
	include_server/macro_eval_test.py \
	include_server/mirror_path_test.py \
	include_server/parse_command_test.py \
	include_server/parse_file_test.py \
	include_server/include_analyzer_test.py \
	include_server/include_analyzer_memoizing_node_test.py \
	include_server/basics_test.py


######################################################################
## IMPLICIT BUILD rules

.SUFFIXES: .html .latte .o .c

.c.o:
	$(CC) $(CPPFLAGS) $(WERROR_CFLAGS) $(CFLAGS) -o $@ -c $<


######################################################################
## OVERALL targets

.PHONY: all include-server

## NOTE: "all" must be the first (default) rule, aside from patterns.

all: $(bin_PROGRAMS) pump include-server

#  src/config.h.in is used by config.status
Makefile: Makefile.in src/config.h.in config.status
	./config.status


######################################################################
## BUILD targets

# We would like to detect when config.h.in has changed: this should trigger
# config.status to be rerun. But if the config.h file actually does not change
# as a result of running config.status (a feature of autoconf), then
# config.status will be rerun every time. That's confusing. So, the rule
#
# src/config.h: src/config.h.in
#        ./config.status
#
# is not sufficient.

src/config.h: src/config.h.stamp

src/config.h.stamp: src/config.h.in
	echo "path: $$PATH"
	./config.status
	touch src/config.h.stamp

pump: pump.in config.status
	./config.status

# Grab the dependency files generated by gcc's -MD option.
-include */*.d

# Disable some warnings for popt/*.c.
$(popt_OBJS): CFLAGS += $(POPT_CFLAGS)

distcc: $(distcc_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(distcc_obj) $(LIBS)

distccd: $(distccd_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(distccd_obj) $(LIBS)	

distccmon-text: $(mon_obj) src/mon-text.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(mon_obj) src/mon-text.o $(LIBS)

lsdistcc: $(lsdistcc_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(lsdistcc_obj) $(LIBS)

h_exten: $(h_exten_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_exten_obj) $(LIBS)

h_issource: $(h_issource_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_issource_obj) $(LIBS)

h_repsubstr: $(h_repsubstr_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_repsubstr_obj) $(LIBS)

h_sa2str: $(h_sa2str_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_sa2str_obj) $(LIBS)

h_scanargs: $(h_scanargs_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_scanargs_obj) $(LIBS)

h_hosts: $(h_hosts_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_hosts_obj) $(LIBS)

h_argvtostr: $(h_argvtostr_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_argvtostr_obj) $(LIBS)

h_parsemask: $(h_parsemask_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_parsemask_obj) $(LIBS)

h_strip: $(h_strip_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_strip_obj) $(LIBS)

h_ccvers: $(h_ccvers_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_ccvers_obj) $(LIBS)

h_dotd: $(h_dotd_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_dotd_obj) $(LIBS)

h_fix_debug_info: $(h_fix_debug_info)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_fix_debug_info) $(LIBS)

h_compile: $(h_compile_obj)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(h_compile_obj) $(LIBS)


src/h_fix_debug_info.o: src/fix_debug_info.c
	$(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) \
		-DTEST \
		$(srcdir)/src/fix_debug_info.c

src/mon-gnome.o: src/mon-gnome.c
	$(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) \
		$(GNOME_CFLAGS) \
		$(srcdir)/src/mon-gnome.c

src/renderer.o: src/renderer.c
	$(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS)			\
		$(GNOME_CFLAGS) \
		$(srcdir)/src/renderer.c

distccmon-gnome: $(mon_obj) $(gnome_obj)
	$(CC) -o $@ $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) \
		$(mon_obj) $(gnome_obj) \
		$(LIBS) $(GNOME_CFLAGS) $(GNOME_LIBS)

# The include-server is a python app, so we use Python's build system.  We pass
# the distcc version, the source location, the CPP flags (for location of the
# includes), and the build location.
include-server:
	if test -z "$(INCLUDESERVER_PYTHON)"; then	\
	  echo "Not building $@: No suitable python found"; \
	else						\
	  mkdir -p "$(include_server_builddir)" &&      \
	  cat "$(srcdir)/include_server/setup.py" |     \
      DISTCC_VERSION="$(VERSION)"                   \
	  SRCDIR="$(srcdir)"                            \
	  PYTHON_CFLAGS="$(PYTHON_CFLAGS)"              \
	  CFLAGS="$(PYTHON_SETUP_CFLAGS)"               \
	  CPPFLAGS="$(CPPFLAGS)"                        \
	  $(INCLUDESERVER_PYTHON) - \
	      build 					\
	        --build-base="$(include_server_builddir)"  \
	        --build-temp="$(include_server_builddir)";  \
	fi


######################################################################
## DIST TARGETS

.PHONY: dist distcheck dist-sign dist-files

# The sub-targets copy (and if necessary, build) various files that
# have to go into the tarball.  They also create necessary directories
# -- bear in mind that they might be run in parallel.

# This looks a bit gross to me, but it's not as bad as it might be :-/

# TODO(csilvers): add 'make rpm' and 'make deb'.

dist:
	-rm -fr "$(distdir)"
	$(MAKE) dist-files 
	$(TAR) cf "$(tarball)" "$(distdir)"
	$(GZIP_BIN) --help >/dev/null && \
		$(GZIP_BIN) -fc "$(tarball)" > "$(tarball_gz)"
	$(BZIP2_BIN) --help 2>/dev/null && \
		$(BZIP2_BIN) -vfc "$(tarball)" > "$(tarball_bz2)"
	rm -f "$(tarball)"
	rm -r "$(distdir)"
	cp "$(srcdir)/NEWS" "$(distnews)"

# We create two new directories: one for the build and one to install,
# and make sure we can build and install from different directories
# than the source directory.  Then we run a "make distclean" and
# verify it got rid of everything not in the tarball by deleting every
# file mentioned in the tarball, and then making sure nothing is left.
distcheck: dist
	[ ! -d +distcheck ] || chmod -R u+w +distcheck
	rm -rf '+distcheck'
	mkdir '+distcheck'
	cd '+distcheck' && $(GZIP_BIN) -d < "../$(tarball_gz)" | $(TAR) xvf -
	mkdir "+distcheck/$(distdir)/_build"
	mkdir "+distcheck/$(distdir)/_inst"
	chmod -R a-w +distcheck
	chmod u+w "+distcheck/$(distdir)/_build" "+distcheck/$(distdir)/_inst"
	dc_install_base=`cd "+distcheck/$(distdir)/_inst" && pwd` \
	&& cd "+distcheck/$(distdir)/_build" \
	&& ../configure --srcdir=.. --prefix="$$dc_install_base" \
	&& $(MAKE) && $(MAKE) maintainer-check \
	&& $(MAKE) install \
	&& $(MAKE) DISTCC_INSTALLATION="$$dc_install_base/bin" \
	        maintainer-installcheck \
	&& $(MAKE) distclean
	chmod -R u+w +distcheck
	test `find "+distcheck/$(distdir)/_build" -type f -print | wc -l` -eq 0 \
		|| { echo "ERROR: files left in build-dir after distclean:"; \
                     find "+distcheck/$(distdir)/_build" -type f -print; \
	             rm -rf '+distcheck'; \
	             exit 1; }
	rm -rf '+distcheck'

dist-sign:
	gpg -a --detach-sign "$(tarball_bz2)"

# For the dirs we copy, we don't want to copy control files like '.cvs'.
# We use find for this; if 'find' doesn't work, just don't worry about it.
dist-files: $(dist_files)
	for f in $(dist_files) $(dist_dirs); do \
	  mkdir -p "$(distdir)"/`dirname "$$f"` || exit 1; \
	  cp -pR "$(srcdir)/$$f" "$(distdir)/$$f" 2>/dev/null || \
	      cp -pR "$$f" "$(distdir)/$$f" || exit 1; \
	done
	for f in $(dist_dirs); do \
	  find "$(distdir)/$$f" -name '.[^.]*' -exec rm -rf \{\} \; -prune ; \
	done


######################################################################
## BUILD manual targets

man/distcc_1.html: man/distcc.1
	troff2html -man "$(srcdir)"/man/distcc.1 > $@

man/distccd_1.html: man/distccd.1
	troff2html -man "$(srcdir)"/man/distccd.1 > $@

man/distccmon_text_1.html: man/distccmon-text.1
	troff2html -man "$(srcdir)"/man/distccmon-text.1 > $@

man/pump_1.html: man/pump.1
	troff2html -man "$(srcdir)"/man/pump.1 > $@

man/include_server_1.html: man/include_server.1
	troff2html -man "$(srcdir)"/man/include_server.1 > $@

######################################################################
## CHECK targets for code that has been build.

.PHONY: check_programs
.PHONY: maintainer-check-no-set-path distcc-maintainer-check
.PHONY: include-server-maintainer-check pump-maintainer-check
.PHONY: lzo-maintainer-check maintainer-check 
.PHONY: check
.PHONY: lzo-check pump-check valgrind-check single-test pump-single-test

check_programs: $(check_PROGRAMS) $(bin_PROGRAMS)

TESTDISTCC_OPTS =

# This target is for internal use by distcc-maintainer-check and
# distcc-installcheck.  These rules differ only in their choice of the value of
# PATH to use.  PATH must be set appropriately so that python, distcc binaries,
# gcc, and those of the check_PROGRAMS, can be found on PATH.  This is done in
# the call of this target through use of the variable RESTRICTED_PATH.
#
# The more prominent of these conditions are checked explicitly checked below.
#
# TODO(klarlund): the outermost if assumes that the include-server target may be
# satisfied w/o actually building an include server (or rather the C extension);
# this logic needs to be verified or amended.
maintainer-check-no-set-path:
	@if ! $(TEST_PYTHON) -c 'import sys; print sys.version'; then \
	  echo "WARNING: python not found; tests skipped"; \
	else \
	  if ! gcc --version 2>/dev/null; then \
	    echo "Could not find gcc on the restricted path used to avoid"; \
	    echo "confusion caused by distcc masquerades on the normal path."; \
	    echo "PATH is currently '$$PATH'."; \
	    echo "Please change RESTRICTED_PATH to change this PATH value."; \
	    exit 1; \
	  fi; \
	  $(TEST_PYTHON) "$(srcdir)/test/testdistcc.py" $(TESTDISTCC_OPTS); \
	fi

distcc-maintainer-check: check_programs
	 $(MAKE) PATH="`pwd`:$(RESTRICTED_PATH)" \
	   TESTDISTCC_OPTS="$(TESTDISTCC_OPTS)" maintainer-check-no-set-path

# If the include server extension module was built, then run the tests include
# server.  TODO(klarlund): the outermost if assumes that the include-server
# target may be satisfied w/o actually building an include server (or rather the
# C extension); this logic needs to be verified or amended.
# TODO(csilvers): keep track of failures instead of exiting on the first one.
include-server-maintainer-check: include-server
	@if ! test -d "$(include_server_builddir)"; then \
	  echo "Skipped include-server check"; \
	else \
	  CURDIR=`pwd`; \
	  include_server_loc=`"$(srcdir)/find_c_extension.sh" "$(builddir)"`; \
	  test $$? = 0 || (echo 'Could not locate extension.' 1>&2 && exit 1); \
	  cd "$(srcdir)/include_server"; \
	  for p in $(check_include_server_PY); do \
	    p_base=`basename "$$p"`; \
	    echo -n "Running: "; \
	    echo \
              "PYTHONPATH=$$CURDIR/$$include_server_loc:$$PYTHONPATH $(INCLUDESERVER_PYTHON) $$p_base"; \
	    if PYTHONPATH="$$CURDIR/$$include_server_loc:$$PYTHONPATH" $(INCLUDESERVER_PYTHON) "$$p_base" \
		 > "$$CURDIR/$(tempdir)/$$p_base.out" 2>&1; then \
	      echo "PASS"; \
	      rm "$$CURDIR/$(tempdir)/$$p_base.out"; \
            else \
              echo "FAIL"; cat "$$CURDIR/$(tempdir)/$$p_base.out"; exit 1; \
	    fi; \
	  done; \
	fi

# Do distcc-maintainer-check in pump-mode, if possible.
pump-maintainer-check: pump include-server check_programs
	@if [ -d "$(include_server_builddir)" ]; then \
	  DISTCC_HOSTS='<invalid>,cpp,lzo' \
	    "$(builddir)/pump" \
	        $(MAKE) \
	        RESTRICTED_PATH="$(RESTRICTED_PATH)" \
	        TESTDISTCC_OPTS="--pump $(TESTDISTCC_OPTS)" \
	        distcc-maintainer-check; \
	fi

# Do distcc-maintainer-check in lzo-mode (without pump), if possible.
lzo-maintainer-check: check_programs
	@DISTCC_HOSTS='<invalid>,cpp' \
	  $(MAKE) \
	      RESTRICTED_PATH="$(RESTRICTED_PATH)" \
	      TESTDISTCC_OPTS="--lzo $(TESTDISTCC_OPTS)" \
	      distcc-maintainer-check; \


# Do distcc-maintainer-check, for non-pumped distcc, and try the include_server
# check to check the include server's behavior, if applicable.  If the include
# server exists, then carry out distcc-maintainer-check in pump-mode.
maintainer-check: distcc-maintainer-check include-server-maintainer-check \
	pump-maintainer-check lzo-maintainer-check

check:
	@if test -n "$(INCLUDESERVER_PYTHON)"; then \
	   $(MAKE) maintainer-check; \
	elif test -n "$(TEST_PYTHON)"; then \
	   echo "WARNING: pump-mode not being tested"; \
	   $(MAKE) distcc-maintainer-check; \
	else \
	   echo "Cannot run tests: python binary not found"; \
	   false; \
	fi

# Runs the tests in lzo-mode.
lzo-check: lzo-maintainer-check

# Runs the tests in pump-mode (,cpp,lzo).
pump-check: pump-maintainer-check

# Runs the tests with valgrind.
valgrind-check:
	$(MAKE) TESTDISTCC_OPTS=--valgrind maintainer-check

# The following target is useful for running a single test at a time.
# Sample usage:
#    make TESTNAME=Lsdistcc_Case single-test
#    make TESTNAME=Lsdistcc_Case TESTDISTCC_OPTS=--valgrind single-test
TESTNAME = NoDetachDaemon_Case  # Override this with the desired test.
single-test: check_programs
	PATH="`pwd`:$(RESTRICTED_PATH)" \
	    $(TEST_PYTHON) "$(srcdir)/test/onetest.py" $(TESTDISTCC_OPTS) $(TESTNAME)

# Run a single test in pump-mode.
pump-single-test: pump include-server check_programs
	DISTCC_HOSTS='<invalid>,cpp,lzo' \
	    "$(builddir)/pump" \
	        $(MAKE) \
	        RESTRICTED_PATH="$(RESTRICTED_PATH)" \
	        TESTDISTCC_OPTS="--pump $(TESTDISTCC_OPTS)" \
	        single-test

######################################################################
## CHECK targets for code that has been installed.

.PHONY: pump-installcheck distcc-installcheck maintainer-installcheck
.PHONY: installcheck verify-binaries-installcheck daemon-installcheck

# Verify that DISTCC_INSTALLATION contains the expected set of binaries.
verify-binaries-installcheck:
	@echo -n "Locating binaries in DISTCC_INSTALLATION="
	@echo "'$(DISTCC_INSTALLATION)'"
	@echo -n "To use installation in ${exec_prefix}/bin, remake with"
	@echo " argument 'DISTCC_INSTALLATION=${exec_prefix}/bin'."
	@echo "Make sure all paths below are where you expect them to be:"
	@echo "**********************************************************"
	@for p in $(bin_PROGRAMS); do \
	  if ! PATH="$(DISTCC_INSTALLATION)" `which which` "$$p"; then \
	    echo "Binary '$$p' could not be found in DISTCC_INSTALLATION."; \
	    exit 1; \
	  fi; \
	done 
	@echo "**********************************************************"

# Lookup distcc programs to be checked in $(DISTCC_INSTALLATION).  The
# check_PROGRAMS binaries, however, are to be found in $(builddir).
distcc-installcheck: $(check_PROGRAMS)
	BUILDDIR=`cd "$(builddir)" && pwd`; \
	PATH="$(DISTCC_INSTALLATION):$$BUILDDIR:$(RESTRICTED_PATH)" \
	  TESTDISTCC_OPTS="$(TESTDISTCC_OPTS)" \
	  $(MAKE) maintainer-check-no-set-path

# Check the installation to see whether pump-mode works.
pump-installcheck:
	which_loc=`which which`; \
	pump_loc=`PATH="$(DISTCC_INSTALLATION)" "$$which_loc" pump`; \
	DISTCC_HOSTS='<invalid>,cpp,lzo' \
	  "$$pump_loc" \
            $(MAKE) DISTCC_INSTALLATION="$(DISTCC_INSTALLATION)" \
	      RESTRICTED_PATH="$(RESTRICTED_PATH)" \
              TESTDISTCC_OPTS=--pump distcc-installcheck; \

# "make maintainer-installcheck" verifies the currently installed version in
# RESTRICTED_PATH.  It does not have the "install" target as a dependency so
# that you can can check an installation that is installed via some different
# method (e.g. rpm or debian package).  You must specify the location of such an
# installation by overriding the value of DISTCC_INSTALLATION.
#
# The maintainer-installcheck does not run the include server unit tests;
# but the integration tests in 'test' are run in pump mode.
maintainer-installcheck: verify-binaries-installcheck distcc-installcheck \
	pump-installcheck

installcheck:
	@if test -n "$(INCLUDESERVER_PYTHON)"; then \
	   $(MAKE) maintainer-installcheck; \
	elif test -n "$(TEST_PYTHON)"; then \
	   echo "WARNING: pump-mode not being tested"; \
	   $(MAKE) distcc-maintainer-installcheck; \
	else \
	   echo "Cannot run install-tests: python binary not found"; \
	   false; \
	fi

# This tests that the distcc daemon is running, and that it and distcc
# and the pump script have been installed correctly, by compiling a simple
# hello world program with distcc and distcc-pump.
# This can be used after "make install-deb".
#
# This uses distcc from your PATH and (for the first test)
# may use DISTCC_HOSTS from your environment or /etc/distcc/hosts.
#
# This test might fail if the --allow options passed to distccd
# (which may be set in the /etc/distcc/clients.allow file)
# do not include 127.0.0.1.
daemon-installcheck:
	mkdir -p _testtmp/daemon-installcheck && \
	    cd _testtmp/daemon-installcheck && \
	    echo '#include <stdio.h>' > hello.c && \
	    echo 'int main(void) { puts("hello world"); return 0; }' >> hello.c && \
	    rm -f hello.o && \
	    DISTCC_FALLBACK=0 distcc $(CC) $(CFLAGS) -c hello.c -o hello.o && \
	    test -f hello.o && \
	    rm -f hello.o && \
	    DISTCC_POTENTIAL_HOSTS=127.0.0.1 DISTCC_FALLBACK=0 \
	        pump distcc $(CC) $(CFLAGS) -c hello.c -o hello.o && \
	    test -f hello.o

######################################################################
## BENCHMARK targets

.PHONY: benchmark

benchmark: 
	@echo "The distcc macro-benchmark uses your existing distcc installation"
	@if [ -n "$$DISTCC_HOSTS" ]; \
	then echo "DISTCC_HOSTS=\"$$DISTCC_HOSTS\""; \
	else echo "You must set up servers and set DISTCC_HOSTS before running the benchmark"; \
	exit 1; \
	fi
	@echo "This benchmark may download a lot of source files, and it takes a "
	@echo "long time to run.  Interrupt now if you want."
	@echo 
	@echo "Pass BENCH_ARGS to make to specify which benchmarks to run."
	@echo
	@sleep 5
	cd bench && $(TEST_PYTHON) benchmark.py $(BENCH_ARGS)


######################################################################
## CLEAN targets

.PHONY: clean clean-autoconf clean-lzo clean-include-server
.PHONY: maintainer-clean maintainer-clean-autoconf distclean distclean-autoconf

# Also clean binaries which are optionally built. Also remove .d files; old ones
# may confuse 'make'.
clean: clean-autoconf clean-lzo clean-include-server
	rm -f src/*.[od] popt/*.[od]
	rm -f test/*.pyc
	rm -f $(check_PROGRAMS) $(bin_PROGRAMS)
	rm -f $(man_HTML)
	rm -f distccmon-gnome
	rm -rf _testtmp  # produced by test/testdistcc.py and daemon-installcheck
	rm -rf +distcheck
	rm -rf "$(include_server_builddir)"

clean-autoconf:
	rm -f config.cache config.log

clean-lzo:
	rm -f lzo/*.[od] lzo/testmini


clean-include-server:
	if test -n "$(INCLUDESERVER_PYTHON)"; then	\
	  cat "$(srcdir)/include_server/setup.py" |  \
      DISTCC_VERSION="$(VERSION)"			     \
	  SRCDIR="$(srcdir)"                            \
	  PYTHON_CFLAGS="$(PYTHON_CFLAGS)"              \
	  CFLAGS="$(PYTHON_SETUP_CFLAGS)"               \
	  CPPFLAGS="$(CPPFLAGS)"                        \
	  $(INCLUDESERVER_PYTHON) - \
	      clean	\
	         --build-base="$(include_server_builddir)"  \
	         --build-temp="$(include_server_builddir)";  \
	fi

maintainer-clean: distclean \
	maintainer-clean-autoconf clean

# configure and co are distributed, but not in CVS
maintainer-clean-autoconf:
	rm -f configure src/config.h.in

distclean-autoconf:
	rm -f Makefile src/config.h src/config.h.stamp pump
	rm -f popt/.stamp-conf lzo/.stamp-conf
	rm -f config.status config.cache config.log aclocal.m4
	rm -rf autom4te.cache

distclean: distclean-autoconf clean


######################################################################
## MAINTAINER targets

.PHONY: upload-man upload-dist rpm deb install-deb

upload-man: $(man_HTML)
	mkdir -p doc/web/man
	cp -f $(man_HTML) doc/web/man
	svn commit doc/web/man

# When uploading the package, we try to update the website as well.
# However, that's just best-effort, and if we can't (because, say, we
# don't have troff2html installed), we just upload the tarballs.
upload-dist: alldist
	-$(MAKE) upload-man
	"$(srcdir)/packaging/googlecode_upload.py" \
	    "$(tarball_gz)" \
	    "$(tarball_bz2)" \
	    packaging/$(rpm_glob_pattern) \
	    packaging/$(deb_glob_pattern)

rpm: dist packaging/rpm.sh packaging/RedHat/rpm.spec
	cd packaging && ./rpm.sh $(PACKAGE) $(VERSION)

# This uses the output of 'make rpm' to convert rpm files to deb files
deb: rpm packaging/deb.sh
	cd packaging && ./deb.sh $(PACKAGE) $(VERSION) *.rpm

# We copy .deb files to /tmp to avoid problems with NFS root_squash.
install-deb: deb
	tmpdir=`mktemp -d /tmp/distcc-install-deb-XXXXXX` && \
	cp packaging/*.deb $$tmpdir && \
	cd "$$tmpdir" && \
	sudo dpkg -i $(deb_glob_pattern) && \
	rm -rf $$tmpdir

# deb creates rpm files first, which in turn creates .gz files
alldist: deb
	@echo dist files created:
	@ls -1 "$(tarball_gz)" "$(tarball_bz2)"
	@ls -1 packaging/$(rpm_glob_pattern)
	@ls -1 packaging/$(deb_glob_pattern)

### INSTALL (and UNINSTALL) targets

.PHONY: showpaths install install-programs install-include-server
.PHONY: install-man install-doc install-example install-gnome-data 
.PHONY: install-conf

# TODO: Allow root directory to be overridden for use in building
# packages.

showpaths:
	@echo "'make install' will install distcc as follows:"
	@echo "  man pages            $(DESTDIR)$(man1dir)"
	@echo "  documents            $(DESTDIR)$(docdir)"
	@echo "  programs             $(DESTDIR)$(bindir)"
	@echo "  system configuration $(DESTDIR)$(sysconfdir)"
	@echo "  shared data files    $(DESTDIR)$(pkgdatadir)"


# install-sh can't handle multiple arguments, but we don't need any
# tricky features so mkinstalldirs and cp will do

install: showpaths install-doc install-man install-programs \
	install-include-server install-example  install-conf

install-programs: $(bin_PROGRAMS)
	$(mkinstalldirs) "$(DESTDIR)$(bindir)"
	for p in $(bin_PROGRAMS); do \
	  $(INSTALL_PROGRAM) "$$p" "$(DESTDIR)$(bindir)" || exit 1; \
	done

# See comments for the include-server target.  Also, we work around an issue in
# the change_root function of distutils/utils.py that turns the absolute prefix
# into a relative reference if the root is the empty string: we absolutize the
# destination directory in order to substitute '/' for the empty prefix (the
# default) when defining the '--root' parameter.
# The final complex issue involves installing pump.  pump wants to
# know the installed-location of include_server.py.  The only way to
# tell is to have setup.py install it, and then look what it says (via
# the --record output).  So when installing pump, we look at the
# --record output and modify the installed pump to have that location.
# Note: --record output is inconsistent (buggy?) and sometimes leaves out
# the leading slash in $prefix, even though we require prefix start with
# a slash.  We use sed to add it back in at cp time.
# Also, on Cygwin the --record output is in DOS text file format (CR LF
# line endings), so we need to convert it from DOS text file format to
# Unix text file format (LF line endings); we use sed for that too.
install-include-server: include-server pump
	if test -z "$(INCLUDESERVER_PYTHON)"; then	\
	  echo "Not building $@: No suitable python found"; \
	else						\
	  mkdir -p "$(include_server_builddir)" &&      \
	  DESTDIR=`cd "$(DESTDIR)/" && pwd` &&          \
	  cat "$(srcdir)/include_server/setup.py" |     \
      DISTCC_VERSION="$(VERSION)"			        \
	  SRCDIR="$(srcdir)"                            \
	  PYTHON_CFLAGS="$(PYTHON_CFLAGS)"              \
	  CFLAGS="$(PYTHON_SETUP_CFLAGS)"               \
	  CPPFLAGS="$(CPPFLAGS)"                        \
	  $(INCLUDESERVER_PYTHON) - \
	      build 					\
	        --build-base="$(include_server_builddir)" \
	        --build-temp="$(include_server_builddir)" \
	      install 					\
	         --prefix="$(prefix)" 			\
	         --record="$(include_server_builddir)/install.log.pre" \
	         --root="$$DESTDIR"                     \
	    || exit 1; \
	  sed -e '/^[^\/]/ s,^,/,' \
	      -e 's/\r$$//' \
	      "$(include_server_builddir)/install.log.pre" \
	      > "$(include_server_builddir)/install.log"; \
	  if test -n "$(PYTHON_INSTALL_RECORD)"; then \
	    cp -f "$(include_server_builddir)/install.log" "$(PYTHON_INSTALL_RECORD)"; \
	  fi; \
	  $(mkinstalldirs) "$(DESTDIR)$(bindir)" && \
	  INCLUDE_SERVER=`grep '/include_server.py$$' "$(include_server_builddir)/install.log"` && \
	  sed "s,^include_server='',include_server='$$INCLUDE_SERVER'," \
	    pump > "$(include_server_builddir)/pump" && \
	  $(INSTALL_PROGRAM) "$(include_server_builddir)/pump" "$(DESTDIR)$(bindir)"; \
	fi

install-man: $(man1_MEN)
	$(mkinstalldirs) "$(DESTDIR)$(man1dir)"
	for p in $(man1_MEN); do				\
	$(INSTALL_DATA)	"$(srcdir)/$$p" "$(DESTDIR)$(man1dir)" || exit 1; \
	done

install-doc: $(pkgdoc_DOCS)
	$(mkinstalldirs) "$(DESTDIR)$(docdir)"
	for p in $(pkgdoc_DOCS); do				\
	$(INSTALL_DATA) "$(srcdir)/$$p" "$(DESTDIR)$(docdir)" || exit 1; \
	done

install-example: $(example_DOCS)
	$(mkinstalldirs) "$(DESTDIR)$(docdir)/example"
	for p in $(example_DOCS); do				\
	$(INSTALL_DATA) "$(srcdir)/$$p" "$(DESTDIR)$(docdir)/example" || exit 1; \
	done

install-gnome-data: $(gnome_data)
	$(mkinstalldirs) "$(DESTDIR)$(pkgdatadir)"
	for p in $(gnome_data); do				\
	$(INSTALL_DATA) "$$p" "$(DESTDIR)$(pkgdatadir)" || exit 1; \
	done

install-conf: $(conf_files) $(default_files)
	$(mkinstalldirs) "$(DESTDIR)$(sysconfdir)/distcc"
	$(mkinstalldirs) "$(DESTDIR)$(sysconfdir)/default"
	@for p in $(conf_files); do                              \
	  base=`basename $$p`;                                   \
	  target="$(DESTDIR)$(sysconfdir)/distcc/$$base";        \
	  if test -e "$$target"; then                            \
	    echo "******************************************";   \
	    echo "*** Configuration file '$$target'";            \
	    echo "*** already exists; not installing '$$p'.";    \
	  else                                                   \
	    echo "$(INSTALL_DATA) $(srcdir)/$$p $$target";       \
	    $(INSTALL_DATA) "$(srcdir)/$$p" "$$target"           \
	        || exit 1;                                       \
	  fi;                                                    \
	done
	@for p in $(default_files); do                           \
	  base=`basename $$p`;                                   \
	  target="$(DESTDIR)$(sysconfdir)/default/$$base";       \
	  if test -e "$$target"; then                            \
	    echo "******************************************";   \
	    echo "*** Configuration file '$$target'";            \
	    echo "*** already exists; not installing '$$p'.";    \
	  else                                                   \
	    echo "$(INSTALL_DATA) $(srcdir)/$$p $$target";       \
	    $(INSTALL_DATA) "$(srcdir)/$$p" "$$target"           \
	        || exit 1;                                       \
	  fi;                                                    \
	done

# For best results, uninstall-example has to run before uninstall-doc,
# so we clean up the doc subdirectory before cleaning up doc itself.

uninstall: uninstall-man uninstall-programs  \
	uninstall-include-server uninstall-example uninstall-doc uninstall-conf

uninstall-programs:
	for p in $(bin_PROGRAMS) pump; do			\
	  file="$(DESTDIR)$(bindir)/`basename $$p`";            \
	  if [ -e "$$file" ]; then rm -fv "$$file"; fi          \
	done
	-[ "`basename $(bindir)`" = "$(PACKAGE)" ] && rmdir "$(DESTDIR)$(bindir)"

# There's no setup.py --uninstall. :-( So I depend on
# PYTHON_INSTALL_RECORD being set.  If it was used at --install time,
# I can use it again to uninstall.
uninstall-include-server:
	if [ -e "$(PYTHON_INSTALL_RECORD)" ]; then              \
	  cat "$(PYTHON_INSTALL_RECORD)" | xargs rm -fv;        \
	  cat "$(PYTHON_INSTALL_RECORD)" | sed 's/py$/pyc/' | xargs rm -fv; \
	  cat "$(PYTHON_INSTALL_RECORD)" | sed 's/py$/pyo/' | xargs rm -fv; \
	else                                                    \
	  echo "Cannot uninstall include-server: no PYTHON_INSTALL_RECORD"; \
	fi

uninstall-man:
	for p in $(man1_MEN); do				\
	  file="$(DESTDIR)$(man1dir)/`basename $$p`";           \
	  if [ -e "$$file" ]; then rm -fv "$$file"; fi          \
	done
	-[ "`basename $(man1dir)`" = "$(PACKAGE)" ] && rmdir "$(DESTDIR)$(man1dir)"

uninstall-doc:
	for p in $(pkgdoc_DOCS); do				\
	  file="$(DESTDIR)$(docdir)/`basename $$p`";            \
	  if [ -e "$$file" ]; then rm -fv "$$file"; fi          \
	done
	-[ "`basename $(docdir)`" = "$(PACKAGE)" ] && rmdir "$(DESTDIR)$(docdir)"

uninstall-example:
	for p in $(example_DOCS); do				\
	  file="$(DESTDIR)$(docdir)/example/`basename $$p`";    \
	  if [ -e "$$file" ]; then rm -fv "$$file"; fi          \
	done
	-rmdir "$(DESTDIR)$(docdir)/example"

uninstall-gnome-data:
	for p in $(gnome_data); do				\
	  file="$(DESTDIR)$(pkgdir)/`basename $$p`";            \
	  if [ -e "$$file" ]; then rm -fv "$$file"; fi          \
	done
	-[ `basename $(pkgdir)` = $(PACKAGE) ] && rmdir "$(DESTDIR)$(pkgdir)"

uninstall-conf:
	for p in $(conf_files); do                              \
	  file="$(DESTDIR)$(sysconfdir)/distcc/`basename $$p`"; \
	  if [ -e "$$file" ]; then rm -fv "$$file"; fi          \
	done
	-rmdir "$(DESTDIR)$(sysconfdir)/distcc"
	for p in $(default_files); do                           \
	  file="$(DESTDIR)$(sysconfdir)/default/`basename $$p`";\
	  if [ -e "$$file" ]; then rm -fv "$$file"; fi          \
	done

tags: $(SRC) $(HEADERS)
	ctags --defines --globals --typedefs-and-c++ --no-warn $(SRC) $(HEADERS)

#! /bin/sh

# Run this script to build distcc from CVS.

## first try the default names
AUTOHEADER="autoheader"
AUTOCONF="autoconf"

if which $AUTOCONF > /dev/null
then
    :
else
    echo "$0: need autoconf 2.53 or later to build distcc from CVS" >&2
    exit 1
fi

echo "$0: running $AUTOHEADER"
$AUTOHEADER || exit 1

echo "$0: running $AUTOCONF"
$AUTOCONF || exit 1

echo "Now run ./configure and then make."
exit 0

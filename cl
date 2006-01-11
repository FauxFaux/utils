#!/bin/bash

#=======================================================================
# $Id$
# Latskap. Lister ut loggen for Subversion, SVK eller CVS.
#
# Valg (Må spesifiseres alfabetisk):
#
# -k
#   Bruk svk istedenfor svn.
# -s
#   Bruk --stop-on-copy.
#=======================================================================

if [ "$1" = "-k" ]; then
    use_svk=1
    shift
else
    use_svk=0
fi

if [ "$1" = "-s" ]; then
    use_stop=1
    stoponcopy=' --stop-on-copy'
    svk_cross=''
    shift
else
    use_stop=0
    stoponcopy=''
    svk_cross=' --cross'
fi

if [ -d .svn/. ]; then
    if [ "$use_svk" = "1" ]; then
        svk log$svk_cross -v "$@" | less
    else
        svn log$stoponcopy -v "$@" | less
    fi
elif [ -d CVS/. ]; then
    cvs log$stoponcopy "$@" | sortcvs | less
else
    if [ "$use_svk" = "1" ]; then
        svk log$svk_cross -v "$@" | less
    else
        svn log$stoponcopy -v "$@" | less
    fi
fi

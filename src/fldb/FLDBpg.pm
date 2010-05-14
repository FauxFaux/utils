package FLDBpg;

#=======================================================================
# $Id$
# File ID: defb97ea-fa5a-11dd-b1bc-000475e441b9
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License, see end of file for legal stuff.
#=======================================================================

use strict;
use warnings;

use lib "$ENV{'HOME'}/bin/src/fldb";
use FLDBdebug;

BEGIN {
    use Exporter ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    my $rcs_id = '$Id$';
    push(@main::version_array, $rcs_id);
    $VERSION = ($rcs_id =~ / (\d+) /, $1);

    @ISA = qw(Exporter);
    @EXPORT = qw(&safe_sql &safe_tab);
    %EXPORT_TAGS = ();
}
our @EXPORT_OK;

sub safe_sql {
    # {{{
    my $Text = shift;
    $Text =~ s/\\/\\\\/g;
    $Text =~ s/'/''/g;
    $Text =~ s/\n/\\n/g;
    $Text =~ s/\r/\\r/g;
    $Text =~ s/\t/\\t/g;
    return($Text);
    # }}}
} # safe_sql()

sub safe_tab {
    # {{{
    my $Str = shift;
    $Str =~ s/\\/\\\\/gs;
    $Str =~ s/\n/\\n/gs;
    $Str =~ s/\r/\\r/gs;
    $Str =~ s/\t/\\t/gs;
    return($Str);
    # }}}
} # safe_tab()

1;

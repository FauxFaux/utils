#!/usr/bin/perl

#=======================================================================
# installed_progs.t
# File ID: a5a038ee-5803-11e0-aa2f-00023faf1383
# Check for missing programs
#
# Character set: UTF-8
# ©opyleft 2011– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 3 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    # push(@INC, "$ENV{'HOME'}/bin/STDlibdirDTS");
    use Test::More qw{no_plan};
    # use_ok() goes here
}

use Getopt::Long;

local $| = 1;

our $Debug = 0;
our $CMD = 'STDexecDTS';

our %Opt = (

    'all' => 0,
    'debug' => 0,
    'help' => 0,
    'todo' => 0,
    'verbose' => 0,
    'version' => 0,

);

our $progname = $0;
$progname =~ s/^.*\/(.*?)$/$1/;
our $VERSION = '0.00';

Getopt::Long::Configure('bundling');
GetOptions(

    'all|a' => \$Opt{'all'},
    'debug' => \$Opt{'debug'},
    'help|h' => \$Opt{'help'},
    'todo|t' => \$Opt{'todo'},
    'verbose|v+' => \$Opt{'verbose'},
    'version' => \$Opt{'version'},

) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
if ($Opt{'version'}) {
    print_version();
    exit(0);
}

diag(sprintf('========== Executing %s v%s ==========',
    $progname,
    $VERSION));

if ($Opt{'todo'} && !$Opt{'all'}) {
    goto todo_section;
}

=pod

installed('prog --version', # {{{
    '//',
    'description',
);

# }}}

=cut

diag("Testing return values...");
likecmd("perl -e 'exit(0)'", '/^$/', '/^$/', 0, "likecmd(): return 0");
likecmd("perl -e 'exit(1)'", '/^$/', '/^$/', 1, "likecmd(): return 1");
likecmd("perl -e 'exit(255)'", '/^$/', '/^$/', 255, "likecmd(): return 255");
testcmd("perl -e 'exit(0)'", '', '', 0, "testcmd(): return 0");
testcmd("perl -e 'exit(1)'", '', '', 1, "testcmd(): return 1");
testcmd("perl -e 'exit(255)'", '', '', 255, "testcmd(): return 255");

# }}}

todo_section:
;

if ($Opt{'all'} || $Opt{'todo'}) {
    diag('Running TODO tests...'); # {{{

    TODO: {

local $TODO = '';
# Insert TODO tests here.

    }
    # TODO tests }}}
}

installed('vim --version', '/VIM - Vi IMproved 7\../', 'vim', 'Check for the best editor ever');
installed('git --version', '/git version/', 'git-core');
installed('uuid -d ac89d100-5809-11e0-b3ff-00023faf1383', '/2011-03-27 00:32:19\.377792\.0 UTC/', 'uuid');
installed('perl --version', '/This is perl, v5/', 'perl');
installed('pv --version', '/Andrew Wood/', 'pv');
installed('mc --version', '/GNU Midnight Commander/');
installed('svn --version', '/svn, version /');
installed('psql --version', '/psql \(PostgreSQL\)/', 'postgresql');
installed('gnuplot --version', '/gnuplot \d+\.\d+ patchlevel/');
# installed('gitk --version', '//');
installed('gpsbabel --version', '/GPSBabel Version \d/');
installed('inkscape --version', '/Inkscape \d+\.\d/');
installed('gdb --version', '/Free Software Foundation, Inc\./');
installed('ddd --version', '/GNU DDD \d/', 'ddd');
# installed('dpkg -l', '/(libcurl4-openssl-dev/');
# installed('', '//');

=pod

my @packages = (

    'libcurl4-openssl-dev',

# Packages {{{
git-core
mc vim subversion
mc vim subversion ctags subversion-tools arj gv vim-doc vim-scripts
uuid
flashplugin-nonfree
flashplugin-nonfree
vim
vim-gnome
gitk
libexpat1
gpsbabel
asciidoc make gcc gettext docbook2x libssl-dev tk
postgresql
postgresql-8.4-postgis
gnuplot inkscape gimp gebabbel
libcurl4-openssl-dev
libexpat1-dev
libdvdread4
libdvdread4 libdvdcss2
mplayer
vorbis-tools
ddd
ddd gdb
perl-doc
openssh-server
htop
apache2
apache2-doc
uptimed
libossp-uuid-perl
gimp inkscape
lame
xz
xz-utils
arj
x264
vlc
gnumeric gnucash
gqview
libjpeg-progs
mercurial mercurial-git bzr
mercurial mercurial-git bzr bzr-doc mercuriaL-DOC
mercurial mercurial-git bzr bzr-doc mercuriaL-doc
mercurial mercurial-git bzr bzr-doc mercurial-doc
mercurial mercurial-git bzr bzr-doc
graphwiz ddd tree
graphviz ddd tree
graphviz-doc ddd tree
pandoc
lame
audacity
ktorrent
ffmpeg
pandoc
lame
audacity
ktorrent
ktorrent
ffmpeg
lynx-cur
faac
ffmpeg
ardour
frozenbubble
frozen-bubble
dict
apcalc
wipe
nmap
sqlite3 sqlite3-doc
qemu
homebank
grisbi
rand
rand
cpipe pv
dialog
dosbox
elinks
curl
stgit
python2.6-dev python-fuse
geneweb
geneweb gwsetup gwtp menu
gramps
sshfs
autoconf automake intltool
autoconf automake intltool
audacity
ktorrent
ardour
autoconf automake glib-gettext intltool
autoconf automake intltool
cpipe pv
curl
dialog
dict
elinks
fdupes
ffmpeg
frozen-bubble
frozenbubble
g++
geneweb
gramps
grisbi
homebank
libbz2-dev
libdbd-sqlite3-perl
liblzo2-dev
libtest-perl-critic-perl
libtool
python2.6-dev python-fuse
qemu
rand
sqlite3 sqlite3-doc
stopwatch
tidy
ledger
stgit
dosbox
faac
geneweb gwsetup gwtp menu
ktorrent
lynx-cur
sshfs
cpipe pv

# }}}

);

# Output from surkle:~/.bash_history {{{
$ git lp --reverse .bash_history | grep 'apt-get.*install' | grep '^+'
+apt-get install git-core
+apt-get install mc vim subversion
+apt-get install mc vim subversion ctags subversion-tools arj gv vim-doc vim-scripts
+apt-get install uuid
+apt-get install flashplugin-nonfree
+apt-get install flashplugin-nonfree
+apt-get install vim
+apt-get install vim-gnome
+apt-get install gitk
+apt-get install libexpat1
+apt-get install gpsbabel
+apt-get install asciidoc make gcc gettext docbook2x libssl-dev tk
+apt-get install postgresql
+apt-get install postgresql-8.4-postgis
+apt-get install gnuplot inkscape gimp gebabbel
+apt-get install libcurl4-openssl-dev
+apt-get install libexpat1-dev
+apt-get install libdvdread4
+apt-get install libdvdread4 libdvdcss2
+apt-get install libdvdread4'
+apt-get install mplayer
+apt-get install vorbis-tools
+apt-get install ddd
+apt-get install ddd gdb
+apt-get install perl-doc
+sudo apt-get install openssh-server
+apt-get install htop
+sess apt-get install apache
+sess apt-get install apache2
+sess apt-get install apache2 apache2-doc
+apt-get install uprecords
+apt-get install uptimed
+apt-get install libossp-uuid-perl
+apt-get install gimp inkscape
+apt-get install lame
+apt-get install xz
+apt-get install xz-utils
+apt-get install arj
+apt-get install x264
+apt-get install vlc
+apt-get install gnumeric gnucash
+apt-get install gqview
+apt-get install libjpeg-progs
+apt-get install mercurial mercurial-git bzr
+apt-get install mercurial mercurial-git bzr bzr-doc mercuriaL-DOC
+apt-get install mercurial mercurial-git bzr bzr-doc mercuriaL-doc
+apt-get install mercurial mercurial-git bzr bzr-doc mercurial-doc
+apt-get install mercurial mercurial-git bzr bzr-doc
+apt-get install graphwiz ddd tree
+apt-get install graphviz ddd tree
+apt-get install graphviz-doc ddd tree
+apt-get install pandoc
+apt-get install lame
+apt-get install audacity
+sess apt-get install ktorrent
+sess apt-get install ktorrent
+apt-get install ffmpeg
+apt-get install pandoc
+apt-get install lame
+apt-get install audacity
+sess apt-get install ktorrent
+sess apt-get install ktorrent
+apt-get install ffmpeg
+sess apt-get install lynx-cur
+sess apt-get install faac
+apt-get install ffmpeg
+apt-get install ardour
+apt-get install frozenbubble
+apt-get install frozen-bubble
+apt-get install dict
+apt-get install apcalc
+apt-get install wipe
+apt-get install nmap
+apt-get install sqlite3 sqlite3-doc
+apt-get install qemu
+apt-get install homebank
+apt-get install grisbi
+apt-get install rand
+apt-get install rand
+apt-get install cpipe pv
+sudo apt-get install cpipe pv
+apt-get install dialog
+apt-get install dialog
+sess apt-get install dosbox
+apt-get install elinks
+apt-get install curl
+sess -c "Det er like greit å installere den fra apt-get, siste versjon er 0.15 i begge tilfeller." apt-get install stgit
+apt-get install python2.6-dev python-fuse
+apt-get install geneweb
+sess apt-get install geneweb gwsetup gwtp menu
+apt-get install gramps
+sess apt-get install sshfs
+sess -c "Utrolig hva man roter med." apt-get install xkermit
+sess -c "Utrolig hva man roter med." apt-get install ckermit
+apt-get install stopwatch
+apt-get install autoconf automake glib-gettext intltool
+apt-get install autoconf automake intltool
+sess apt-get install autoconf automake intltool
+apt-get install audacity
+sess apt-get install ktorrent
+sess apt-get install ktorrent
+apt-get install ffmpeg
+sess apt-get install lynx-cur
+sess apt-get install faac
+apt-get install ffmpeg
+apt-get install ardour
+apt-get install elinks
+apt-get install curl
+sess -c "Det er like greit å installere den fra apt-get, siste versjon er 0.15 i begge tilfeller." apt-get install stgit
+apt-get install python2.6-dev python-fuse
+apt-get install geneweb
+sess apt-get install geneweb gwsetup gwtp menu
+apt-get install gramps
+sess apt-get install sshfs
+sess -c "Utrolig hva man roter med." apt-get install xkermit
+sess -c "Utrolig hva man roter med." apt-get install ckermit
+apt-get install stopwatch
+apt-get install autoconf automake glib-gettext intltool
+apt-get install autoconf automake intltool
+sess apt-get install autoconf automake intltool
+apt-get update; sess -c "Det var jo ikke på linode jeg skulle installere den. Jaja." apt-get install ledger
+apt-get update; sess -c "Det var jo ikke på linode jeg skulle installere den. Jaja." apt-get install ledger
+sess apt-get install lynx-cur
+sess apt-get install faac
+apt-get install ffmpeg
+apt-get install ardour
+apt-get install frozenbubble
+apt-get install frozen-bubble
+apt-get install dict
+apt-get update; sess -c "Det var jo ikke på linode jeg skulle installere den. Jaja." apt-get install ledger
+apt-get install libbz2-dev
+apt-get install liblzo2-dev
+apt-get install g++
+apt-get install libtool
+apt-get install g++
+apt-get install ffmpeg
+apt-get install ardour
+apt-get install frozenbubble
+apt-get install frozen-bubble
+apt-get install dict
+apt-get update; sess -c "Det var jo ikke på linode jeg skulle installere den. Jaja." apt-get install ledger
+apt-get install libbz2-dev
+apt-get install liblzo2-dev
+apt-get install g++
+apt-get install libtool
+apt-get install g++
+apt-get install fdupes
+apt-get install sqlite3 sqlite3-doc
+apt-get install qemu
+apt-get install homebank
+apt-get install grisbi
+apt-get install rand
+apt-get install rand
+apt-get install cpipe pv
+sudo apt-get install cpipe pv
+apt-get install dialog
+apt-get install dialog
+sess apt-get install dosbox
+apt-get install elinks
+apt-get install curl
+apt-get install libbz2-dev
+apt-get install liblzo2-dev
+apt-get install g++
+apt-get install libtool
+apt-get install g++
+apt-get install fdupes
+apt-get install tidy
+apt-get install libdbd-sqlite3-perl
+apt-get install libtest-perl-critic-perl
+grep "apt-get install" .bash_history
# }}}

=cut

diag('Testing finished.');

sub installed {
    # {{{
    my ($Cmd, $Exp, $Desc) = @_;
    my $stderr_cmd = '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );

    like(`$Cmd 2>&1`, $Exp, $Txt);
    return;
    # }}}
} # installed()

sub testcmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'installed_progs-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    is(`$Cmd$deb_str$stderr_cmd`, $Exp_stdout, $Txt);
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            is(file_data($TMP_STDERR), $Exp_stderr, "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # testcmd()

sub likecmd {
    # {{{
    my ($Cmd, $Exp_stdout, $Exp_stderr, $Exp_retval, $Desc) = @_;
    my $stderr_cmd = '';
    my $deb_str = $Opt{'debug'} ? ' --debug' : '';
    my $Txt = join('',
        "\"$Cmd\"",
        defined($Desc)
            ? " - $Desc"
            : ''
    );
    my $TMP_STDERR = 'installed_progs-stderr.tmp';

    if (defined($Exp_stderr) && !length($deb_str)) {
        $stderr_cmd = " 2>$TMP_STDERR";
    }
    like(`$Cmd$deb_str$stderr_cmd`, "$Exp_stdout", $Txt);
    my $ret_val = $?;
    if (defined($Exp_stderr)) {
        if (!length($deb_str)) {
            like(file_data($TMP_STDERR), "$Exp_stderr", "$Txt (stderr)");
            unlink($TMP_STDERR);
        }
    } else {
        diag("Warning: stderr not defined for '$Txt'");
    }
    is($ret_val >> 8, $Exp_retval, "$Txt (retval)");
    return;
    # }}}
} # likecmd()

sub file_data {
    # Return file content as a string {{{
    my $File = shift;
    my $Txt;
    if (open(my $fp, '<', $File)) {
        local $/ = undef;
        $Txt = <$fp>;
        close($fp);
        return($Txt);
    } else {
        return;
    }
    # }}}
} # file_data()

sub print_version {
    # Print program version {{{
    print("$progname v$VERSION\n");
    return;
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    if ($Opt{'verbose'}) {
        print("\n");
        print_version();
    }
    print(<<"END");

Usage: $progname [options] [file [files [...]]]

Check for missing programs every self-respecting *NIX system should 
have.

Options:

  -a, --all
    Run all tests, also TODOs.
  -h, --help
    Show this help.
  -t, --todo
    Run only the TODO tests.
  -v, --verbose
    Increase level of verbosity. Can be repeated.
  --version
    Print version information.
  --debug
    Print debugging messages.

END
    exit($Retval);
    # }}}
} # usage()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
    return;
    # }}}
} # msg()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME

run-tests.pl

=head1 SYNOPSIS

installed_progs.t [options] [file [files [...]]]

=head1 DESCRIPTION

Check for missing programs every self-respecting *NIX system should 
have.

=head1 OPTIONS

=over 4

=item B<-a>, B<--all>

Run all tests, also TODOs.

=item B<-h>, B<--help>

Print a brief help summary.

=item B<-t>, B<--todo>

Run only the TODO tests.

=item B<-v>, B<--verbose>

Increase level of verbosity. Can be repeated.

=item B<--version>

Print version information.

=item B<--debug>

Print debugging messages.

=back

=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation, either version 3 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program.
If not, see L<http://www.gnu.org/licenses/>.

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :

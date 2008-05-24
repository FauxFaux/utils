#!/usr/bin/perl -w

#=======================================================================
# $Id$
# File Library Database
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 2 or later, see end of 
# file for legal stuff.
#=======================================================================

BEGIN {
    our @version_array;
}

use strict;
use Getopt::Long;
use DBI;
use Digest::MD5;
use Digest::SHA1;
use Digest::CRC;
use Time::HiRes qw{ gettimeofday };

$| = 1;

our $Debug = 0;
my $STD_OUTPUT_FORMAT = "sql";
my $STD_DATABASE = "fldbtest";

our %Opt = (
    'add' => 0,
    'crc32' => 0,
    'database' => $STD_DATABASE,
    'debug' => 0,
    'help' => 0,
    'output-format' => $STD_OUTPUT_FORMAT,
    'verbose' => 0,
    'version' => 0,
);

our $progname = $0;
$progname =~ s#^.*/(.*?)$#$1#;

my $rcs_id = '$Id$';
my $id_date = $rcs_id;
$id_date =~ s/^.*?\d+ (\d\d\d\d-.*?\d\d:\d\d:\d\d\S+).*/$1/;

push(@main::version_array, $rcs_id);

Getopt::Long::Configure("bundling");
GetOptions(
    "add" => \$Opt{'add'},
    "crc32" => \$Opt{'crc32'},
    "database|d=s" => \$Opt{'database'},
    "debug" => \$Opt{'debug'},
    "help|h" => \$Opt{'help'},
    "output-format|o=s" => \$Opt{'output-format'},
    "verbose|v+" => \$Opt{'verbose'},
    "version" => \$Opt{'version'},
) || die("$progname: Option error. Use -h for help.\n");

$Opt{'debug'} && ($Debug = 1);
$Opt{'help'} && usage(0);
$Opt{'version'} && print_version();

my $postgresql_database = $Opt{'database'};
# my $postgresql_user=yourpostgresuser;
# my $postgresql_password=yourpostgrespass;
my $postgresql_host="localhost";
my $sth;
chomp(my $Hostname = `/bin/hostname`); # FIXME

my $TAG = '$lD8qQ$'; # FIXME: should be random and checked against every string.
# my $dbh = DBI->connect("DBI:Pg:dbname=$postgresql_database;host=$postgresql_host", "$postgresql_user", "$postgresql_password");
my $dbh = DBI->connect("DBI:Pg:dbname=$postgresql_database;host=$postgresql_host")
    or die("connect: På trynet: $!");
my $Sql;

my $use_pg = 0;
my $Table = "jada";

# Test
$dbh->do(
    "CREATE TABLE $Table (" .
        "id serial, counter integer, text varchar, value smallint, bin bytea" .
    ");"
) || warn("Cannot CREATE TABLE $Table");
my $Counter = 1;
for (my $t = ord("\x01"); $t <= ord("\xFF"); $t++) {
    msg(1, "==================== $t ('" . widechar($t) . "') ===================\n");
    $Sql = "INSERT INTO $Table (counter, text, value) VALUES($Counter, ${TAG}"
        . widechar($t)
        . "${TAG}, $t);";
    print("$Sql\n");
    $use_pg && eval('$dbh->do($Sql) || warn("$t: Cannot INSERT\n");');
    $Counter++;
}
$use_pg && print(STDERR "Result stored in database \"$postgresql_database\", table \"$Table\".\n");
exit 0;

while (my $Filename = <>) {
    chomp($Filename);
    if ($Opt{'add'}) {
        $Opt{'verbose'} && print("$Filename\n");
        $Sql = add_entry($Filename);
        if (defined($Sql)) {
            $dbh->do($Sql) || warn("$Filename: Cannot INSERT\n");
        } else {
            # warn("$Filename: Could not retrieve file data\n");
        }
    } else {
        print_entry($Filename);
    }
}

exit 0;

sub add_entry {
    # {{{
    my $Filename = shift;
    my $safe_filename = $Filename;
    # $safe_filename =~ s/'/''/g;
    D("add_entry(\"$Filename\")");
    my $Retval = "";
    my @stat_array = ();
    if (@stat_array = stat($Filename)) {
        my ($Dev, $Inode, $Mode, $Nlinks, $Uid, $Gid, $Rdev, $Size,
            $Atime, $Mtime, $Ctime, $Blksize, $Blocks) = @stat_array;
        $Mtime = sec_to_string($Mtime);
        $Ctime = sec_to_string($Ctime);
        D("Mode før: '$Mode'");
        $Mode = sprintf("%04o", $Mode & 07777);
        D("Mode etter: '$Mode'");
        my %Sum = checksum($Filename);
        my $crc32_str = $Opt{'crc32'} ? "'$Sum{crc32}'" : "NULL";
        if (scalar(%Sum)) {
            my $latin1_str;
            if (valid_utf8($Filename)) {
                $latin1_str = "FALSE";
            } else {
                $latin1_str = "TRUE";
                $safe_filename = latin1_to_utf8($Filename);
            }
            D("latin1_str = '$latin1_str'");
            my $base_filename = $safe_filename;
            $base_filename =~ s/^.*\/(.*?)$/$1/;
            D("base_filename = '$base_filename'");
            $Retval = <<END;
INSERT INTO files (
    sha1, md5, crc32, size, filename, mtime, ctime, calctime, path,
    inode, device, hostname, uid, gid, perm, lastver, nextver, descr, latin1
) VALUES (
    ${TAG}$Sum{sha1}${TAG}, ${TAG}$Sum{md5}${TAG}, $crc32_str, $Size, ${TAG}$base_filename${TAG}, ${TAG}$Mtime${TAG}, ${TAG}$Ctime${TAG}, $Sum{calctime}, ${TAG}$safe_filename${TAG},
    $Inode, ${TAG}$Dev${TAG}, ${TAG}$Hostname${TAG}, $Uid, $Gid, ${TAG}$Mode${TAG}, NULL, NULL, NULL, $latin1_str
);
END
            D("=== \$Retval \x7B\x7B\x7B\n$Retval=== \x7D\x7D\x7D");
        } else {
            warn("$Filename: Cannot read file: $!\n");
            $Retval = undef;
        }
    } else {
        warn("$progname: $Filename: Cannot stat file: $!\n");
        $Retval = undef;
    }
    D("add_entry() finished");
    return($Retval);
    # }}}
} # add_entry()

sub checksum {
    # {{{
    my $Filename = shift;
    my $Retval = "";
    my %Sum = ();
    my $starttime = gettimeofday;
    local *FP;

    D("checksum(\"$Filename\"");
    if (open(FP, "<", "$Filename")) {
        my $sha1 = Digest::SHA1->new;
        my $md5 = Digest::MD5->new;
        my $crc32 = Digest::CRC->new(type => "crc32");
        while (my $Curr = <FP>) {
            $sha1->add($Curr);
            $md5->add($Curr);
            $crc32->add($Curr) if $Opt{'crc32'};
        }
        $Sum{'sha1'} = $sha1->hexdigest;
        $Sum{'md5'} = $md5->hexdigest;
        $Opt{'crc32'} && ($Sum{'crc32'} = sprintf("%08x", $crc32->digest));
    } else {
        # warn("$Filename: Cannot read file: $!\n");
    }
    my $endtime = gettimeofday;
    $Sum{'calctime'} = $endtime-$starttime;
    D("checksum() returnerer " . scalar(%Sum) . " elementer");
    return(%Sum);
    # }}}
} # checksum()

sub print_entry {
    # {{{
    my $File = $1;
    # printf(join("\t",
    printf(<<END,
INSERT INTO files (sha1, md5, crc32, size, filename, mtime, ctime, path, device, hostname, uid, gid, perm, lastver, nextver, descr) VALUES (
    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
);
END
        "NULL", # sha1
        "NULL", # md5
        "NULL", # crc32
        "NULL", # size
        "NULL", # filename
        "NULL", # mtime
        "NULL", # ctime
        "NULL", # path
        "NULL", # device
        "NULL", # hostname
        "NULL", # uid
        "NULL", # gid
        "NULL", # perm
        "NULL", # lastver
        "NULL", # nextver
        "NULL", # descr
    );
    # }}}
} # print_entry()

sub valid_utf8 {
    # {{{
    my $Text = shift;
    $Text =~ s/([\xFC-\xFD][\x80-\xBF][\x80-\xBF][\x80-\xBF][\x80-\xBF][\x80-\xBF])//g;
    $Text =~ s/([\xF8-\xFB][\x80-\xBF][\x80-\xBF][\x80-\xBF][\x80-\xBF])//g;
    $Text =~ s/([\xF0-\xF7][\x80-\xBF][\x80-\xBF][\x80-\xBF])//g;
    $Text =~ s/([\xE0-\xEF][\x80-\xBF][\x80-\xBF])//g;
    $Text =~ s/([\xC0-\xDF][\x80-\xBF])//g;
    return($Text =~ /[\x80-\xFF]/ ? 0 : 1);
    # }}}
} # valid_utf8()

sub latin1_to_utf8 {
    # {{{
    my $Text = shift;
    D("latin1_to_utf8()");
    $Text =~ s/([\x80-\xFF])/widechar(ord($1))/ge;
    return($Text);
    # }}}
} # latin1_to_utf8()

sub widechar {
    # {{{
    my $Val = shift;
    if ($Val < 0x80) {
        return sprintf("%c", $Val);
    } elsif ($Val < 0x800) {
        return sprintf("%c%c", 0xC0 | ($Val >> 6),
                               0x80 | ($Val & 0x3F));
    } elsif ($Val < 0x10000) {
        return sprintf("%c%c%c", 0xE0 |  ($Val >> 12),
                                 0x80 | (($Val >>  6) & 0x3F),
                                 0x80 |  ($Val        & 0x3F));
    } elsif ($Val < 0x200000) {
        return sprintf("%c%c%c%c", 0xF0 |  ($Val >> 18),
                                   0x80 | (($Val >> 12) & 0x3F),
                                   0x80 | (($Val >>  6) & 0x3F),
                                   0x80 |  ($Val        & 0x3F));
    } elsif ($Val < 0x4000000) {
        return sprintf("%c%c%c%c%c", 0xF8 |  ($Val >> 24),
                                     0x80 | (($Val >> 18) & 0x3F),
                                     0x80 | (($Val >> 12) & 0x3F),
                                     0x80 | (($Val >>  6) & 0x3F),
                                     0x80 | ( $Val        & 0x3F));
    } elsif ($Val < 0x80000000) {
        return sprintf("%c%c%c%c%c%c", 0xFC |  ($Val >> 30),
                                       0x80 | (($Val >> 24) & 0x3F),
                                       0x80 | (($Val >> 18) & 0x3F),
                                       0x80 | (($Val >> 12) & 0x3F),
                                       0x80 | (($Val >>  6) & 0x3F),
                                       0x80 | ( $Val        & 0x3F));
    } else {
        return widechar(0xFFFD);
    }
    # }}}
} # widechar()

sub print_version {
    # Print program version {{{
    for (@main::version_array) {
        print("$_\n");
    }
    exit(0);
    # }}}
} # print_version()

sub usage {
    # Send the help message to stdout {{{
    my $Retval = shift;

    print(<<END);

$rcs_id

Usage: $progname [options] [file [files [...]]]

Options:

  -a, --add
    Add file information to database.
  --crc32
    Also calculate CRC32. Reads the whole file into memory, so it’s not 
    suitable for big files. Maybe fixed in newer Perl versions.
  -d x, --database x
    Use database x.
  -h, --help
    Show this help.
  -o x, --output x
    Output format. Default: $STD_OUTPUT_FORMAT
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

sub sec_to_string {
    # Convert seconds since 1970 to "yyyy-mm-ddThh:mm:ssZ" {{{
    my ($Seconds) = shift;
    ($Seconds =~ /^(\d*)(\.\d+)?$/) || return(undef);

    my @TA = gmtime($Seconds);
    my($DateString) = sprintf("%04u-%02u-%02uT%02u:%02u:%02uZ",
                              $TA[5]+1900, $TA[4]+1, $TA[3],
                              $TA[2], $TA[1], $TA[0]);
    return($DateString);
    # }}}
} # sec_to_string()

sub msg {
    # Print a status message to stderr based on verbosity level {{{
    my ($verbose_level, $Txt) = @_;

    if ($Opt{'verbose'} >= $verbose_level) {
        print(STDERR "$progname: $Txt\n");
    }
    # }}}
} # msg()

sub D {
    # Print a debugging message {{{
    $Debug || return;
    my @call_info = caller;
    chomp(my $Txt = shift);
    my $File = $call_info[1];
    $File =~ s#\\#/#g;
    $File =~ s#^.*/(.*?)$#$1#;
    print(STDERR "$File:$call_info[2] $$ $Txt\n");
    return("");
    # }}}
} # D()

__END__

# Plain Old Documentation (POD) {{{

=pod

=head1 NAME



=head1 REVISION

$Id$

=head1 SYNOPSIS

 [options] [file [files [...]]]

=head1 DESCRIPTION



=head1 OPTIONS

=over 4

=item B<-h>, B<--help>

Print a brief help summary.

=item B<-v>, B<--verbose>

Increase level of verbosity. Can be repeated.

=item B<--version>

Print version information.

=item B<--debug>

Print debugging messages.

=back

=head1 BUGS



=head1 AUTHOR

Made by Øyvind A. Holm S<E<lt>sunny@sunbase.orgE<gt>>.

=head1 COPYRIGHT

Copyleft © Øyvind A. Holm E<lt>sunny@sunbase.orgE<gt>
This is free software; see the file F<COPYING> for legalese stuff.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your 
option) any later version.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program; if not, write to the Free Software Foundation, Inc., 
59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=head1 SEE ALSO

=cut

# }}}

# vim: set fenc=UTF-8 ft=perl fdm=marker ts=4 sw=4 sts=4 et fo+=w :
# End of file $Id$
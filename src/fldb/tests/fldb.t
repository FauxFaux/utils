#!/usr/bin/perl

#=======================================================================
# tests/fldb.t
# File ID: 393bb6d2-f9f1-11dd-8b2b-000475e441b9
# Test suite for fldb(1).
#
# Character set: UTF-8
# ©opyleft 2008– Øyvind A. Holm <sunny@sunbase.org>
# License: GNU General Public License version 3 or later, see end of 
# file for legal stuff.
#=======================================================================

use strict;
use warnings;

BEGIN {
    push(@INC, "$ENV{'HOME'}/bin/src/fldb");
    use Test::More qw{no_plan};
    use_ok('FLDBpg');
    use_ok('FLDBsum');
    use_ok('FLDButf');
}

use Getopt::Long;

local $| = 1;

our $Debug = 0;
our $CMD = '../fldb';

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

testcmd("$CMD command", # {{{
    <<'END',
[expected stdin]
END
    "",
    0,
    "description",
);

# }}}

=cut

diag('Testing -h (--help) option...');
likecmd("$CMD -h", # {{{
    '/  Show this help\./',
    '/^$/',
    0,
    'Option -h prints help screen',
);

# }}}
diag('Testing -v (--verbose) option...');
likecmd("$CMD -hv", # {{{
    '/^\n\S+ v\d\.\d\d\n/s',
    '/^$/',
    0,
    'Option --version with -h returns version number and help screen',
);

# }}}
diag('Testing --version option...');
likecmd("$CMD --version", # {{{
    '/^\S+ v\d\.\d\d\n/',
    '/^$/',
    0,
    'Option --version returns version number',
);

diag("Testing return values...");
likecmd("perl -e 'exit(0)'", '/^$/', '/^$/', 0, "likecmd(): return 0");
likecmd("perl -e 'exit(1)'", '/^$/', '/^$/', 1, "likecmd(): return 1");
likecmd("perl -e 'exit(255)'", '/^$/', '/^$/', 255, "likecmd(): return 255");
testcmd("perl -e 'exit(0)'", '', '', 0, "testcmd(): return 0");
testcmd("perl -e 'exit(1)'", '', '', 1, "testcmd(): return 1");
testcmd("perl -e 'exit(255)'", '', '', 255, "testcmd(): return 255");

# }}}
chdir('files') or die("$progname: files: Cannot chdir(): $!\n");
likecmd('tar xzf dir1.tar.gz', # {{{
    '/^$/',
    '/.*/',
    0,
    "Extract dir1.tar.gz",
);

# }}}
chdir('..') or die("$progname: ..: Cannot chdir(): $!\n");

diag("Testing safe_sql()...");
is(safe_sql(""), # {{{
    "",
    'safe_sql("") - Empty string'
);

# }}}
is(safe_sql("abc"), # {{{
    "abc",
    'safe_sql("abc") - Regular ASCII'
);

# }}}
is(safe_sql("'"), # {{{
    "''",
    'safe_sql("\'") - Apostrophe'
);

# }}}
is(safe_sql("\t\n\r"), # {{{
    "\\t\\n\\r",
    'safe_sql("\\t\\n\\r") - TAB, LF and CR'
);

# }}}
is(safe_sql("æ☺’"), # {{{
    "æ☺’",
    'safe_sql("abc") - UTF-8'
);

# }}}
is(safe_sql("a\0b"), # {{{
    "a\0b",
    'safe_sql("a\\0b") - Null byte'
);

# }}}
is(safe_sql("\xF8"), # {{{
    "\xF8", # FIXME: Is this OK? It will never happen.
    'safe_sql("\\xF8") - Invalid UTF-8'
);

# }}}
# diag("Testing checksum()...");
diag("Testing valid_utf8()...");
is(valid_utf8(""), # {{{
    1,
    'valid_utf8("") - Empty string'
);

# }}}
is(valid_utf8("abc"), # {{{
    1,
    'valid_utf8("abc") - Regular ASCII'
);

# }}}
is(valid_utf8("æ©☺"), # {{{
    1,
    'valid_utf8("æ©☺") - Valid UTF-8'
);

# }}}
is(valid_utf8("\xF8"), # {{{
    0,
    'valid_utf8("\\xF8") - Invalid UTF-8'
);

# }}}
# is(valid_utf8(""), # {{{
#     "",
#     'valid_utf8("")'
# );

# }}}
diag("Testing widechar()...");
diag("Testing latin1_to_utf8()...");
diag("Testing -d (--description) option...");
testcmd("$CMD -d Groovy -s files/dir1/random_2048", # {{{
    <<END,
INSERT INTO files (
 sha1, md5, crc32,
 size, filename, mtime,
 descr,
 latin1
) VALUES (
 'bd91a93ca0462da03f2665a236d7968b0fd9455d', '4a3074b2aae565f8558b7ea707ca48d2', NULL,
 2048, E'random_2048', '2008-09-22T00:18:37Z',
 E'Groovy',
 FALSE
);
END
    "",
    0,
    "Output SQL with description",
);

# }}}
testcmd("$CMD -d Yess -xs files/dir1/random_2048", # {{{
    <<END,
<fldb>
<file> <size>2048</size> <sha1>bd91a93ca0462da03f2665a236d7968b0fd9455d</sha1> <md5>4a3074b2aae565f8558b7ea707ca48d2</md5> <name>files/dir1/random_2048</name> <date>2008-09-22T00:18:37Z</date> <descr>Yess</descr> </file>
</fldb>
END
    "",
    0,
    "Output short XML from random_2048 with description and mtime",
);

# }}}
testcmd("$CMD -d \"This is a description with spaces\" -s files/dir1/random_2048", # {{{
    <<END,
INSERT INTO files (
 sha1, md5, crc32,
 size, filename, mtime,
 descr,
 latin1
) VALUES (
 'bd91a93ca0462da03f2665a236d7968b0fd9455d', '4a3074b2aae565f8558b7ea707ca48d2', NULL,
 2048, E'random_2048', '2008-09-22T00:18:37Z',
 E'This is a description with spaces',
 FALSE
);
END
    "",
    0,
    "Output SQL with description with space and apos",
);

# }}}
testcmd("$CMD -d \"Somewhat & weird < > yepp\" -xs files/dir1/random_2048", # {{{
    <<END,
<fldb>
<file> <size>2048</size> <sha1>bd91a93ca0462da03f2665a236d7968b0fd9455d</sha1> <md5>4a3074b2aae565f8558b7ea707ca48d2</md5> <name>files/dir1/random_2048</name> <date>2008-09-22T00:18:37Z</date> <descr>Somewhat &amp; weird &lt; &gt; yepp</descr> </file>
</fldb>
END
    "",
    0,
    "Output short XML from random_2048 with weird description and mtime",
);

# }}}
likecmd("$CMD files/dir1/random_2048", # {{{
    '/^INSERT INTO files \(\n' .
        ' sha1, md5, crc32,\n' .
        ' size, filename, mtime, descr, ctime,\n' .
        ' path,\n' .
        ' inode, links, device, hostname,\n' .
        ' uid, gid, perm,\n' .
        ' lastver, nextver,\n' .
        ' latin1\n' .
        '\) VALUES \(\n' .
        ' \'bd91a93ca0462da03f2665a236d7968b0fd9455d\', \'4a3074b2aae565f8558b7ea707ca48d2\', NULL,\n' .
        ' 2048, E\'random_2048\', \'2008-09-22T00:18:37Z\', NULL, \'\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ\',\n' .
        ' E\'files\/dir1\/random_2048\',\n' .
        ' \d+, 1, E\'\d+\', E\'.+\',\n' .
        ' \d+, \d+, \'0644\',\n' .
        ' NULL, NULL,\n' .
        ' FALSE\n' .
        '\);\n' .
        '$/',
    '/^$/',
    0,
    "Output SQL from random_2048",
);

# }}}
diag("Testing -s (--short-format) option...");
testcmd("$CMD -s files/dir1/random_2048", # {{{
    <<END,
INSERT INTO files (
 sha1, md5, crc32,
 size, filename, mtime,
 descr,
 latin1
) VALUES (
 'bd91a93ca0462da03f2665a236d7968b0fd9455d', '4a3074b2aae565f8558b7ea707ca48d2', NULL,
 2048, E'random_2048', '2008-09-22T00:18:37Z',
 NULL,
 FALSE
);
END
    "",
    0,
    "Output short SQL from dir1/random_2048",
);

# }}}
diag("Testing -x (--xml) option...");
likecmd("$CMD -x files/dir1/random_2048", # {{{
    '/^<fldb>\n' .
            '<file> ' .
                '<size>2048<\/size> ' .
                '<sha1>bd91a93ca0462da03f2665a236d7968b0fd9455d<\/sha1> ' .
                '<md5>4a3074b2aae565f8558b7ea707ca48d2<\/md5> ' .
                '<filename>random_2048<\/filename> ' .
                '<mtime>2008-09-22T00:18:37Z<\/mtime> ' .
                '<ctime>\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ<\/ctime> ' .
                '<path>files\/dir1\/random_2048<\/path> ' .
                '<inode>\d+<\/inode> <links>1<\/links> ' .
                '<device>\d+<\/device> ' .
                '<hostname>.*?<\/hostname> ' .
                '<uid>\d+<\/uid> <gid>\d+<\/gid> ' .
                '<perm>0644<\/perm> ' .
            '<\/file>\n' .
        '<\/fldb>\n' .
        '$/',
    '/^$/',
    0,
    "Output short XML from dir1/random_2048 with mtime",
);

# }}}
testcmd("$CMD -xs files/dir1/random_2048", # {{{
    <<END,
<fldb>
<file> <size>2048</size> <sha1>bd91a93ca0462da03f2665a236d7968b0fd9455d</sha1> <md5>4a3074b2aae565f8558b7ea707ca48d2</md5> <name>files/dir1/random_2048</name> <date>2008-09-22T00:18:37Z</date> </file>
</fldb>
END
    "",
    0,
    "Output short XML from dir1/random_2048 with mtime",
);

# }}}

ok(chmod(0644, "files/dir1/chmod_0000"), "chmod(0644, 'files/dir1/chmod_0000')");
ok(unlink(glob("files/dir1/*")), 'Delete files in files/dir1/*');
ok(rmdir("files/dir1"), 'rmdir files/dir1');

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

diag('Testing finished.');

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
    my $TMP_STDERR = 'fldb-stderr.tmp';

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
    my $TMP_STDERR = 'fldb-stderr.tmp';

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

Contains tests for the fldb(1) program.

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

fldb.t [options] [file [files [...]]]

=head1 DESCRIPTION

Contains tests for the fldb(1) program.

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

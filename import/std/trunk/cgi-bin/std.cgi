#!/usr/bin/perl -w

#=========================================================
# Standardoppsett til index.cgi
# $Id: std.cgi,v 1.2 2001/09/23 23:33:17 sunny Exp $
# (C)opyright 2001 �yvind A. Holm <sunny@sunbase.org>
#=========================================================

require 5.003;

BEGIN {
	$main::Debug = 0; # Skriver masse debuggingsinfo til $debug_file
	$main::Utv = (-e "utv.mrk") ? 1 : 0;
	$main::utv_str = $main::Utv ? " (utv)" : "";
	$main::writable_dir = $main::Utv ? "/tmp" : "/tmp/utv";
	$suncgi::Border = 0;
	if ($main::Utv) {
		unshift(@INC, qw{/home/badata/Utv/perllib /home/badata/Utv/basnakk});
	} else {
		unshift(@INC, qw{/home/badata/Stable/perllib /home/badata/Stable/basnakk});
	}
}

use strict;
use Fcntl ':flock';

use suncgi;

$| = 1;

# Ting som suncgi.pm vil ha:
$Url = $main::Utv ? "http://" : "http://";
$debug_file = "$main::writable_dir/DEBUG";
$error_file = "$main::writable_dir/ERROR";
$log_dir = "$main::writable_dir/log";
$request_log_file = "$log_dir/request.log";
$log_requests = 1;
$WebMaster = 'sunny@sunbase.org';
$doc_width = '95%';

$main::rcs_id = '$Id: std.cgi,v 1.2 2001/09/23 23:33:17 sunny Exp $';
unshift(@main::rcs_array, $main::rcs_id);

$css_default = <<END;
<style type="text/css">
	<!--
	body { color: #000000; background: #fefbeb; font-family: sans-serif; }
	p, big, th, td, ul, li, h1, h2, h3 { font-family: sans-serif; }
	pre { font-family: monospace; }
	td.for { font-weight: bold; text-align: right; }
	td.oinp, p.oinp { font-weight: bold; text-align: left; }
	td.einp { font-weight: lighter; text-align: left; font-size: small; }
	div.footer { font-family: sans-serif; font-size: x-small; }
	-->
</style>
END

$Opt = get_cgivars();

print_header("Det virket visst.");

tab_print("<h1>Vi er oppe og g�r</h1>\n");

#### End of file $Id: std.cgi,v 1.2 2001/09/23 23:33:17 sunny Exp $ ####
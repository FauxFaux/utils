#!/usr/bin/perl

#===============================================
# $Id: hhi,v 1.2 2002/04/15 03:20:26 sunny Exp $
# Html Header Indexer
# Made by Oyvind A. Holm <sunny@sunbase.org>
#===============================================

use strict;

my ($header_level, $last_level) = (0, 0);
my @header_num = qw{0};

while (<>) {
	chomp();
	if (m!^(.*)<(h)(\d+)(.*?)>(.*)!i) {
		$header_level = $3;
		if ($header_level < $last_level) {
			splice(@header_num, $header_level);
		}

		$header_num[$header_level-1]++;
		my $tall_str = join(".", @header_num);
		$_ = "$1<$2$3$4>$tall_str $5";
	}
	print("$_\n");
	$last_level = $header_level;
}

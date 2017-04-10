#!/usr/bin/perl

use warnings;
use strict;
use utf8;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

my $line = 1;
my $text = '';
my $url = '';
my $book = '';
my $pers = '';
my $fbtype = '';
my $wdprop = '';
my $neout = '';

## Simple types
if($ARGV[0] eq 'book') {
	$fbtype = 'book.written_work.author';
	$wdprop = 'P50';
	$neout = 'book';
}
if($ARGV[0] eq 'director') {
	$fbtype = 'film.film.directed_by';
	$wdprop = 'P57';
	$neout = 'film';
}
if($ARGV[0] eq 'buried') {
	$fbtype = 'people.place_of_interment.interred_here';
	$neout = 'place';
	$wdprop = 'P119';
}
if($ARGV[0] eq 'involved') {
	$fbtype = 'time.event.people_involved';
	$neout = 'event';
	$wdprop = 'P710';
}

while(<STDIN>) {
	chomp;
	if(/^http/ && $line == 1) {
		$url = $_;
		$line = 2;
		next;
	}
	if($line == 2) {
		$text = $_;
		$line = 3;
		next;
	}
	if($line == 3) {
		($book, $pers) = split/\t/;
		$line = 1;
		$url =~ s/\&/&amp;/g;
		$text =~ s!$pers!<ne type='person'>$pers</ne>!;
		$text =~ s!$book!<ne type='$neout'>$book</ne>!;
		$book =~ s/'/&apos;/g;
print <<__END__;
<txt src='$url'>
<fragment>
$text
</fragment>
<rels src='$book'>
  <rel fbtype='$fbtype' wdprop='$wdprop' trg='$pers'/>
</rels>
</txt>
__END__
		next;
	}
}

package Kwiki::SocialMap;

=head1 NAME

Kwiki::SocialMap - Display social relation of this kwiki site

=head1 COPYRIGHT

Copyright 2004 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut

use strict;
use warnings;
use Kwiki::Plugin '-Base';
use Kwiki::Installer '-base';
use YAML;

our $VERSION = '0.01';

const class_id => 'socialmap';
const class_title => 'SocialMap Blocks';

sub register {
    my $registry = shift;
    $registry->add(wafl => socialmap => 'Kwiki::SocialMap::Wafl');
}

package Kwiki::SocialMap::Wafl;
use base 'Spoon::Formatter::WaflBlock';
use Graph::SocialMap;
use Digest::MD5;

sub to_html {
    $self->cleanup;
    $self->render_socialmap($self->units->[0]);
}

# XXX: I think cleanup should be called ony once per-page.
# (If a page is modified, re-generate all the socialmap inside)
# but put it in here will make it be called once per-socialmap-block.
sub cleanup {
    my $path = $self->hub->config->socialmap_directory;
    my $page =$self->hub->pages->current;
    my $page_id = $page->id;
    for(<$path/$page_id/*.png>) {
	my $mt = (stat($_))[9];
	unlink($_) if $mt < $page->modified_time;
    }
}

# use md5 as filename because I don't want to regenerate all the graphs
# on every page rendering. That's totally a waste of time.
sub render_socialmap {
    my $reldump = shift;

    my $digest = Digest::MD5::md5_hex($reldump);
    my $path = $self->hub->config->socialmap_directory;
    my $page = $self->hub->pages->current->id;
    my $file = "$path/$page/";
    mkdir($file) unless -d $file;
    $file .= "$digest.png";

    unless(-f $file) {
	my $relation = YAML::Load($reldump);
	my $gsmio = io($file);
	my $gsm = Graph::SocialMap->new(-relation => $relation);
	$gsm->save(-format=> 'png',-file=> $gsmio);
    }

    return qq{<img src="$file" />};
}

1;

package Kwiki::SocialMap;
__DATA__
__socialmap/.keepme__
This file is used to keep this directory.

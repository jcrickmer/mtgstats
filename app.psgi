#!/bin/env perl
use strict;
use warnings;
use Plack::Builder;
use MTG::Web::App;

my $app = MTG::Web::App->new();
my $codeRef = sub { $app->call(@_); };

builder {
    # Precious debug info. Right on your page!
    enable 'Debug';

    # Make Plack middleware render some static for you
    enable "Static",
      path => qr{\.(?:js|css|jpe?g|gif|ico|png|html?|swf|txt)$},
      root => './htdocs';

    # Let Plack care about length header
    enable "ContentLength";

    $codeRef;
}

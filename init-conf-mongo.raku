#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
#
#     Initialisation d'une configuration de Black Box (base MongoDB)
#     Initialising a Black Box configuration (in a MongoDB database)
#     Copyright (C) 2021 Jean Forget
#
#     Voir la licence dans la documentation incluse ci-dessous.
#     See the license in the embedded documentation below.
#

use v6;
use lib 'lib';
use BSON::Document;
use MongoDB::Client;
use MongoDB::Database;
use MongoDB::Collection;
use init-conf-common;

my MongoDB::Client     $client        .= new(:uri('mongodb://'));
my MongoDB::Database   $database       = $client.database('Black-Box');
my MongoDB::Collection $configurations = $database.collection('Configurations');
my MongoDB::Collection $molecules      = $database.collection('Molecules');

sub MAIN (Str $config) {
  my $cf = $config.uc;
  init($cf, &purge-Configurations, &purge-Molecules, &store-Configuration);
}

sub purge-Configurations(Str $cf) {
  my BSON::Document $req .= new: (
    delete    => 'Configurations',
    deletes   => [ (
          q     => ( config => ($cf), ),
          limit => 0,
    ), ],
  );
  my BSON::Document $result = $database.run-command($req);
  say "Clean-up configuration ok : ", $result<ok>, " nb : ", $result<n>;
}

sub purge-Molecules(Str $cf) {
  my BSON::Document $req .= new: (
    delete    => 'Molecules',
    deletes   => [ (
          q     => ( config => ($cf), ),
          limit => 0,
    ), ],
  );
  my BSON::Document $result = $database.run-command($req);
  say "Clean-up molecules     ok : ", $result<ok>, " nb : ", $result<n>;
}

sub store-Configuration(BSON::Document $doc) {
  my BSON::Document $req .= new: (
    insert    => 'Configurations',
    documents => [ $doc ],
  );
  my BSON::Document $result = $database.run-command($req);
  say "Creation configuration ok : ", $result<ok>, " nb : ", $result<n>;
}

=begin POD

=encoding utf8

=head1 NAME

init-conf-mongo.raku -- initialising a Black Box configuration, MongoDB variant

=head1 DESCRIPTION

This  program  creates  a   single  record  in  the  C<Configurations>
collection of the Black Box MongoDB database and, if necessary, cleans
the  C<Molecules>   collection,  removing  any   C<Molecule>  document
identified by the configuration code.

=head1 USAGE

  raku init-conf-mongo.raku a4_b8

=head2 Parameters

=item configuration code

A string patterned  as C<A>I<n>C<_B>I<p>, where I<n> is  the number of
atoms and I<p> is the width of the box

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD

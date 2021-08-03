#!/bin/sh
# -*- encoding: utf-8; indent-tabs-mode: nil -*-

mongo Black-Box --eval "db.Molecules.createIndex({config: 1, number:   1})"
mongo Black-Box --eval "db.Molecules.createIndex({config: 1, molecule: 1})"
mongo Black-Box --eval "db.Molecules.createIndex({config: 1, spectrum: 1})"

exit;

=begin POD

=encoding utf8

=head1 NAME

add-index-mongo.sh -- Adding indexes to the Molecules collection in the MongoDB database

=head1  DESCRIPTION

Adding indexes  to the  C<Molecules> collection, hopefully  to improve
the process time.

Note:  when filling  the C<Spectrums>  collection for  a configuration
with many molecules, the indexes  created by the present programme may
be a requirement. If the indexes are missing, the C<aggregate> MongoDB
function might fail.

=head1 USAGE

  sh add-index-mongo.sh

=head2 Parameters

None.

=head1 COPYRIGHT and LICENCE

Copyright (C) 2021, Jean Forget, all rights reserved

This  program is  published under  the  same conditions  as Raku:  the
Artistic License version 2.0.

The text of  the licenses is available  in the F<LICENSE-ARTISTIC-2.0>
file in this repository, or you can read them at:

  L<https://raw.githubusercontent.com/Raku/doc/master/LICENSE>

=end POD

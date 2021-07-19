#!/usr/bin/env perl6
# -*- encoding: utf-8; indent-tabs-mode: nil -*-

use v6;

unit module db-conf-sql;

my Str $dbname = '/home/jf/Documents/prog/rakudo/black-box/Black-Box.db';

sub dbname is export {
  return $dbname;
}

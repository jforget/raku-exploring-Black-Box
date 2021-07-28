-*- encoding: utf-8; indent-tabs-mode: nil -*-

Exploring the Black Box
=======================

This project is an complete exploration  of the game Black Box (with 4
atoms). This  is not yet  another implementation  of the game.  When I
just want  to play  the game,  I use Emacs  or Simon  Tatham's Puzzles
Collection.

So the  project generates all  635376 possible atoms  combinations and
computes statistics  on these  combinations. For a  smaller processing
time, you  can reduce the  number of atoms or  the size of  the square
board.

Installation
============

Some assembly required. After downloading  the project, if you want to
use the SQLite version, you must enter the pathname of the database in
`lib/db-conf-sql.rakumod`. For  the MongoDB  version, if  the security
set-up is  not the default  "127.0.0.1 only"  set-up, you need  to add
authentication and access checks to the programmes.

Author
======

Jean Forget (JFORGET at cpan dot org)

License
=======

The programmes  are under the  Artistic License  2.0. See the  text in
LICENSE-ARTISTIC-2.0.

The various texts  of this repository are licensed under  the terms of
Creative Commons, with attribution and share-alike (CC-BY-SA).


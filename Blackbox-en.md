-*- encoding: utf-8; indent-tabs-mode: nil -*-

Presentation
============

This project is an complete exploration of the game
Black Box (with 4 atoms). This is not yet another
implementation of the game. When I just want to play
the game, I use Emacs or Simon Tatham's Puzzles Collection.
This project feeds a database which can be used to
produce statistics about Black Box.

The main purpose of the project
-------------------------------

[Black Box](https://en.wikipedia.org/wiki/Black_Box_(game))
is a puzzle game in which the hider player sets
up 4 or 5 atoms in a black box and in which the
seeker player shoots rays from the sides of the black
box to locate the hidden atoms.
As all deduction games, there is a luck factor because
some answers from the hider player can be more interesting than
others and thus lead to a shorter solution. Or the answers are
more mundane and give fewer informations to the seeker player.
Another luck factor is that there are 
some configurations where the seeker player cannot
guess all the atom positions, even if he has shot all
possible rays from the outside of the box. A well-known
example is this 5-atom situation:


```                     
   - - - - - - - -   
   - - O - - O - -   
   - - - ? ? - - -   
   - - - ? ? - - -   
   - - O - - O - -   
   - - - - - - - -   
   - - - - - - - -   
   - - - - - - - -   
```                     

The O-atoms are easily located. But they form a "no-ray's land"
represented by question marks. The 5th atom can be in any
question mark position, where no ray can interact with it.
The seeker has to choose one of these 4 positions,
with a 1-in-4 chance of finding the good position
and a 3-in-4 chance of getting a 5-point penalty.

There are other ambiguous 5-atom situations, a bit
more convoluted, like
[this one](https://boardgamegeek.com/thread/1621945/spoilers-game-80-has-two-valid-solutions)
from a forum discussion on
Board Game Geek. The general opinion is that
ambiguous situations exist in the 5-atom variant,
but not in the 4-atom variant. This opinion is wrong.
Ambiguous 4-atom positions exists, just read my
answer to the forum discussion.

For the moment (before writing the programmes), in the 4-atom game, I had found only
situations where the ambiguous situations are grouped
by two. The purpose of this project is to determine
whether situations exist in groups of 3 or 4.
This project examines all the ways 4 atoms can be
arrayed inside the box, computes the results for all
possible 32 rays and, thus, determines which atom configurations
leads to the same ray results.

Post-scriptum. While writing the exploration program
and _before_ running it on a configuration with 4 atoms on
a 8×8 square, or even on any configuration with a square bigger
than 4×4, I have found by pure thought this game:

```
   6 7 5 H 4 H 3 H
 1 - - - - - - - - 1
 2 - - - - - - - - 2
 3 - - - - - - - - R
 H - - - - - - - - H
 4 - - - - - - - - R
 H - - - - - - - - H
 5 - - - - - - - - R
 H - - - - - - - - H
   6 7 R H R H R H

There are 4 balls in the box
```

(H = absorbed, R = reflected) Try to decode it...

Secondary Purpose
-----------------

Here are 4 games I played within Emacs.

```                     
             3       
 1 - - - - - - - - 1 
 R - - - - - - - -   
 H O - - O - - - -   
   - - - - - - - -   
 3 - - - - - - - -   
   - - - - - - O -   
 R - - - - - - - - 2 
 H O - - - - - - -   
       4     4   2   

There are 4 balls in the box

           6 2   1   
 H O - - - - - - -   
   - - - - - - - - 4 
 3 - - - - - - - - 3 
   - - - - - - - - 6 
   - - - O - - - -   
 4 - - - - - - - - 5 
   - - - - - - - - 5 
 H O - - O - - - - H 
   H     H R 2   1   

There are 4 balls in the box

     4 3   2         
 H - - - - - - O -   
 5 - - - - - - - - 6 
   - - - - - - - - 4 
   O - - - - - - -   
   - - - - - - - - 5 
   - - - - - - - - 6 
   O - - - - - O -   
 R - - - - - - - - 1 
       3   2     1   

There are 4 balls in the box

   1   7 5 4 6 7     
 1 - - - - - - - -   
   - O - - - - - O   
   - - - - - - - -   
 H - O - - - - - -   
 3 - - - - - - - -   
 R - - - - - - - -   
 H - - - - - - - O   
 2 - - - - - - - -   
   3     5 4 6 2     

There are 4 balls in the box
```

As you can see, in each game a ray has been deflected several times
before exiting the board (in the first 3 games) or before being reflected
(in the 4th game).

The secondary purpose is to gather statistics on the rays:
path length, number of deflections, to know if other convoluted
configurations exist.

We can easily find that a ray can be deflected up to 6 times and cross up to 23 squares,
as in the following situation:

```
     1
   - + - - - - - O   
   - + + + + + + -   
   O - - - - - + -   
   - + + + + + + -   
   - + - - - - - O   
   - + + + + + + -   
   O - - - - - + -   
   - - - - - - + -   
               1

There are 4 balls in the box
```

Yet, the exploration programme will compute statistics for
each situation, to confirm or to refine this statement.

Tertiary purpose
----------------

Up to now, my mark-up language of choice was Perl's POD. I have
decided to try another possibility. So this text is written in
Markdown.

For the Impatients
==================

Supposing everything is installed (Raku, modules, database),
here is how you explore all possible games with 4 atoms within
a 8×8 box.

SQLite version
--------------

First, edit and update the content of the `lib/db-conf-sql.rakumod` file.
This file holds the fully qualified pathname of the database in
_my_ computer. The directory structure of _your_ computer is most
certainly a bit different. So you have to replace the fully qualified
pathname of the database by another qualified pathname compatible
with _your_ computer.

Then please run:

```
raku init-conf-sql.raku    --config=A4_B8
raku explore-conf-sql.raku --config=A4_B8
```

For the last command, do not redirect the standard output.
There will be about 100 lines which will keep you
a bit entertained while waiting for the programme to finish.

Go on with

```
raku init-spectrum-sql.raku --config=A4_B8
raku upd-spectrum-sql.raku  --config=A4_B8
```

Now the database is ready and you can query it with `sqlite3`.
If you want to display the records in a user-friendly format,
run commands like these:

```
raku display-sql.raku --config=A4_B8  5 6 7 8 9 10
raku display-sql.raku --config=A4_B8  --from=5 --to=10
```

MongoDB version
---------------

Please type

```
./add-index-mongo.sh
raku init-conf-mongo.raku    --config=A4_B8
raku explore-conf-mongo.raku --config=A4_B8
```

For the last command, do not redirect the standard output.
There will be about 100 lines which will keep you
a bit entertained while waiting for the programme to finish.

Go on with

```
raku init-spectrum-mongo.raku --config=A4_B8
raku upd-spectrum-mongo.raku  --config=A4_B8
```


Now the database is ready and you can query it with the `mongo` shell.
If you want to display the records in a user-friendly format,
run commands like these:

```
raku display-mongo.raku --config=A4_B8  5 6 7 8 9 10
raku display-mongo.raku --config=A4_B8  --from=5 --to=10
```

Project Organisation
====================

Vocabulary
----------

The contents of Black Box consists of several atoms in a precise
position. So we will call each configuration a _molecule_.

Likewise, all 32 rays are grouped together in what is called
a _spectrum_.

The metaphor has its limits. In the real world, a spectrum is a bunch
of rays over a wide range of wavelengths. Here, a spectrum is a bunch
or rays over a wide range of geometric positions.

With these definitions, the main purpose of this project is to
find different molecules with the same spectrum.

In our 3-D real world, when given a molecule, its enantiomer is its mirror
image, provided the first molecule is asymmetrical. In the 2-D abstract Black
Box world, I will use the word enantiomer to designate a molecule obtained from
the first one by a rotation around the square's center or a symmetry with respect
to one of the square's diagonals or medians.

For example, for the following molecule:

```
   - O O - - - - -
   - O - - - - - -
   O - - - - - - -
   - - - - - - - -
   - - - - - - - -
   - - - - - - - -
   - - - - - - - -
   - - - - - - - -
```

the 7 enantiomers are:


```
   - - - - - O - -      - - - - - - - -      - - - - - - - -
   - - - - - - O O      - - - - - - - -      - - - - - - - -
   - - - - - - - O      - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - O      O - - - - - - -
   - - - - - - - -      - - - - - - O -      O O - - - - - -
   - - - - - - - -      - - - - - O O -      - - O - - - - -


   - - O - - - - -      - - - - - O O -      - - - - - - - -      - - - - - - - -
   O O - - - - - -      - - - - - - O -      - - - - - - - -      - - - - - - - -
   O - - - - - - -      - - - - - - - O      - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -      - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -      - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -      - - - - - - - O      O - - - - - - -
   - - - - - - - -      - - - - - - - -      - - - - - - O O      - O - - - - - -
   - - - - - - - -      - - - - - - - -      - - - - - O - -      - O O - - - - -
```

On the other hand, the following molecules are not enantiomers:

```
   - - - O O - - -      - O O - - - - -
   - - - O - - - -      - - O - - - - -
   - - O - - - - -      - - - O - - - -
   - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -
   - - - - - - - -      - - - - - - - -
```

because we discard translations and we discard rotations and symmetries
which do not apply to the 8×8 square.

In an enantiomer group, I define the "canonical molecule" as the molecule
with the smallest number when stored in the database, that is, the first
molecule of the group that is processed by the exploration programme.
This phrase has no equivalent in 3-D chemicals, but I need to give
a name to this concept. So it will be "canonical molecule".

Basic Projects
--------------

The programmes will explore the Black Box games in a 8×8 square with
4 atoms. This gives 635376 molecules. Yet, the number of atoms and the
size of the square are parameters, not hard-coded values. So the
same programmes will be able to explore Black Box games with 2 atoms in a 4×4 square.
There are only 120 molecules, so I will be able to thoroughly check the
programmes and their results.

In addition, some interesting results can appear when exploring molecules
with 4 atoms in a 6×6 square, or even in a 5×5 square.

A configuration will be identified by the An\_Bp code, where _n_ is the number of
atoms and _p_ is the size of the box. So the "normal" configuration will
have the key "A4\_B8".

The project includes several programmes.

1. The first programme is initialisation, which cleans up the contents of the
database for a given configuration.

2. The exploration programme, which generates all possible molecules for
a given configuration, computes the spectrum for each molecule and store
them into the database.

3. A programme summarising the findings of the exploration programme, extracting
the spectrums which appear in two molecules or more.

4. A programme updating the spectrums created by the previous programme, filling the
attributes that could not be computed before.

5. A programme extracting some molecules from the database and displaying
in a human-friendly fashion.

About the exploration programme: the programme will not process
all 635376 molecules in one go. It will be able to stop at any moment
and restart later from the point where it stopped.

Internal Implementation of a Game
---------------------------------

The 8×8 square with the atoms is implemented as a 2-D array,
with a line coordinate and a column coordinate. Lines and columns
are numbered 1-to-8. Why not start at 0? Because line 0 and column
0 are dedicated to the ray entry points and exit points, as well as
the additional line 9 and column 9. An atom is represented by a "heavy"
character, such as "O", "X" or "*", while an empty box is represented
by a "light" character, such as a space, a dot or a hyphen.
Actually, I have used the Emacs notation, with a "O" and an hyphen.

For the peripheral area (lines and columns 0 and 9), I will not use
Emacs' notation. Firstly, the rays which come out will be shown as
lower-caps letters, not 1-to-9 digits. A competitive player seldom
shoot all possible rays, so 1-to-9 is sufficient for nearly all competitive games.
But here, the exploration is based on shooting all possible rays.
The digits 1 to 9, or even 0 to 9, are not sufficient. Here is an
example (without "0"):

```
   8 2 1 H
 1 - - - - - - - -
 2 - - - O - - - -
 H - - O - O - - - H 
 3 - - - O - - - -
 4 - - - - - - - - 9 
 5 - - - - - - - - 5 
 6 - - - - - - - - 6 
 7 - - - - - - - - 7 
   8 3 4 H 9

There are 4 balls in the box
```
The game is rewritten as:

```
   h b a H n m k l
 a - - - - - - - - n 
 b - - - O - - - - m 
 H - - O - O - - - H 
 c - - - O - - - - j 
 d - - - - - - - - i 
 e - - - - - - - - e 
 f - - - - - - - - f 
 g - - - - - - - - g 
   h c d H i j k l

There are 4 balls in the box
```
As you can see, the upper-case "H" (for a "hit" ray) is not standing out of the
lower-case letters for coming-out rays. Same thing, for other spectrums,
for the "R" letter representing a reflected ray. I will use instead "@"
for hitting rays and "&" for reflected rays.

```
   h b a @ n m k l
 a - - - - - - - - n 
 b - - - O - - - - m 
 @ - - O - O - - - @ 
 c - - - O - - - - j 
 d - - - - - - - - i 
 e - - - - - - - - e 
 f - - - - - - - - f 
 g - - - - - - - - g 
   h c d @ i j k l

There are 4 balls in the box
```

When storing the data in the database and for some processes, the
8×8 square will be "linearised" as a 64-char line. Line 1 from the
original square will be stored in chars 0-to-7 of the 64-char line,
line 2 will be stored in chars 8-to-15 and so on, until line 8
which will be stored in chars 56-to-63.

In the same manner, the peripheral area (lines and columns 0 and 9)
showing the in- and out-positions of rays, are stored linearly
as a 32-char string. The traditional Black-Box game uses this
1-to-32 numbering scheme:

```
   3 3 3 2 2 2 2 2
   2 1 0 9 8 7 6 5
 1 - - - - - - - - 24
 2 - - - O - - - - 23
 3 - - O - O - - - 22
 4 - - - O - - - - 21
 5 - - - - - - - - 20
 6 - - - - - - - - 19
 7 - - - - - - - - 18
 8 - - - - - - - - 17 
   9 1 1 1 1 1 1 1
     0 1 2 3 4 5 6
```

The 32-char string will store the peripheral positions in the
same order. There is just a 1-bias for indexing, because the
`substr` function begins at 0.

Here is a simplified example in the A2\_B4 configuration,
that is with 2 atoms in a 4×4 box:


```
   @ & @ &
 @ O - O - @
 & - - - - c
 a - - - - a
 b - - - - b
   @ & @ c

There are 2 balls in the box
```

The linearised version will give the following two strings:

```
O-O-------------
@&ab@&@cbac@&@&@
```
In this example, we see:

- 3 rays which are absorbed as soon as they enter the box

- 1 ray absorbed after crossing an empty box

- 2 rays absorbed after crossing 3 boxes each

- 3 rays which are reflected as soon as they enter the box

- 1 ray reflected after crossing 3 boxes

- 2 rays which exit the box after crossing 4 boxes and without being deflected

- 1 ray which exits the box after crossing 3 boxes and being deflected once.

For reasons that will be explained later, this example is the 2nd tested
configuration in the A2\_B4 configuration.
Using JSON syntax, the database record will look like:

```
{ config: "A2_B4",
  number: 2,
  molecule: 'O-O-------------',
  spectrum: '@&ab@&@cbac@&@&@',
  absorbed-number:      6,
  absorbed-max-length:  3,
  absorbed-max-turns:   0,
  absorbed-tot-length:  7,
  absorbed-tot-turns:   0,
  reflected-number:     4,
  reflected-edge:       3,
  reflected-deep:       1,
  reflected-max-length: 3,
  reflected-max-turns:  0,
  reflected-tot-length: 3,
  reflected-tot-turns:  0,
  out-number:      3,
  out-max-length:  4,
  out-max-turns:   1,
  out-tot-length: 11,
  out-tot-turns:   1
}
```

First Optimisation
------------------

When I write that the programme will shoot all 32 possible rays, this is not
quite true. The rays follow the "invariant return path of light". If the
ray shot from position 1 comes out in position 24, then the ray shot from
position 24 will come out in position 1. For configuration A4\_B8, you need
to shoot only 18 to 28 rays. See the examples below: either 14 coming-out rays
and 4 absorbed rays, or 4 coming-out rays, 16 absorbed rays and 8 reflected rays.
These examples show a situation with the maximum number of out-coming rays
and a situation with the minimum number.

```
   h b a @ n m k l         & @ & c d @ @ @  
 a - - - - - - - - n     @ - O - - - - - - &
 b - - - O - - - - m     @ - - - - - - - O @
 @ - - O - O - - - @     @ - - - - - - - - &
 c - - - O - - - - j     a - - - - - - - - a
 d - - - - - - - - i     b - - - - - - - - b
 e - - - - - - - - e     & - - - - - - - - @
 f - - - - - - - - f     @ O - - - - - - - @
 g - - - - - - - - g     & - - - - - - O - @
   h c d @ i j k l         @ @ @ c d & @ &  

There are 4 balls in the box
```

Second Optimisation
-------------------

Using the symmetries and rotations of the 8×8 square, we see that each
molecule belongs to a group of usually 8 enantiomers. Sometimes, the group
contains only 4 enantiomers, or just 2. And very rarely, the molecule is alone
in its group (and so does not deserve the name "enantiomer").

Anyhow, once we have achieved the lengthy calculation of the spectrum
of a molecule, it is rather easy and fast to compute the spectrum of its
7 enantiomers (or 3 enantiomers, or its only 1 enantiomer). This allows us
to write 8 records (or 4, or 2) at once in the database instead of just one.

Let us use the previous example from the A2\_B4 configuration. So we computed:


```
   @ & @ &
 @ O - O - @
 & - - - - c
 a - - - - a
 b - - - - b
   @ & @ c

There are 2 balls in the box
```

After a 180-degree rotation, we obtain:

```
   c @ & @
 b - - - - b
 a - - - - a
 c - - - - &
 @ - O - O @
   & @ & @

There are 2 balls in the box
```

In a second step, we rename the out-coming rays, so when examined
in the usual order, they are alphabetically sorted. In this case,
the renaming is this:

```
    a → b
    b → a
    c → c

   c @ & @
 a - - - - a
 b - - - - b
 c - - - - &
 @ - O - O @
   & @ & @  

There are 2 balls in the box
```

Why this renaming? Because the letters "a" to "c" are just meaningless
labels, whose only purpose is to distinguish each out-coming ray from
the others. The three cases below are basically the same spectrum:

```
   c @ & @          c @ & @         b @ & @  
 b - - - - b      a - - - - a     c - - - - c
 a - - - - a      b - - - - b     a - - - - a
 c - - - - &      c - - - - &     b - - - - &
 @ - O - O @      @ - O - O @     @ - O - O @
   & @ & @          & @ & @         & @ & @  

There are 2 balls in the box
```

These are in essence the same spectrum.
But the programmes will see three different linearised strings:

```
bac@&@&@@&ab@&@c
abc@&@&@@&ba@&@c
cab@&@&@@&ac@&@b
```

This is why we rename the out-coming rays, so they appear
in alphabetical order along the peripheral area of the blackbox.

Instead of storing just one record into the database, we will
store simultaneously 8 of them. To tell a long story short,
here are two of them. In addition, I have stripped the statistics.

```
{ config: "A2_B4",
  number: 2,
  canonical-number: 2,
  molecule: 'O-O-------------',
  spectrum: '@&ab@&@cbac@&@&@',
  transform: 'id',
  [...]
}
{ config: "A2_B4",
  number: 0,
  canonical-number: 2,
  molecule: '-------------O-O',
  spectrum: 'abc@&@&@@&ba@&@c',
  transform: 'rot180',
  [...]
}
```
The `canonical-number` property is a link to the
first molecule of the enantiomers group. The `transform` property
is a reminder of which rotation or which symmetry gave the
current molecule, when applied to the canonical enantiomer. The `number`
property is initialised with value zero, but is filled
later when the exhaustive search comes upon the molecule.
At this time, the record will be updated to:

```
{ config: "A2_B4",
  number: 119,
  canonical-number: 2,
  molecule: '-------------O-O',
  spectrum: 'abc@&@&@@&ba@&@c',
  transform: 'rot180',
  [...]
}
```

Exhaustive Search of All the Molecules
--------------------------------------

In the exploration programme, the main loop extracts all 635376
molecules. So why bother about rotations and symmetries?
Actually, on each iteration, the programme begins by checking
whether the molecule is already in the database. If so, it just
fills the `number` property with the right value, updates the record
in the database and skip to the next iteration. If no, it computes
the full spectrum of the current molecule, looks for enantiomers,
compute the spectrum of each enantiomer and stores all that into
the database.

How do we find exhaustively the molecules?

I will illustrate this with a A6\_B4 configuration and by naming
the atoms "A" to "F", instead of the anonymous "O".
We begin with a molecule where all the atoms are packed on the left:

```
1 ABCDEF----------
```

For the next 10 iterations, the rightmost atom, or atom F, 
shifts to the right step by step:

```
2 ABCDE-F---------
3 ABCDE--F--------
4 ABCDE---F-------
     (...)
10 ABCDE---------F-
11 ABCDE----------F
```

At iteration 12, atom F can no longer move. So atom E shift one
step to the right and atom F comes back all the way to atom E.

```
12 ABCD-EF---------
```

The atom F again walks to the right, this time for only 9 iterations.

```
13 ABCD-E-F--------
     (...)
21 ABCD-E---------F
```

Again, atom E moves one step to the right and atom F leaps all the way
leftward to atom E.

```
22 ABCD--EF--------
```

The 8 steps rightward

```
23 ABCD--E-F-------
     (...)
30 ABCD--E--------F
```

At some moment, both atoms E and F are stuck to the right.

```
66 ABCD----------EF
```

When this happens, this is atom D's turn to move one step rightward
and both atoms E and F leap leftward to atom D.

```
67 ABC-DEF---------
```

It would appear that this could be implemented as embedded loops, the outer
one on atom A's position, the next one on atom B's position and so on until
the inner loop on atom F's position. This does not scale up. You must allow
for configurations with different numbers of atoms. And you can end with
code eligible for the
[Daily WTF](https://thedailywtf.com/articles/classic-wtf-the-great-code-spawn)
[website](https://thedailywtf.com/articles/just-a-few-questions).

But the description above shows rather a kind of transformation algorithm,
which takes one molecule and finds the next one. The algorithm is as follows:

1. Look for the rightmost `O-` substring.

2. If not found, rejoice! we have the very last molecule! the exhaustive search is over!

3. Split the molecule around the found `O-` substring.

4. Replace the `O-` substring with `-O`.

5. On the right of this substring, shift all `O`'s to the left.

Example with  `-O--O-O------OOO`

```
          111111
0123456789012345
-O--O-O------OOO
```

The `O-` substrings are at 1, 4 et 6. The interesting one is the substring
at 6. The sting is split thus:

```
                  111111
012345 // 67 // 89012345
-O--O- // O- // -----OOO
```

The substrings are modified in this way:

```
                  111111
012345 // 67 // 89012345
-O--O- // -O // OOO-----
```

And the pieces are gathered together:

```
          111111
0123456789012345
-O--O--OOOO-----
```

A counterintuitive step is how the 3 atoms are shifted to the left.
We do this with a `flip`. When using different names for the atoms,
the `flip` converts `-----DEF` to `FED-----` while we would expect
a transformation to `DEF-----`. But since the programmes will only use anonymous `O`'s,
while the `A` to `F` are used only in this descriptive text,
the `flip` function is the function to use.

Table of Spectrums
------------------

When the Molecules table is fully populated (for a given configuration),
we extract from this table all the spectrums that appear in two or more
records and we store them in a new table, Spectrums.

Example with a A4\_B6 configuration. We have these two molecules, with the
same spectrum:

```
   @ & @ & c d             @ & @ & c d
 @ O - O - - - @         @ - - O - - - @
 & - - - - - - &         & - - - - - - &
 @ - - O - - - @         @ O - O - - - @
 & - - - - - - b         & - - - - - - b
 @ O - - - - - @         @ O - - - - - @
 & - - - - - - a         & - - - - - - a
   @ a @ b c d             @ a @ b c d

There are 4 balls in the box
```

The Molecules table will contain:

```
{ config: "A4_B6",
  number: 868,
  canonical-number: 868,
  molecule: 'O-O-----------O---------O-----------',
  spectrum: '@&@&@&@a@bcda@b@&@dc&@&@',
  transform: 'id',
  [...]
}
{ config: "A4_B6",
  number: 15993,
  canonical-number: 7361,
  molecule: '--O---------O-O---------O-----------',
  spectrum: '@&@&@&@a@bcda@b@&@dc&@&@',
  transform: 'id',
  [...]
}
```

and the Spectrums table will contain:

```
{ config: "A4_B6",
  spectrum: '@&@&@&@a@bcda@b@&@dc&@&@',
  nb-mol: 2,
  transform: 'id',
  canonical-number: 868
}
```

Which means that for this spectrum, there are two molecules.

Why the `transform` and `canonical-number` attributes? When two asymmetrical molecules
form a spectral group, the same happens with their respective enantiomers.
So we have 8 spectrums which are rotations / symmetries of each other.
We may want to study one of them, but then we would be bored studying
the 7 other groups. By tagging one group with `transform: 'id',`
and the others with  `transform: 'rot180',` `transform: 'sym-h',`
and the like, we know which spectrums we need to study.

So with:

```
   @ & @ & c d             @ & @ & c d             c d b @ a @             c d b @ a @  
 @ O - O - - - @         @ - - O - - - @         a - - - - - - &         a - - - - - - 1
 & - - - - - - &         & - - - - - - &         @ - - - - - O @         @ - - - - - O 2
 @ - - O - - - @         @ O - O - - - @         b - - - - - - &         b - - - - - - &
 & - - - - - - b         & - - - - - - b         @ - - - O - O @         @ - - - O - - @
 @ O - - - - - @         @ O - - - - - @         & - - - - - - &         & - - - - - - &
 & - - - - - - a         & - - - - - - a         @ - - - O - - @         @ - - - O - O @
   @ a @ b c d             @ a @ b c d             c d & @ & @             c d & @ & @  

There are 4 balls in the box
```

we will have these two records in the Spectrums table:

```
{ config: "A4_B6",
  spectrum: '@&@&@&@a@bcda@b@&@dc&@&@',
  nb-mol: 2,
  transform: 'id',
  canonical-number: 868
}
{ config: "A4_B6",
  spectrum: 'a@b@&@cd&@&@@&@&@&@a@bdc',
  nb-mol: 2,
  transform: 'rot180',
  canonical-number: 868
}
```

How is the Spectrums table populated? First, we insert all spectrum records
without bothering with the `transform` column, which will be initialised with
a dummy value. This will be acheived by harnessing the power of the `group by`
SQL clause or of the MongoDB function `aggregate`.

Then, we fix the `transform` and `canonical-number` attributes. For this, the programme scans all
canonical molecules (`transform: 'id'`) whose spectrum exists in the
Spectrums table. Then the programme reads this spectrum record. If 
the spectrum record is not already updated, the programmes reads the
whole enantiomer group of the current molecule, and the corresponding
records from the Spectrums table, copies the `transform` and `canonical-number` values from the
molecule to the spectrum and updates the spectrum record.

Physical Implementation
-----------------------

Which kind of database? SQL or MongoDB? I began this work as a MongoDB
project.  Then, because  of  two problems  with  the existing  MongoDB
module, I  switched to SQLite,  while ensuring the MongoDB  code would
still  work.  And  after  the  SQLite  project  was  fully  functional
(including the update of the `Spectrums` table), I finally found a way
to bypass the  MongoDB module limitations and I  completed the MongoDB
version.

The first problem is that the Raku module for MongoDB does not
implement the full set of functionalities available for MongoDB.
For example, I do not know how to code in Raku a `≥` selection:

```
  { key: { '$gte': min-value }}
```

I can  only code `=`  selections. Likewise, I do  not know how  to ask
MongoDB  to sort  the  retrieved  documents. If  I  need  to sort  the
documents, I must do it within  the Raku programme. These problems did
not  hinder me  much when  writing the  exploration programme.  On the
other hand, it  was impossible to write a pure  Raku programme filling
the `Spectrums` collection.

The  other  problem  is  performances.  Here are  the  times  for  the
exploration programme using a MongoDB  backend, with various Black Box
configurations:

```
         nb_mol          real             user 
A4_B4      1820      2 min  2.201 s     2 min 46.945 s
A4_B5     12650     16 min 45.232 s    19 min 29.010 s
A4_B6     58905    132 min 22.944 s    94 min 55.280 s
```

With a SQLite backend and  before implementing `begin`/ `commit`, here
are a few timing results:

```
         nb_mol          real             user 
A4_B4      1820      0 min 47.436 s     0 min 21.424 s
A4_B5     12650      6 min 15.180 s     2 min 50.238 s 
```

The results with a `commit` every 50 updates:

```
         nb_mol          real             user 
A4_B4      1820      0 min 15.031 s     0 min 15.463 s
A4_B5     12650      2 min 16.277 s     2 min  0.199 s 
```

The results with a `commit` every 500 updates:

```
         nb_mol          real             user 
A4_B4      1820      0 min 19.017 s     0 min 18.053 s
A4_B5     12650      2 min  4.514 s     1 min 56.635 s 
A4_B6     58905     26 min 39.339 s    21 min 40.528 s
```

Programming with Raku
---------------------

This is not my first Raku project, so I did not need to install
Raku. If you need to install it, maybe you should take a look at
[the documentation of this previous project](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Description/description-en.pod),
especially the chapter about
[compiling Raku](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Description/description-en.pod#Compilation-and-Installation-of-Rakudo)
and the chapter about
[using Raku](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Description/description-en.pod#usage).

Programming with Raku and SQLite
--------------------------------

I had a few problems when developing the SQLite version.
First, kebab case. In Raku, kebab case is usually preferred 
to snake case and to camel case, and it is compatible with
JSON/BSON and MongoDB. But you cannot use kebab case for SQLite
column names. So there was no immediate link between the
`canonical_number` column name and the `canonical-number` hash
key. Of course, you can use the translitteration of underscores
to dashes, but at first I did not think of that when I wrote the
first version of the `select` statements.

The problem did not appear at first, because it was hidden behind
another problem the syntax of `insert` statements. The first version
of the main `insert` statement looked like:

```
  $dbh.execute(q:to/SQL/
  insert into Molecules
            ( config
            , number
            , canonical_number
            [...]
            , dh2)
     values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
SQL
            , $molecule<config                  >    
            , $molecule<number                  >
            , $molecule<canonical-number        >
            [...]
            , $molecule<dh2                     >
            );
```

with all 23 column names, with 23 question marks for bind values
and the 23 Raku values used for the binding. You may
notice that underscores in the column names are replaced by
dashes in the Raku values, among other edits. The problem is that
you have to specify all 23 column names and all 23 Raku values,
without the convenient way of using a hash variable. Maybe there is
a trick in the DBIish module which I have not seen and which would
allow me to use a hash table.

In the second version of the `insert` statement, I generated the list of
database columns and the list of question marks and I interpolated them
into the SQL statement. This is not a
[Bobby Tables](https://xkcd.com/327/)
[issue](https://bobby-tables.com/).
The interpolated strings are fully controlled by the programme maintainer.
They do not come from user input or from an external source.
And this helps with the DRY principle (Don't Repeat Yourself).

The last problem is a bit ironical. There is a missing feature in MongoDB
which is implemented in SQL: consistent updates, aka database transactions. This is done with `begin
transaction` and `commit transaction` in SQLite or similar statements in
other SQL dialects. So I coded a way to bypass this problem, which would
be necessary in MongoDB and superfluous in SQLite. On one hand, this
bypass measure was unnecessary in MongoDB, on the other hand it was buggy
with SQLite.

When I run the exploration program a second or a third time, why do I need
to delete and recreate the last enantiomer group created in the previous run?
Here is my reasoning before writing the programmes.
It may have happened, in the previous run, that `Ctrl-C` took effect
when some molecules documents of the group, but not all, have been inserted
into the database. Yet, it is necessary that each enantiomer group is stored
in the database as a whole. This prerequisite is easy to implement in SQLite,
with `begin transaction` / `commit transaction`, but there is no consistency
mechanism in MongoDB. So at the start of the second or subsequent run, I extract
the maximum value of `number` from the database. If this is the number of a
canonical molecule, the program deletes the whole enantiomer group (sometimes
a full group, some times an incomplete group) and rebuilds it in full.

On one hand, this precaution was not required for MongoDB. In MongoDB,
I execute a bulk insert, by giving an array of 8 documents to the `insert`
statement. During my tests, I have never seen a partial enantiomer group
in which the programme would have had time to insert, for example, only
two documents before being interrupted by `Ctrl-C`. Each time, the
last created enantiomer group was a complete one.

On the other hand, the first SQLite version did not include
`begin transaction`/ `commit transaction` statements. And the programme
would run `insert` statements on single molecules, I did not know that SQLite could do
[`bulk insert`](https://www.educba.com/sqlite-bulk-insert/).
There was one test in which the group identified by `canonical-number = 2`
was fully created and the group identified by `canonical-number = 3`
was incomplete, with two molecules in the database and the six other dropped.
Especially, the canonical molecule identified by `number = 3` was missing.
When I relaunched the exploration programme, the search for the maximum value
of `number` gave 2, not 3. So the enantiomer group identified by `canonical-number = 2`
was deleted and created again, then the enantiomer group identified by `canonical-number = 3`
was created, without considering the two already existing molecules.
Therefore, an inconsistent enantiomer group with 10 molecules, including 2 duplicates.

How can I fix it? There are at least three ways:

- Retrieve not only the maximum value of `number`, but also the maximum value
of `canonical-number`. In the example above, the program would have obtained a 2 and a 3
and it would have removed the enantiomer group identified by `canonical-number = 3` while
leaving alone the enantiomer group identified by `canonical-number = 2`.

- Ensure that the canonical molecule of the enantiomer group is the first one
to be inserted in the database. In this case, the extraction of the maximum value
of `number` would have given a 3 and the deleted group would have been the one
identified by `canonical-number = 3`.

- Add  `begin transaction` / `commit transaction` to the exploration programme
and ensure there will be no `commit transaction` before an enantiomer group is
complete.

Since I already had the intention to add `begin transaction` / `commit transaction`,
I did not tried the other fixes.

Programming with Raku and MongoDB
---------------------------------

As stated above, this is not my first Raku+MongoDB project, so the software was
already installed. If you need to install them, please see
[the documentation of said project](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Description/description-en.pod).
Be sure to read the paragraphs on
[prerequisite installation](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Description/description-en.pod#installing-rakudo-modules)
(do not bother with Bailador and Templace::Anti), on
[installing the MongoDB software](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Description/description-en.pod#installing-mongodb)
and [installing the MongoDB Raku module](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Description/description-en.pod#installation-of-the-mongodb-module).

I have explained how the features missing from the MongoDB module
made me develop the SQLite version. Yet, I did not try to find a solution
to nevertheless use these advanced MongoDB features. If the `aggregate` function
is available in the Mongo shell, but not in the `MongoDB` Raku module, I build
a Mongo shell (or JavaScript) source which extracts the data and aggregates them,
I run this Mongo shell programme as an external process, I gather the standard output
and I store it into a Raku variable.

You should notice that, when building the Mongo shell source, I need to mention
the `An_Bp` value of the configuration in this source. Unlike what I explained in
the SQLite chapter, this is really a
["Bobby Tables"](https://xkcd.com/327/)
[problem](https://bobby-tables.com/),
because the `An_Bp` value is specified by the user.
So the programme filters, examines, checks, sanitises and validates the value
with a very restrictive regex: an anchor at both ends, to ensure the whole value
is checked, only 3 literal chars `A_B` and the digits `0` to `9`, with a limited
number of occurrences (no more than 99 atoms and the box not larger than 9×9).

Once, when running the programme building the `Spectrums` collection, I encountered
an error, because of insufficient memory to process and aggregate all the
`Molecules` documents. As explained by the error message, overcoming this limit
is rather simple, you just have to add a proper index to the `Molecules` collection.
Therefore the `add-index-mongo.sh` script.

Programming with Raku, SQLite and MongoDB
-----------------------------------------

The programmes are split in a fashion similar to the MVC principle (Model,
View, Controller). For example, to display a molecule or a list of molecules,
you have:

1. The `display-sql.raku` programme, which contains the model (invoking
the `DBIish` Raku module and the SQLite database access functions) and the
parameter parsing (in the `MAIN` multi-sub).

2. The `display-mongo.raku` programme, which contains too the model (invoking
the various `MongoDB::xx` Raku modules and the MongoDB database access functions) and the
parameter parsing (in the `MAIN` multi-sub).

3. The `lib/display-common.rakumod` module, which contains the controller (the
internal logic of the process) and the view (to format and display the data).

When initialising the `Spectrums` table / collection, the process logic is very
basic: first deleting any existing records / documents, then creating all
the records / documents in a single database access. So, there is no module
for this step, only the two programmes.

When a programme calls a function defined in the module, this is very basic.
The necessary module functions are flagged with `is export`, calling these
functions is straightforward. When the module calls a function defined in the
programme, it is a bit more difficult. The main programme has initialised a
dispatch table and this dispatch table is transmitted as a parameter to each
function in the module which needs it.

Conclusion
==========

I write this conclusion after running my programmes on the A4\_B6 configuration.
I have not yet run the programmes on the A4\_B8 standard configuration, but
the findings on the A4\_B6 configuration are interesting and in most cases can
be extended to the A4\_B8 configuration.

Before starting to develop this project, I knew of two ambiguous spectrums
(actually 16 spectrums, because of symmetries and rotations). Each one would
lead to two molecules. So I was expecting to find several other spectrums with
2 molecules, a few ones with 3 molecules and possibly, but hardly probably, one
spectrum with 4 molecules (actually 8 spectrums because of symmetries and rotations).

Here is what I found with configuration A4\_B6:
```
number of molecules     spectrums       spectrums       molecules
for each spectrum     w/o  rot / sym  with rot / sym  with rot / sym
       2                    89            696             1392
       3                     6             36              108
       4                     4             24               96
       5                     1              8               40
total                      100            764             1636
```
I checked the spectral groups with 4 or 5 molecules and I found they
can easily be extrapolated to the A4\_B8 configuration, by inserting
two empty lines and two empty columns at the right place. I think this
is the case also for most spectral groups with 2 or 3 molecules.
It may also happen that the A4\_B8 will give a few more ambiguous cases,
with no corresponding case in the A4\_B6 configuration, but in my opinion,
this will be very rare.

Anyhow, we can suppose that the A4\_B8 configuration will provide at least
750 spectrums and 1600 molecules leading to ambiguity. I did not expect
such a big number.

Also, up to now, I had only found spectral groups where the molecules
would differ by only one atom, that is, which would give a 5-point penalty
to the player. With the programmes, I have found a few spectral groups where
two molecules differ by two atoms, for a 10-point penalty.

About statistics on the lengths of paths and the number of turns, we cannot
extrapolate the A4\_B6 findings to the A4\_B8 configuration. But this is
a secondary topic. The main purpose of the project is reached with the A4\_B6 configuration.

License
=======

This text is licensed under the terms of Creative Commons, with
attribution and share-alike (CC-BY-SA).


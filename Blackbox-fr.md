-*- encoding: utf-8; indent-tabs-mode: nil -*-

Présentation
============

Ce projet est une exploration exhaustive
du jeu Black Box avec 4 atomes. Ce n'est pas
une _n_+1 ème implémentation du jeu. Pour jouer à Black Box,
j'utilise soit Emacs, soit la collection de
jeux de Simon Tatham.

But principal du projet
-----------------------

[Black Box](https://fr.wikipedia.org/wiki/Black_Box_(jeu))
est un jeu de déduction dans lequel
le joueur "codeur" place 4 ou 5 atomes dans
une boîte noire et où le joueur "décodeur" tente
de les localiser en lançant des rayons depuis
la périphérie de cette boîte noire.
C'est aussi un jeu de hasard dans la mesure
où certaines configurations d'atomes
sont complètement indiscernables par le décodeur,
même s'il a utilisé toutes les possibilités
pour lancer les rayons. Un exemple très connu est
cette configuration à 5 atomes.


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

Il est facile de localiser les 4 atomes
symbolisés par "O". Mais le cinquième
est situé dans l'une des quatre positions
marquées d'un point d'interrogation et
aucun rayon ne peut interagir avec ce
cinquième atome. Le décodeur est alors obligé
de proposer une réponse au hasard, avec une chance
sur quatre de trouver la bonne réponse et trois
chances sur quatre d'avoir un malus de cinq points.

Il existe d'autres situations indiscernables
avec 5 atomes, telle
[cette situation](https://boardgamegeek.com/thread/1621945/spoilers-game-80-has-two-valid-solutions)
exposée dans une discussion sur
Board Game Geek. L'opinion générale est
que ce genre de situation indiscernable
peut apparaître dans le jeu à 5 atomes, mais
pas dans le jeu à 4 atomes. C'est faux. Il existe des
situations indiscernables à 4 atomes, ainsi
que je l'ai exposé dans ma réponse à la
discussion sus-mentionnée.

Pour l'instant, dans le cadre du jeu à 4 atomes,
je ne connais que des cas où les situations
indiscernables vont 2 par 2. Le but de ce projet est de voir
s'il existe des cas plus complexes avec 3 ou 4 situations
indiscernables. Le projet passe en revue toutes les façons
de disposer les atomes à l'intérieur de la boîte, détermine
les résultats de tous les rayons et détermine ainsi
quelles sont les configurations d'atomes qui donnent
les mêmes résultats pour les rayons.

Post-scriptum : pendant le développement du programme
d'exploration, et _avant_ de le lancer pour la configuration
avec 4 atomes dans un carré 8×8, ou même pour toute configuration
dans un carré plus grand que 4×4, j'ai trouvé par réflexion
ce cas de figure :

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

(H = absorbé, R = réfléchi) Essayez de le décoder...


But secondaire
--------------

Voici quatre parties jouées avec la variante Emacs de Black Box.

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

Comme vous pouvez le voir, dans chacune de ces parties, un rayon
a été dévié à plusieurs reprises avant de ressortir (dans trois cas)
ou d'être réfléchi (dans le quatrième cas).

Un but annexe du projet est de rassembler des statistiques sur
les rayons : longueur du chemin, nombre de déviations,
pour savoir s'il est fréquent d'avoir des situations
aussi complexes.

On peut d'ores et déjà penser que le nombre maximal de
déviations est 6 et la longueur maximale est 23, avec la situation suivante :

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

Néanmoins, le programme d'exploration calculera les statistiques
pour chaque situation, pour confirmer ou infirmer cette supposition.

Troisième but
-------------

Jusqu'à présent, lorsque je devais écrire du texte, mon format
préféré était le POD de Perl. J'ai décidé d'essayer autre chose.
Et ce texte est ainsi écrit en Markdown.

Organisation du développement
=============================

Vocabulaire
-----------

Le contenu de la boîte noire comporte plusieurs atomes.
Nous appellerons donc ce contenu une _molécule_.

De la même manière, tous les 32 rayons lancés depuis les 32 positions périphériques
de Black Box sont réunis sous le terme _spectre_.

La métaphore a ses limites. Dans la vraie vie, un spectre est tout un tas
de rayons sur une large plage de longueurs d'onde. Ici, un spectre est tout un
tas de rayons sur une large plage de positions géométriques.

Avec ces précisions de vocabulaire, le but principal de ce projet
est donc de trouver deux molécules différentes avec le même spectre.

Dans notre monde réel en 3-D, pour une molécule asymétrique donnée, on appelle énantiomère
l'image miroir de cette molécule. Dans le monde abstrait 2-D de Black Box,
j'utilise le terme "énantiomère" pour désigner une molécule obtenue à partir de la
première par une rotation autour du centre du carré, ou bien une symétrie par rapport
à une diagonale ou une médiane du carré.

Par exemple, pour la molécule initiale suivante

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

les 7 énantiomères sont :


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

En revanche, les molécules suivantes ne sont pas des énantiomères :

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

car on exclut les translations et on exclut les rotations et symétries qui ne sont pas
des rotations ou symétries du carré 8×8.

Dans un groupe d'énantiomères, je définis la "molécule canonique" comme étant
celle qui est identifiée par le plus petit numéro, c'est-à-dire la première
à être traitée par le programme d'exploration. Ce terme n'a pas de correspondance
dans le monde réel de la chimie 3-D, mais il en faut en pour mon projet
Black Box. Donc ce sera "molécule canonique".

Découpage en projets élémentaires
---------------------------------

Les programmes permettront d'explorer les parties de Black Box
avec une molécule de 4 atomes dans un carré 8×8. Cela représente
635376 molécules. Le nombre d'atomes et la taille du carré
ne seront pas des valeurs en dur, mais des paramètres.
Ainsi, il sera possible d'effectuer par exemple une exploration des
parties avec des molécules de 2 atomes dans un carré 4×4. Il n'y a que 120 possibilités,
ce qui fait qu'il est possible de vérifier les résultats intégraux.

Également, il est possible que certaines molécules
ambiguës du jeu 8×8 apparaissent dans le jeu 6×6, voire
dans le jeu 5×5.

Une configuration simplifiée sera identifiée par un code An\_Bp, où _n_ est le nombre
d'atomes et _p_ la longueur d'un côté de la boîte ("A" pour "atomes",
"B" pour "Black Box" ou pour "boîte"). Ainsi, la configurations "normale"
sera identifiée par "A4\_B8".

Le projet est divisé en deux parties. Un premier programme
examine les 635376 molécules, calcule leur spectre et les stocke
dans une base de données. Dans la deuxième partie,
quelques programmes accèdent à la base de données
et génèrent des fichiers textes ou des pages web affichant les données sous
forme synthétique. Le premier programme ne traitera pas
les 635376 molécules d'une traite. Il pourra
s'interrompre à n'importe quel moment et reprendre
là où il s'était arrêté.

Représentation interne d'une partie
-----------------------------------

Le carré 8×8 contenant les atomes sera représenté
par un tableau à deux coordonnées ligne
et colonne, chaque coordonnée variant
de 1 à 8. Pourquoi ne pas commencer à 0 ?
Parce que la ligne 0 et la colonne 0 sont
réservées aux marques d'entrée et de sortie
des rayons, tout comme la ligne 9 et la
colonne 9. Un atome est représenté par un
caractère "lourd", comme un "X", un "O" ou une
"*", une case vide par un caractère "léger",
comme un espace, un point, voire un tiret.
En fin de compte, j'ai pris la notation d'Emacs,
avec des "O" et des tirets.

Pour la périphérie (colonnes et lignes 0 et 9), je n'utiliserai pas la
notation de la version Emacs de Black Box. Tout d'abord, les rayons
qui ressortent seront représentés par des lettres minuscules, pas par
les chiffres 1 à 9. Pour une partie compétitive, il est rare de lancer tous
les rayons possibles et d'avoir ainsi plus de 9 rayons ressortant de
la boîte, donc les chiffres de 1 à 9 sont suffisants. En revanche, mon
programme d'exploration systématique lance tous les rayons possibles.
Les 9 chiffres sont insuffisants pour certaines spectres. Et
même si l'on ajoute le "0", cela reste insuffisant. Exemple (sans le "0") :

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
Réécrivons cette partie ainsi :

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

Ensuite, le "H" pour "hit" et, dans d'autres spectres,
le "R" pour "reflected" ou pour "réfléchi" sont difficiles à distinguer
des lettres minuscules. Je remplacerai donc les "H" et les "R" par
"@" et "&" respectivement.

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

Pour le stockage en base de données et pour
certains traitements, le carré sera "linéarisé"
en une chaîne de caractères de longueur 64,
les caractères étant en positions 0 à 63.
Ainsi, la ligne 1 sera stockée dans les
caractères 0 à 7, la ligne 2 dans les caractères
8 à 15 et ainsi de suite, jusqu'à la ligne 8 stockée
dans les caractères 56 à 63.

Par ailleurs, les lignes et colonnes 0 et 9,
indiquant les points d'entrée et de sortie
des rayons, sont stockées linéairement dans une autre
chaîne de caractères, sur 32 positions. Traditionnellement,
les positions d'entrée et de sortie sont numérotés de 1 à 32
ainsi :


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

Les 32 positions seront linéarisées dans le même ordre.
Il y aura juste un décalage d'une unité pour le numéro
pour aboutir à un numéro de 0 à 31,
car la fonction `substr` compte à partir de 0.

Exemple dans la configuration A2\_B4, c'est-à-dire avec un carré 4×4 et 2 atomes :

```
   @ & @ &
 @ O - O - @
 & - - - - c
 a - - - - a
 b - - - - b
   @ & @ c

There are 2 balls in the box
```

La version linéarisée donne les deux chaînes suivantes :

```
O-O-------------
@&ab@&@cbac@&@&@
```

Dans cet exemple, on peut voir :

- 3 rayons absorbés dès l'entrée

- 1 rayon absorbé après avoir traversé une case vide

- 2 rayons absorbés après avoir traversé 3 cases vides chacun

- 3 rayons réfléchis dès l'entrée

- 1 rayon réfléchi après avoir traversé 3 cases vides

- 2 rayons qui ressortent après avoir traversé 4 cases et sans avoir été déviés

- 1 rayon qui ressort après avoir traversé 3 cases et après avoir été dévié une fois.

Pour des raisons qui apparaîtront dans la suite du texte, cet exemple est la deuxième
molécule testée dans la configuration A2\_B4.
L'enregistrement de la base de données, en syntaxe JSON, ressemble à :

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

Première optimisation
---------------------

Lorsque j'écris que le programme lance les 32 rayons possibles,
ce n'est pas tout-à-fait vrai. Les rayons suivent ce que l'on
appelle la "loi du retour inverse de la lumière". Si le rayon
lancé en 1 sort en 24, alors pour la même molécule, le
rayon lancé en 24 sera ressorti en 1. Pour la configuration A4\_B8,
il suffira de lancer entre 18 et 28 rayons. Les exemples
ci-dessous montrent que l'on peut avoir 14 rayons sortants
plus 4 rayons absorbés, ou bien 4 rayons sortants, plus 16
rayons absorbés et 8 rayons réfléchis.

Voici des exemples pourla situation avec un maximum de rayons
qui sortent et pour la situation inverse.

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

Deuxième optimisation
---------------------

En faisant jouer les symétries et les rotations
du carré, on voit que chaque molécule
appartient en général à un groupe de 8 énantiomères.
Parfois, le groupe n'aura que 4 énantiomères,
ou 2, voire une seule molécule qui ne mérite plus l'appellation "énantiomère".

Toujours est-il que si l'on a (laborieusement) calculé
ce que donnent tous les rayons pour une molécule chirale,
il est facile et rapide de déterminer ce que donnent les rayons
pour les 7 énantiomères (ou pour les 3 autres, ou pour l'autre).
Ainsi, au lieu d'écrire un seul enregistrement dans la base de données,
on en écrit 8 (ou 4, ou 2) en une seule fois.

Reprenons l'exemple de la configuration A2\_B4.  Ainsi donc on a calculé :

```
   @ & @ &
 @ O - O - @
 & - - - - c
 a - - - - a
 b - - - - b
   @ & @ c

There are 2 balls in the box
```

Avec une rotation de 180 degrés, on a :

```
   c @ & @
 b - - - - b
 a - - - - a
 c - - - - &
 @ - O - O @
   & @ & @

There are 2 balls in the box
```

Dans un deuxième temps, on renomme les rayons sortants, de façon qu'ils
soient nommés dans l'ordre où ils apparaissent sur la périphérie. Dans le
cas présent, le renommage est :

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

Pourquoi cette étape de renommage ? Parce que les lettres "a" à "c"
sont simplement des étiquettes arbitraires, destinées à différencier
chaque rayon de chaque autre. Ainsi, ces
trois schémas représentent le même spectre :

```
   c @ & @          c @ & @         b @ & @
 b - - - - b      a - - - - a     c - - - - c
 a - - - - a      b - - - - b     a - - - - a
 c - - - - &      c - - - - &     b - - - - &
 @ - O - O @      @ - O - O @     @ - O - O @
   & @ & @          & @ & @         & @ & @

There are 2 balls in the box
```

Ce sont intrinsèquement le même spectre. Mais les
programmes voient trois chaînes linéarisées différentes :

```
bac@&@&@@&ab@&@c
abc@&@&@@&ba@&@c
cab@&@&@@&ac@&@b
```

C'est pour cela que l'on renomme les rayons, de façon qu'il
apparaissent par ordre alphabétique le long de la périphérie
de la boîte noire, selon le parcours conventionnel.

Au lieu de stocker un seul enregistrement en base de données, on en
stockera 8. Pour rester bref, j'en présente deux ci-dessous et j'ai retiré
les statistiques.

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
La propriété `canonical-number` est un pointeur vers la première
molécule du groupe de 8 énantiomères. La propriété `transform` permet
de savoir quelle rotation ou quelle symétrie a donné la présente molécule
à partir de l'énantiomère canonique. Et la propriété `number`
sera alimentée ultérieurement, lorsque la recherche exhaustive
trouvera la molécule correspondante. On aura alors :

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


Recherche exhaustive de toutes les molécules
---------------------------------------------

La boucle principale du programme d'exploration extrait
les 635376  molécules. Alors, à quoi cela a-t-il servi de
calculer les rotations et les symétries ? À chaque
itération, le programme teste si la molécule à traiter
existe déjà dans la base de données. Si oui, il fait
une rapide mise à jour de l'enregistrement associé
pour attribuer la bonne valeur à la propriété `number`
et il passe à la molécule suivante. Dans la
négative, il calcule le spectre complet de la molécule,
cherche les énantiomères, calcule le spectre de chacun
et stocke tout cela dans la base de données.

Comment trouve-t-on la liste exhaustive des
molécules ?

Je vais illustrer cela avec une configuration A6\_B4
et en me basant sur la représentation linéaire et en
attribuant des codes différents à chaque atome.
On commence par la molécule avec tous les
atomes à gauche :

```
1 ABCDEF----------
```

Pendant les 10 itérations suivantes, l'atome
plus à droite, l'atome F, se décale d'une position à chaque fois

```
2 ABCDE-F---------
3 ABCDE--F--------
4 ABCDE---F-------
     (...)
10 ABCDE---------F-
11 ABCDE----------F
```

L'atome de droite ne peut plus avancer. Alors
c'est l'atome E qui avance et l'atome F revient coller à l'atome E.

```
12 ABCD-EF---------
```

Puis l'atome F reprend sa progression, cette fois-ci pendant 9 itérations.

```
13 ABCD-E-F--------
     (...)
21 ABCD-E---------F
```

De nouveau, un pas de E vers la droite et un bond de F vers la gauche

```
22 ABCD--EF--------
```

Puis 8 pas de F vers la droite

```
23 ABCD--E-F-------
     (...)
30 ABCD--E--------F
```

Arrive un moment où E et F sont tous deux bloqués sur la droite

```
66 ABCD----------EF
```

À ce moment-là, c'est D qui avance d'un pas vers la droite et c'est E et F
qui bondissent tous les deux vers la gauche.

```
67 ABC-DEF---------
```

On pourrait croire que cela pourrait être implémenté avec des boucles
emboîtées, la boucle extérieure sur toutes les positions possibles de l'atome
A, la boucle suivante sur les positions possibles de l'atome B et ainsi
de suite jusqu'à la boucle interne sur les positions de l'atome F.
Mais le programme est censé fonctionner pour des configurations avec
des nombres d'atomes différents. Il est probable que l'on aboutirait
à un code digne de figurer dans le 
[site web](https://thedailywtf.com/articles/classic-wtf-the-great-code-spawn)
[Daily WTF](https://thedailywtf.com/articles/just-a-few-questions).

La description que j'ai donnée ressemble plus à un algorithme
de transformation, qui prend une molécule et en déduit la molécule
suivante. L'algorithme est le suivant :

1. Rechercher la sous-chaîne `O-` la plus à droite.

2. Si la sous-chaîne `O-` n'apparaît pas dans la molécule, youpi ! on est
sur la dernière molécule ! l'extraction est terminée !

3. Découper la molécule de part et d'autre de la sous-chaîne `O-`

4. La sous-chaîne `O-` est remplacée par `-O`

5. À droite de cette sous-chaîne, tous les `O`sont rassemblés à gauche.

Exemple avec `-O--O-O------OOO`

```
          111111
0123456789012345
-O--O-O------OOO
```

Les sous-chaînes `O-` sont en 1, 4 et 6. Celle qui nous intéresse est
en 6. On découpe la molécule ainsi :

```
                  111111
012345 // 67 // 89012345
-O--O- // O- // -----OOO
```

On modifie les sous-chaînes ainsi :

```
                  111111
012345 // 67 // 89012345
-O--O- // -O // OOO-----
```

Et on recolle l'ensemble

```
          111111
0123456789012345
-O--O--OOOO-----
```

Un point paradoxal est le décalage des trois atomes vers la gauche.
Ce décalage se fera par un `flip`. Lorsque l'on utilise des noms
différenciés pour les atomes, cela conduit à convertir
`-----DEF` en `FED-----`, alors que l'on attendait plutôt
une conversion vers `DEF-----`. Mais puisque les programmes
utilisent des `O` anonymes  et que les noms de `A` à `F`
ne sont utilisés que dans le présent texte, le `flip` convient
parfaitement.

Table des spectres
------------------

Lorsque la table des molécules est complètement remplie (pour
une configuration donnée), nous extrayons de cette table les
spectres qui apparaissent pour deux molécules ou plus et nous
les stockons dans une nouvelle table, la table Spectrums des spectres.

Example avec une configuration A4\_B6. Nous avons ces deux molécules,
avec des spectres identiques :

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

La table Molecules contient alors :

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

et la table Spectrums contient :

```
{ config: "A4_B6",
  spectrum: '@&@&@&@a@bcda@b@&@dc&@&@',
  nb-mol: 2,
  transform: 'id',
  canonical-number: 868
}
```

ce qui veut dire que pour ce spectre, nous avons deux molécules.

Pourquoi cet attribut `transform` ? Quand deux molécules asymétriques
forment un groupe spectral, il en va de même avec leurs énantiomères
respectifs. Nous avons donc 8 groupes spectraux qui se déduisent les uns
des autres par rotation ou par symétrie. Nous voulons bien en étudier un
en détail, mais les autres ne nous intéressent pas. Donc en étiquetant
l'un de ces spectres avec  `transform: 'id',`
et les autres avec  `transform: 'rot180',` `transform: 'sym-h',`
et ainsi de suite, nous savons quels sont les spectres qu'il faut
examiner pour avoir un aperçu complet.

Ainsi, avec les quatre molécules :

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

cela génère deux enregistrements dans la table Spectrums :

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

Concrètement, comment la table Spectrums est-elle alimentée ?
Dans un premier temps, on crée tous les enregistrements sans s'intéresser
au champ `transform`, qui sera provisoirement alimenté avec une valeur
bidon. Cela se fait en mettant à profit la puissance de la clause `group by` en
SQL ou de la fonction  `aggregate` de MongoDB.

Ensuite, on rectifie le champ `transform`. Pour ce faire, le programme
extrait toutes les molécules canoniques (`transform: 'id'`) associées à
un spectre de la table Spectrums. Puis le programme lit ce spectre.
S'il n'a pas encoré été modifié, alors le programme lit le groupe d'énantiomères
complet de la molécule traitée, lit les spectres correspondants dans la
table Spectrums, copie le champ `transform` de chaque molécule vers le spectre
associé et modifie cet enregistrement.


Implémentation physique
-----------------------

Quelle base de données ? Une base SQL ou MongoDB ? J'écris ces mots
alors que le programme d'exploration fonctionne parfaitement avec
MongoDB et pourtant, la question continue à se poser.
Il y a deux problèmes avec MongoDB.

Le premier problème est que le module Raku
pour MongoDB n'implémente pas toutes les options disponibles avec
MongoDB. Par exemple, je ne sais pas comment faire des
sélection du type `≥` :

```
  { cle: { '$gte': valeur-min }}
```

On ne peut faire que des sélections de type `=`, pas des comparaisons
par inégalités ou par intervalle. De même, pour trier le résultat d'une
recherche, il faut le faire dans le programme Raku, il n'y a pas moyen de
demander à MongoDB de trier les documents extraits avant de les transmettre
au programme Raku. Cela ne m'a pas trop gêné pour le programme d'exploration,
cela risque de poser plus de problèmes pour les programmes d'affichage (qui
ne sont pas encore écrits).

Le deuxième problème, peut-être, est un problème de performances. Voici les
temps relevés pour diverses configurations, avec un stockage dans MongoDB. 

```
         nb_mol          real             user 
A4_B4      1820      2 min  2,201 s     2 min 46,945 s
A4_B5     12650     16 min 45,232 s    19 min 29,010 s
A4_B6     58905    132 min 22,944 s    94 min 55,280 s
```

Peut-être que SQLite sera plus rapide. Ou peut-être pas. Il faut essayer.
Je ne vais pas supprimer le code MongoDB pour le remplacer par du
code SQLite. Je vais m'arranger pour faire cohabiter les deux.
Ainsi, si quelqu'un d'autre est intéressé par mon code, il pourra
choisir une base de données SQLite ou une base de données MongoDB.

Post scriptum : la version SQLite est opérationnelle. Voici les
résultats avant mise en place des `begin` / `commit`.

```
         nb_mol          real             user 
A4_B4      1820      0 min 47,436 s     0 min 21,424 s
A4_B5     12650      6 min 15,180 s     2 min 50,238 s 
```

Les résultats avec des `commit` toutes les 50 mises à jour.

```
         nb_mol          real             user 
A4_B4      1820      0 min 15,031 s     0 min 15,463 s
A4_B5     12650      2 min 16,277 s     2 min  0,199 s 
```

Les résultats avec des `commit` toutes les 500 mises à jour.

```
         nb_mol          real             user 
A4_B4      1820      0 min 19,017 s     0 min 18,053 s
A4_B5     12650      2 min  4,514 s     1 min 56,635 s 
A4_B6     58905     26 min 39,339 s    21 min 40,528 s
```

Problèmes avec SQLite
---------------------

J'ai eu quelques problèmes lors du développement de la version SQLite.
Tout d'abord, le _kebab case_. Le _kebab case_ est le style privilégié
en Raku et est compatible avec JSON/BSON et MongoDB. En revanche, il est
interdit dans les noms de colonnes en SQLite, pour lesquels il vaut mieux
utiliser le _snake case_.  Ainsi, il n'était pas immédiat de faire le
lien entre la colonne SQLite `canonical_number` et la clé de hachage
`canonical-number`. Bien sûr, il est possible de convertir les soulignés
en tirets, mais je n'y ai pas pensé lorsque j'ai codé les instructions `select`.

Je n'ai pas constaté ce problème dès le début, car il était masqué par
un autre problème, la syntaxe des instructions `insert`. Dans la première
version, l'instruction `insert` pour la table `Molecules` était
codée ainsi :

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

avec les 23 noms de colonnes, 23 points d'interrogation pour
les valeurs à substituer et les 23 valeurs substituées. Vous pouvez
remarquer que les soulignés des noms de colonnes sont remplacés par
des tirets dans les valeurs Raku, entre autres adaptations. Les lectures `select`
peuvent produire des hachages, les écritures `insert` nécessitent de tout
écrire explicitement. Ou alors, il y a une astuce que je n'ai pas vue
dans le module DBIish et qui me permettrait d'avoir recours à une table de hachage.

Remarque : dans la deuxième version de l'instruction `insert`, la liste des colonnes
et la liste de points d'interrogation ont été générées par programme et insérées
dans l'instruction SQL. Il ne s'agit pas ici d'un
[problème](https://xkcd.com/327/)
[« à la Bobby Tables »](https://bobby-tables.com/).
Les chaînes interpolées dans l'instruction SQL sont entièrement sous le
contrôle du programmeur. Elles ne proviennent pas de la saisie de valeurs
par l'utilisateur, ni même d'une autre source extérieure. Du coup, cela
permet de mieux respecter le principe DRY (_Don't Repeat Yourself_ ou « Ne
répétez pas la même chose »).

Le dernier problème est un peu ironique. Il y a une lacune en MongoDB (ou je croyais
qu'il y avait une lacune), facile à éviter en SQLite. J'ai donc prévu un moyen
de contournement, que je pensais nécessaire en MongoDB et superflu en SQLite
et ce moyen de contournement s'est révélé bugué... dans la version SQLite.

Pourquoi, lorsque je lance le programme d'exploration une deuxième ou une troisième fois, faut-il supprimer le dernier
groupe d'énantiomères et le recréer de toutes pièces ? Voici le raisonnement que j'ai tenu
avant de commencer à écrire les programmes. Lors du premier passage,
lorsque j'ai tapé `Ctrl-C` pour interrompre le programme, il a pu arriver que
le groupe d'énantiomères en cours de traitement était partiellement stocké en base
de données. Or il est indispensable que les huit molécules (dans le cas le plus fréquent)
soient stockées simultanément. Cette contrainte est facile à mettre en place en SQL avec
des `begin transaction` / `commit transaction`, mais il n'y a pas de mécanisme similaire
en MongoDB. Donc je cherche la valeur maximale de `number` dans la base
de données, puis si cette valeur identifie la molécule canonique d'un groupe d'énantiomères,
je supprime ce groupe d'énantiomères (parfois complet, parfois incomplet) et je le recrée complètement.

D'une part cette précaution s'est révélée inutile pour MongoDB. Dans MongoDB, j'effectue
un `insert` en masse, en transmettant un tableau contenant les huit documents à stocker.
Et lors de mes tests, je n'ai jamais vu de cas où le programme aurait inséré en base de données
deux documents sur les huit avant d'être interrompu par `Ctrl-C`. À chaque fois, le groupe d'énantiomères
était complet.

Lorsque j'ai développé la version SQLite, je n'ai pas tout de suite mis en place
les `begin transaction`/ `commit transaction`. Et les `insert` se faisaient un par un,
je n'avais pas cherché s'il existait des
[`bulk insert`](https://www.educba.com/sqlite-bulk-insert/)
en SQLite. Lors d'un test, j'ai eu le cas où le groupe identifié par `canonical-number = 2`
était entièrement créé et le groupe identifié par `canonical-number = 3` était partiellement
stocké en base, deux molécules de ce groupe étaient présentes et les six autres
absentes. Notamment, la molécule identifiée par `number = 3` n'avait pas encore été
insérée dans la base. Lors du passage suivant, la recherche du plus grand `number` a donné le numéro 2,
donc c'est le groupe identifié par `canonical-number = 2` qui a été supprimé et recréé.
Puis le programme a créé le  groupe identifié par `canonical-number = 3`, sans tenir compte
des deux molécules déjà présentes. D'où un groupe incohérent à 10 molécules, dont deux doublons.

Comment remédier ? Il y a, au moins, trois façons :

- Extraire non seulement la valeur maximale de `number` mais aussi celle de `canonical-number`
et traiter la plus grande des deux. Dans le cas présenté ci-dessus, cela aurait conduit à supprimer
le groupe identifié par `canonical-number = 3` contenant deux molécules et à laisser tranquille le
groupe identifié par `canonical-number = 2` qui était complet.

- S'arranger pour que la molécule canonique, celle pour laquelle `number` est renseigné,
soit la première à être insérée en base de données. Ainsi, l'extraction de la valeur maximale
de `number` aurait conduit à supprimer le groupe identifié par `canonical-number = 3`.

- Mettre en place les `begin transaction` / `commit transaction` et s'arranger pour qu'il
n'y ait pas un `commit` en plein milieu du traitement d'un groupe d'énantiomères.

Comme j'avais déjà planifié la mise  en place les `begin transaction` / `commit transaction`,
je n'ai pas cherché à programmer la méthode 1 ou la méthode 2.

Conclusion
==========

J'écris cette conclusion après avoir lancé l'exploration sur une configuration
A4\_B6. Je n'ai pas encore essayé la configuration standard A4\_B8, mais 
les conclusions tirées de la configuration A4\_B6 sont intéressantes et peuvent
en grande partie s'étendre à la configuration A4\_B8.

Avant de commencer le développement de ces programmes, je connaissais deux spectres
ambigus pour la configuration A4\_B8 (en fait 16, à cause des rotations et des symétries).
Ces deux (ou 16) spectres offrent chacun deux solutions. Je m'attendais à en trouver
d'autres avec deux solutions, une poignée avec trois solutions et peut-être, vraiment
peut-être, un avec quatre solutions (en fait 8 compte tenu des rotations et symétries).

Voici ce que j'ai trouvé pour la configuration A4\_B6 :
```
nombre de molécules     spectres        spectres        molécules
par spectre           sans rot / sym  avec rot / sym  avec rot / sym
       2                    89            696             1392
       3                     6             36              108
       4                     4             24               96
       5                     1              8               40
total                      100            764             1636
```
J'ai vérifié les groupes spectraux à 4 ou 5 molécules et j'ai constaté qu'ils
pouvaient sans problème s'étendre à une configuration A4\_B8, en insérant
deux lignes vides et deux colonnes vides au bon endroit. Je pense qu'il en
va de même avec la plupart des groupes spectraux à 2 ou 3 molécules. Il est possible
qu'il y ait de nouveaux cas d'ambiguïté dans A4\_B8 qui n'auraient pas
d'équivalents dans A4\_B6. Si tel est le cas, je pense qu'ils seront en
nombre très limité.

Toujours est-il que l'on peut compter sur vraisemblablement au moins 750
spectres et 1600 molécules pour la configuration A4\_B8. Je ne m'attendais
pas à un tel nombre.

Également, jusqu'à présent, je ne connaissais que des cas de figure où
les deux molécules solutions d'un jeu différaient l'une de l'autre par un
seul atome. En d'autres termes, des molécules qui pouvaient occasionner
un malus de 5 points. Grâce à mes programmes, j'ai obtenu des groupes spectraux
dans lesquels il y a au moins deux molécules qui diffèrent l'une de l'autre
par deux atomes, ce qui donnerait un malus de 10 points.

Pour les statistiques sur la longueur des trajets et le nombre de virages,
il est impossible d'extrapoler les résultats de la configuration A4\_B6
à ceux que l'on aurait avec la configuration A4\_B8. Mais c'est un but secondaire.
Le but primaire est atteint rien qu'en analysant la configuration A4\_B6.

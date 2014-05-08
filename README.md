CUnitTestMake
=============

Makefile for C/C++ unit tests

This repo contains makefiles used to build object files, library (archive .a) 
files, and executables based on the source code directory structures.

The purpose of this makefile system is to allow users to add or modify 
source code and corresponding unit tests with as few modifications in the 
makefiles as possible, so that let developers focus on problems solving process,
 without introducing much work in specifying compile-time code dependences, or 
link-time object files dependences, and running unit tests.  One of the benefit
of this work is that it can automate build and test systems.

How are the source code, library .a (archive), and executable files organized.
--------------

Source code files can be divided into two types. The first ones have
main() function.  The second ones do not have and used to build libraries.
Correspondingly, we assume object files are either used to build executables
directly (which have main() defined), or are used to build libraries which are
used to build other depending libraries or executables.

In Makefile, users have to take care of dependences. There are dependences in 
compiling the source code to object code and dependences in linking object and 
library files to executables.

The first dependences among source code can be specified by .d file created by
gcc using -M flags without developer specifying in make rules.

The second dependences requires developers to specify object files and
libraries (static) in a proper order. 

To simplify the second dependence specification, we use directory structure to
organize object libraries.  In a directory, there is only one object library 
file (i.e. .a file), which contains all object files compiled from the source 
in the same source directory, and depend library objects from other directories.

There is a link-time dependence between two directories, if a object file in one
directory calls a function defined in the source code in a different directory.
Therefore, when we build the library of the first directory, the depend
directory's library is required to be built first, and its library objects are
added in the depending library build.

Based on this simplified object dependence structure, developers only need to 
specify directories of called functions when building executables.

Certainly, developers must avoid cycle-dependence by organizing object
libraries in the tree structure, which bears the same structure as the source
code directories.






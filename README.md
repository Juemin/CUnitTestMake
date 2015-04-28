CUnitTestMake
=============

Makefile for C/C++ unit tests

This make file system is created to simplify building object files, library 
(archive .a) files, and executables based on the source code directory structures.

The initial goal is to allow developers to add c/c++ unit tests for source code, 
compile source and testing code, build executables, and carry out tests under 
one directory by using makefile in a simple and easy way.  Developers do not 
need to specify complicated build rules to do above, but focus on problem
solving process, providing correct and well-tested source code.

Developers add source code and its unit test files in a directory, the makefile 
will compile source code, build executable, and run tests.  Developers only 
need to specify the testing code's dependences(other than system libraries).


--------------

Source code files can be divided into two types. The first ones have
main() function, and the second ones do not have and used to build libraries.
Correspondingly, we assume object files are either used to build executables
directly (which have main() defined), or are used to build libraries which 
can be used to build other depending libraries or executables.

In Makefile, users have to take care of dependences. There are dependences in 
compiling the source code to object code and dependences in linking object and 
library files to executables.

The first dependences among source code can be specified by .d file created by
gcc using -M flags without developer to instruct the make rules. The second 
dependences requires developers to specify object files and libraries (static)
in a proper order. 


To simplify the second dependence specification, we use directory structure to
organize libraries.  A source code directory can multiple executable source
(with main()), and one exporting library file (.a file) which is used to build
build other depending libraries or executables.  This export library only 
contains object files compiled from source code without main().

Based on this simplified object dependence structure, developers only need to 
specify directories of called functions when building executables.

Certainly, developers must avoid cycle-dependence by organizing object
libraries in the tree structure, which can bear the same structure as the source
code directories.


Usage
==========================================

1) Copy make directory to the root of your project dir, or BASE_DIR
   Here you can overwrite some global variables in load_makefile.mk 
   to meet your needs
    BD_DIR:     build direcotry. Default is build/Debug/OS.
    SUB_TEST:   test directory. Default is 


2) In each source directory, make a copy of $(BASE_DIR)/make/Makefile.template.
   Rename to Makefile and edit optional variables based on your needs

    BASE_DIR:   root directory of project 
    MK_DIR:     CUnitTest makefile directory

    SRC:        all source file in the directory.  If not specified, we will 
                use all .c and .cpp files  
    IGNORE:     excluding files from SRC

    DEP_DIR:    depend directories, directories which have source defining the 
                called functions

    GTEST_DIR:  google unit test directory, if needed

    NO_MK_LIB:  do not build library for this directory
    NO_MK_EXE:  do not build executable for this directory


    default:    specifying the default build target

    Other compile and link options:
    All build options are applied to all implicit building rules. If you need to add
    compiling flags in building some object files, you need to write your own
    explicit build rules in the Makefile to overwrite the default implicit build rules.
    Check make/Makefile_obj.mk and and make/Makefile_exe.mk to find out how 
    the the implicit rules are defined.


3) Predefined build targets:
    .build-dep: build dependence files for all source files
    .build-obj: build object files for all sources file in the directory
    .build-lib: build directory library file used for build executable or
                required by building other depend library in a different directory
                No all directories need this target, such as the unit test directory
                which does not have depending libraries. Use NO_MK_LIB to exclude
                the Makefile_lib.mk module.
    .build-exe: build executables.  
    .runtest:   run all executables built from the current directory.  The output
                and timestamp files are written to SUB_TEST directory.
    .clean:     Remove all built object, library, executable, and testing output
                and timestamp files.
    distclean:  remove current unit test build directory
    .distclean-all: remove unit test build direcotyr in current and its all sub-directories recursively.
   





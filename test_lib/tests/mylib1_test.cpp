/* 
 * File:   mylib1_test.cpp
 * Author: jzhang
 *
 * Created on April 22, 2014, 11:30 AM
 */

#include <stdlib.h>
#include <stdio.h>
#include <iostream>

#include "../mylib1.h"
#include "../mylib2.h"
#include "../sub1/mysublib1.h"
#include "../sub1/mysublib2.h"
#include "../sub2/mysublib2.h"

void test()
{
    lib_func1();	
    lib_func2();	// defined in mylib1
    lib2_func1();      // defined in mylib2
    sub1_lib1_func1(); // defined in sub1/mysublib1
    sub1_lib2_func2();	// defined in sub1/mysublib2
    sub2_lib1_func1(); // defined in sub2/mysublib2	
}

int main(int argc, char** argv)
{
    test();

    std::cout << "%TEST_FINISHED% time=0" << std::endl;

    return (0);
}

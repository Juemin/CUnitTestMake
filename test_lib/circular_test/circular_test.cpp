/* 
 * File:   mylib1_test.cpp
 * Author: jzhang
 *
 * Created on April 22, 2014, 11:30 AM
 */

#include <stdlib.h>
#include <stdio.h>
#include <iostream>

#include "../sub3/mysublib3.h"
#include "../sub4/mysublib4.h"

void test()
{
    sub3_lib1_func1(); // defined in sub1/mysublib1
    sub4_lib1_func1(); // defined in sub1/mysublib2
}

int main(int argc, char** argv)
{
    test();

    std::cout << "%TEST_FINISHED% time=0" << std::endl;

    return (0);
}

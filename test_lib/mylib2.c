#include <stdlib.h>
#include <stdio.h>

#include "mylib2.h"
#include "sub1/mysublib1.h"
#include "sub2/mysublib2.h"

void lib2_func1()
{
    printf("Calling support lib2 func1\n");
    sub1_lib1_func1();
}

void lib2_func2()
{
    printf("Calling support lib2 func2\n");
    sub2_lib1_func2();
 
}

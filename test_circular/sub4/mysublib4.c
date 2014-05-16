#include <stdlib.h>
#include <stdio.h>

#include "mysublib4.h"
#include "../sub3/mysublib3.h"

void sub4_lib1_func1()
{
    printf("Calling support sub4 lib1 func1\n");
    sub3_lib1_func2();
}

void sub4_lib1_func2()
{
    printf("Calling support sub4 lib1 func2\n");
}

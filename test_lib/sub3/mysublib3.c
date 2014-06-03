#include <stdlib.h>
#include <stdio.h>

#include "mysublib3.h"
#include "../sub4/mysublib4.h"

void sub3_lib1_func1()
{
    printf("Calling support sub3 lib1 func1\n");
    sub4_lib1_func2();
}

void sub3_lib1_func2()
{
    printf("Calling support sub3 lib1 func2\n");
}

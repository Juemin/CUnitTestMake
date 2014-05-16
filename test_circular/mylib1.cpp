#include <stdlib.h>
#include <stdio.h>

#include "mylib1.h"
#include "sub1/mysublib1.h"
#include "sub1/mysublib2.h"
#include "sub2/mysublib2.h"

#ifdef	__cplusplus
extern "C" {
#endif
    
void lib_func1()
{
    printf("Calling support lib func1\n");
    sub1_lib1_func1();
    sub1_lib2_func1();
    sub2_lib1_func1();
}

void lib_func2()
{
    printf("Calling support lib func2\n");
    sub1_lib1_func2();
    sub1_lib2_func2();
    sub2_lib1_func2();
}

#ifdef	__cplusplus
}
#endif
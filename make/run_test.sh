#!/usr/bin/env bash

##
## Created by zhangj26

TERM=xterm-color
ret_stt=0
test_exe=$1
test_dir=$2
test_ts=
cap_output=0

if [ $# -gt 2 ] ; then
    test_ts=$3
fi

black='\E[30m'
red='\E[31m'
green='\E[1;32m'
yellow='\E[33m'
blue='\E[34m'
magenta='\E[35m'
cyan='\E[36m'
white='\E[37m'
bold='\E[1;37m'
clr='\E[0m'

######################################
exe_path=`readlink -f $test_exe`
reset_term=

if [ hash tput -V 2>/dev/null ] ; then
    reset_term="tput sgr0"
fi

echo -e          ">>>Test:run test---------- $bold$exe_path$clr"

#env | grep LD_LIBRARY_PATH

orig_pwd=$PWD

test_name=`basename $test_exe`
test_out=$test_dir/$test_name.output
#pass_ts=$test_dir/$test_name.ts

echo             ">>>Test:cd --------------- $test_dir"
echo             ">>>Test:test output------- $test_out"
echo             ">>>Test:test timestamp---- $test_ts"

rm -f $pass_ts

if [ -e ".ignore.$test_name" ] ; then
    echo -e      ">>>Test:not running test-- found $magenta.ignore.$test_name$clr"
else
    if [ $cap_output -eq 0 ] ; then
        $exe_path
        ret_stt=$?
    else
        $exe_path | tee $test_out
        ret_stt=${PIPESTATUS[0]}
    fi

    if [ $ret_stt -eq 0 ] ; then
        echo -en ">>>Test:passed------------ $green$test_name$clr"
        echo
        if [ -e  ".force.$test_name" ] ; then
            echo ">>>Test:no timestamp------ .force.$test_name"
        elif [ -z "$test_ts" ] ; then
            echo ">>>Test:no timestamp specified"
        else
            #touch $test_dir/$test_name.ts
            echo ">>>Test:touch timestamp--- $test_ts"
            touch $test_ts
        fi
    else
        echo -e  ">>>Test:failed------------ $red$test_name$clr"
    fi
fi

$reset_term

cd $orig_pwd


exit $ret_stt

#!/bin/bash


test_exe=$1
test_dir=$2

exe_path=`readlink -f $test_exe`

echo ">>>Test:run test--------- $exe_path"

orig_pwd=$PWD

test_name=`basename $test_exe`
test_out=$test_dir/$test_name.output
pass_ts=$test_dir/$test_name.ts

echo ">>>Test:cd -------------- $test_dir"
echo ">>>Test:test output------ $test_out"
echo ">>>Test:pass timestamp--- $pass_ts"

rm -f $pass_ts

$exe_path | tee $test_out

retstt=${PIPESTATUS[0]}

#if [ $retstt -eq 0 ] ; then
#   touch $pass_ts
#fi

cd $orig_pwd

exit $retstt
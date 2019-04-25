#!/usr/bin/env python

""" Part of CUnitMake makefile syste 
    This python script combines two makefiles which specify include search
    path lists, removing duplicated one and write the result to the later one.
"""
__author__ = "Jeff Zhang"
__copyright__ = "Copyright 2014, BitWise software"
__credits__ = []
__license__ = "GPL"
__version__ = "1.0.1"
__maintainer__ = "Jeff Zhang"
__email__ = ""
__status__ = "testing"


from optparse import OptionParser
import re

parser = OptionParser()

parser.add_option("-i", "--input",
                  dest="input_file", metavar="FILE",
                  help="input pathname of the makefile to combine with")
parser.add_option("-o", "--output",
                  dest="output_file", metavar="FILE",
                  help="pathname of the in/out makefile, the input "
                  "combines with")


# ==============================================================================
def get_list(input_lines):
    out_list = []
    for ln in input_lines:
        for elm in ln.split():
            if (re.search(r'EXP_INC_PATH', elm) or re.search(r'\+\=', elm) or
                    elm in out_list):
                continue
            out_list.append(elm)
    return out_list


def get_hash(input_lines):
    out_hash = {}
    for ln in input_lines:
        for elm in ln.split():
            if (re.search(r'EXP_INC_PATH', elm) or re.search(r'\+\=', elm)):
                continue
            out_hash[elm] = ''
    return out_hash


# ---- main-------
(options, args) = parser.parse_args()

#print("input_file", options.input_file)
#print("output_file", options.output_file)

in_file = open(options.input_file, "r")
out_file = open(options.output_file, "rw+")

in_lines = in_file.readlines()
in_file.close()

out_lines = out_file.readlines()
# print "Output:", out_lines

in_list = get_list(in_lines)
out_hash = get_hash(out_lines)

newline = ""
add_list = []
for e in in_list:
    if e in out_hash:
        continue
    newline += " " + e

if (len(newline) > 0):
    # print "Add line: ", newline
    out_file.write("EXP_INC_PATH += " + newline + "\n")

out_file.close()

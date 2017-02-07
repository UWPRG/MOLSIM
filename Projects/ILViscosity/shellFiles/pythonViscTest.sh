#!/bin/bash

###THIS SCRIPT HANDLES EQUILIBRATION AND PRODUCTION MD CYCLES
###FOR A GIVEN DES

#1. 5 ns NVT at 500K, starting structures taken at 1,2,3,4,5 ns
#2. 5 ns NPT at 298.15 K and 1 bar with Berendsen barostat
#3. 5 ns NPT at 298.15 K and 1 bar with Parrinello-Rahman barostat
#4. select 1 from each of the 5 and initiate triplicate sims non-eq MD NPT sims
#        1 ns in length with a cosine acceleration factor of $VISC
#        nm/ps2 applied to each particle

###*****************************************************************
###MD SETUP
Xguess=5
PERCENT=100
LABEL=`echo $PERCENT | awk '{print int($1)}'`
VISC=(0.005 0.01 0.02 0.03 0.05)
lenVISC=${#VISC[*]}
t=(100 200 300 400 500)
len=${#t[*]}
s=1
it_num=1

###*****************************************************************
if [ ! -f historyMD ]; then
  touch historyMD
fi


echo $s $len $lenVISC ${t[@]} ${VISC[@]}
python analysisPythonVisc.py $LABEL $s $len $lenVISC ${it_num} ${t[@]} ${VISC[@]}

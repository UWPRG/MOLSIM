#!/bin/bash
set -e

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
Xguess=2.2327778820909483
PERCENT=`echo $Xguess | awk '{print 1/(1+$1)*100}'` #% IL (in DES and IL) or organic
LABEL=`echo $PERCENT | awk '{print int($1)}'`
VISC=(0.005 0.01 0.02 0.03 0.05)
lenVISC=${#VISC[*]}
t=(100 200 300 400 500)
len=${#t[*]}
s=1
it_num=1

###*****************************************************************
###GRAD DESCENT SETUP
alpha=1			#step size
Y=$(tail -1 historyMD)

if [ ! -f historyGradDes ] ; then
  echo $Y, $Xguess > historyGradDes
  tr -d '\r' < historyGradDes > outfile
  mv outfile historyGradDes
fi

python spGradDescent.py $Xguess $Y $alpha
Xguess=$(tail -1 historyGradDes | awk -F ',' '{print $2}')
echo $Xguess



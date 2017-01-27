#!/bin/bash
#run this script with the name of your system (match input file)
#and a name for your log file
#for an HMI CHL salt at 350K this could look like:
#source master.sh HMI_CHL > HMI_CHL.350 &
#source master.sh ${name} > ${name}.${characteristic} &
set -e						#exit script on error
name=$1						#set variable name to first argument
source ${name}.inp				#source the input file
LABEL=${name}.${Temp}				#set a label to organize your files
echo "sourcing ${name}.inp"
cat ${name}.inp 				#print input to log file
sed -i "6s/.*/name=${name}/" ${name}.inp	#print name to input file
wait
source directory.inp				#create directory architecture

###*****************************************************************
###Run EQ
  
  cd $SANDBOX
  if [ "${MD}" == "yes" ] ; then
    source spMD.sh 
    wait
  fi

###*****************************************************************
###Run Analysis

  if [ "${Analysis}" == "yes" ] ; then
    source spAnalysis.sh
    wait
  fi

###*****************************************************************
###Run Analysis

echo "job complete"
echo "job complete for ${name}" | mail -s "message from hyak" wesleybeckner@gmail.com

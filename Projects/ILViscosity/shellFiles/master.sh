#!/bin/bash
set -e
name=$1
source ${name}.inp
echo "sourcing ${name}.inp"
cat ${name}.inp 
sed -i "3s/.*/name=${name}/" ${name}.inp
wait
source directory.inp

lenVISC=${#VISC[*]}			#for python viscosity analysis

###CHECK STATUS IN THE LOOP
if [ "$loop" == "none" ] ; then
  startbump=1
  len=$iterations 				#for handling of serial runs
  lenViscRuns=$[${len}*${lenVISC}*${s}]
fi
if [ "$loop" == "Temperature" ] ; then
  iterations=${#Temps[*]}
  len=${#t[*]} 				#for handling of serial runs
  lenViscRuns=$[${len}*${lenVISC}*${s}]
  if [ -f ${name}HistoryMD ] ; then
    startbump=$((`wc -l ${name}HistoryMD | awk '{print $1}'`+1))
  else
    startbump=1
  fi
fi

###Overwritten if history files are present
if [ "$loop" == "ML" ] ; then
  if [ ! -f historyGradDes ]; then
    echo $Y, $Xguess > historyGradDes
    tr -d '\r' < historyGradDes > outfile
    mv outfile historyGradDes
    startbump=1
  else
    Xguess=`tail -1 historyGradDes | awk -F ',' '{print $2}'` 
    startbump=`wc -l historyGradDes | awk '{print $1}'`
  fi
  if [ ! -f ${name}HistoryMD ]; then
    touch ${name}HistoryMD
  else
    Y=$(tail -1 ${name}HistoryMD)
  fi
fi

###*****************************************************************
###Run EQ
  
  cd $SANDBOX
  if [ "${runEqMD}" == "yes" ] ; then
    source spMD.sh 
    wait
  fi

###*****************************************************************
###Tidy up EQ Files

  source spDiskClean.sh
  wait

###*****************************************************************
###Run EQ NVT Analysis

  if [ "${eqNVTAnalysis}" == "yes" ] ; then
    source spEqNVTAnalysisMD.sh
    wait
  fi

###*****************************************************************
###Run EQ Analysis

  if [ "${eqAnalysis}" == "yes" ] ; then
    source spEqAnalysisMD.sh
    wait
  fi

###*****************************************************************
###Run NonEQ

  if [ "${runNonEqMD}" == "yes" ] ; then
    source spViscMiniMD.sh
    wait
  fi

###*****************************************************************
###Run Non EQ Analysis
  if [ "${NonEqAnalysis}" == "yes" ] ; then
    source analysisGromacsVisc.sh 
    wait
    touch $ILhome/${it_num}.${LABEL}/analysis_files_${novel}/${name}HistoryMD 
    cp analysisPythonVisc.py $ILhome/${it_num}.${LABEL}/analysis_files_${novel}/
    cd $ILhome/${it_num}.${LABEL}/analysis_files_${novel}/ 
    python analysisPythonVisc.py $LABEL $s $len $lenVISC ${it_num} ${t[@]} ${VISC[@]}
    wait
    cd -
  fi
###*****************************************************************
###Call Gradient Descent
###store Xguess, X_history, and Y_history 

  cd $SANDBOX
  if [ "${loop}" == "ML" ] ; then
    cat $ILhome/${it_num}.${LABEL}/analysis_files/${name}HistoryMD >> ${name}HistoryMD 
    Y=$(tail -1 ${name}HistoryMD)
    python spGradDescent.py $Xguess $Y $alpha
    Xguess=$(tail -1 historyGradDes | awk -F ',' '{print $2}')
    echo $Xguess
  fi
echo "job complete"
echo "job complete for ${name}" | mail -s "message from hyak" wesleybeckner@gmail.com

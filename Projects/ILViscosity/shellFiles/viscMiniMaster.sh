#!/bin/bash
set -e
name=$1
source ${name}.inp
wait
novel=righttemp #name this type of visc test, this with engender
             #the analysis directory name
###CHECK STATUS IN THE LOOP
if [ "$loop" = "Temperature" ] ; then
  iterations=${#Temps[*]}
  if [ -f ${name}HistoryMD ] ; then
    startbump=$((`wc -l ${name}HistoryMD | awk '{print $1}'`+1))
  else
    startbump=1
  fi
fi

###Overwritten if history files are present
if [ "loop" == "ML" ] ; then
  Xguess=1 		#Hdonor:IL ratio guess
  Y=7.3			#initial viscosity guess
  
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

for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
###*****************************************************************
###CALL spMD, analysisGromacsVisc and analysisPythonVisc
  
  cd $SANDBOX
  if [ "$loop" == "ML" ] ; then
    LABEL=`echo $PERCENT | awk '{print int($1)}'`
  elif [ "$loop" == "Temperature" ] ; then
    currentTemp=${Temps[${it_num}-1]}
    LABEL=`echo ${Temps[${it_num}-1]} | awk '{print int($1)}'`
  fi
  source spViscMiniMD.sh #TEST WITH SHORT MDP FILES
  wait
  source viscAnalysisGromacsVisc.sh 
  wait
  touch $ILhome/${it_num}.${LABEL}/analysis_files_${novel}/historyMD 
  cp analysisPythonVisc.py $ILhome/${it_num}.${LABEL}/analysis_files_${novel}/
  cd $ILhome/${it_num}.${LABEL}/analysis_files_${novel}/ 
  python analysisPythonVisc.py $LABEL $s $len $lenVISC ${it_num} ${t[@]} ${VISC[@]}
  wait
  cd -
  cat $ILhome/${it_num}.${LABEL}/analysis_files_${novel}/historyMD >> historyMD 
  Y=$(tail -1 historyMD)
  
  # python spVisGen.py $Xguess
  # echo $Y

###*****************************************************************
###CALL spDiskClean

  #source spViscClean.sh
  #wait

###*****************************************************************
###Call Gradient Descent
###store Xguess, X_history, and Y_history 

  cd $SANDBOX
  if [ "loop" == "ML" ] ; then
    python spGradDescent.py $Xguess $Y $alpha
    Xguess=$(tail -1 historyGradDes | awk -F ',' '{print $2}')
    echo $Xguess
  fi
done

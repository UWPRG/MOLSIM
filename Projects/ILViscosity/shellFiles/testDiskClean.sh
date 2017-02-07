#!/bin/bash
set -e
name=$1
source ${name}.inp
echo "sourcing ${name}.inp"
cat ${name}.inp 
wait
source directory.inp

lenVISC=${#VISC[*]}			#for python viscosity analysis
len=${#t[*]} 				#for handling of serial runs
lenViscRuns=$[${len}*${lenVISC}*${s}]

###Create the intial packed box
###FFmaker files must be present
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

for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
  echo " "
  echo "checking for setup files"
  cd $SETUP
  if [ "$loop" == "ML" ] ; then
    LABEL=`echo $PERCENT | awk '{print int($1)}'`
    if [ ! -d $SETUP/${it_num}.$LABEL/ ] ; then
      mkdir ${it_num}.$LABEL
    fi
    if [ ! -f $SETUP/${it_num}.$LABEL/conf.gro ] ; then
      cp $SANDBOX/acpype.py $SETUP/${it_num}.$LABEL/
      cp $SANDBOX/packmol.inp $SETUP/${it_num}.$LABEL/
      cp $SANDBOX/boxmagic.bash $SETUP/${it_num}.$LABEL/
      cp $STRUCTURES/${IL_CAT}* $SETUP/${it_num}.$LABEL/
      cp $STRUCTURES/${IL_AN}* $SETUP/${it_num}.$LABEL/
      cp $SANDBOX/boxmagic.pbs $SETUP/${it_num}.$LABEL/
      cp $SANDBOX/${name}.inp $SETUP/${it_num}.$LABEL/
      cp $SANDBOX/directory.inp $SETUP/${it_num}.$LABEL/
      sed -i "8s/.*/source ${name}.inp/" $SETUP/system/boxmagic.bash
      
      if [ "${SOLVENT_TYPE}" = "DES" ] ; then
        cp $SANDBOX/${ORG_MOL}* $SETUP/${it_num}.$LABEL/
      fi
      cd $SETUP/${it_num}.$LABEL/
      qsub boxmagic.pbs
      if [ ! -f $SETUP/${it_num}.$LABEL/conf.gro ] ; then
        while true ; do
          if [ -f $SETUP/${it_num}.$LABEL/conf.gro ] ; then
            echo "boxmagic complete... moving forward"
            break
          else
            echo "waiting for boxmagic to complete"
            sleep 60
          fi
        done
      else
        echo "${it_num}.${LABEL} boxmagic files present... moving forward"
        sleep 1
      fi
      wait
      if [ ! -f $SETUP/${it_num}.$LABEL/conf.gro ] ; then #check for error
        return 0 
      fi
    fi
  elif [ "$loop" == "Temperature" ] ; then
    currentTemp=${Temps[${it_num}-1]}
    LABEL=`echo ${Temps[${it_num}-1]} | awk '{print int($1)}'`
    if [ ! -d $SETUP/system/ ] ; then
      mkdir system
    fi
    if [ ! -f $SETUP/system/conf.gro ] ; then
      cp $SANDBOX/acpype.py $SETUP/system/
      cp $SANDBOX/packmol.inp $SETUP/system/
      cp $SANDBOX/boxmagic.bash $SETUP/system/
      cp $STRUCTURES/${IL_CAT}* $SETUP/system/
      cp $STRUCTURES/${IL_AN}* $SETUP/system/
      cp $SANDBOX/boxmagic.pbs $SETUP/system/
      cp $SANDBOX/${name}.inp $SETUP/system/
      cp $SANDBOX/directory.inp $SETUP/system/
      sed -i "8s/.*/source ${name}.inp/" $SETUP/system/boxmagic.bash
      
      if [ "${SOLVENT_TYPE}" = "DES" ] ; then
        cp $STRUCTURES/${ORG_MOL}* $SETUP/system/
      fi
      cd $SETUP/system/
      qsub boxmagic.pbs
      if [ ! -f $SETUP/system/conf.gro ] ; then
        while true ; do
          if [ -f $SETUP/system/conf.gro ] ; then
            echo "boxmagic complete... moving forward"
            break
          else
            echo "waiting for boxmagic to complete"
            sleep 60
          fi
        done
      else
        echo "${it_num}.${LABEL} boxmagic files present... moving forward"
        sleep 1
      fi
      wait
      if [ ! -f $SETUP/system/conf.gro ] ; then #check for error
        return 0 
      fi
    fi
  fi


###*****************************************************************
###Tidy up EQ Files
  cd $SANDBOX

  source spDiskClean.sh
  wait

  cd $SANDBOX
done
echo "job complete"

#!/bin/bash
set -e

###PACK THE BOX USING BOXMAKER 
for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
  echo " "
  echo "checking for setup files"
  cd $SETUP
  if [ ! -d $SETUP/system/ ] ; then
    mkdir $SETUP/system
  fi
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
  elif [ "$loop" == "none" ] ; then
    currentTemp=${Temps[0]}
    LABEL=`echo ${Temps[0]} | awk '{print int($1)}'`
    if [ ! -d $SETUP/system/${it_num}/ ] ; then
      mkdir $SETUP/system/${it_num}
    fi
    if [ ! -f $SETUP/system/${it_num}/conf.gro ] ; then
      cp $SANDBOX/acpype.py $SETUP/system/${it_num}/
      cp $SANDBOX/packmol.inp $SETUP/system/${it_num}/
      cp $SANDBOX/boxmagic.bash $SETUP/system/${it_num}/
      cp $STRUCTURES/${IL_CAT}* $SETUP/system/${it_num}/
      cp $STRUCTURES/${IL_AN}* $SETUP/system/${it_num}/
      cp $SANDBOX/boxmagic.pbs $SETUP/system/${it_num}/
      cp $SANDBOX/${name}.inp $SETUP/system/${it_num}/
      cp $SANDBOX/directory.inp $SETUP/system/${it_num}/
      sed -i "8s/.*/source ${name}.inp/" $SETUP/system/${it_num}/boxmagic.bash
      
      if [ "${SOLVENT_TYPE}" = "DES" ] ; then
        cp $STRUCTURES/${ORG_MOL}* $SETUP/system/${it_num}/
      fi
      cd $SETUP/system/${it_num}/
      qsub boxmagic.pbs
    fi
  fi
done
i=0
while true ; do
  for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
    if [ ! -f $SETUP/system/${it_num}/conf.gro ] ; then
      echo "checking boxmaker files for ${it_num}"
        i=0
      else
        i=$(( $i+1 ))
    fi
  done
  if [ "$i" -ge "$len" ] ; then
    echo "boxmaker complete... moving forward"
    sleep 1
    break
  else
    echo "waiting for boxmaker to complete"
    sleep 60
  fi
done
###ENERGY MINIMIZE THE BOXMAKER STRUCTURE
for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
  echo " "
  echo "beginning ${it_num}.${LABEL} runs"
  cd $ILhome
  if [ ! -d $ILhome/${it_num}.${LABEL}/ ] ; then
    mkdir ${it_num}.${LABEL}
    echo "made new directory $ILhome/${it_num}.${LABEL}"
  fi
  cd ${it_num}.${LABEL}
  if [ ! -d $ILhome/${it_num}.${LABEL}/mini ] ; then
    mkdir mini
    echo "made ${it_num}.${LABEL}/mini directory"
  fi
  if [ ! -f mini/confout.gro ] && [ ! -f mini/md.log ] ; then
    echo "initiating energy minimization for ${it_num}.${LABEL}"
    cp $MDP/mini.mdp mini/
    cp $MDP/GROMACS_5.pbs mini/GROMACS.pbs
    cp $SANDBOX/nodeseaker.sh mini/nodeseaker.sh
    if [ "$loop" == "ML" ] ; then
      cp $SETUP/${it_num}.${LABEL}/conf.gro mini/
      cp $SETUP/${it_num}.${LABEL}/topol.top mini/
    elif [ "$loop" == "Temperature" ] || [ "$loop" == "none" ] ; then
      cp $SETUP/system/${it_num}/conf.gro mini/
      cp $SETUP/system/${it_num}/topol.top mini/
    fi
    cd mini/
    if [ "$SYSTYPE" == "hyak" ] ; then
    gmx_8c grompp -f mini.mdp
    source nodeseaker.sh
    wait
    qsub GROMACS.pbs
    fi
    if [ "$SYSTYPE" == "linux" ] ; then
    grompp -f mini.mdp
    mdrun -v
    wait
    fi
    cd -
  fi
done
i=0
while true ; do
  for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
      if [ ! -f $ILhome/${it_num}.${LABEL}/mini/confout.gro ] ; then
        i=0
        echo "waiting on minimization files for ${it_num}.${LABEL}"
      else
        i=$(( $i+1 ))
      fi
  done
  if [ "$i" -ge "$len" ] ; then
    echo "minimization complete... moving forward"
    sleep 1
    break
  else
    echo "waiting for minimization to complete"
    sleep 60
  fi
done
###HEAT THE SYSTEM
#for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
#  if [ ! -d $ILhome/${it_num}.${LABEL}/hot ] ; then
#    mkdir hot
#    echo "made $ILhome/${it_num}.${LABEL}/hot directory"
#  fi
#  if [ ! -f hot/confout.gro ] && [ ! -f hot/md.log ] ; then
#    echo "initiating heat equilibration for ${it_num}.${LABEL}"
#    cp $MDP/nvt_heat.mdp hot/nvt.mdp
#    cp $MDP/GROMACS_5.pbs hot/GROMACS.pbs
#    cp $ILhome/${it_num}.${LABEL}/mini/confout.gro hot/conf.gro
#    if [ "$loop" == "ML" ] ; then
#      cp $SETUP/${it_num}.${LABEL}/topol.top hot/
#    elif [ "$loop" == "Temperature" ] ; then
#      cp $SETUP/system/topol.top hot/
#    fi
#    cd hot
#    sed -i "7s/.*/nsteps                  =  ${heat_length}/" nvt.mdp 
#    gmx_8c grompp -f nvt.mdp -maxwarn 1
#    wait
#    qsub GROMACS.pbs
#    cd -
#  fi
#  if [ ! -f hot/confout.gro ] ; then
#    while true ; do
#      if [ -f hot/confout.gro ] ; then
#        echo "heating complete... moving forward"
#        break
#      else
#        echo "waiting for heating to complete"
#        sleep 600
#        if [ -f hot/md.log ] ; then
#          tail -11 hot/md.log
#        fi
#      fi
#    done
#  else
#      echo "${it_num}.${LABEL} hot files present... moving forward"
#      sleep 1
#  fi
#done
###RUN BERENDSEN EQUILIBRATION
for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
  if [ -f $ILhome/${it_num}.${LABEL}/mini/confout.gro ] ; then  
    if [ ! -d $ILhome/${it_num}.${LABEL}/equilibrate ] ; then
      mkdir $ILhome/${it_num}.${LABEL}/equilibrate
      echo "made $ILhome/${it_num}.${LABEL}/equilibrate directory"
    fi
    cd $ILhome/${it_num}.${LABEL}
    if [ -f equilibrate/confout.gro ] ; then    
      echo "equilibrate ${it_num} files present..."
    elif [ ! -f equilibrate/md.log ] ; then
      echo "creating new files: ${it_num}.${LABEL}/equilibrate/"
      if [ ! -d equilibrate/ ] ; then	
        mkdir equilibrate/
      fi
      cd $ILhome/${it_num}.${LABEL}/mini/
      cp confout.gro ../equilibrate/conf.gro
      cd -
      cp $MDP/GROMACS_5.pbs equilibrate/GROMACS.pbs
      cp $MDP/nptber_5ns.mdp equilibrate/npt.mdp
      cp $SANDBOX/nodeseaker.sh equilibrate/nodeseaker.sh
      cp mini/topol.top equilibrate/
      cd equilibrate/
      sed -i "51s/.*/ref_t			= ${currentTemp}/" npt.mdp 
      sed -i "62s/.*/gen_temp		= ${currentTemp}/" npt.mdp 
      gmx_8c grompp -f npt.mdp -maxwarn 1
      source nodeseaker.sh
      wait
      qsub GROMACS.pbs
      sleep 5
      cd -
      echo "equilibration setup for ${it_num}.${LABEL} file complete" 
    else
      echo "It looks like ${it_num}.${LABEL} is currently running"
    fi
 fi
done 
cd $ILhome/
i=0
while true ; do
  for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
      if [ ! -f $ILhome/${it_num}.${LABEL}/equilibrate/confout.gro ] ; then
        echo "waiting on equilibration files for ${it_num}.${LABEL}"
        i=0
      else
        i=$(( $i+1 ))
      fi
  done
  if [ "$i" -ge "$len" ] ; then
    echo "equilibration complete... moving forward"
    sleep 1
    break
  else
    sleep 600
    echo "waiting for equilibration to complete"
    if [ -f $ILhome/${it_num}.${LABEL}/equilibrate/md.log ] ; then 
      tail -11 $ILhome/${it_num}.${LABEL}/equilibrate/md.log
    fi
  fi
done
####RUN PARRINELLO-RAHMAN
#if [ "$npt_production" == "yes" ] ; then
#  if [ ! -d $ILhome/${it_num}.${LABEL}/NPT_${novel} ] ; then
#    mkdir $ILhome/${it_num}.${LABEL}/NPT_${novel}
#  fi
#  for i in "${t[@]}"; do
#    cd $ILhome/${it_num}.${LABEL}
#    if [ -f NPT_${novel}/$i/confout.gro ] ; then    
#      echo "NPT_${novel} $i files present..." 
#    elif [ ! -f NPT_${novel}/$i/conf.gro ] ; then  	
#      echo "creating new files: ${it_num}.${LABEL}/NPT_${novel}/$i"   
#      if [ ! -d NPT_${novel}/$i ] ; then	
#        mkdir NPT_${novel}/$i
#      fi
#      cp $ILhome/${it_num}.${LABEL}/equilibrate/$i/confout.gro NPT_${novel}/$i/conf.gro
#      cp $MDP/GROMACS_5.pbs NPT_${novel}/$i/GROMACS.pbs
#      cp $MDP/nptpar.mdp NPT_${novel}/$i/npt.mdp
#      cp $ILhome/${it_num}.${LABEL}/equilibrate/$i/topol.top NPT_${novel}/$i
#      cd NPT_${novel}/$i
#      sed -i "8s/.*/nsteps                  =  ${npt_length}/" npt.mdp 
#      sed -i "51s/.*/ref_t			= ${currentTemp}/" npt.mdp 
#      sed -i "62s/.*/gen_temp		= ${currentTemp}/" npt.mdp 
#        if [ "${comremoval}" = "yes" ] ; then
#          sed -i "12s/.*/comm_mode                 =  Linear/" npt.mdp
#        elif [ "${comremoval}" = "no" ] ; then
#          sed -i "12s/.*/comm_mode                 =  None/" npt.mdp
#        fi    
#      #if [ -f \#* ] ; then
#      #  rm \#*
#      #fi
#      gmx_8c grompp -f npt.mdp -maxwarn 2
#      qsub GROMACS.pbs
#      echo "NPT_${novel} setup for ${it_num}.${LABEL} $i file complete" 
#    elif [ ! -f NPT_${novel}/$i/confout.gro ] && [ -f NPT_${novel}/${i}/md.log ] ; then  	
#      cd NPT_${novel}/$i
#      qsub GROMACS.pbs
#      cd -
#    else
#      echo "It looks like ${it_num}.${LABEL} $i is currently running NPT_${novel}"
#    fi
#  done
#  cd $ILhome/${it_num}.${LABEL}/NPT_${novel}
#  i=0
#  while true ; do
#    for file in "${t[@]}" ; do
#      echo "checking NPT_${novel} files for iteration:${it_num} percent:${LABEL} ps:${file}"
#        if [ ! -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/${file}/confout.gro ] ; then
#         i=0
#        else
#          i=$(( $i+1 ))
#        fi
#    done
#    if [ "$i" -ge "$len" ] ; then
#      echo "NPT_${novel} complete... moving forward"
#      sleep 1
#      break
#    else
#      echo "waiting for NPT_${novel} to complete"
#      sleep 600
#      if [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/${file}/md.log] ; then 
#        tail -11 $ILhome/${it_num}.${LABEL}/NPT_${novel}/${file}/md.log
#      fi
#    fi
#  done
#fi
###RUN NVT PRODUCTION
if [ "$nvt_production" == "yes" ] ; then
  for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
    if [ ! -d $ILhome/${it_num}.${LABEL}/NVT_${novel} ] ; then
      mkdir $ILhome/${it_num}.${LABEL}/NVT_${novel}
    fi
    cd $ILhome/${it_num}.${LABEL}
    if [ -f NVT_${novel}/confout.gro ] ; then    
      echo "NVT_${novel} ${it_num}.${LABEL} files present..." 
    elif [ ! -f NVT_${novel}/conf.gro ] ; then  	
      echo "creating new files: ${it_num}.${LABEL}/NVT_${novel}/"   
      if [ ! -d NVT_${novel}/ ] ; then	
        mkdir NVT_${novel}/
      fi
      cp $ILhome/${it_num}.${LABEL}/equilibrate/confout.gro NVT_${novel}/conf.gro
      cp $MDP/GROMACS_5.pbs NVT_${novel}/GROMACS.pbs
      cp $MDP/nvt.mdp NVT_${novel}/nvt.mdp
      cp $SANDBOX/nodeseaker.sh NVT_${novel}/nodeseaker.sh
      cp $ILhome/${it_num}.${LABEL}/equilibrate/topol.top NVT_${novel}/
      cd NVT_${novel}/
      sed -i "7s/.*/nsteps                  =  ${nvt_length}/" nvt.mdp 
      sed -i "50s/.*/ref_t			= ${currentTemp}/" nvt.mdp 
      sed -i "54s/.*/gen_temp		= ${currentTemp}/" nvt.mdp 
        if [ "${comremoval}" = "yes" ] ; then
          sed -i "12s/.*/comm_mode                 =  Linear/" nvt.mdp
        elif [ "${comremoval}" = "no" ] ; then
          sed -i "12s/.*/comm_mode                 =  None/" nvt.mdp
        fi    
      gmx_8c grompp -f nvt.mdp -maxwarn 2
      source nodeseaker.sh
      wait
      qsub GROMACS.pbs
      sleep 5
      echo "NVT_${novel} setup for ${it_num}.${LABEL} file complete" 
    elif [ ! -f NVT_${novel}/confout.gro ] && [ -f NVT_${novel}/md.log ] ; then  	
      cd NVT_${novel}/
      source nodeseaker.sh
      wait
      qsub GROMACS.pbs
      sleep 5
      cd -
    else
      echo "It looks like ${it_num}.${LABEL} is currently running NVT_${novel}"
    fi
  done
  cd $ILhome/
  i=0
  while true ; do
    for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
      echo "checking NVT_${novel} files for iteration:${it_num} Temp:${LABEL}"
        if [ ! -f $ILhome/${it_num}.${LABEL}/NVT_${novel}/confout.gro ] ; then
         i=0
         echo "waiting on NVT files for ${it_num}.${LABEL}"
        else
          i=$(( $i+1 ))
        fi
    done
    if [ "$i" -ge "$len" ] ; then
      echo "NVT_${novel} complete... moving forward"
      sleep 1
      break
    else
      sleep 600
      echo "waiting for production to complete"
      if [ -f $ILhome/${it_num}.${LABEL}/NVT_${novel}/md.log ] ; then 
        tail -11 $ILhome/${it_num}.${LABEL}/NVT_${novel}/md.log
      fi
    fi
  done
fi
echo "production runs complete"
cd $SANDBOX

#!/bin/bash
set -e

###ENERGY MINIMIZE THE STARTING STRUCTURE
echo " "
echo "beginning ${LABEL} runs"
cd $ILhome
if [ ! -d $ILhome/${LABEL}/ ] ; then
  mkdir ${LABEL}
  echo "made new directory $ILhome/${LABEL}"
fi
cd ${LABEL}
if [ ! -d $ILhome/${LABEL}/mini ] ; then
  mkdir mini
  echo "made ${LABEL}/mini directory"
fi
if [ ! -f mini/confout.gro ] && [ ! -f mini/md.log ] ; then
  echo "initiating energy minimization for ${LABEL}"
  cp $SANDBOX/mini.mdp mini/
  cp $SANDBOX/GROMACS.pbs mini/
  cp $SANDBOX/nodeseaker.sh mini/
  cp $SANDBOX/conf.gro mini/
  cp $SANDBOX/topol.top mini/
  cd mini/
  gmx_8c grompp -f mini.mdp
  source nodeseaker.sh
  wait
  qsub GROMACS.pbs
  cd -
fi
i=0
while true ; do
  if [ ! -f $ILhome/${LABEL}/mini/confout.gro ] ; then
    echo "waiting for minimization to complete"
    sleep 60
  else
    echo "minimization complete... moving forward"
    sleep 1
    break
  fi
done
###EQUILIBRATE THE SYSTEM
if [ -f $ILhome/${LABEL}/mini/confout.gro ] ; then  
  if [ ! -d $ILhome/${LABEL}/equilibrate ] ; then
    mkdir $ILhome/${LABEL}/equilibrate
    echo "made $ILhome/${LABEL}/equilibrate directory"
  fi
  cd $ILhome/${LABEL}
  if [ -f equilibrate/confout.gro ] ; then    
    echo "equilibrate  files present..."
  elif [ ! -f equilibrate/md.log ] ; then	#note: re-qsubing GROMACS.pbs
    echo "creating new files: ${LABEL}/equilibrate/" #will not obstruct a run
    if [ ! -d equilibrate/ ] ; then		     #in progress
      mkdir equilibrate/
    fi
    cp mini/confout.gro equilibrate/conf.gro
    cp mini/topol.top equilibrate/
    cp $SANDBOX/GROMACS.pbs equilibrate/GROMACS.pbs
    cp $SANDBOX/nptber.mdp equilibrate/npt.mdp #we are only running for 50 ps
    cp $SANDBOX/nodeseaker.sh equilibrate/nodeseaker.sh #in a real production
    cd equilibrate/			#you would run much longer eqlbration
    sed -i "51s/.*/ref_t			= ${Temp}/" npt.mdp 
    sed -i "62s/.*/gen_temp		= ${Temp}/" npt.mdp 
    gmx_8c grompp -f npt.mdp -maxwarn 1
    source nodeseaker.sh
    wait
    qsub GROMACS.pbs
    sleep 5
    cd -
    echo "equilibration setup for ${LABEL} file complete" 
  else
    echo "It looks like ${LABEL} is currently running"
  fi
fi
cd $ILhome/
while true ; do
  if [ ! -f $ILhome/${LABEL}/equilibrate/confout.gro ] ; then
    echo "waiting for equilibration to complete"
    if [ -f $ILhome/${LABEL}/equilibrate/md.log ] ; then 
      tail -11 $ILhome/${LABEL}/equilibrate/md.log
    fi
    sleep 600
  else
    echo "equilibration complete... moving forward"
    sleep 1
    break
  fi
done
###RUN PARRINELLO-RAHMAN
if [ "$npt_production" == "yes" ] ; then
  if [ ! -d $ILhome/${LABEL}/NPT ] ; then
    mkdir $ILhome/${LABEL}/NPT
  fi
  cd $ILhome/${LABEL}
  if [ -f NPT/confout.gro ] ; then    
    echo "NPT  files present..." 
  elif [ ! -f NPT/conf.gro ] ; then  	
    echo "creating new files: ${LABEL}/NPT"   
    if [ ! -d NPT ] ; then	
      mkdir NPT
    fi
    cp $ILhome/${LABEL}/equilibrate/confout.gro NPT/conf.gro
    cp $SANDBOX/GROMACS.pbs NPT/
    cp $SANDBOX/nptpar.mdp NPT/npt.mdp
    cp $ILhome/${LABEL}/equilibrate/topol.top NPT/
    cd NPT
    sed -i "8s/.*/nsteps                  =  ${npt_length}/" npt.mdp 
    sed -i "51s/.*/ref_t			= ${Temp}/" npt.mdp 
    sed -i "62s/.*/gen_temp		= ${Temp}/" npt.mdp 
    gmx_8c grompp -f npt.mdp -maxwarn 2
    qsub GROMACS.pbs
    echo "NPT setup for ${LABEL} file complete" 
  elif [ ! -f NPT/confout.gro ] && [ -f NPT/md.log ] ; then  	
    cd NPT
    qsub GROMACS.pbs
    cd -
  else
    echo "It looks like ${LABEL}  is currently running NPT"
  fi
  cd $ILhome/${LABEL}/NPT
  while true ; do
    if [ ! -f $ILhome/${LABEL}/NPT/confout.gro ] ; then
      echo "waiting for NPT to complete"
      if [ -f $ILhome/${LABEL}/NPT/md.log] ; then 
        tail -11 $ILhome/${LABEL}/NPT/md.log
      fi
      sleep 600
    else
      echo "NPT complete... moving forward"
      sleep 1
      break
    fi
  done
fi
###RUN NVT PRODUCTION
if [ "$nvt_production" == "yes" ] ; then
  if [ ! -d $ILhome/${LABEL}/NVT ] ; then
    mkdir $ILhome/${LABEL}/NVT
  fi
  cd $ILhome/${LABEL}
  if [ -f NVT/confout.gro ] ; then    
    echo "NVT ${LABEL} files present..." 
  elif [ ! -f NVT/conf.gro ] ; then  	
    echo "creating new files: ${LABEL}/NVT"   
    if [ ! -d NVT ] ; then	
      mkdir NVT
    fi
    cp $ILhome/${LABEL}/equilibrate/confout.gro NVT/conf.gro
    cp $SANDBOX/GROMACS.pbs NVT/
    cp $SANDBOX/nvt.mdp NVT/
    cp $SANDBOX/nodeseaker.sh NVT/
    cp $ILhome/${LABEL}/equilibrate/topol.top NVT/
    cd NVT
    sed -i "7s/.*/nsteps                  =  ${nvt_length}/" nvt.mdp 
    sed -i "50s/.*/ref_t			= ${Temp}/" nvt.mdp 
    sed -i "54s/.*/gen_temp		= ${Temp}/" nvt.mdp 
    gmx_8c grompp -f nvt.mdp -maxwarn 2
    source nodeseaker.sh
    wait
    qsub GROMACS.pbs
    sleep 5
    echo "NVT setup for ${LABEL} file complete" 
  elif [ ! -f NVTconfout.gro ] && [ -f NVTmd.log ] ; then  	
    cd NVT
    source nodeseaker.sh
    wait
    qsub GROMACS.pbs
    sleep 5
    cd -
  else
    echo "It looks like ${LABEL} is currently running NVT"
  fi
  cd $ILhome/
  while true ; do
    if [ ! -f $ILhome/${LABEL}/NVTconfout.gro ] ; then
      echo "waiting for production to complete"
      if [ -f $ILhome/${LABEL}/NVTmd.log ] ; then 
        tail -11 $ILhome/${LABEL}/NVTmd.log
      fi
      sleep 600
         echo "waiting on NVT files for ${LABEL}"
    else
      echo "NVT complete... moving forward"
      sleep 1
      break
    fi
  done
fi
echo "production runs complete"
cd $SANDBOX

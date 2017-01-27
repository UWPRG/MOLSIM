#!/bin/bash
set -e

###ENERGY MINIMIZE THE STARTING STRUCTURE
cd $PROJROOT
if [ ! -d $PROJROOT/mini ] ; then
  mkdir mini
  echo "made mini directory"
fi
if [ ! -f mini/confout.gro ] && [ ! -f mini/md.log ] ; then
  echo "initiating energy minimization for ${name}"
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
while true ; do
  if [ ! -f $PROJROOT/mini/confout.gro ] ; then
    echo "waiting for minimization to complete"
    sleep 60
  else
    echo "minimization complete... moving forward"
    sleep 1
    break
  fi
done
###EQUILIBRATE THE SYSTEM
if [ -f $PROJROOT/mini/confout.gro ] ; then  
  if [ ! -d $PROJROOT/equilibrate ] ; then
    mkdir $PROJROOT/equilibrate
    echo "made $PROJROOT/equilibrate directory"
  fi
  cd $PROJROOT/
  if [ -f equilibrate/confout.gro ] ; then    
    echo "equilibrate  files present..."
  elif [ ! -f equilibrate/md.log ] ; then	#note: re-qsubing GROMACS.pbs
    echo "creating new files: equilibrate/" #will not obstruct a run
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
    echo "equilibration setup for ${name} file complete" 
  else
    echo "It looks like ${name} is currently running"
  fi
fi
cd $PROJROOT/
while true ; do
  if [ ! -f $PROJROOT/equilibrate/confout.gro ] ; then
    echo "waiting for equilibration to complete"
    if [ -f $PROJROOT/equilibrate/md.log ] ; then 
      tail -11 $PROJROOT/equilibrate/md.log
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
  if [ ! -d $PROJROOT/NPT ] ; then
    mkdir $PROJROOT/NPT
  fi
  cd $PROJROOT/
  if [ -f NPT/confout.gro ] ; then    
    echo "NPT  files present..." 
  elif [ ! -f NPT/conf.gro ] ; then  	
    echo "creating new files: NPT"   
    if [ ! -d NPT ] ; then	
      mkdir NPT
    fi
    cp $PROJROOT/equilibrate/confout.gro NPT/conf.gro
    cp $SANDBOX/GROMACS.pbs NPT/
    cp $SANDBOX/nptpar.mdp NPT/npt.mdp
    cp $PROJROOT/equilibrate/topol.top NPT/
    cd NPT
    sed -i "8s/.*/nsteps                  =  ${npt_length}/" npt.mdp 
    sed -i "51s/.*/ref_t			= ${Temp}/" npt.mdp 
    sed -i "62s/.*/gen_temp		= ${Temp}/" npt.mdp 
    gmx_8c grompp -f npt.mdp -maxwarn 2
    qsub GROMACS.pbs
    echo "NPT setup for ${name} file complete" 
  elif [ ! -f NPT/confout.gro ] && [ -f NPT/md.log ] ; then  	
    cd NPT
    qsub GROMACS.pbs
    cd -
  else
    echo "It looks like ${name}  is currently running NPT"
  fi
  cd $PROJROOT/NPT
  while true ; do
    if [ ! -f $PROJROOT/NPT/confout.gro ] ; then
      echo "waiting for NPT to complete"
      if [ -f $PROJROOT/NPT/md.log] ; then 
        tail -11 $PROJROOT/NPT/md.log
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
  if [ ! -d $PROJROOT/NVT ] ; then
    mkdir $PROJROOT/NVT
  fi
  cd $PROJROOT/
  if [ -f NVT/confout.gro ] ; then    
    echo "NVT ${name} files present..." 
  elif [ ! -f NVT/conf.gro ] ; then  	
    echo "creating new files: NVT"   
    if [ ! -d NVT ] ; then	
      mkdir NVT
    fi
    cp $PROJROOT/equilibrate/confout.gro NVT/conf.gro
    cp $SANDBOX/GROMACS.pbs NVT/
    cp $SANDBOX/nvt.mdp NVT/
    cp $SANDBOX/nodeseaker.sh NVT/
    cp $PROJROOT/equilibrate/topol.top NVT/
    cd NVT
    sed -i "7s/.*/nsteps                  =  ${nvt_length}/" nvt.mdp 
    sed -i "50s/.*/ref_t			= ${Temp}/" nvt.mdp 
    sed -i "54s/.*/gen_temp		= ${Temp}/" nvt.mdp 
    gmx_8c grompp -f nvt.mdp -maxwarn 2
    source nodeseaker.sh
    wait
    qsub GROMACS.pbs
    sleep 5
    echo "NVT setup for ${name} file complete" 
  elif [ ! -f NVTconfout.gro ] && [ -f NVTmd.log ] ; then  	
    cd NVT
    source nodeseaker.sh
    wait
    qsub GROMACS.pbs
    sleep 5
    cd -
  else
    echo "It looks like ${name} is currently running NVT"
  fi
  cd $PROJROOT/
  while true ; do
    if [ ! -f $PROJROOT/NVT/confout.gro ] ; then
      echo "waiting for production to complete"
      if [ -f $PROJROOT/NVT/md.log ] ; then 
        tail -11 $PROJROOT/NVT/md.log
      fi
      sleep 600
         echo "waiting on NVT files for ${name}"
    else
      echo "NVT complete... moving forward"
      sleep 1
      break
    fi
  done
fi
echo "production runs complete"
cd $SANDBOX

#!/bin/bash
echo "starting spDiskClean"
#SAVE PARRINELLO-RAHMAN TRAJECTORIES
if [ "${npt_production}" == "yes" ] ; then

for (( it_num=${startbump} ; it_num<=${len} ; it_num++ )) ; do
  echo " "
  echo "Cleaning files"
  cd $ILhome/${it_num}.${LABEL}
  if [ ! -d $ILhome/${it_num}.${LABEL}/NPTtraj_${novel} ] ; then
    mkdir $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}
  fi
  if [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.xtc ] ; then    
    echo "${it_num} $LABEL NPT xtc present..." 
  elif [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/traj_comp.xtc ] ; then    
      mv $ILhome/${it_num}.${LABEL}/NPT_${novel}/traj_comp.xtc NPTtraj_${novel}/${it_num}.$LABEL.xtc
  elif [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/traj.xtc ] ; then    
      mv $ILhome/${it_num}.${LABEL}/NPT_${novel}/traj.xtc NPTtraj_${novel}/${it_num}.$LABEL.xtc
  else
    echo "no xtc to move in $ILhome/${it_num}.${LABEL}/NPT_${novel}/"
  fi
  if [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.edr ] ; then    
    echo "${it_num} $LABEL NPT edr present..." 
  elif [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/ener.edr ] ; then  	
    mv $ILhome/${it_num}.${LABEL}/NPT_${novel}/ener.edr NPTtraj_${novel}/${it_num}.$LABEL.edr
  else
    echo "no edr to move in $ILhome/${it_num}.${LABEL}/NPT_${novel}/"
  fi
  if [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.gro ] ; then    
    echo "${it_num} $LABEL NPT gro present..." 
  elif [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/conf.gro ] ; then  	
    mv $ILhome/${it_num}.${LABEL}/NPT_${novel}/conf.gro NPTtraj_${novel}/${it_num}.$LABEL.gro
  else
    echo "no gro to move in $ILhome/${it_num}.${LABEL}/NPT_${novel}/"
  fi
  cd -
done

fi
      
if [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.xtc ] && [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.edr ] && [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.gro ] ; then 
  echo "cleaning files"
#  rm -rf $ILhome/${it_num}.${LABEL}/equilibrate
#  rm -rf $ILhome/${it_num}.${LABEL}/hot
#  rm -rf $ILhome/${it_num}.${LABEL}/mini
  rm -rf $ILhome/${it_num}.${LABEL}/NPT_${novel}/
fi

#SAVE NVT TRAJECTORIES

if [ "${nvt_production}" == "yes" ] ; then

  for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
    cd $ILhome/${it_num}.${LABEL}
    if [ ! -d $ILhome/${it_num}.${LABEL}/NVTtraj_${novel} ] ; then
      mkdir $ILhome/${it_num}.${LABEL}/NVTtraj_${novel}
    fi
    if [ -f $ILhome/${it_num}.${LABEL}/NVTtraj_${novel}/${it_num}.$LABEL.xtc ] ; then    
      echo "${it_num} $LABEL NVT xtc present..." 
    elif [ -f $ILhome/${it_num}.${LABEL}/NVT_${novel}/traj_comp.xtc ] ; then    
        mv $ILhome/${it_num}.${LABEL}/NVT_${novel}/traj_comp.xtc NVTtraj_${novel}/${it_num}.$LABEL.xtc
    elif [ -f $ILhome/${it_num}.${LABEL}/NVT_${novel}/traj.xtc ] ; then    
        mv $ILhome/${it_num}.${LABEL}/NVT_${novel}/traj.xtc NVTtraj_${novel}/${it_num}.$LABEL.xtc
    else
      echo "no xtc to move in $ILhome/${it_num}.${LABEL}/NVT_${novel}/"
    fi
    if [ -f $ILhome/${it_num}.${LABEL}/NVTtraj_${novel}/${it_num}.$LABEL.edr ] ; then    
      echo "${it_num} $LABEL NVT edr present..." 
    elif [ -f $ILhome/${it_num}.${LABEL}/NVT_${novel}/ener.edr ] ; then  	
      mv $ILhome/${it_num}.${LABEL}/NVT_${novel}/ener.edr NVTtraj_${novel}/${it_num}.$LABEL.edr
    else
      echo "no edr to move in $ILhome/${it_num}.${LABEL}/NVT_${novel}/"
    fi
    if [ -f $ILhome/${it_num}.${LABEL}/NVTtraj_${novel}/${it_num}.$LABEL.gro ] ; then    
      echo "${it_num} $LABEL NVT gro present..." 
    elif [ -f $ILhome/${it_num}.${LABEL}/NVT_${novel}/conf.gro ] ; then  	
      mv $ILhome/${it_num}.${LABEL}/NVT_${novel}/conf.gro NVTtraj_${novel}/${it_num}.$LABEL.gro
    else
      echo "no gro to move in $ILhome/${it_num}.${LABEL}/NVT_${novel}/"
    fi
    cd -
  done
        
  if [ -f $ILhome/${it_num}.${LABEL}/NVTtraj_${novel}/${it_num}.$LABEL.xtc ] && [ -f $ILhome/${it_num}.${LABEL}/NVTtraj_${novel}/${it_num}.$LABEL.edr ] && [ -f $ILhome/${it_num}.${LABEL}/NVTtraj_${novel}/${it_num}.$LABEL.gro ] ; then 
    echo "cleaning files"
  #  rm -rf $ILhome/${it_num}.${LABEL}/equilibrate
  #  rm -rf $ILhome/${it_num}.${LABEL}/hot
  #  rm -rf $ILhome/${it_num}.${LABEL}/mini
  #   rm -rf $ILhome/${it_num}.${LABEL}/NVT_${novel}/
  fi
fi

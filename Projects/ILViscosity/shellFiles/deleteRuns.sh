#!/bin/bash

#SAVE PARRINELLO-RAHMAN TRAJECTORIES

if [ ! -d $ILhome/${it_num}.${LABEL}/NPTtraj_${novel} ] ; then
  mkdir $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}
fi
for i in "${t[@]}"; do
  cd $ILhome/${it_num}.${LABEL}
  if [ $i != 10000 ] ; then
    v=${i:0:1}
  else
    v=${i:0:2}
  fi
  if [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.${v}ns.xtc ] ; then    
    echo "${it_num} $LABEL NPT ${v}ns xtc present..." 
  elif [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}/traj_comp.xtc ] ; then    
      mv $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}/traj_comp.xtc NPTtraj_${novel}/${it_num}.$LABEL.${v}ns.xtc
  elif [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}/traj.xtc ] ; then    
      mv $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}/traj.xtc NPTtraj_${novel}/${it_num}.$LABEL.${v}ns.xtc
  else
    echo "no xtc to move in $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}"
  fi
  if [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.${v}ns.edr ] ; then    
    echo "${it_num} $LABEL NPT ${v}ns edr present..." 
  elif [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}/ener.edr ] ; then  	
    mv $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}/ener.edr NPTtraj_${novel}/${it_num}.$LABEL.${v}ns.edr
  else
    echo "no edr to move in $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}"
  fi
  if [ -f $ILhome/${it_num}.${LABEL}/NPTtraj_${novel}/${it_num}.$LABEL.${v}ns.gro ] ; then    
    echo "${it_num} $LABEL NPT ${v}ns gro present..." 
  elif [ -f $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}/conf.gro ] ; then  	
    mv $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}/conf.gro NPTtraj_${novel}/${it_num}.$LABEL.${v}ns.gro
  else
    echo "no gro to move in $ILhome/${it_num}.${LABEL}/NPT_${novel}/${i}"
  fi
  cd -
done
if [ -f NPT_${novel}/$i/confout.gro ] ; then  	
  echo "cleaning files"
#  rm -rf $ILhome/${it_num}.${LABEL}/equilibrate
#  rm -rf $ILhome/${it_num}.${LABEL}/hot
#  rm -rf $ILhome/${it_num}.${LABEL}/mini
  rm -rf $ILhome/${it_num}.${LABEL}/NPT_${novel}/
fi
#

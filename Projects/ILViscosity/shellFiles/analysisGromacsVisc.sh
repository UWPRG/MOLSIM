#!/bin/bash
###NOTES FOR FINAL VERSION
#will want to remove '1' directory. This was originally
#there to seed multiple viscosity measurements from the 
#same time in the NPT run. It would be better to pull
#from different places in the NPT run

#might replace 't' with a read-in from the jobhandler script
###
#run g_energy and prepare output files for python

for g in "${VISCLABEL[@]}"; do
  echo "Processing ${it_num}.${LABEL} for $g analysis..."
  cd $ILhome
  cd ${it_num}.${LABEL}
  ###make and grab the g_energy files
  if [ ! -d analysis_files/ ] ; then
    mkdir analysis_files
  fi
  cd $g
    for h in "${t[@]}"; do
      if [ $h != 10000 ] ; then
        v=${h:0:1}
      else 
        v=${h:0:2}
      fi
      for (( i=1 ; i<=$s ; i++ )) ; do 
        #check if analysis has been done
        if [ ! -f $ILhome/${it_num}.${LABEL}/analysis_files/${it_num}.${LABEL}.${v}ns.$i.$g ] && [ -f $ILhome/${it_num}.${LABEL}/$g/$h/$i/ener.edr ] ; then
         #run g_energy
         cd $h/$i
         gmx_8c energy -f ener.edr -vis -xvg none
         grep ^" " energy.xvg | awk '{print $1,$2,$3}' | tr ' ' ',' >> ${it_num}.${LABEL}.${v}ns.$i.$g
         mv ${it_num}.${LABEL}.${v}ns.$i.$g ../../../analysis_files/
         if [ -f \#* ] ; then
           rm \#*
         fi
         cd -
        elif [ ! -f $ILhome/${it_num}.${LABEL}/analysis_files/${it_num}.${LABEL}.${v}ns.$i.$g ] && [ ! -f $ILhome/${it_num}.${LABEL}/$g/$h/$i/ener.edr ] ; then
          echo ${it_num}.${LABEL}.$h.$i.$g still running
        else
          echo ${it_num}.${LABEL}.${v}ns.$i.$g file present
        fi
      done
    done
 ###run python script to do some neat stuff
 # cd $ILhome/$FILES/analysis_files
 # python ../../../algorithm_sandbox/viscosity.py $RUNS
  cd $SANDBOX
done

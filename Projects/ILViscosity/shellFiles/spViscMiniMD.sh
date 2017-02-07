###Need to fix v=labels
###VISCOSITY RUNS
for j in "${VISC[@]}"; do
  for k in "${t[@]}"; do
    if [ ! -d $ILhome/${it_num}.${LABEL}/viscosity$j ] ; then
      mkdir $ILhome/${it_num}.${LABEL}/viscosity$j 
    fi
    if [ ! -d $ILhome/${it_num}.${LABEL}/viscosity$j/$k ] ; then
      mkdir $ILhome/${it_num}.${LABEL}/viscosity$j/$k
    fi
    for ((i=1 ; i<=$s ; i++ )) ; do
      cd $ILhome/${it_num}.${LABEL}
      if [ -f viscosity$j/$k/$i/confout.gro ] ; then
        echo "${it_num}.${LABEL} viscosity$j npt$k replicate$i files present... moving forward"
      elif [ ! -f viscosity$j/$k/$i/md.log ] ; then
        echo "creating new files: ${it_num}.${LABEL}/viscosity$j/$k/$i"
        sleep 1
        if [ ! -d viscosity$j/$k/$i ] ; then
          mkdir viscosity$j/$k/$i
        fi
        if [ $k != 10000 ] ; then
          v=${k:0:1}
        else
          v=${k:0:2}
        fi
        cp $MDP/GROMACS_5_visc.pbs viscosity$j/$k/$i/GROMACS.pbs
        cp $MDP/npt.visc.mdp viscosity$j/$k/$i/npt.mdp
        sed -i "66s/.*/cos-acceleration=${j}/" viscosity$j/$k/$i/npt.mdp 
        sed -i "51s/.*/ref_t			= ${currentTemp}/" viscosity$j/$k/$i/npt.mdp 
        sed -i "62s/.*/gen_temp			= ${currentTemp}/" viscosity$j/$k/$i/npt.mdp 
	if [ "${comremoval}" = "yes" ] ; then
	  sed -i "12s/.*/comm_mode                 =  Linear/" viscosity$j/$k/$i/npt.mdp
        elif [ "${comremoval}" = "no" ] ; then
	  sed -i "12s/.*/comm_mode                 =  None/" viscosity$j/$k/$i/npt.mdp
	fi    
        if [ ! -d $ILhome/${it_num}.${LABEL}/NPT/ ] ; then
          cd NPTtraj_${novel} 
          if [ "$loop" == "Temperature" ] ; then
            cp $SETUP/system/topol.top .
	  elif [ "$loop" == "ML" ] ; then
            cp $SETUP/${it_num}.${LABEL}/topol.top .
          fi
          gmx_8c grompp -f npt.mdp -c ${it_num}.${LABEL}.${v}ns.gro -maxwarn 1
	  
          echo 0 | gmx_8c trjconv -f ${it_num}.${LABEL}.${v}ns.xtc -b 5000 -e 5000 -o conf.gro
          wait
          mv conf.gro ../viscosity$j/$k/$i/conf.gro
          cd -
        else
          cp NPT/$k/confout.gro viscosity$j/$k/$i/conf.gro
        fi  

        if [ "$loop" == "Temperature" ] ; then
          cp $SETUP/system/topol.top viscosity$j/$k/$i/
	elif [ "$loop" == "ML" ] ; then
          cp $SETUP/${it_num}.${LABEL}/topol.top viscosity$j/$k/$i/
        fi
           

        echo "processing ${it_num}.${LABEL}/viscosity${j}/${k}/${i} files... complete"
        sleep 1
        echo "initiating ${it_num}.${LABEL}/viscosity${j}/${k}/${i} viscosity${j} simulations"
        sleep 1
        cd $ILhome/${it_num}.${LABEL}/viscosity${j}/${k}/${i}
        sleep 1
        gmx_8c grompp -f npt.mdp -maxwarn 2
        wait
        qsub -q bf GROMACS.pbs
        wait
      else
        echo "${it_num}.${LABEL} ${j} ${k} ${i} appears to be running"
      fi
    done
  done
done
cd $ILhome/${it_num}.${LABEL}
i=0
while true ; do
  for j in "${VISC[@]}"; do
    for file in "${t[@]}" ; do
      for ((k=1 ; k<=$s ; k++ )) ; do
          if [ ! -f $ILhome/${it_num}.${LABEL}/viscosity${j}/${file}/${k}/confout.gro ] ; then
            i=0
            echo "waiting for ${it_num}.${LABEL}/viscosity${j}/${file}/${k}/confout.gro"
            sleep 2
          else
            i=$(( $i+1 ))
          fi
      done
   done
 done
 if [ "$i" -ge "$lenViscRuns" ] ; then
   echo "viscosity complete... moving forward"
   sleep 1
   break
 fi
done
cd $SANDBOX

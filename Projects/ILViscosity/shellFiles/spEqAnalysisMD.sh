echo "starting spEqAnalysis"
###Search the leap.log file for the size of the box created.

###EQ calculations
for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
  if [ "$nvt_production" == "yes" ] ; then
    cd ${ILhome}/${it_num}.${LABEL}/NVTtraj_${novel} 
    cp $MDP/nvt.mdp npt.mdp
    BOX_X=`cat ${it_num}.${LABEL}.gro | tail -1 | awk {'print $1'}`
    BOX_Y=`cat ${it_num}.${LABEL}.gro | tail -1 | awk {'print $2'}`
    BOX_Z=`cat ${it_num}.${LABEL}.gro | tail -1 | awk {'print $3'}`
    BOX_VOLUME=`echo "scale=3; $BOX_X*$BOX_Y*$BOX_Z" | bc`
  elif [ "$npt_production" == "yes" ] ; then
    cd ${ILhome}/${it_num}.${LABEL}/NPTtraj_${novel} 
    cp $MDP/nptpar.mdp npt.mdp
  fi
  #cd ${PROJROOT}
  #cd ${ILhome}/${it_num}.${LABEL}
  if [ ! -d ${ILhome}/eq_analysis_${novel} ] ; then
    mkdir ${ILhome}/eq_analysis_${novel}
  fi
  #cd NPTtraj_${novel}
  cp $MDP/GROMACS_5.pbs .
  if [ "$loop" == "Temperature" ] ; then
    cp $SETUP/system/topol.top .
  elif [ "$loop" == "ML" ] ; then
    cp $SETUP/${it_num}.${LABEL}/topol.top .
  elif [ "$loop" == "none" ] ; then
    cp $SETUP/system/${it_num}/topol.top .
  fi

###make an energy file for viscosity
###first youll need a tpr file for md rerun
###md rerun will only generate the correct T,P
### if velocities were saved in the trajectory file
    if [ ! -f ${it_num}.${LABEL}.edr ] && [ ! -f ${it_num}.${LABEL}.tpr ] ; then 
      sed -i "37s/.*/traj=${it_num}.${LABEL}/" GROMACS_5.pbs
      sed -i "38s/.*/\$EXEC mdrun -rerun \${traj}.xtc -cpi restart -cpo restart -append -cpt 1.0/" GROMACS_5.pbs 
      gmx_8c grompp -f npt.mdp -c ${it_num}.${LABEL}.gro -maxwarn 1
      wait
      mv topol.tpr ${it_num}.${LABEL}.tpr
    fi
    if [ ! -f ${it_num}.${LABEL}.edr ] ; then
      qsub GROMACS_5.pbs
      while true ; do
        if [ -f ener.edr ] ; then
          break
        else
          echo "waiting on edr file for ${it_num} ${LABEL}"
          sleep 20 
        fi
      done
      mv ener.edr ${it_num}.${LABEL}.edr  
    fi
###*****************************************************************
###viscosity 
    if [ ! -f ${it_num}.${LABEL}_3.visc ] ; then
      echo "calculating viscosity for ${it_num}.${LABEL}" 
        sed -i "37s/.*/traj=${it_num}.${LABEL}/" GROMACS_5.pbs
      if [ "$nvt_production" == "yes" ] ; then
        sed -i "38s/.*/echo $BOX_VOLUME | \$EXEC energy -f \${traj}.edr -vis -xvg none/" GROMACS_5.pbs
      elif [ "$npt_production" == "yes" ] ; then
        sed -i "38s/.*/\$EXEC energy -f \${traj}.edr -vis -xvg none/" GROMACS_5.pbs
      fi
      qsub GROMACS_5.pbs
      while true ; do
        if [ -f evisco.xvg ] ; then
          break
        else
          echo "waiting on viscosity file for ${it_num} ${LABEL}"
          sleep 20 
        fi
      done
      mv evisco.xvg ${it_num}.${LABEL}_1.visc
      while true ; do
        if [ -f eviscoi.xvg ] ; then
          break
        else
          echo "waiting on viscosity file for ${it_num} ${LABEL}"
          sleep 20 
        fi
      done
      mv eviscoi.xvg ${it_num}.${LABEL}_2.visc
      while true ; do
        if [ -f visco.xvg ] ; then
          break
        else
          echo "waiting on viscosity file for ${it_num} ${LABEL}"
          sleep 20 
        fi
      done
      mv visco.xvg ${it_num}.${LABEL}_3.visc
      wait
    fi
    if [ ! -f ../../eq_analysis_${novel}/${it_num}.${LABEL}_3.visc ] ; then
      grep ^" " ${it_num}.${LABEL}_1.visc | awk '{print $1,$2,$3,$4,$5}' | tr ' ' ',' >> temp1
      grep ^" " ${it_num}.${LABEL}_2.visc | awk '{print $1,$2,$3,$4,$5}' | tr ' ' ',' >> temp2
      grep ^" " ${it_num}.${LABEL}_3.visc | awk '{print $1,$2,$3}' | tr ' ' ',' >> temp3
      mv temp1 ../../eq_analysis_${novel}/${it_num}.${LABEL}_1.visc 
      mv temp2 ../../eq_analysis_${novel}/${it_num}.${LABEL}_2.visc 
      mv temp3 ../../eq_analysis_${novel}/${it_num}.${LABEL}_3.visc 
    fi
done
for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
  if [ "$nvt_production" == "yes" ] ; then
    cd ${ILhome}/${it_num}.${LABEL}/NVTtraj_${novel} 
  elif [ "$npt_production" == "yes" ] ; then
    cd ${ILhome}/${it_num}.${LABEL}/NPTtraj_${novel} 
  fi
###*****************************************************************
###heat capacity   
  if [ ! -f ${it_num}.${LABEL}.Cp ] ; then
  nmol=`tail -2 ${it_num}.${LABEL}.gro | head -1 | awk '{print $1}' | sed "s/[[:alpha:].-]/ /g" | awk '{print $1}'`
  echo "calculating heat capacity for ${it_num}.${LABEL}" 
    echo 10 11 12 13 14 0 | gmx_8c energy -f ${it_num}.${LABEL}.edr -driftcorr -fluct_props -nmol ${nmol} >> ${it_num}.${LABEL}.Cp
    rm energy.xvg
  fi
  if [ "${SOLVENT_TYPE}" == "IL" ] ; then
    grep -i 'Heat capacity' ${it_num}.${LABEL}.Cp >> ${IL_CAT}.${IL_AN}.Cp 
  elif [ "${SOLVENT_TYPE}" == "DES" ] ; then
    grep -i 'Heat capacity' ${it_num}.${LABEL}.Cp >> ${IL_CAT}.${IL_AN}.${ORG_MOL}.Cp
  fi 
  if [ "${SOLVENT_TYPE}" == "IL" ] ; then
    if [ ! -f ${ILhome}/eq_analysis_${novel}/${it_num}.${LABEL}.Cp ] ; then
      cp ${it_num}.${LABEL}.Cp ${ILhome}/eq_analysis_${novel}/
    fi
  fi 
  wait
###*****************************************************************
###density
  if [ ! -f ${it_num}.${LABEL}.dens ] ; then
  echo "calculating density for ${it_num}.${LABEL}" 
    #you'll need a tpr file for gmx density
    if [ ! -f ${it_num}.${LABEL}.tpr ] ; then 
      gmx_8c grompp -f npt.mdp -c ${it_num}.${LABEL}.gro -maxwarn 1
      wait
      mv topol.tpr ${it_num}.${LABEL}.tpr
    fi 
    sed -i "37s/.*/traj=${it_num}.${LABEL}/" GROMACS_5.pbs
    sed -i "38s/.*/echo 0 | \$EXEC density -f \${traj}.xtc -s \${traj}.tpr -xvg none/" GROMACS_5.pbs
    qsub GROMACS_5.pbs
    while true ; do
      if [ -f density.xvg ] ; then
        break
      else
        echo "waiting for ${it_num}.${LABEL}.dens file"
        sleep 20 
      fi
    done
    mv density.xvg ${it_num}.${LABEL}.dens 
  fi
  if [ ! -f ../../eq_analysis_${novel}/${it_num}.${LABEL}.dens ] ; then
    grep ^" " ${it_num}.${LABEL}.dens | awk '{print $1,$2}' | tr ' ' ',' >> temp
    mv temp ../../eq_analysis_${novel}/${it_num}.${LABEL}.dens 
  fi
###*****************************************************************
###diffusion constant
done
for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
  if [ "$nvt_production" == "yes" ] ; then
    cd ${ILhome}/${it_num}.${LABEL}/NVTtraj_${novel} 
  elif [ "$npt_production" == "yes" ] ; then
    cd ${ILhome}/${it_num}.${LABEL}/NPTtraj_${novel} 
  fi
  if [ "${SOLVENT_TYPE}" == "IL" ] ; then
    if [ ! -f ${it_num}.${LABEL}.${IL_CAT}.diff ] ; then
    echo "calculating diffusivity for ${it_num}.${LABEL}" 

      sed -i "37s/.*/traj=${it_num}.${LABEL}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 2 | \$EXEC msd -f \${traj}.xtc -s \${traj}.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for ${it_num}.${LABEL}.${IL_CAT}.diff file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${IL_CAT}.diff 
    fi
    if [ ! -f ${it_num}.${LABEL}.${IL_AN}.diff ] ; then
      sed -i "37s/.*/traj=${it_num}.${LABEL}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 3 | \$EXEC msd -f \${traj}.xtc -s \${traj}.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for ${it_num}.${LABEL}.${IL_AN}.diff  file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${IL_AN}.diff 
    fi
    if [ ! -f ${ILhome}/eq_analysis_${novel}/${it_num}.${LABEL}.${IL_CAT}.diff ] ; then
      cp ${it_num}.${LABEL}.${IL_CAT}.diff ${ILhome}/eq_analysis_${novel}/
    fi
    if [ ! -f ${ILhome}/eq_analysis_${novel}/${it_num}.${LABEL}.${IL_AN}.diff ] ; then
      cp ${it_num}.${LABEL}.${IL_AN}.diff ${ILhome}/eq_analysis_${novel}/
    fi
  elif [ "${SOLVENT_TYPE}" == "DES" ] ; then
    if [ ! -f ${it_num}.${LABEL}.${IL_CAT}.diff ] ; then
      sed -i "37s/.*/traj=${it_num}.${LABEL}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 2 | \$EXEC msd -f \${traj}.xtc -s \${traj}.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for  ${it_num}.${LABEL}.${IL_CAT}.diff file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${IL_CAT}.diff 
    fi
    if [ ! -f ${it_num}.${LABEL}.${IL_AN}.diff ] ; then
      sed -i "37s/.*/traj=${it_num}.${LABEL}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 3 | \$EXEC msd -f \${traj}.xtc -s \${traj}.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for ${it_num}.${LABEL}.${IL_AN}.diff file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${IL_AN}.diff 
    fi
    if [ ! -f ${it_num}.${LABEL}.${ORG_MOL}.diff ] ; then
      sed -i "37s/.*/traj=${it_num}.${LABEL}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 4 | \$EXEC msd -f \${traj}.xtc -s \${traj}.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for ${it_num}.${LABEL}.${ORG_MOL}.diff file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${ORG_MOL}.diff 
    fi
  fi
done
###*****************************************************************
###PROPERTIES SUMMARY
if [ "${SOLVENT_TYPE}" == "IL" ] ; then
  cd ${ILhome}/eq_analysis_${novel}/
###VISCOSITY EINSTEIN
    if [ "${appendToProperties}" == "yes" ] ; then
      counter=1
      for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
	awk -F "\"*,\"*" '{print $5}' ${it_num}.${LABEL}_1.visc >> temp.${it_num} 
        if [ ${counter} -eq 1 ] ; then
          paste -d, temp.${it_num} >> out
          rm temp.${it_num}
        elif [ $((counter%2)) -eq 0 ] ; then
          paste -d, out temp.${it_num} >> out2
          rm out temp.${it_num}
        elif [ ! $((counter%2)) -eq 0 ] ; then
          paste -d, out2 temp.${it_num} >> out
          rm out2 temp.${it_num}
        fi
        counter=$(( $counter+1 ))
      done
      if [ -f out ] ; then
        mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.einsteinvisc
      elif [ -f out2 ] ; then
        mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.einsteinvisc
      fi
    fi 
###VISCOSITY GREEN-KUBO
    if [ "${appendToProperties}" == "yes" ] ; then
      counter=1
      for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
	awk -F "\"*,\"*" '{print $3}' ${it_num}.${LABEL}_3.visc >> temp.${it_num} 
        if [ ${counter} -eq 1 ] ; then
          paste -d, temp.${it_num} >> out
          rm temp.${it_num}
        elif [ $((counter%2)) -eq 0 ] ; then
          paste -d, out temp.${it_num} >> out2
          rm out temp.${it_num}
        elif [ ! $((counter%2)) -eq 0 ] ; then
          paste -d, out2 temp.${it_num} >> out
          rm out2 temp.${it_num}
        fi
        counter=$(( $counter+1 ))
      done
      if [ -f out ] ; then
        mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.greenkubo
      elif [ -f out2 ] ; then
        mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.greenkubo
      fi
    fi 
###DENSITY
    if [ "${appendToProperties}" == "yes" ] ; then
      counter=1
      for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
	awk -F "\"*,\"*" '{print $2}' ${it_num}.${LABEL}.dens >> temp.${it_num} 
        if [ ${counter} -eq 1 ] ; then
          paste -d, temp.${it_num} >> out
          rm temp.${it_num}
        elif [ $((counter%2)) -eq 0 ] ; then
          paste -d, out temp.${it_num} >> out2
          rm out temp.${it_num}
        elif [ ! $((counter%2)) -eq 0 ] ; then
          paste -d, out2 temp.${it_num} >> out
          rm out2 temp.${it_num}
        fi
        counter=$(( $counter+1 ))
      done
      if [ -f out ] ; then
        mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.dens
      elif [ -f out2 ] ; then
        mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.dens
      fi
    fi 
###HEAT CAPACITY
    if [ "${appendToProperties}" == "yes" ] ; then
      for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
        grep -i 'Heat capacity' ${it_num}.${LABEL}.Cp | awk '{print $8}' >> ${IL_CAT}.${IL_AN}.${LABEL}.${novel}.Cp
      done
      mv ${IL_CAT}.${IL_AN}.${LABEL}.${novel}.Cp ${PROPERTIES}/ 
    fi 
###DIFFUSIVITY
    if [ "${appendToProperties}" == "yes" ] ; then
      counter=1
      for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
        grep ^" " ${it_num}.${LABEL}.${IL_CAT}.diff | awk '{print $2}' | tr ' ' ',' >> temp.${it_num}
        if [ ${counter} -eq 1 ] ; then
          paste -d, temp.${it_num} >> out
          rm temp.${it_num}
        elif [ $((counter%2)) -eq 0 ] ; then
          paste -d, out temp.${it_num} >> out2
          rm out temp.${it_num}
        elif [ ! $((counter%2)) -eq 0 ] ; then
          paste -d, out2 temp.${it_num} >> out
          rm out2 temp.${it_num}
        fi
        counter=$(( $counter+1 ))
      done
      if [ -f out ] ; then
        mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.diff
      elif [ -f out2 ] ; then
        mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.diff
      fi
    fi
    if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.diff ] ; then
      counter=1
      for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
        grep ^" " ${it_num}.${LABEL}.${IL_AN}.diff | awk '{print $2}' | tr ' ' ',' >> temp.${it_num}
        if [ ${counter} -eq 1 ] ; then
          paste -d, temp.${it_num} >> out
          rm temp.${it_num}
        elif [ $((counter%2)) -eq 0 ] ; then
          paste -d, out temp.${it_num} >> out2
          rm out temp.${it_num}
        elif [ ! $((counter%2)) -eq 0 ] ; then
          paste -d, out2 temp.${it_num} >> out
          rm out2 temp.${it_num}
        fi
        counter=$(( $counter+1 ))
      done
      if [ -f out ] ; then
        mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.diff
      elif [ -f out2 ] ; then
        mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.diff
      fi
    fi
    if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.D ] ; then
      for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
        grep 'D\[' ${it_num}.${LABEL}.${IL_CAT}.diff | awk '{print $5,$6,$7}' >> temp
      done
      mv temp ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.D
    fi
    if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.D ] ; then
      for (( it_num=${startbump} ; it_num<=iterations ; it_num++ )) ; do
        grep 'D\[' ${it_num}.${LABEL}.${IL_AN}.diff | awk '{print $5,$6,$7}' >> temp
      done
      mv temp ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.D
    fi
echo "equilibrium analysis complete"
fi
cd $SANDBOX

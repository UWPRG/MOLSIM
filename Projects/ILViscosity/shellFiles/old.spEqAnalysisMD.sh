echo "spEqAnalysis running"
###EQ calculations
cd $ILhome/${it_num}.${LABEL}
if [ ! -d eq_analysis_${novel} ] ; then
  mkdir eq_analysis_${novel}
fi
cd NPTtraj_${novel} 
cp $MDP/GROMACS_5.pbs .
cp $MDP/nptpar_5ns.mdp npt.mdp
if [ "$loop" == "Temperature" ] ; then
  cp $SETUP/system/topol.top .
elif [ "$loop" == "ML" ] ; then
  cp $SETUP/${it_num}.${LABEL}/topol.top .
fi

for k in "${t[@]}"; do
    if [ "$k" -lt "10000" ] ; then
      v=${k:0:2}
    else
      v=${k:0:3}
    fi
###make an energy file for viscosity
###first you'll need a tpr file for md rerun
###md rerun will only generate the correct T,P
### if velocities were saved in the trajectory file
    if [ ! -f ${it_num}.${LABEL}.${v}ns.edr ] && [ ! -f ${it_num}.${LABEL}.${v}ns.tpr ] ; then 
      sed -i "37s/.*/traj=${it_num}.${LABEL}.${v}/" GROMACS_5.pbs
      sed -i "38s/.*/\$EXEC mdrun -rerun \${traj}ns.xtc -cpi restart -cpo restart -append -cpt 1.0/" GROMACS_5.pbs 
      gmx_8c grompp -f npt.mdp -c ${it_num}.${LABEL}.${v}ns.gro -maxwarn 1
      wait
      mv topol.tpr ${it_num}.${LABEL}.${v}ns.tpr
    fi 
    if [ ! -f ${it_num}.${LABEL}.${v}ns.edr ] ; then
      qsub GROMACS_5.pbs
      while true ; do
        if [ -f ener.edr ] ; then
          break
        else
          echo "waiting for edr file"
          sleep 20 
        fi
      done
      mv ener.edr ${it_num}.${LABEL}.${v}ns.edr  
    fi
###*****************************************************************
###viscosity 
    if [ ! -f ${it_num}.${LABEL}.${v}ns_3.visc ] ; then
    echo "calculating viscosity for ${it_num}.${LABEL}.${v}ns" 
      sed -i "37s/.*/traj=${it_num}.${LABEL}.${v}/" GROMACS_5.pbs
      sed -i "38s/.*/\$EXEC energy -f \${traj}ns.edr -vis -xvg none/" GROMACS_5.pbs
      qsub GROMACS_5.pbs
      while true ; do
        if [ -f evisco.xvg ] ; then
          break
        else
          echo "waiting for energy files"
          sleep 20 
        fi
      done
      mv evisco.xvg ${it_num}.${LABEL}.${v}ns_1.visc
      while true ; do
        if [ -f eviscoi.xvg ] ; then
          break
        else
          echo "waiting for energy files"
          sleep 20 
        fi
      done
      mv eviscoi.xvg ${it_num}.${LABEL}.${v}ns_2.visc
      while true ; do
        if [ -f visco.xvg ] ; then
          break
        else
          echo "waiting for energy files"
          sleep 20 
        fi
      done
      mv visco.xvg ${it_num}.${LABEL}.${v}ns_3.visc
      wait
    fi
    if [ ! -f ../eq_analysis_${novel}/${it_num}.${LABEL}.${v}ns_3.visc ] ; then
      grep ^" " ${it_num}.${LABEL}.${v}ns_1.visc | awk '{print $1,$2,$3,$4,$5}' | tr ' ' ',' >> temp1
      grep ^" " ${it_num}.${LABEL}.${v}ns_2.visc | awk '{print $1,$2,$3,$4,$5}' | tr ' ' ',' >> temp2
      grep ^" " ${it_num}.${LABEL}.${v}ns_3.visc | awk '{print $1,$2,$3}' | tr ' ' ',' >> temp3
      mv temp1 ../eq_analysis_${novel}/${it_num}.${LABEL}.${v}ns_1.visc 
      mv temp2 ../eq_analysis_${novel}/${it_num}.${LABEL}.${v}ns_2.visc 
      mv temp3 ../eq_analysis_${novel}/${it_num}.${LABEL}.${v}ns_3.visc 
    fi
done
for k in "${t[@]}"; do
  if [ "$k" -lt "10000" ] ; then
    v=${k:0:2}
  else
    v=${k:0:3}
  fi
###*****************************************************************
###heat capacity   
  if [ ! -f ${it_num}.${LABEL}.${v}ns.Cp ] ; then
  nmol=`tail -2 ${it_num}.${LABEL}.${v}ns.gro | head -1 | awk '{print $1}' | sed "s/[[:alpha:].-]/ /g" | awk '{print $1}'`
  echo "calculating heat capacity for ${it_num}.${LABEL}.${v}ns" 
    echo 10 11 12 13 14 0 | gmx_8c energy -f ${it_num}.${LABEL}.${v}ns.edr -driftcorr -fluct_props -nmol ${nmol} >> ${it_num}.${LABEL}.${v}ns.Cp
    rm energy.xvg
  fi
  if [ "${SOLVENT_TYPE}" == "IL" ] ; then
    grep -i 'Heat capacity' ${it_num}.${LABEL}.${v}ns.Cp >> ${IL_CAT}.${IL_AN}.Cp 
  elif [ "${SOLVENT_TYPE}" == "DES" ] ; then
    grep -i 'Heat capacity' ${it_num}.${LABEL}.${v}ns.Cp >> ${IL_CAT}.${IL_AN}.${ORG_MOL}.Cp
  fi 
  wait
###*****************************************************************
###density
  if [ ! -f ${it_num}.${LABEL}.${v}ns.dens ] ; then
  echo "calculating density for ${it_num}.${LABEL}.${v}ns" 
    #you'll need a tpr file for gmx density
    if [ ! -f ${it_num}.${LABEL}.${v}ns.tpr ] ; then 
      gmx_8c grompp -f npt.mdp -c ${it_num}.${LABEL}.${v}ns.gro -maxwarn 1
      wait
      mv topol.tpr ${it_num}.${LABEL}.${v}ns.tpr
    fi 
    sed -i "37s/.*/traj=${it_num}.${LABEL}.${v}/" GROMACS_5.pbs
    sed -i "38s/.*/echo 0 | \$EXEC density -f \${traj}ns.xtc -s \${traj}ns.tpr -xvg none/" GROMACS_5.pbs
    qsub GROMACS_5.pbs
    while true ; do
      if [ -f density.xvg ] ; then
        break
      else
        echo "waiting for ${it_num}.${LABEL}.${v}ns.dens file"
        sleep 20 
      fi
    done
    mv density.xvg ${it_num}.${LABEL}.${v}ns.dens 
  fi
  if [ ! -f ../eq_analysis_${novel}/${it_num}.${LABEL}.${v}ns.dens ] ; then
    grep ^" " ${it_num}.${LABEL}.${v}ns.dens | awk '{print $1,$2}' | tr ' ' ',' >> temp
    mv temp ../eq_analysis_${novel}/${it_num}.${LABEL}.${v}ns.dens 
  fi
###*****************************************************************
###diffusion constant
done
for k in "${t[@]}"; do
  if [ "$k" -lt "10000" ] ; then
    v=${k:0:2}
  else
    v=${k:0:3}
  fi
  if [ "${SOLVENT_TYPE}" == "IL" ] ; then
    if [ ! -f ${it_num}.${LABEL}.${v}ns.${IL_CAT}.diff ] ; then
    echo "calculating diffusivity for ${it_num}.${LABEL}.${v}ns" 

      sed -i "37s/.*/traj=${it_num}.${LABEL}.${v}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 2 | \$EXEC msd -f \${traj}ns.xtc -s \${traj}ns.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for ${it_num}.${LABEL}.${v}ns.${IL_CAT}.diff file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${v}ns.${IL_CAT}.diff 
    fi
    if [ ! -f ${it_num}.${LABEL}.${v}ns.${IL_AN}.diff ] ; then
      sed -i "37s/.*/traj=${it_num}.${LABEL}.${v}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 3 | \$EXEC msd -f \${traj}ns.xtc -s \${traj}ns.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for ${it_num}.${LABEL}.${v}ns.${IL_AN}.diff  file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${v}ns.${IL_AN}.diff 
    fi
  elif [ "${SOLVENT_TYPE}" == "DES" ] ; then
    if [ ! -f ${it_num}.${LABEL}.${v}ns.${IL_CAT}.diff ] ; then
      sed -i "37s/.*/traj=${it_num}.${LABEL}.${v}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 2 | \$EXEC msd -f \${traj}ns.xtc -s \${traj}ns.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for  ${it_num}.${LABEL}.${v}ns.${IL_CAT}.diff file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${v}ns.${IL_CAT}.diff 
    fi
    if [ ! -f ${it_num}.${LABEL}.${v}ns.${IL_AN}.diff ] ; then
      sed -i "37s/.*/traj=${it_num}.${LABEL}.${v}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 3 | \$EXEC msd -f \${traj}ns.xtc -s \${traj}ns.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for ${it_num}.${LABEL}.${v}ns.${IL_AN}.diff file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${v}ns.${IL_AN}.diff 
    fi
    if [ ! -f ${it_num}.${LABEL}.${v}ns.${ORG_MOL}.diff ] ; then
      sed -i "37s/.*/traj=${it_num}.${LABEL}.${v}/" GROMACS_5.pbs
      sed -i "38s/.*/echo 4 | \$EXEC msd -f \${traj}ns.xtc -s \${traj}ns.tpr -beginfit -1 -endfit -1/" GROMACS_5.pbs 
        qsub GROMACS_5.pbs
        while true ; do
          if [ -f msd.xvg ] ; then
            break
          else
            echo "waiting for ${it_num}.${LABEL}.${v}ns.${ORG_MOL}.diff file"
            sleep 20 
          fi
        done
       mv msd.xvg ${it_num}.${LABEL}.${v}ns.${ORG_MOL}.diff 
    fi
  fi
done
###*****************************************************************
###PROPERTIES SUMMARY
if [ "${SOLVENT_TYPE}" == "IL" ] ; then
###VISCOSITY
  if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.visc ] ; then
    counter=1
    for k in "${t[@]}"; do
      if [ "$k" -lt "10000" ] ; then
        v=${k:0:2}
      else
        v=${k:0:3}
      fi
      grep ^" " ${it_num}.${LABEL}.${v}ns_1.visc | awk '{print $5}' | tr ' ' ',' >> temp.${v}
      if [ ${counter} -eq 1 ] ; then
        paste -d, temp.${v} >> out
        rm temp.${v}
      elif [ $((counter%2)) -eq 0 ] ; then
        paste -d, out temp.${v} >> out2
        rm out temp.${v}
      elif [ ! $((counter%2)) -eq 0 ] ; then
        paste -d, out2 temp.${v} >> out
        rm out2 temp.${v}
      fi
      counter=$(( $counter+1 ))
    done
    if [ -f out ] ; then
      mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.visc
    elif [ -f out2] ; then
      mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.visc
    fi
  fi 
###DENSITY
  if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.dens ] ; then
    counter=1
    for k in "${t[@]}"; do
      if [ "$k" -lt "10000" ] ; then
        v=${k:0:2}
      else
        v=${k:0:3}
      fi
      grep ^" " ${it_num}.${LABEL}.${v}ns.dens | awk '{print $2}' | tr ' ' ',' >> temp.${v}
      if [ ${counter} -eq 1 ] ; then
        paste -d, temp.${v} >> out
        rm temp.${v}
      elif [ $((counter%2)) -eq 0 ] ; then
        paste -d, out temp.${v} >> out2
        rm out temp.${v}
      elif [ ! $((counter%2)) -eq 0 ] ; then
        paste -d, out2 temp.${v} >> out
        rm out2 temp.${v}
      fi
      counter=$(( $counter+1 ))
    done
    if [ -f out ] ; then
      mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.dens
    elif [ -f out2] ; then
      mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.dens
    fi
  fi 
  if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.Cp ] ; then
    grep -i 'Heat capacity' ${IL_CAT}.${IL_AN}.Cp | awk '{print $8}' >> ${IL_CAT}.${IL_AN}.${LABEL}.${novel}.Cp
    mv ${IL_CAT}.${IL_AN}.${LABEL}.${novel}.Cp ${PROPERTIES}/ 
  fi 
  if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.diff ] ; then
    counter=1
    for k in "${t[@]}"; do
      if [ "$k" -lt "10000" ] ; then
        v=${k:0:2}
      else
        v=${k:0:3}
      fi
      grep ^" " ${it_num}.${LABEL}.${v}ns.${IL_CAT}.diff | awk '{print $2}' | tr ' ' ',' >> temp.${v}
      if [ ${counter} -eq 1 ] ; then
        paste -d, temp.${v} >> out
        rm temp.${v}
      elif [ $((counter%2)) -eq 0 ] ; then
        paste -d, out temp.${v} >> out2
        rm out temp.${v}
      elif [ ! $((counter%2)) -eq 0 ] ; then
        paste -d, out2 temp.${v} >> out
        rm out2 temp.${v}
      fi
      counter=$(( $counter+1 ))
    done
    if [ -f out ] ; then
      mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.diff
    elif [ -f out2] ; then
      mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.diff
    fi
  fi
  if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.diff ] ; then
    counter=1
    for k in "${t[@]}"; do
      if [ "$k" -lt "10000" ] ; then
        v=${k:0:2}
      else
        v=${k:0:3}
      fi
      grep ^" " ${it_num}.${LABEL}.${v}ns.${IL_AN}.diff | awk '{print $2}' | tr ' ' ',' >> temp.${v}
      if [ ${counter} -eq 1 ] ; then
        paste -d, temp.${v} >> out
        rm temp.${v}
      elif [ $((counter%2)) -eq 0 ] ; then
        paste -d, out temp.${v} >> out2
        rm out temp.${v}
      elif [ ! $((counter%2)) -eq 0 ] ; then
        paste -d, out2 temp.${v} >> out
        rm out2 temp.${v}
      fi
      counter=$(( $counter+1 ))
    done
    if [ -f out ] ; then
      mv out ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.diff
    elif [ -f out2] ; then
      mv out2 ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.diff
    fi
  fi
  if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.D ] ; then
    for k in "${t[@]}"; do
      if [ "$k" -lt "10000" ] ; then
        v=${k:0:2}
      else
        v=${k:0:3}
      fi
      grep 'D\[' ${it_num}.${LABEL}.${v}ns.${IL_CAT}.diff | awk '{print $5,$6,$7}' >> temp
    done
    mv temp ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_CAT}.D
  fi
  if [ ! -f ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.D ] ; then
    for k in "${t[@]}"; do
      if [ "$k" -lt "10000" ] ; then
        v=${k:0:2}
      else
        v=${k:0:3}
      fi
      grep 'D\[' ${it_num}.${LABEL}.${v}ns.${IL_AN}.diff | awk '{print $5,$6,$7}' >> temp
    done
    mv temp ${PROPERTIES}/${IL_CAT}.${IL_AN}.${LABEL}.${novel}.${IL_AN}.D
  fi
fi
echo "equilibrium analysis complete"
cd $SANDBOX

echo "starting spEqAnalysis"
#*****************************************************************
#prep for the right direcotry depending on NPT or NVT
if [ "$nvt_production" == "yes" ] ; then
  cd ${ILhome}/${LABEL}/NVT
elif [ "$npt_production" == "yes" ] ; then
  cd ${ILhome}/${LABEL}/NPT
fi
if [ ! -d ${ILhome}/analysis ] ; then
  mkdir ${ILhome}/analysis
fi
cp $SANDBOX/GROMACS.pbs .
cp $SETUP/topol.top .
#*****************************************************************
#heat capacity   
if [ ! -f ${LABEL}.HeatCapacity.txt ] ; then 	#nmol grabs the correct amount of molecules for g_energy
nmol=`tail -2 ${LABEL}.gro | head -1 | awk '{print $1}' | sed "s/[[:alpha:].-]/ /g" | awk '{print $1}'`
echo "calculating heat capacity for ${LABEL}" 
  echo 10 11 12 13 14 0 | gmx_8c energy -f ${LABEL}.edr -driftcorr -fluct_props -nmol ${nmol} >> ${LABEL}.HeatCapacity.txt
  rm energy.xvg
  cp ${LABEL}.HeatCapacity.txt ${ILhome}/analysis/
fi
#*****************************************************************
#temperature
if [ ! -f ${LABEL}.Temp.xvg ] ; then
echo "calculating temperature for ${LABEL}" 
  echo gmx_8c energy -f ${LABEL}.edr -o ${LABEL}.Temp.xvg
  rm energy.xvg
  cp ${LABEL}.Cp ${ILhome}/analysis/
fi
#*****************************************************************
echo "analysis complete"
cd $SANDBOX

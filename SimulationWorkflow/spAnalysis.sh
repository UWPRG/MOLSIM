echo "starting spEqAnalysis"
#*****************************************************************
#prep for the right direcotry depending on NPT or NVT
if [ "$nvt_production" == "yes" ] ; then
  cd ${PROJROOT}/NVT
elif [ "$npt_production" == "yes" ] ; then
  cd ${PROJROOT}/NPT
fi
if [ ! -d ${PROJROOT}/analysis ] ; then
  mkdir ${PROJROOT}/analysis
fi
cp $SANDBOX/GROMACS.pbs .
cp $SANDBOX/topol.top .
#*****************************************************************
#heat capacity   
if [ ! -f heatcapacity.txt ] ; then 	#nmol grabs the correct amount of molecules for g_energy
  nmol=`tail -2 conf.gro | head -1 | awk '{print $1}' | sed "s/[[:alpha:].-]/ /g" | awk '{print $1}'`
  echo "calculating heat capacity for ${name}" 
  echo 8 6 0 | gmx_8c energy -f ener.edr -driftcorr -fluct_props -nmol ${nmol} >> temp
  grep -i 'Heat capacity' temp | awk '{print $8}' >> heatcapacity.txt
  rm energy.xvg
  rm temp
fi
#*****************************************************************
#temperature
if [ ! -f temperature.xvg ] ; then
  echo "calculating temperature for ${name}" 
  echo 8 0 | gmx_8c energy -f ener.edr -o temperature.xvg
fi
#*****************************************************************
echo "analysis complete"
cd $SANDBOX

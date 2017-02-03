echo "starting spEqAnalysis"
#*****************************************************************
#prep for the right direcotry depending on NPT or NVT
if [ "$nvt_production" == "yes" ] ; then
  cd ${PROJROOT}/NVT
elif [ "$npt_production" == "yes" ] ; then
  cd ${PROJROOT}/NPT
fi
cp $SANDBOX/GROMACS.pbs .
cp $SANDBOX/topol.top .
#*****************************************************************
#volume
if [ ! -f volume.xvg ] ; then 
  echo "calculating volume for ${name}"
  echo 12 0 | gmx_8c energy -f ener.edr -o volume.xvg
fi
#*****************************************************************
#pressure
if [ ! -f pressure.xvg ] ; then
  echo "calculating pressure for ${name}" 
  echo 8 0 | gmx_8c energy -f ener.edr -o pressure.xvg
fi
#*****************************************************************
echo "analysis complete"
cd $SANDBOX

#!/bin/bash
#Usage: source wrapper.sh &
set -e
jobname=hw4
name=(water_1 water_100 water_500)
pressure=(1 100 500)
echo "starting analysis for ${jobname}" > ${jobname}.log
for (( i=0 ; i<=2 ; i++ )) ; do
  currentp=${pressure[$i]}
  echo "Pressure = ${currentp}" >> ${jobname}.log
  cp input.inp ${name[$i]}.inp
  sed -i "9s/.*/Pressure=${currentp}/" ${name[$i]}.inp
  source master.sh ${name[$i]} > ${name[$i]}.log
  wait
  echo "finished run with P=${currentp}" > ${jobname}.log
  echo "........step $i complete" >> ${jobname}.log
done

echo "job complete" >> ${jobname}.log
echo "job complete for ${jobname}" | mail -s "message from hyak" ldgibson@uw.edu

#!/bin/bash
#run this script with the name of your system (match input file)
#and a name for your log file
#for an HMI CHL salt at 350K this could look like:
#source master.sh HMI_CHL > HMI_CHL.350 &
#source master.sh ${name} > ${name}.${characteristic} &

name=(cutoff RFZ pme) 						
dimensions=(Cut-off Reaction-Field-zero PME)	

for (( i=0 ; i<=2 ; i++ )) ; do
	currentdim=${dimensions[$i]}
	cname=${name[$i]}
	cp input.inp ${cname}.inp
	echo ${currentdim}
	sed -i "8s/.*/CType=${currentdim}/" ${cname}.inp
	
	source master.sh ${cname} > ${cname}.log &
done

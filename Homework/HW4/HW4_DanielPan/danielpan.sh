#!/bin/bash

name=(water300 water350 water400)
dimensions=(300 350 400)

for (( i=0 ; i<=2 ; i++ )) ; do
	ctemp=${dimensions[$i]}
	cp input.inp ${name}.inp
	sed -i "8s/.*/Temp=${ctemp}/" ${name}.inp
	source master.sh ${name} > ${name}.log &
done

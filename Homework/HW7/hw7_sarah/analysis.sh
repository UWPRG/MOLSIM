#!/bin/bash

molecule=(ch3 ch2 ch h2)
basis=(basis1 basis2 basis3 basis4 basis5)
method=(B3LYP MP2 CCSD M062X)
analysis=()


for ((i=0 ; i<=3 ; i++ )) ; do
	cmolecule=${molecule[$i]}
	for ((j=0 ; j<=4 ; j++ )) ; do
	  cbasis=${basis[$j]}
		for ((k=0 ; k<=3 ; k++ )) ; do
			cmethod=${method[$k]}
			if [ ${cmolecule} = h2 ] ; then
				grep R\(1,2\) ${cmolecule}/${cbasis}/${cmolecule}_${cmethod}_${cbasis}.log | tail -1 | awk '{print $4}' >>  h2_bond.txt
			  grep Job\ cpu\ time\: ${cmolecule}/${cbasis}/${cmolecule}_${cmethod}_${cbasis}.log |awk '{print $6, $8, $10}' >> h2_time.txt
			else
				grep R\(1,2\) ${cmolecule}/${cbasis}/${cmolecule}_${cmethod}_${cbasis}.log | tail -1 | awk '{print $4}' >>  ccbonds.txt
				grep R\(1,3\) ${cmolecule}/${cbasis}/${cmolecule}_${cmethod}_${cbasis}.log | tail -1 | awk '{print $4}' >>  chbonds.txt
			  grep Job\ cpu\ time\: ${cmolecule}/${cbasis}/${cmolecule}_${cmethod}_${cbasis}.log |awk '{print $6, $8, $10}' >> calctime.txt	
			fi
		done
	done
done


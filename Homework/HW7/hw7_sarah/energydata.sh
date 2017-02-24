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
		  grep SCF\ Done  ${cmolecule}/${cbasis}/${cmolecule}_${cmethod}_${cbasis}.log | awk '{print $5}' >> energy/${cmolecule}_${cmethod}_${cbasis}_ener.txt
			FILES=energy/*
			for f in FILES ; do
				   nl energy/${cmolecule}_${cmethod}_${cbasis}_ener.txt > energy/gnuplot/${cmolecule}_${cmethod}_${cbasis}_ener.txt
			done
		done
	done
done


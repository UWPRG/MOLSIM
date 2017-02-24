#!/bin/bash

file=(ch3 ch2 ch h2)
method=(B3LYP MP2 CCSD M062X)
basis=('STO-3G' '3-21G' '6-31G(d)' '6-31G(d,p)' 'LANL2DZ')
bnames=(basis1 basis2 basis3 basis4 basis5)

for ((i=0 ; i<=3 ; i++ )) ; do
	cfile=${file[$i]}
	if [ ! -f ${cfile}/${cfile}_${method[$i]}.com ] ; then
		for ((j=0 ; j<=3 ; j++ )) ; do
			cmethod=${method[$j]}
			cp ${cfile}.com ${cfile}/${cfile}_${cmethod}.com
			sed -i "2s/B3LYP/${cmethod}/" ${cfile}/${cfile}_${cmethod}.com
			if [ ! -f ${cfile}/${cfile}_${cmethod}_${basis[$j]}.com ] ; then
				for ((k=0 ; k<=4 ; k++ )) ; do
					cbasis=${basis[$k]}
					cbnames=${bnames[$k]}	
					cp ${cfile}/${cfile}_${cmethod}.com ${cfile}/${cfile}_${cmethod}_${cbnames}.com
					sed -i "2s/6-31G(d)/${cbasis}/" ${cfile}/${cfile}_${cmethod}_${cbnames}.com
				done
			fi
		done
	fi
done




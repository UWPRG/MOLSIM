#!/bin/bash

SANDBOX=/suppscr/pfaendtner/ldgibson/MOLSIM/week7

if [ ! -d $SANDBOX/energies ] ; then
	mkdir $SANDBOX/energies
fi

ENERGIES=$SANDBOX/energies

xc=(b3lyp mp2 m062x ccsd)
bs=(STO-3G 3-21G 6-31G\(d\) 6-31G\(d,p\) LANL2DZ)
moltype=(hydrogen ethane ethene ethyne)

for (( i=0 ; i<=4 ; i++ )) ; do
	for (( j=0 ; j<=3 ; j++ )) ; do
		for (( k=0 ; k<=3 ; k++ )) ; do
		
			if [ $i == 0 ] && [ $j == 0 ] && [ $k == 3 ] ; then
				break
			fi
	
			cd $SANDBOX/basis${i}/${moltype[$j]}/${xc[$k]}
			numlines=$(( `grep "SCF Don" ${moltype[$j]}.log | awk '{print $5}' | wc -l` ))

			for (( z=1 ; z<=${numlines} ; z++ )) ; do
				ener=`grep "SCF Don" ${moltype[$j]}.log | awk '{print $5}' | head -n ${z} | tail -1`
				echo ${z} ${ener} >> $ENERGIES/${moltype[$j]}_basis${i}_${xc[$k]}.txt
			done

		done
	done
done

#!/bin/bash

theory=(B3LYP MP2 CCSD M062X)
basis=(STO-3G 3-21G 6-31G\(d\) 6-31G\(d,p\) LANL2DZ )
abr=(S 3G 6Gd 6Gdp L)

for (( i=0 ; i<=3 ; i++ )) ; do
    for (( j=0 ; j<=4 ; j++ )) ; do
        file=CH2_${theory[$i]}_${abr[$j]}
	cp CH2.com ${file}.com
	sed -i "2s/.*/#n ${theory[$i]}\/${basis[$j]} Opt/" ${file}.com
        cp gaussian.pbs ${file}.pbs
        sed -i "13s/.*/g09 ${file}.com/" ${file}.pbs
	qsub ${file}.pbs
    done
done


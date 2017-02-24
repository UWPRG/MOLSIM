#!/bin/bash

mol=(CH CH2 CH3 HH)
theory=(B M C MX)
basis=(3G 6Gd 6Gdp L S)

for (( i=0 ; i<=3 ; i++ )) ; do
    for (( j=0 ; j<=3 ; j++ )) ; do
        for (( k=0 ; k<=4 ; k++ )) ; do
	    file=${mol[$i]}_${theory[$j]}_${basis[$k]}
	    cp gaussian.pbs ${file}.pbs
	    sed -i "13s/.*/g09 ${file}.com/" ${file}.pbs
	    qsub ${file}.pbs
        done
    done
done

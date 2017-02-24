#!/bin/bash
# usage: wrapper.sh > hw7.log &

set -e

xc=(b3lyp mp2 m062x ccsd)
bs=(STO-3G 3-21G 6-31G\(d\) 6-31G\(d,p\) LANL2DZ)
moltype=(hydrogen ethane ethene ethyne)


for (( a=0 ; a<=4 ; a++ )) ; do				# looping through basis types
	current_basis="basis${a}"
	source directory.sh
	cd $PROJROOT

	for (( b=0 ; b<=3 ; b++ )) ; do			# looping through moltypes
		if [ ! -d $PROJROOT/${moltype[$b]} ] ; then
			echo "making directory for ${moltype[$b]}"
			mkdir $PROJROOT/${moltype[$b]}
		fi

		cd $PROJROOT/${moltype[$b]}

		for (( c=0 ; c<=3 ; c++ )) ; do		# looping through xc functionals
			
			if [ ! -d $PROJROOT/${moltype[$b]}/${xc[$c]} ] ; then
				echo "making directory for ${xc[$c]}"
				mkdir $PROJROOT/${moltype[$b]}/${xc[$c]}
			fi

			cd $PROJROOT/${moltype[$b]}/${xc[$c]}
			
			if [ ! -f ${moltype[$b]}.log ] ; then 
				
				# start gaussian runs
				echo "creating .com file for ${moltype[$b]} with ${xc[$c]}/${bs[$a]}..."
				cp $SANDBOX/${moltype[$b]}_template.com ./${moltype[$b]}.com
				cp $SANDBOX/gsub.sh .
				sed -i "4s/xcfunc\/basis/${xc[$c]}\/${bs[$a]}/" ${moltype[$b]}.com
				sed -i "6s/title/${moltype[$b]} opt/" ${moltype[$b]}.com
				echo " "
				echo " "
				cat ${moltype[$b]}.com
				echo " "
				echo " "
				echo "starting gaussian run for ${moltype[$b]} with ${xc[$c]}/${bs[$a]}"

				./gsub.sh ${moltype[$b]}.com 16 8
				sleep 60
				# end gaussian runs

				while true ; do 
					# waiting for gaussian job to start on hyak
					if [ ! -f ${moltype[$b]}.log ] ; then
						sleep 30
					else
						break
					fi
				done

				# start data analysis
				while true ; do
					# check if the gaussian job failed
					if [[ `tail -3 ${moltype[$b]}.log | head -1 | awk '{print $1}'` == "Error" ]] ; then
						echo "********************************************************************"
						echo "* OPTIMIZATION FAILED for ${moltype[$b]} with ${xc[$c]}/${bs[$a]}"
						echo "********************************************************************"
						echo " "
						echo "moving on to next functional..."
						break
					# check if it is still running
					elif [[ `tail -1 ${moltype[$b]}.log | awk '{print $1}'` != "Normal" ]] ; then
						echo "waiting for gaussian calculation to complete... "
						sleep 30
					# when successfully completed, do this...
					else
						if [ -f ../${moltype[$b]}.txt ] ; then # if a txt file already exists, check where it left off
							if [[ `grep ${xc[$c]} ../${moltype[$b]}.txt | awk '{print $1}'` != "${xc[$c]}" ]] ; then
								echo "gaussian calculation complete, starting bond distance calculation... "

								if [ ${moltype[$b]} != "hydrogen" ] ; then
									# do this if NOT hydrogen
									dCC=`grep R\(1,2\) ${moltype[$b]}.log | tail -1 | awk '{print $4}'`
									dCH=`grep R\(1,3\) ${moltype[$b]}.log | tail -1 | awk '{print $4}'`
									rt=`tail -3 ethane_template.log | head -1 | awk '{ time = $8 * 60 + $10; print time }'`
									echo ${xc[$c]} $dCC $dCH $rt >> ../${moltype[$b]}.txt
								else	
									# do this if hydrogen
									dHH=`grep R\(1,2\) ${moltype[$b]}.log | tail -1 | awk '{print $4}'`
									rt=`tail -3 ethane_template.log | head -1 | awk '{ time = $8 * 60 + $10; print time }'`
									echo ${xc[$c]} $dHH $rt >> ../${moltype[$b]}.txt
								fi

							else 
								# do this if bond analysis already complete
								echo "bond analysis for ${moltype[$b]} with ${xc[$c]}/${bs[$a]} already done"
								echo "moving on ... "
							fi

						else 
							# do this if there is no txt file from previous runs
							echo "gaussian calculation complete, starting bond distance calculation... "
							if [ ${moltype[$b]} != "hydrogen" ] ; then
								dCC=`grep R\(1,2\) ${moltype[$b]}.log | tail -1 | awk '{print $4}'`
								dCH=`grep R\(1,3\) ${moltype[$b]}.log | tail -1 | awk '{print $4}'`
								rt=`tail -3 ethane_template.log | head -1 | awk '{ time = $8 * 60 + $10; print time }'`
								echo ${xc[$c]} $dCC $dCH $rt >> ../${moltype[$b]}.txt
							else	
								dHH=`grep R\(1,2\) ${moltype[$b]}.log | tail -1 | awk '{print $4}'`
								rt=`tail -3 ethane_template.log | head -1 | awk '{ time = $8 * 60 + $10; print time }'`
								echo ${xc[$c]} $dHH $rt >> ../${moltype[$b]}.txt
							fi

						fi

						echo "bond distances recorded, moving on..."
						echo " "
						echo "************************************************************************"
						echo " "
						sleep 1
						break
					fi
				done
			
			else
				echo "log file already present for ${moltype[$b]} with ${xc[$c]}/${bs[$a]}. moving on to next system... "
			fi ### end data analysis

			cd ..
		done
		cd ..
  done
	cd ..
done


# groups up log files for easy transfer from hyak
source $SANDBOX/collector.sh

# creates energy plots
source $SANDBOX/energyplot.sh

echo "job complete"
echo "job complete" | mail -s "message from hyak" ldgibson@uw.edu

exit 0

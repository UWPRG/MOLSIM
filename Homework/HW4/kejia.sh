%%bash
### in my input file
declare -a Press=(-100 100 1000)
###Press=(100)


### change pressure to see the influence in density

declare -a name=(water_1 water_2 water_3)
for (( i=0 ; i<${#Press[*]} ; i++ )) ; do
### for p in "${Press[@]}"
###do
  sed -i "58s/.*/ref_p                   = ${Press[i]}/" nptber.mdp
  ###echo "./master.sh input" > water_${p}
  cp input.inp ${name[i]}.inp
  source master.sh ${name[i]} > ${name[i]}.log &
done

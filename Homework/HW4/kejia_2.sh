%%bash
### in my input file
declare -a Diameter=(5.00081 7.00081 9.00081)
###Press=(100)


### change pressure to see the influence in density

declare -a name=(water_4 water_5 water_6)
for (( i=0 ; i<${#Diameter[*]} ; i++ )) ; do
### for p in "${Press[@]}"
###do
  sed -i "2655s/.*/3.00081                   = ${Diameter[i]}/" conf.gro
  ###echo "./master.sh input" > water_${p}
  cp input.inp ${name[i]}.inp
  source master.sh ${name[i]} > ${name[i]}.log &
done

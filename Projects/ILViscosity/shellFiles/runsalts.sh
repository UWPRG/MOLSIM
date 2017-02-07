#!/bin/bash
while IFS=',' read xx yy zz ; do
source master.sh ${xx}_${yy} >> ${xx}_${yy}.comremoved & 
sleep 5
done < "$1"

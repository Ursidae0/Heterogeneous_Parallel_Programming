#!/bin/bash
for((i=1;i<=10;i++))
do
	echo "compiling ${i}"
	nvcc ../HW/v${i}.cu -o v${i}.exe
done

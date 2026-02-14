#!/bin/bash
for((i=1;i<=10;i++))
do
	echo "compiling ${i}_2"
	nvcc ../HW/v${i}_2.cu -o v${i}_2.exe
done

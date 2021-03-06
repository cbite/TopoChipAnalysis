# !/bin/bash

echo "Start Bash Run CellProfiler"

# Set the directory of the batchfile (.hd5 format) and the output folder
DIRECOTRY_BATCHFILE=""
DIRECTORY_OUTPUTDATA=""
DIRECTORY_CELLPROFILER=""

for i in $(seq 1 545 4356); do
	BATCH_START=$i
	BATCH_END=$(($BATCH_START+544))
	TopoSize=4356
	if [ $BATCH_END -gt $TopoSize ]
	then
		BATCH_END=$TopoSize
		echo $BATCH_END
		$DIRECTORY_CELLPROFILER -p $DIRECOTRY_BATCHFILE -c -r -f $BATCH_START -l $BATCH_END -o ${DIRECTORY_OUTPUTDATA}'Batch'${i}
	else
		$DIRECTORY_CELLPROFILER -p $DIRECOTRY_BATCHFILE -c -r -f $BATCH_START -l $BATCH_END -o ${DIRECTORY_OUTPUTDATA}'Batch'${i} &
	fi
done
wait

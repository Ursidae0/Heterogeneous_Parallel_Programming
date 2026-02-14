#!/bin/bash

# --- Configuration ---

# Total number of files to test (e.g., 10 for v1.exe to v10.exe)
# (Assuming your executables are v1_2.exe, v2_2.exe, etc.)
TOTAL_FILES=10

# Number of times to run EACH file (except v3)
RUNS_PER_FILE=10

# The base name of your executables
FILE_PREFIX="v"
FILE_SUFFIX="_2.exe"

# The file to store the final averages
OUTPUT_FILE="average_results.txt"

# --- Script Start ---

echo "Starting performance test..."

# Clear/create the output file for this new run
echo "Average Execution Times" > $OUTPUT_FILE
echo "=========================" >> $OUTPUT_FILE

# --- Special handling for v3 (2 runs) ---

i=3 # Hard-code file number 3
special_runs=2 # Run it 2 times
executable_name="./${FILE_PREFIX}${i}${FILE_SUFFIX}"

# Check if v3 exists and is executable
if [ ! -x "$executable_name" ]; then
    echo "SKIPPING: $executable_name (Not found or not executable)"
    echo "$executable_name: SKIPPED" >> $OUTPUT_FILE
else
    echo "Special Test $executable_name ($special_runs times)..."
    total_time=0.0

    # Inner loop: Runs v3 $special_runs times
    for j in $(seq 1 $special_runs); do
        echo "${j}.th execution"
        current_time=$( $executable_name | grep "Total Time" | awk '{print $1}' )
        total_time=$(echo "$total_time + $current_time" | bc)
    done

    # Calculate the average for v3
    average_time=$(echo "scale=4; $total_time / $special_runs" | bc)

    # Print the result for v3
    result_line="$executable_name: $average_time"
    echo "  -> Average: $average_time"
    echo "$result_line" >> $OUTPUT_FILE
fi

# --- Main loop for all other files (v1, v2, v4, v5... v10) ---

echo "Starting main test loop..."

# Outer loop: Iterates through each executable file
for i in $(seq 1 $TOTAL_FILES); do

    # --- THIS IS THE KEY ---
    # We've already handled v3, so we skip it in this main loop
    if [ $i -eq 3 ]; then
        echo "Skipping $executable_name (handled separately)"
        continue # Skip to the next file
    fi
    # --- END KEY ---

    executable_name="./${FILE_PREFIX}${i}${FILE_SUFFIX}"

    # Check if the file exists and is executable
    if [ ! -x "$executable_name" ]; then
        echo "SKIPPING: $executable_name (Not found or not executable)"
        echo "$executable_name: SKIPPED" >> $OUTPUT_FILE
        continue # Skip to the next file
    fi

    echo "Testing $executable_name ($RUNS_PER_FILE times)..."

    total_time=0.0

    # Inner loop: Runs the current executable 10 times
    for j in $(seq 1 $RUNS_PER_FILE); do
        echo "${j}.th execution"
        current_time=$( $executable_name | grep "Total Time" | awk '{print $1}' )
        total_time=$(echo "$total_time + $current_time" | bc)
    done

    # Calculate the average (using 'bc' for floating-point math)
    average_time=$(echo "scale=4; $total_time / $RUNS_PER_FILE" | bc)

    # Print the result to the console and to the file
    result_line="$executable_name: $average_time"
    echo "  -> Average: $average_time"
    echo "$result_line" >> $OUTPUT_FILE

done

echo "=========================" >> $OUTPUT_FILE
echo "Test complete. Results saved to $OUTPUT_FILE"

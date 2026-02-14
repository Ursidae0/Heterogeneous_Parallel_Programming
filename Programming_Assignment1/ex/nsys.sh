#!/bin/bash

FILE_PREFIX="v"
FILE_SUFFIX=".exe"
TOTAL_FILES=10

# Iterate from 1 to TOTAL_FILES
for i in $(seq 1 $TOTAL_FILES); do
    # Construct the target filename
    TARGET="./${FILE_PREFIX}${i}${FILE_SUFFIX}"
    
    # Define the output report name (e.g., report_v1)

    # Check if the executable exists and is executable
    if [[ -x "$TARGET" ]]; then
        echo "----------------------------------------"
        echo "Profiling: $TARGET"
        echo "Output:    $REPORT_NAME.nsys-rep"
        echo "----------------------------------------"
        
        # Run nsys explicitly
        # -o sets the output filename
        # --force-overwrite ensures you don't get errors if you run the script twice
        nsys profile --stats=true  "$TARGET"
        
    else
        echo "Warning: $TARGET not found or not executable. Skipping."
    fi
done

#!/bin/bash
###OUTPUT FILES FOR THE INDIVIDUAL RUNS WILL BE IN THE v100/.../outputs/ directory

#######################################################################
#                      Create output file  
#######################################################################
IMPL="CUDA OpenMP"

date
#######################################################################
#             Specify path to the circustent executable 
#######################################################################
cd ../
CT_ROOT=$(pwd)
CT_SCRIPTS=$CT_ROOT/scripts
CT_V100_KERNELS=$CT_SCRIPTS/v100
CT_BUILD=$CT_ROOT/build
EXE=$CT_BUILD/src/CircusTent/circustent
cd $TEST_DIR

for I in $IMPL; do
    if [[ "$I" == "CUDA" ]]; then
        echo "Running cuda tests..."
        cd $CT_SCRIPTS
        ./BUILD.sh v100 cuda
        echo "CUDA built, running parallelism"
        cd $CT_V100_KERNELS/parallelism
        ./parallelism.sh CUDA
    elif [[ "$I" == "OpenMP" ]]; then
        echo "Running OpenMP tests..."
        cd $CT_SCRIPTS
        ./BUILD.sh v100 openmp
        echo "OpenMP built, running parallelism"
        cd $CT_V100_KERNELS/parallelism 
        ./parallelism.sh OpenMP
    elif [[ "$I" == "OpenACC" ]]; then
        echo "Running OpenACC tests..."
        cd $CT_SCRIPTS
        ./BUILD.sh v100 openacc
        echo "OpenACC built, running all kernels"
        cd $CT_V100_KERNELS/all_kernels
        ./all_kernels.sh OpenACC
        echo "all kernels done, running parallelism"
        cd ../parallelism
        ./parallelism.sh OpenACC
    fi
done

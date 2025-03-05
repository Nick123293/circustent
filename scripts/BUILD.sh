#!/bin/bash

# --- Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <gpu> <backend>"
  echo "Where <gpu> is either v100 or a100"
  echo "and <backend> is either openmp, openacc, or cuda"
  exit 1
fi

# --- Assign command line arguments to variables
GPU=$1
BACKEND=$2

# --- Validate the GPU argument
if [[ "$GPU" != "v100" && "$GPU" != "a100" ]]; then
  echo "Invalid GPU specified. Must be 'v100' or 'a100'."
  exit 1
fi

# --- Validate the backend argument
if [[ "$BACKEND" != "openmp" && "$BACKEND" != "openacc" && "$BACKEND" != "cuda" ]]; then
  echo "Invalid backend specified. Must be 'openmp', 'openacc', or 'cuda'."
  exit 1
fi

# --- Print the parsed arguments
echo "GPU: $GPU"
echo "Backend: $BACKEND"

# --- Set flags based on GPU and backend
GPU_FLAGS=""
ENABLE_FLAG=""
LINK_FLAGS=""
CXX_COMPILER=""
C_COMPILER=""

if [[ "$GPU" == "v100" ]]; then
  ml load gcc/10.1.0
  ml load nvhpc/21.3-mpi
  CXX_COMPILER=`which nvcc`
  C_COMPILER=`which nvcc`
  case "$BACKEND" in
    openmp)
      ENABLE_FLAG="-DENABLE_OMP_TARGET=ON"
      GPU_FLAGS="-mp=gpu -Minfo=mp -gpu=cc70"
      LINK_FLAGS="-mp=gpu -gpu=cc70"
      ;;
    cuda)
      ml load gcc/9.3.0
      ml load cuda/11.0
      ENABLE_FLAG="-DENABLE_CUDA=ON"
      GPU_FLAGS="-arch=sm_70"
      ;;
    openacc)
      ENABLE_FLAG="-DENABLE_OPENACC=ON"
      GPU_FLAGS="-ta=tesla:cc70"
      ;;
  esac
elif [[ "$GPU" == "a100" ]]; then
  ml load gcc/9.3.0
  ml load nvhpc/21.3-mpi
  CXX_COMPILER=`which nvcc`
  C_COMPILER=`which nvcc`
  case "$BACKEND" in
    openmp)
      ENABLE_FLAG="-DENABLE_OMP_TARGET=ON"
      GPU_FLAGS="-mp=gpu -Minfo=mp -gpu=cc80"
      LINK_FLAGS="-mp=gpu -gpu=cc80"
      export OMP_TARGET_OFFLOAD=MANDATORY
      ;;
    cuda)
      ml load cuda/11.3.0
      ENABLE_FLAG="-DENABLE_CUDA=ON"
      GPU_FLAGS="-arch=sm_80"
      ;;
    openacc)
      ENABLE_FLAG="-DENABLE_OPENACC=ON"
      GPU_FLAGS="-ta=tesla:cc80"
      ;;
  esac
fi

# --- Print the set flags
echo "GPU_FLAGS: $GPU_FLAGS"
echo "ENABLE_FLAG: $ENABLE_FLAG"
echo "LINK_FLAGS: $LINK_FLAGS"

# --- Create build directory and run cmake
ml load cmake/3.17.3

./CLEAN.sh
cd ../
mkdir -p build
cd build
cmake $ENABLE_FLAG -DCMAKE_CXX_COMPILER="$CXX_COMPILER" -DCMAKE_C_COMPILER="$C_COMPILER" -DCMAKE_CXX_FLAGS="$GPU_FLAGS" -DCMAKE_C_FLAGS="$GPU_FLAGS" -DCMAKE_EXE_LINKER_FLAGS="$LINK_FLAGS" ../
make


#!/bin/bash

srun -o OUT_test_all_a100.txt -e ERR_test_all_a100 -N 1 -X -n 1 --partition=toreador -G 1 test_all_a100.sh
srun -o OUT_test_all_v100.txt -e ERR_test_all_v100 -N 1 -X -n 1 --partition=matador -G 1 test_all_v100.sh

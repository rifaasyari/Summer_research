#!/bin/bash
#SBATCH --mail-user=shengnan.han@vanderbilt.edu
#SBATCH --mail-type=ALL
#SBATCH --constraint=[westmere,haswell,skylake]
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --time=0:30:00
#SBATCH --mem=1G
#SBATCH --output=OUT.txt
module load GCC/6.4.0-2.28
module load OpenMPI/2.1.1
module load Anaconda3/5.0.1
module load Intel/2016.3.210 IntelMPI/5.1.3.181 numpy/1.11.1-Python-3.5.2
module load Meep
echo $SLURM_JOB_NODELIST
mpirun -np 12 python spectrum_generator_accre.py
#!/bin/bash
#SBATCH --mail-user=shengnan.han@vanderbilt.edu
#SBATCH --mail-type=ALL
#SBATCH --constraint=[westmere,haswell,skylake]
#SBATCH --nodes=2
#SBATCH --ntasks=1
#SBATCH --time=20:00:00       
#SBATCH --mem=1G
#SBATCH --output=data/DATA21_#13_sp.txt
module load GCC/6.4.0-2.28
module load OpenMPI/2.1.1
module load S4/1.1.1
echo $SLURM_JOB_NODELIST

S4/1.1.1 Script/R_Poly5.0.lua

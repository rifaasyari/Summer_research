#!/bin/bash
#SBATCH --mail-user=you.zhou@vanderbilt.edu
#SBATCH --mail-type=ALL
#SBATCH --constraint=[westmere,haswell,skylake]
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=12
#SBATCH --time=30:10:00        # 10 minutes
#SBATCH --mem=40G
#SBATCH --output=meep_matlab_job.out
module load GCC/6.4.0-2.28
module load OpenMPI/2.1.1
module load Meep
module load MATLAB/2017a 
echo $SLURM_JOB_NODELIST

mpirun -np 24 meep 1180_bilayer_lens_forw.scm
mpirun -np 24 meep 1180_bilayer_lens_back.scm
matlab -nodisplay -nosplash < Ajoint_updated_whole.m

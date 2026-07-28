#!/bin/bash
#SBATCH --job-name=ITS_cat_seqrun_denoised_reads
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/ITS_dada2_analysis_final/cat_seqrun_denoised_reads%A.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/ITS_dada2_analysis_final/cat_seqrun_denoised_reads%A.err
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

set -euo pipefail


# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data/dada2_analysis_final/CH_All_ITS"
SEQRUN_SUMMARY="${BASE_DIR}/Seq_Runs_Summary" 
mkdir -p ${SEQRUN_SUMMARY}

# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env


# Export vars
export  BASE_DIR SEQRUN_SUMMARY
# Run Rscript with array ID
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/ITS_02_asv_analysis/01b_cat_seqrun_denoised_reads.R
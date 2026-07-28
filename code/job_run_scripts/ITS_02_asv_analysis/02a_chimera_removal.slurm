#!/bin/bash
#SBATCH --job-name=ITS_chimera_removal
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/ITS_dada2_analysis_final/ITS_chimera_removal_dada2%A.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/ITS_dada2_analysis_final/ITS_chimera_removal_dada2%A.err
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

set -euo pipefail


# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
SEQ_RUN_SUMMARY_DIR="${BASE_DIR}/dada2_analysis_final/CH_All_ITS/Seq_Runs_Summary" 

# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env


# Export vars
export  SEQ_RUN_SUMMARY_DIR
# Run Rscript with array ID
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/ITS_02_asv_analysis/02b_chimera_removal.R
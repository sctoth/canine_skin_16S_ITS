#!/bin/bash
#SBATCH --job-name=16S_create_read_fate_table
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis_final/16S_dada2_read_fate_final_table_%A.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis_final/16S_dada2_read_fate_final_table_%A.err
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

set -euo pipefail


# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
META_DIR="${BASE_DIR}/metadata"
SEQ_RUN_SUMMARY_DIR="${BASE_DIR}/dada2_analysis_final/CH_All_16S/Seq_Runs_Summary" 
FILT_READS="${BASE_DIR}/processed/CH_All_16S/06_truncR150_maxEE22_output/summary_read_counts"
# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env


# Export vars
export  SEQ_RUN_SUMMARY_DIR FILT_READS META_DIR
# Run Rscript with array ID
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/16S_02_asv_analysis/04b_final_read_fate.R
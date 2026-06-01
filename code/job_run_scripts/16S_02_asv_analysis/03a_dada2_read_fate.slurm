#!/bin/bash
#SBATCH --job-name=16S_create_read_fate_table
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis_04/16S_dada2_read_fate%A.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/logs/16S_dada2_analysis_04/16S_dada2_read_fate%A.err
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

set -euo pipefail


# Paths
BASE_DIR="/home5/sctoth/projects/dog_skin_microbiomes/data"
SEQ_RUN_SUMMARY_DIR="${BASE_DIR}/dada2_analysis_04/CH_All_16S/Seq_Runs_Summary" 

# Activate environment
source /home5/sctoth/miniconda3/etc/profile.d/conda.sh
conda activate /home5/sctoth/miniconda3/envs/r_env


# Export vars
export  SEQ_RUN_SUMMARY_DIR
# Run Rscript with array ID
/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/job_run_scripts/16S_02_asv_analysis/03b_dada2_read_fate.R
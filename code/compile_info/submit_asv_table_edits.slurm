#!/bin/bash
#SBATCH --job-name=sample_count_ASVs
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --output=/home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/logs/sample_count_%j.out
#SBATCH --error=/home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/logs/sample_count_%j.err

/home5/sctoth/miniconda3/envs/r_env/bin/Rscript /home5/sctoth/projects/dog_skin_microbiomes/code/compile_info/asv_table_edits_01.R
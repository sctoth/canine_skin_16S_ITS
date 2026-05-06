# canine_skin_microbial_communities
Analyzing 16S and ITS sequences from canine skin swabs to assess changes in microbial communities after surgery.

## File Structure 

### Contains read processing and ASV analysis bash and R scripts 
code/
- compile_info / # concatenate summary files across dog samples 
- job_runs / # edited main scripts for each job run 
- read_QC/ # main scripts for read QC (fastqc, multiqc, dada2::plotQualityProfile)
- read_trim_filtering / # main scripts for read processing (cutadapt, dada2::filterandTrim) 

### Includes raw and processed data files including QC summary files (multiqc) 
data/ 
- metadata/ # contains all sample data across timepoints per dog for 16S and ITS 
- raw / # contains raw 16S and ITS files 
- processed / # truncated, trimmed and filtered reads read for downstream analysis 

### Updated for final figures and concatenated files across dog samples 
results/ 

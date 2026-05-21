# Create subdirectories from unique Individual names in TSV
awk -F'\t' 'NR>1 && $3!="" && !seen[$3]++ {print $3}' /home5/sctoth/projects/dog_skin_microbiomes/data/metadata/CH-All_16S_Metadata_20220124.tsv | xargs -I {} mkdir -p "{}"

##
# Move files into correct subdirectories from unique Individual names in CSV (current directory)
for f in *-16S_F_trunc.fastq.gz; do
    [ -f "$f" ] || continue
    
    # Extract ID by stripping the exact suffix
    s="${f%-16S_F_trunc.fastq.gz}"
    
    # Fix potential Windows formatting (\r) and use flexible prefix matching
    i=$(sed 's/\r//g' /home5/sctoth/projects/dog_skin_microbiomes/data/metadata/CH-All_16S_Metadata_20220124.tsv | \
        awk -F'\t' -v s="$s" 'NR>1 && $1 ~ "^"s {print $3; exit}')
    
    if [[ -n "$i" ]]; then
        mv "$f" "${i}/"
        echo "Moved $f → ${i}/"
    else
        echo "No Individual for $f (SampleId: $s)"
    fi
done

for f in *-16S_R_trunc.fastq.gz; do
    [ -f "$f" ] || continue
    
    # Extract ID by stripping the exact suffix
    s="${f%-16S_R_trunc.fastq.gz}"
    
    # Fix potential Windows formatting (\r) and use flexible prefix matching
    i=$(sed 's/\r//g' /home5/sctoth/projects/dog_skin_microbiomes/data/metadata/CH-All_16S_Metadata_20220124.tsv | \
        awk -F'\t' -v s="$s" 'NR>1 && $1 ~ "^"s {print $3; exit}')
    
    if [[ -n "$i" ]]; then
        mv "$f" "${i}/"
        echo "Moved $f → ${i}/"
    else
        echo "No Individual for $f (SampleId: $s)"
    fi
done

for f in *_fastqc.{html,zip}; do 
    [ -f "$f" ] || continue
    s=$(echo "$f"|sed 's/_.*//; s/-16S$//')
    i=$(awk -F, -v s="$s" 'NR>1&&$1~("^'"$s"'"){print $3;exit}' /home5/sctoth/projects/dog_skin_microbiomes/data/metadata/CH-All_16S_Metadata_20220124.tsv)
    if [[ -n "$i" ]]; then
        mv "$f" "${i}/"
        echo "Moved $f → ${i}/"
    else
       echo "No Individual for $f (SampleId: $s)"
   fi
done
##


for f in *_fastqc.{html,zip}; do
   [ -f "$f" ] || continue
   s=$(echo "$f" | sed 's/_filt_fastqc.*//; s/_F$//; s/_R$//; s/.*-\([0-9][A-Za-z][A-Za-z]\)-16S.*/\1-16S/')
   i=$(awk -F$'\t' -v s="$s" 'NR>1&&$1=="'"$s"'"{print $3;exit}' /home5/sctoth/projects/dog_skin_microbiomes/data/metadata/CH-All_16S_Metadata_20220124.tsv)
   if [[ -n "$i" ]]; then
       mkdir -p "$i"
       mv "$f" "$i/"
       echo "Moved $f → $i/ (SampleId: $s)"
   else
       echo "No Individual for $f (SampleId: $s)"
   fi
done
##
for d in */; do mv "$d" "${d%/}_fastqc"; done 




for f in *trunc.fastq.gz; do 
    [ -f "$f" ] || continue
    s=$(echo "$f" | sed 's/_.*//; s/-16S$//')
    i=$(awk -F'\\s+' -v s="$s" 'NR>1&&$1~("^'"$s"'"){print $3;exit}' /home5/sctoth/projects/dog_skin_microbiomes/data/metadata/CH-All_16S_Metadata_20220124.tsv)
    if [[ -n "$i" ]]; then
        mkdir -p "$i"  # Create folder if missing
        mv "$f" "${i}/"
        echo "Moved $f → ${i}/"
    else
       echo "No Individual for $f (SampleId: $s)"
    fi
done
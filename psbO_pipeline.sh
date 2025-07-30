#!/bin/bash
module load all gencore/3
module load bwa/0.7.19
module load pandas/2.2.3
module load all gencore/2
module load samtools/1.9
    

# === User Inputs ===
DB="psbO_db.fna"
READS1="EAD230701B3_clean_1.fq.gz"
READS2="EAD230701B3_clean_2.fq.gz"

# === Step 1: Index database ===
echo "Indexing psbO database..."
bwa index "$DB"

# === Step 2: Map reads ===
echo "Mapping reads..."
bwa mem -t 4 "$DB" "$READS1" "$READS2" | samtools view -Sb - > mapped.bam
samtools sort mapped.bam -o mapped.sorted.bam
samtools index mapped.sorted.bam

# === Step 3: Count mapped reads ===
echo "Counting mapped reads..."
samtools view -c -F 4 mapped.sorted.bam > mapped_counts.txt

# === Step 4: Count total reads ===
echo "Counting total reads..."
zcat "$READS1" | wc -l | awk '{print $1/4}' > total_reads.txt

# === Step 5: Get gene lengths ===
echo "Extracting gene lengths..."
awk '/^>/{if(seq){print id"\t"length(seq)}; id=$1; seq=""} !/^>/{seq=seq$0} END{print id"\t"length(seq)}' "$DB" | sed 's/^>//' > gene_lengths.tsv

# === Step 6: Count reads per gene ===
echo "Counting reads per gene..."
samtools idxstats mapped.sorted.bam | cut -f1,3 > gene_counts.tsv

# === Step 7: Calculate RPKM ===
echo "Calculating RPKM..."
python3 calculate_rpkm.py

# === Step 8: Assign taxonomy and calculate abundance ===
echo "Assigning taxonomy and aggregating..."
python3 assign_taxa.py

echo "Pipeline complete. Outputs:"
echo "- gene_counts.tsv"
echo "- gene_lengths.tsv"
echo "- rpkm.tsv"
echo "- taxa_abundance.tsv"

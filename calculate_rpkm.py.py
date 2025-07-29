import pandas as pd

gene_lengths = pd.read_csv("gene_lengths.tsv", sep="\t", names=["gene", "length"])
gene_counts = pd.read_csv("gene_counts.tsv", sep="\t", names=["gene", "counts"])
with open("total_reads.txt") as f:
    total_reads = int(float(f.read().strip()))

df = pd.merge(gene_counts, gene_lengths, on="gene", how="inner")
df["rpkm"] = (df["counts"] * 1e9) / (df["length"] * total_reads)
df.to_csv("rpkm.tsv", sep="\t", index=False)

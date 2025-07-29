import pandas as pd

rpkm_df = pd.read_csv("rpkm.tsv", sep="\t")

taxa = {}
with open("psbO_db.fna") as f:
    for line in f:
        if line.startswith(">"):
            parts = line.strip().split(None, 1)
            gene_id = parts[0][1:]
            tax = parts[1].split(" Reference=")[0]
            taxa[gene_id] = tax

rpkm_df["taxonomy"] = rpkm_df["gene"].map(taxa)
abundance = rpkm_df.groupby("taxonomy")["rpkm"].sum().reset_index()
abundance.columns = ["taxonomy", "total_rpkm"]
abundance = abundance.sort_values("total_rpkm", ascending=False)
abundance.to_csv("taxa_abundance.tsv", sep="\t", index=False)

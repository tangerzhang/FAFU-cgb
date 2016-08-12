easy_KaKs use KaKs_calculator for Ka/Ks calculation

1. prepare a text file, which contains gene ids.
Each line for each group.
For example,
AP850000300     AP850383270     AP850933620
AP850000030     AP850501700     AP850674460

We will calulate pair-wise Ka/Ks for each line

2. download easy_KaKs package
git clone https://link
cd easy_KaKs/*
chmod +x *
cp *.pl ~/bin/
cp KaKs_Calculator ~/bin/
cp proc /path/to/your/workplace/

3. run easy_KaKs.pl
perl ~/bin/KaKs.pl -g group.txt -i cds.fasta

4. results
group_kaks.txt
>gene groups
gene_pair Ka  Ks  Ka/Ks_ratio P-value

For details, see kaks_result/



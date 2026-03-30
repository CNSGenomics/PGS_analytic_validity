#!/bin/bash

trait=$1
# gwas_file=$2

echo "Chr SNP bp refA freq b se p n freq_geno bJ bJ_se pJ LD_r" >  ${trait}/COJO/${trait}_cojo.txt
echo "Chr SNP bp refA freq b se p n freq_geno bJ bJ_se pJ LD_r" >  ${trait}/COJO_imp/${trait}_cojo_imp.txt

for chr in {1..22}
do

awk 'NR>1'  ${trait}/COJO/${trait}_chr${chr}_cojo.jma.cojo  >> ${trait}/COJO/${trait}_cojo.txt
awk 'NR>1'  ${trait}/COJO_imp/${trait}_chr${chr}_cojo_imp.jma.cojo  >> ${trait}/COJO_imp/${trait}_cojo_imp.txt

done


#inFile=${trait}/CplusT/${gwas_file}

#cat ${inFile}_chr*_clumped.clumped | grep "CHR" | head -1 > ${inFile}.clumped
#cat ${inFile}_chr*_clumped.clumped | grep -v "CHR" |sed '/^$/d'  >> ${inFile}.clumped
#awk '{print $3}' ${inFile}.clumped | awk 'NR>1' >  ${inFile}.clumped_SNPs.txt
#awk '{print $1, $2, $5}' ${inFile}  > ${inFile}_allele_effect
#grep -w -f  ${inFile}.clumped_SNPs.txt  ${inFile}_allele_effect > ${inFile}_PT_0.05_predictor.txt
#awk '{print $3, $5}' ${inFile}.clumped | awk 'NR>1' >  ${inFile}.clumped_pvalue.txt




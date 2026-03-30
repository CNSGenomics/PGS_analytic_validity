library(dplyr)
library(tidyr)
library(data.table)

args=commandArgs(trailingOnly = TRUE)

bimfile=args[1]
pred.file=args[2]

# Read the files
predictor <- read.table(pred.file, header = TRUE, stringsAsFactors = FALSE)
colnames(predictor)[1:6] = c("Index" ,"SNP", "chr","pos", "A1", "A2")

bim <- read.table(bimfile, header = FALSE, stringsAsFactors = FALSE,
                  col.names = c("chr", "SNP", "cm", "pos", "A1", "A2"))


# add an index column

bim$index = c(1:nrow(bim))

# Create chrbpAB for bim
bim <- bim %>%
  mutate(A = pmin(toupper(A1), toupper(A2)),
         B = pmax(toupper(A1), toupper(A2)),
         chrbpAB = paste0("chr", chr, ":", pos, ":", A, ":", B))

# If 'SNP' is ".", replace it with the value in 'chrbpAB'
bim <- bim %>%  mutate(SNP = ifelse(SNP == ".", chrbpAB, SNP))


# Handle duplicates in bim
predictor <- predictor %>%
  mutate(A = pmin(toupper(A1), toupper(A2)),
         B = pmax(toupper(A1), toupper(A2)))

# Match with predictor and handle duplicates
bim <- bim %>%  left_join(predictor, by = c("SNP", "A", "B"), suffix = c("", ".pred")) 
bim <- bim %>%  mutate(exact_match = !is.na(A1.pred) & !is.na(A2.pred)) 

dup.bim = bim[bim$SNP %in% bim[duplicated(bim$SNP) , "SNP"],]
dup.bim <- dup.bim %>% 
  group_by(SNP) %>% 
  arrange(desc(exact_match), .by_group = T) %>%
  ungroup()

dup.bim = data.frame(dup.bim)

# If there are duplicated SNPs for any reason then label them as _2, _3 etc
temp <- rle(dup.bim$SNP)
temp2 <- paste0(dup.bim$SNP, "_", unlist(lapply(temp$lengths, seq_len)))
temp2 <- gsub("_1$", "", temp2)
dup.bim$SNP <- temp2

## get the key columns
uniq.bim =  bim[!bim$SNP %in% bim[duplicated(bim$SNP) , "SNP"],]

fixed.bim = rbind(uniq.bim %>%  select(chr, SNP, cm, pos, A1, A2, index),
                  dup.bim %>%  select(chr, SNP, cm, pos, A1, A2, index))

fixed.bim = fixed.bim[order(fixed.bim$index),]

# Save the modified bim file
write.table(x = fixed.bim[,1:6], file = paste0(bimfile,"_updated" ), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)

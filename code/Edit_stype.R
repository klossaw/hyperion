# There are nine stypes.

sampleinfo <- read_excel("/cluster/home/flora_jh/projects/hyperion/docs/sampleinfo_hyperion_yemao.xlsx", sheet =1)
sampleinfo_copy <- sampleinfo

# Before Chemotherapy: tumor_cb.
sampleinfo[sampleinfo$chemotherapy == "no",]$stype <- "tumor_cb"

# After Chemotherapy: tumor_ca. Only those patients have "before chemotherapy" data are considered whether
# or not they are after chemotherapy.

fil <- sampleinfo[sampleinfo$chemotherapy == "no",]$cn_name %in%
  sampleinfo[sampleinfo$chemotherapy == "yes",]$cn_name
both_cb_ca <- sampleinfo[sampleinfo$chemotherapy == "no",]$cn_name[fil]
sampleinfo[(sampleinfo$chemotherapy == "yes") & (sampleinfo$cn_name %in% both_cb_ca),]$stype <- "tumor_ca"

# Punctured patients are divided into tumor_liver and tumor_pdac
punctured <- sampleinfo[sampleinfo$puncture == "yes" & sampleinfo$chemotherapy == "yes",]
punctured[punctured$disease == "liver",]$stype <- "tumor_liver"
punctured[punctured$disease == "pdac",]$stype <- "tumor_pdac"

# Paracancerous with tumor.
sampleinfo[sampleinfo$is_paired == "yes" & sampleinfo$disease == "para",]$stype <- "para"

# Paracancerous without tumor.
sampleinfo[sampleinfo$is_paired == "no" & sampleinfo$disease == "para",]$stype <- "para_only"

# Tumors with para.
sampleinfo[sampleinfo$is_paired == "yes" & sampleinfo$disease == "pdac",]$stype <- "tumor_para"

# Tumors without para. We don't care whether they are being chemo-therapied or not.
sampleinfo[sampleinfo$is_paired == "no" & sampleinfo$disease == "pdac" & sampleinfo$puncture == "no" & !(sampleinfo$cn_name %in% both_cb_ca),]$stype <- "tumor_only"

# Normal
sampleinfo[sampleinfo$disease == "normal",]$stype <- "normal"
# identical(sampleinfo$stype, sampleinfo_copy$stype)






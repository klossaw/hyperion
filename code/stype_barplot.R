sampleinfo <- read_excel("/cluster/home/flora_jh/projects/hyperion/docs/sampleinfo_hyperion.xlsx")
sampleinfo$stype[!duplicated(sampleinfo$sample_id)]

table <- table(sampleinfo$stype[!duplicated(sampleinfo$sample_id)])
table[2] <- 50
table <- table[-3]
data <- data.frame(stype = names(table), number = unname(table))
data$stype <- factor(data$stype, levels = c("normal", "tumor_ca", "tumor_cb",
                                            "tumor_liver", "tumor_pdac", "tumor_para",
                                            "para", "tumor_only"))
palette <- c("#1F9330", "#F1E020", "#F17C21", "#6F0880", "#EA3C9C",
             "#1B81B6", "#273593", "#F00A23")
p <- ggbarplot(data, x = "stype", y = "number.Freq", fill = "stype", palette = palette,
               xlab = "", ylab = "", label = T, ylim = c(0, 160))
pdf("/cluster/home/flora_jh/projects/hyperion/output/stype_number.pdf",
    width = 4, height = 4)
ggpar(p, x.text.angle = 90, legend = "none")
dev.off()


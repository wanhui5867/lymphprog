library(tidyverse)
library(ggpubr)
library(ggrepel)

# setwd('LymphRisk/')

ref.gene.distribution = read_tsv('data/gene_distribution.forQuantilNorm.xls') %>% column_to_rownames('Gene')
df.coef = read_tsv('data/gene.coef.xls')
cutoff.score = -0.5206329
backgroup.riskscore = read_tsv('data/riskScore.n1376.xls')
Example = read_tsv('data/Example.RNAseq.xls')

# Function of qunatile norm
quan.norm <- function(df_raw){
  df_log = df_raw %>% filter(Gene %in% rownames(ref.gene.distribution)) %>% 
    gather(Sample, TPM, -Gene) %>%
    mutate(TPM = if_else(is.na(TPM),0,TPM)) %>%
    dplyr::group_by(Sample, Gene) %>%
    dplyr::summarise(  TPM = max(TPM)) %>%
    spread(Sample, TPM) %>% select(Gene , everything())
  
  
  df_log.qn = normalize.quantiles.use.target(df_log %>%  column_to_rownames('Gene') %>% as.matrix(), 
                                             target = ref.gene.distribution[df_log$Gene,1] )
  
  
  rownames(df_log.qn) = df_log$Gene
  colnames(df_log.qn) = names(df_log)[-1]
  
  df_norm = as.data.frame(df_log.qn) %>% rownames_to_column('Gene')
  
  return(df_norm)
  
}

# Function of calculating risk score
cal.risk.score <- function(df_norm, df.coef) {
  df_score = df_norm %>% 
    gather(Sample, value, -Gene) %>% 
    right_join(df.coef %>% filter(Gene != "(Intercept)")) %>% 
    group_by(Sample) %>% 
    dplyr::summarise(riskScore = sum(value * Coef) + df.coef$Coef[df.coef$Gene == "(Intercept)" ]) %>% 
    mutate(Risk = if_else(riskScore > cutoff.score, 'High', 'Low'))
  
  return(df_score)
  
}

# plot dotplot 
point_plot <- function(df_score){
  
  col_riskgroup = structure(c('red', 'blue'), names = c('High', 'Low'))
  risk.allsample <-  df_score %>% bind_rows(backgroup.riskscore) %>% 
    arrange(riskScore) %>% mutate(rank = 1:nrow(.)) %>% 
    mutate(label = ifelse(!is.na(Risk), Sample, NA ))
  
  p <- ggplot(risk.allsample) +
    geom_point( mapping = aes(x = rank, y = riskScore, color = Risk, alpha = Risk ) , 
                size = 2) +
    scale_color_manual(values = col_riskgroup, na.value = 'grey90') + 
    scale_alpha_manual(values = c(1, 1), na.value = 0.2) +
    geom_hline(yintercept = cutoff.score, lty = 2) +  
    geom_text_repel(aes(x = rank, y = riskScore, label = label),  
                    arrow = arrow(length = unit(0.02, "npc")),
                    box.padding = 1) + 
    theme_pubr() + guides(alpha = "none" ) +
    rremove('x.text') + rremove('x.ticks') + rremove('x.title')+ rremove('x.axis') 
  return(p)
  
}




# wrap function
runRisk <- function(df_raw){
  # quantile normalization
  df_norm = quan.norm(df_raw)
  
  # check the normalization
  densityplot <- ggdensity(df_norm %>% gather(Sample, value, -Gene), x = 'value', color = 'Sample')
  
  # calculate risk score
  df_score = cal.risk.score(df_norm, df.coef) 
  
  # point plot
  pointplot = point_plot(df_score)
  return(list(df_norm = df_norm, df_score = df_score, densityplot = densityplot, point = pointplot ))
  
}

# # Run
# output <- runRisk(Example)
# output$df_score
# output$pointplot



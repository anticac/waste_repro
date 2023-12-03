rm(list = ls())
graphics.off()
library(dplyr)
library(ggplot2)
library(ggpubr)

setwd("~/Publikacije/Publikacija_Purgar_et_al_2022/codes and datasets") # set to you working directory

# Data from the Dataset_MA_final.csv
data_wjm <- read.csv("Dataset_MA_final.csv", header=T, sep=";", dec=".") # data_wjm contains estimate from Jennions&Moller paper
data_wjm <- data_wjm%>%mutate_if(is.character, as.factor)
data_wjm$N <- as.numeric(data_wjm$N)
data_wjm$DOG <- as.factor(data_wjm$DOG)
names(data_wjm)[names(data_wjm) == "DOG"] <- "Generality"
data_wjm$Stage <- factor(data_wjm$Stage, 
                         levels = c("Publication",
                                    "Study planning",
                                    "Reporting"))
data <- data_wjm[-c(8),] # data is without Jennions & Moller paper

# Data - Meta-analytic means (CI) from the Meta_analytic_means.csv
mam_all <- read.csv("Meta_analytic_means.csv", header=T, sep=";", dec=".")
#mam_all contains estimate from Jennions&Moller paper

mam_all <- mam_all%>%mutate_if(is.character, as.factor)
mam_all$Stage <- factor(mam_all$Stage, 
                        levels = c("Publication", 
                                   "Study planning",
                                   "Reporting")) 


#############################  PLOTS  ##########################################

################################################################################
#### Figure 3A - Estimates of the unused potential of ecological research by ### 
############# the stage of the research-cycle, Box and whisker plot ############
################################################################################

data_fig1 <- filter(data, Remove.from.the.global.MA=="No")

f1  <- ggplot(data_fig1, aes(x=Stage, y=Estimate)) + 
  geom_boxplot(lwd=0.3, fatten=1.8) +
  stat_boxplot(geom = "errorbar", width=0.1, lwd=0.3) +
  geom_jitter(aes(size = N), alpha=0.5, shape=1, color="gray30", stroke=0,
              position = position_jitter(width = 0.4, height = 0.1, seed = 1993)) +
  geom_jitter(aes(fill=Generality, size = N), alpha=0.6, shape=21, color="gray30",
              stroke=0.1,
              position = position_jitter(width = 0.4, height = 0.1, seed = 1993)) +
  scale_fill_manual(values=c("#E69F00", "#56B4E9", "black")) +
  scale_size(range = c(1, 8), name="Actual sample size") +
  guides(fill = guide_legend(override.aes = list(size = 3.5))) +
  guides(size = "none") +
  theme_light() +
  theme(legend.direction = "vertical",
        legend.justification=c(0.01,0.99), legend.position=c(0.01,0.99),
        legend.background = element_rect(fill="transparent"),
        legend.title = element_text(color = "gray20", 
                                    size=7),
        legend.text = element_text(size=7, color = "gray20"),
        plot.title = element_text(color="gray20", size=7),
        axis.title.x = element_text(size=7, color = "gray20", vjust = 1.7,
                                    margin = margin(t = 10, r = 10, b = 0, l = 0)),
        axis.text.x = element_text(size=7),
        axis.title.y = element_text(size=7, color = "gray20"),
        axis.text.y = element_text(size=7),
        panel.grid.major=element_blank(),
        panel.grid.minor = element_blank(),
        legend.spacing.x = unit(1, "mm"),
        legend.spacing.y = unit(1, "mm"),
        legend.key = element_rect(color = NA, fill = NA),
        legend.key.size = unit(0.5, "mm"),
        panel.border = element_rect(fill=NA, size=0.3)
        
  ) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +
  ylab("Proportion wasted") +
  xlab("") +
  ggtitle(" ")

f1   
#______________________________________
# ggsave("Figure_3A.png", dpi=700, dev='png', height=4.5, width=6.5, units="in")

################################################################################
################# Figure 3 A - Meta-analytic means (CI) ########################
################################################################################

mam <- filter(mam_all, Generality=="1" | Generality=="2&3" | Generality=="All")
mam$Generality <- factor(mam$Generality, 
                         levels = c("All", "1", "2&3"))

mam_plot  <- ggplot() + 
  geom_pointrange(data=mam, 
                  mapping=aes(x=mean, y=Stage, xmin=lowerCI, 
                              xmax=upperCI, color=Generality), 
                  size=0.6, position = position_dodge(0.3), 
                  fatten = 0.4, shape=19) + 
  scale_colour_manual(values=c("black", "#E69F00", "#999999"), 
                      guide = guide_legend(override.aes = list(linetype = c(0, 0, 0),
                                                               shape = c(19, 19, 19),
                                                               size = 0.5), 
                                           keyheight = 0.7)) +
  theme_light() +
  theme(panel.background=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        axis.title.x = element_text(size=7, color = "gray20", vjust = 3.5,
                                    margin = margin(t = 10, r = 10, b = 0, l = 0)),
        axis.text.x = element_text(size=7),
        axis.title.y = element_text(size=7, color = "gray20"),
        axis.text.y = element_text(size=7, color = "gray20", angle = 90, 
                                   vjust=0.5, hjust = 0.5),
        plot.title = element_text(color="gray20", size=7, vjust = -1),
        legend.title = element_text(color = "gray20", 
                                    size = 7),
        legend.direction = "vertical",
        legend.justification=c(0.01,0.99), legend.position=c(0.75, 0.99),
        legend.background = element_rect(fill="transparent"),
        legend.text = element_text(size=7, color="gray20"),
        legend.spacing.x = unit(1, "mm"),
        legend.spacing.y = unit(1, "mm"),
        legend.key = element_rect(color = NA, fill = NA),
        legend.key.size = unit(4.4, "mm"),
        panel.border = element_rect(fill=NA, size=0.3)
        
  ) +
  scale_x_continuous(breaks = seq(0.3, 0.9, by=0.1), limits = c(0.3, 0.9)) +
  ggtitle("Meta-analytic means (CI)") + 
  xlab("Effect size") +
  ylab("") 

mam_plot 
#______________________________________
# ggsave("Fig3A_mameans.png", dpi=700, dev='png', height=4.5, width=4.5, units="in")


################################################################################
##### Figure 3B - Estimates of the unused potential of ecological research #####
######################## by Study planning stage ###############################
################################################################################

planning <- filter(data, Stage=="Study planning")
planning$Substage <- factor(planning$Substage, 
                            levels = c("Design", "Blinding", "Analysis"))


f2  <- ggplot(planning, aes(x=Substage, y=Estimate)) + 
  geom_boxplot(lwd=0.3, fatten=1.8) +
  stat_boxplot(geom = "errorbar", width=0.1, lwd=0.3) +
  geom_jitter(aes(size = N), alpha=0.5, shape=1, color="gray30", stroke=0,
              position = position_jitter(width = 0.3, height = 0.1, seed = 2000)) +
  geom_jitter(aes(fill=Generality, size = N), alpha=0.6, shape=21, color="gray30",
              stroke=0.1,
              position = position_jitter(width = 0.3, height = 0.1, seed = 2000)) +
  scale_fill_manual(values=c("#E69F00", "#56B4E9", "black")) +
  scale_size(range = c(1, 8), name="Actual sample size") +
  guides(fill = guide_legend(override.aes = list(size = 3.5))) +
  guides(size = "none") +
  theme_light() +
  theme(plot.title = element_text(color="gray20", size=7),
        axis.title.x = element_text(size=7, color = "gray20", vjust = 1.7,
                                    margin = margin(t = 10, r = 10, b = 0, l = 0)),
        axis.text.x = element_text(size=7),
        axis.title.y = element_text(size=7, color = "gray20"),
        axis.text.y = element_text(size=7),
        panel.grid.major=element_blank(),
        panel.grid.minor = element_blank(),
        legend.position="none",
        panel.border = element_rect(fill=NA, size=0.3)
        
  ) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +
  ylab("Proportion wasted") +
  xlab("") +
  ggtitle(" ") 

f2   
#______________________________________
# ggsave("Figure_3B.png", dpi=700, dev='png', height=4.5, width=6.5, units="in")


################################################################################
############## Data - Study planning Meta-analytic means (CI) ##################
################################################################################

# data from Study_planning_ma_means.csv
sp_mam <- read.csv("Study_planning_ma_means.csv", header=T, sep=";", dec=".")
sp_mam <- sp_mam%>%mutate_if(is.character, as.factor)

sp_mam$Planning <- factor(sp_mam$Planning, 
                          levels = c("Design", "Blinding", "Analysis"))

sp_mam$Generality <- factor(sp_mam$Generality, 
                            levels = c("All", "1", "2&3"))

################################################################################
################# Figure 3B - Meta-analytic means (CI) ######################### 
################################################################################

fig2_mam  <- ggplot() + 
  geom_pointrange(data=sp_mam, 
                  mapping=aes(x=mean, y=Planning, xmin=lowerCI, 
                              xmax=upperCI, color=Generality), 
                  size=0.6, position = position_dodge(0.3), 
                  fatten = 0.4, shape=19) + 
  scale_colour_manual(values=c("black", "#E69F00", "#999999"), 
                      guide = guide_legend(override.aes = list(linetype = c(0, 0, 0),
                                                               shape = c(19, 19, 19),
                                                               size = 0.5), 
                                           keyheight = 0.7)) +
  theme_light() +
  theme(panel.background=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        axis.title.x = element_text(size=7, color = "gray20", vjust = 3.5,
                                    margin = margin(t = 10, r = 10, b = 0, l = 0)),
        axis.text.x = element_text(size=7),
        axis.title.y = element_text(size=7, color = "gray20"),
        axis.text.y = element_text(size=7, color = "gray20", angle = 90, 
                                   vjust=0.5, hjust = 0.5),
        plot.title = element_text(color="gray20", size=7, vjust = -1),
        legend.position="none",
        panel.border = element_rect(fill=NA, size=0.3)
        
  ) +
  scale_x_continuous(breaks = seq(0.3, 0.9, by=0.1), limits = c(0.3, 0.9))+
  ggtitle("Meta-analytic means (CI)") + 
  ylab("") +
  xlab("Effect size")

fig2_mam 
#______________________________________
# ggsave("Fig3B_mameans.png", dpi=700, dev='png', height=4.5, width=4.5, units="in")


Figure3  <- ggarrange(f1 , mam_plot , f2 , fig2_mam ,
                      ncol=2, nrow=2,
                      labels = c("a", "", "b", ""), 
                      widths = c(1.4, 1),
                      font.label = list(size = 7, color = "gray30")) 
Figure3 
ggsave("Figure3.pdf", dpi=700, dev='pdf', height=150, width=170, units="mm")
# ggsave("Figure3_jpg.jpg", dpi=700, dev='jpg', height=150, width=170, units="mm")


################################################################################
############################## Supplementary ###################################
################################################################################

################################################################################
# Supplement figure - Estimates of the unused potential of ecological research #
################################################################################

data_suppl_fig <- filter(data_wjm, Remove.from.the.global.MA=="No")

f_wjm <- ggplot(data_suppl_fig, aes(x=Stage, y=Estimate)) + 
  geom_boxplot(lwd=0.3, fatten=1.8) +
  stat_boxplot(geom = "errorbar", width=0.1, lwd=0.3) +
  geom_jitter(aes(size = N), alpha=0.5, shape=1, color="gray30", stroke=0,
              position = position_jitter(width = 0.4, height = 0.1, seed = 17)) +
  geom_jitter(aes(fill=Generality, size = N), alpha=0.6, shape=21, color="gray30",
              stroke=0.1,
              position = position_jitter(width = 0.4, height = 0.1, seed = 17)) +
  scale_fill_manual(values=c("#E69F00", "#56B4E9", "black")) +
  scale_size(range = c(1, 8), name="Actual sample size") +
  guides(fill = guide_legend(override.aes = list(size = 3.5))) +
  guides(size = "none") +
  theme_light() +
  theme(legend.direction = "vertical",
        legend.justification=c(0.01,0.99), legend.position=c(0.01,0.99),
        legend.background = element_rect(fill="transparent"),
        legend.title = element_text(color = "gray20", 
                                    size=7),
        legend.text = element_text(size=7, color = "gray20"),
        plot.title = element_text(color="gray20", size=7),
        axis.title.x = element_text(size=7, color = "gray20", vjust = 1.7,
                                    margin = margin(t = 10, r = 10, b = 0, l = 0)),
        axis.text.x = element_text(size=7),
        axis.title.y = element_text(size=7, color = "gray20"),
        axis.text.y = element_text(size=7),
        panel.grid.major=element_blank(),
        panel.grid.minor = element_blank(),
        legend.spacing.x = unit(1, "mm"),
        legend.spacing.y = unit(1, "mm"),
        legend.key = element_rect(color = NA, fill = NA),
        legend.key.size = unit(0.5, "mm"),
        panel.border = element_rect(fill=NA, size=0.3)
        
  ) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +
  ylab("Proportion wasted") +
  xlab("") +
  ggtitle(" ")

f_wjm  
#______________________________________
# ggsave("Suppl_fig.png", dpi=700, dev='png', height=4.5, width=6.5, units="in")

################################################################################
############## Supplement figure - Meta-analytic means (CI) ####################
################################################################################

mam_wjm <- filter(mam_all, Generality=="with Jennions&Moller paper")

mam_wjm$Stage <- factor(mam_wjm$Stage, 
                        levels = c("Publication", 
                                   "Study planning",
                                   "Reporting"))

suppl_mam <- ggplot() + 
  geom_pointrange(data=mam_wjm, 
                  mapping=aes(x=mean, y=Stage, xmin=lowerCI, xmax=upperCI, color=Generality), 
                  size=0.6, position = position_dodge(0.3), fatten = 0.4, shape=19) + 
  scale_colour_manual(values=c("black"), 
                      guide = guide_legend(override.aes = list(linetype = c(0),
                                                               shape = c(19),
                                                               size = 0.5)),
                      labels="with Jennions & Moller\npaper") +
  theme_light() +
  theme(panel.background=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        axis.title.x = element_text(size=7, color = "gray20", vjust = 3.5,
                                    margin = margin(t = 10, r = 10, b = 0, l = 0)),
        axis.text.x = element_text(size=7),
        axis.title.y = element_text(size=7, color = "gray20"),
        axis.text.y = element_text(size=7, color = "gray20", angle = 90, 
                                   vjust=0.5, hjust = 0.5),
        plot.title = element_text(color="gray20", size=7, vjust = -1),
        legend.title = element_text(color = "gray20", 
                                    size = 7),
        legend.direction = "vertical",
        legend.justification=c(0.01,0.99), legend.position=c(0.55, 0.99),
        legend.background = element_rect(fill="transparent"),
        legend.text = element_text(size=5, color="gray20"),
        legend.spacing.x = unit(1, "mm"),
        legend.spacing.y = unit(1, "mm"),
        legend.key = element_rect(color = NA, fill = NA),
        legend.key.size = unit(3.5, "mm"),
        panel.border = element_rect(fill=NA, size=0.3)
        
  ) +
  scale_x_continuous(breaks = seq(0.2, 1.0, by=0.1), limits = c(0.2, 1.0))+
  ggtitle("Meta-analytic means (CI)") + 
  ylab("") +
  xlab("Effect size")

suppl_mam
#______________________________________
# ggsave("Suppl_ma_means.png", dpi=700, dev='png', height=4.5, width=4.5, units="in")


suppl_fig <- ggarrange(f_wjm, suppl_mam,
                       ncol=2, nrow=1,
                       widths = c(1.4, 1))

suppl_fig

# ggsave("Suppl_fig.png", dpi=700, dev='png', height=4.5, width=10, units="in")
ggsave("Fig_S4.pdf", dpi=700, dev='pdf', height=75, width=170, units="mm")
# ggsave("Fig_S4_jpg.jpg", dpi=700, dev='jpg', height=75, width=170, units="mm")

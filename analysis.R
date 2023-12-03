#=============================================================================================================#
# Script created by Antica Culina, a.culina@yahoo.com
# Script created in version R 1.4.1106
# This script is for runnin meta-analytic & meta-regression models on research waste
# from Purgar et al. 2022: Quantifying research waste in ecology
#=============================================================================================================#

# Set working directory to wherever you have downloaded the data and code
#session info  can be found at the end of this code

# installing needed packages and calling libraries
rm(list = ls())

install.packages("lme4", dep = T) # note ve used version '1.1.28'
library(MASS)
library(metafor)
library(dplyr)


sessionInfo()

# lading data

data.waste <- read.table(file.choose(), header = T, sep = ";") # load in the 'Dataset_MA_final' here

data.waste$DOG2 <- as.factor(data.waste$DOG2) # DOG2 needs to become a factor

# Desription of the variables in the dataset
# Ref.n = codes for a meta-study, see the ref list at the end of the code
# columns Field, Subfield, Exact.topic.coverage = general filed/subfield/topic of the meta-study from which the effect
####### size comes from
# DOG1 = Degree of generality. Codes for whether a meta-study is concerned with a narrow research
#######  field within ecology (e.g. facultative sex-ratio adjustment in birds. coded with "1") 
####### or a border area of ecological research (e.g. literature from nine prominent ecological journals, coded with "3")

# DOG2 = same as DOG1 but the two broader categories (i.e. "2"  and "3") are merged (now coded as DOG2)
# Type.of.studies = codes for whether a meta-study only considered experimental literature ('experimental') or 
################# any literature (thus experimental and observational studies;  'any')

# Type.of.literature = codes for whether a meta-study considered only peer-reviewed literature 
################# any literature (both peer-reviewed and non-reviewed)
# Period = time period considered by a meta-study
# Stage = the stage of research life-cycle for which research waste was estimated: 
########## possible values: 'Study planning'; 'Publication'; 'Reporting'
# Substage = codes for the main subcategories of waste, Only for Study planning which is divided into
########## Design, Blinding, Analysis
# Type.of.waste= exact description of the waste as given in the original meta-study
########## This not used in the meta-analysis but left for the transparency on how we 
################ derived to the variable Substage

# N = sample size (n of studies) used in a meta-study to derive the estimate of waste
# units.sampled = what is the main unit of a sample size
# Estimate = the estimate of waste (equals to N_failure/Actual.sample.size)
# N_f = number of units that were wasted (failed)
# Remove.from.the.global.MA = this refers to some estimates of Substages, if the two of Substage estimates are
###### available for the same study (but are left in the main dataset to contribute to calculation of waste at each
######## substage), one  (the lower of the two estimates) is removed for the meta-analysis on the waste at the Study planning.



# creating subsets of data for later analyses. Note that we decided to exclude the
########## estimated of low power of studies as this category does not have a clear connection 
########## with Waste (e.g. under-powered study can still add to the evidence in the global literature
######################on a certain effect)

data.publ <- filter(data.waste, Stage == "Publication")
data.plan <- filter(data.waste, Stage == "Study planning")
data.rep <- filter(data.waste, Stage == "Reporting")

data.plan <- na.omit(data.plan) 

#==============================
### Waste at Publication stage
#==============================

###  method using double arcsin transformation

data.publ$pi <- with(data.publ, N_f/N)
data.publ <- escalc(measure="PFT", xi=N_f, ni=N, data=data.publ)

data.publ # yi values are the Freeman-Tukey (double arcsine) transformed proportions, while the vi values are the corresponding sampling variances. 

res <- rma(yi, vi, method="FE", data=data.publ) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.publ$N))

#### excluding the estimate of Jennions&Moller (we use this one in the main text)

data.publ.direct <- filter(data.publ, Estimate !=0.124)

res <- rma(yi, vi, method="FE", data=data.publ.direct) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.publ.direct$N))


#==============================
#### Wast at Study planning stage
#==============================

data.plan_main <- filter(data.plan, Remove.from.the.global.MA == "No") # keep only the worst estimate if two
## estimates come from the same study

###  method using double arcsin transformation

data.plan_main$pi <- with(data.plan_main, N_f/N)
data.plan_main <- escalc(measure="PFT", xi=N_f, ni=N, data=data.plan_main)

data.rep # yi values are the Freeman-Tukey (double arcsine) transformed proportions, while the vi values are the corresponding sampling variances. 

res <- rma(yi, vi, method="FE", data=data.plan_main) # wighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.plan_main$N))

#==============================
#### Waste at Reporting stage
#==============================

###  method using double arcsin transformation

data.rep$pi <- with(data.rep, N_f/N)
data.rep <- escalc(measure="PFT", xi=N_f, ni=N, data=data.rep)

data.rep # yi values are the Freeman-Tukey (double arcsine) transformed proportions, while the vi values are the corresponding sampling variances. 

res <- rma(yi, vi, method="FE", data=data.rep) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.rep$N))


#==============================
#### Lets add predictors to the models (weighted models)
#==============================


res <- rma(yi, vi, method="FE", mods = ~DOG2, data=data.publ) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.publ$N))

#### excluding the estimate of Jennions&Moller

res <- rma(yi, vi, method="FE", mods = ~DOG2, data=data.publ.direct) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.publ.direct$N))


res <- rma(yi, vi, method="FE", mods = ~DOG2, data=data.rep) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.rep$N))

res <- rma(yi, vi, method="FE", mods = ~DOG2, data=data.plan_main) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.plan_main$N))

#==============================
##### Substages of Study planning
#==============================

data.plan$pi <- with(data.plan, N_f/N)
data.plan <- escalc(measure="PFT", xi=N_f, ni=N, data=data.plan)

res <- rma(yi, vi, method="FE", mods = ~Substage, data=data.plan) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.plan$N))



# substages of study planning by DOG2

data.plan.1 <- filter(data.plan, DOG2 == 1)
data.plan.2 <- filter(data.plan, DOG2 != 1)

res <- rma(yi, vi, method="FE", mods = ~Substage, data=data.plan.1) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.plan$N))


res <- rma(yi, vi, method="FE", mods = ~Substage, data=data.plan.2) # weighted mean
res
predict(res, transf=transf.ipft.hm, targs=list(ni=data.plan$N))


#==================================================================================
#### References for papers, coded by a 'ref.n' in the data table 'Dataset_MA_final'
#==================================================================================

#1.	Bennett, L. T. & Adams, M. A. Assessment of ecological effects due to forest harvesting: approaches and statistical issues. Journal of Applied Ecology 41, 585-598 (2004).
#2.	Campbell, H. A. et al. Finding our way: On the sharing and reuse of animal telemetry data in Australasia. Sci Total Environ 534, 79-84 (2015).
#3.	Cassey, P., Ewen, J. G., Blackburn, T. M. & M ller, A. P. A survey of publication bias within evolutionary ecology. Proc Biol Sci 271 Suppl 6, S451-454 (2004).
#4.	Gillespie, B. R., Desmet, S., Kay, P., Tillotson, M. R. & Brown, L. E. A critical analysis of regulated river ecosystem responses to managed environmental flows from reservoirs. Freshwater Biology 60, 410-425 (2015).
#5.	Jennions, M. D. & M ller, A. P. Publication bias in ecology and evolution: an empirical assessment using the 'trim and fill' method. Biol Rev Camb Philos Soc 77, 211-222 (2002).
#6.	Kardish, M. R. et al. Blind trust in unblinded observation in Ecology, Evolution, and Behavior. Frontiers in Ecology and Evolution 3, 51 (2015).
#7.	M ller, A. P., Thornhill, R. & Gangestad, S. W. Direct and indirect tests for publication bias: asymmetry and sexual selection. Animal Behaviour 70, 497-506 (2005).
#8.	Parker, T. H. What do we really know about the signalling role of plumage colour in blue tits? A case study of impediments to progress in evolutionary biology. Biol Rev Camb Philos Soc 88, 511-536 (2013).
#9.	S nchez-T jar, A. et al. Meta-analysis challenges a textbook example of status signalling and demonstrates publication bias. eLife 7, e37385 (2018).
#10.	Zaitsev, A. S., Gongalsky, K. B., Malmstr m, A., Persson, T. & Bengtsson, J. Why are forest fires generally neglected in soil fauna research? A mini-review. Applied Soil Ecology 98, 261-271 (2016).
#11.	Zvereva, E. L. & Kozlov, M. V. Biases in studies of spatial patterns in insect herbivory. Ecological Monographs 89, e01361 (2019).
#12.	Forstmeier, W. & Schielzeth, H. Cryptic multiple hypotheses testing in linear models: overestimated effect sizes and the winner's curse. Behav Ecol Sociobiol 65, 47-55 (2011).
#13.	Holman, L., Head, M. L., Lanfear, R. & Jennions, M. D. Evidence of Experimental Bias in the Life Sciences: Why We Need Blind Data Recording. PLOS Biology 13, e1002190 (2015).
#14.	Koricheva, J. Non-significant results in ecology: a burden or a blessing in disguise? Oikos 102, 397-401 (2003)
#15.	Yoccoz, N. G. Use, Overuse, and Misuse of Significance Tests in Evolutionary Biology and Ecology. Bulletin of the Ecological Society of America 72, 106-111 (1991).
#16.	Wilgenburg, E. van & Elgar, M. A. Confirmation Bias in Studies of Nestmate Recognition: A Cautionary Note for Research into the Behaviour of Animals. PLOS ONE 8, e53548 (2013).
#17.	Fidler, F., Burgman, M. A., Cumming, G., Buttrose, R. & Thomason, N. Impact of criticism of null-hypothesis significance testing on statistical reporting practices in conservation biology. Conserv Biol 20, 1539-1544 (2006).
#18.	Haddaway, N. R., Styles, D. & Pullin, A. S. Evidence on the environmental impacts of farm land abandonment in high altitude/mountain regions: a systematic map. Environmental Evidence 3, 17 (2014).
#19.	Mrosovsky, N. & Godfrey, M. The path from grey literature to Red Lists. Endangered Species Research 6, 185-191 (2008).
#20.	Brl k, V. et al. Weak effects of geolocators on small birds: A meta-analysis controlled for phylogeny and publication bias. Journal of Animal Ecology 89, 207-220 (2020).
#21.	McDonald, S., Cresswell, T., Hassell, K. & Keough, M. Experimental design and statistical analysis in aquatic live animal radiotracing studies: A systematic review. Critical Reviews in Environmental Science and Technology, 1-30 (2021).
#22.	Ramage, B. S. et al. Pseudoreplication in tropical forests and the resulting effects on biodiversity conservation. Conserv Biol 27, 364-372 (2013).
#23.	Kozlov, M. Plant studies on fluctuating asymmetry in Russia: Mythology and methodology. Russian Journal of Ecology 48, 1-9 (2017).
#24.	O'Brien, C., van Riper, C. & Myers, D. E. Making reliable decisions in the study of wildlife diseases: using hypothesis tests, statistical power, and observed effects. J Wildl Dis 45, 700-712 (2009).
#25.	Hurlbert, S. H. Pseudoreplication and the Design of Ecological Field Experiments. Ecological Monographs 54, 187-211 (1984).
#26.	Heffner, R. A., Butler, M. J. & Reilly, C. K. Pseudoreplication Revisited. Ecology 77, 2558-2562 (1996).
#27.	Kozlov, M. V. Pseudoreplication in ecological research: the problem overlooked by Russian scientists. Zh Obshch Biol 64, 292-307 (2003).
#28.	Vorobeichik, E. L. & Kozlov, M. V. Impact of point polluters on terrestrial ecosystems: Methodology of research, experimental design, and typical errors. Russ J Ecol 43, 89-96 (2012).
#29.	Hurlbert, S. H. & White, M. D. Experiments with Freshwater Invertebrate Zooplanktivores: Quality of Statistical Analyses. Bulletin of Marine Science 53, 128-153 (1993).
#30.	Waller, B., Warmelink, L., Liebal, K., Micheletta, J. & Slocombe, K. Pseudoreplication: A widespread problem in primate communication research. Animal Behaviour 86, 483-488 (2013).
#31.	Sallabanks, R., Arnett, E. B. & Marzluff, J. M. An Evaluation of Research on the Effects of Timber Harvest on Bird Populations. Wildlife Society Bulletin (1973-2006) 28, 1144-1155 (2000).
#32.	Cornwall, C. E. & Hurd, C. L. Experimental design in ocean acidification research: problems and solutions. ICES Journal of Marine Science 73, 572-581 (2016).
#33.	Johnson III, W. T. & Freeberg, T. M. Pseudoreplication in use of predator stimuli in experiments on antipredator responses. Animal Behaviour 119, 161-164 (2016).
#34.	Christie, A. P. et al. Quantifying and addressing the prevalence and bias of study designs in the environmental and social sciences. Nat Commun 11, 6377 (2020).



#=========================================
# > sessionInfo()
#=========================================

# R version 4.0.4 (2021-02-15)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
#Running under: Windows 10 x64 (build 14393)

#Matrix products: default

#locale:
#  [1] LC_COLLATE=English_Europe.1252  LC_CTYPE=English_Europe.1252    LC_MONETARY=English_Europe.1252
#[4] LC_NUMERIC=C                    LC_TIME=English_Europe.1252    

#attached base packages:
#  [1] stats     graphics  grDevices utils     datasets  methods   base     

#other attached packages:
#  [1] dplyr_1.0.6   metafor_2.4-0 Matrix_1.3-2  MASS_7.3-53  

#loaded via a namespace (and not attached):
#  [1] lattice_0.20-41  fansi_0.5.0      assertthat_0.2.1 crayon_1.4.1     utf8_1.2.1       grid_4.0.4      
#[7] R6_2.5.0         DBI_1.1.1        lifecycle_1.0.0  nlme_3.1-152     magrittr_2.0.1   pillar_1.6.1    
#[13] rlang_0.4.11     vctrs_0.3.8      generics_0.1.0   ellipsis_0.3.2   tools_4.0.4      glue_1.4.2      
#[19] purrr_0.3.4      compiler_4.0.4   pkgconfig_2.0.3  tidyselect_1.1.1 tibble_3.1.2 
BiocManager::install("waldronlab/curatedMetagenomicAnalyses")

library(dplyr)
library(curatedMetagenomicData)
library(curatedMetagenomicAnalyses)

# load data
data("sampleMetadata")
availablediseases <- pull(sampleMetadata, study_condition) %>%
  table() %>%
  sort(decreasing = TRUE)
availablediseases

studies <- lapply(names(availablediseases), function(x){
  filter(sampleMetadata, study_condition %in% x) %>%
    pull(study_name) %>%
    unique()
})

names(studies) <- names(availablediseases)
studies <- studies[-grep("control", names(studies))] # get rid of controls
studies <- studies[sapply(studies, length) > 1] # available in more than one study
studies

# save IBD as csv file

studies <- c("LiJ_2014","NielsenHB_2014","VilaAV_2018")
cond <- "IBD"
data_type <- "relative_abundance"

for (study in studies) {

  remove_studies <- c("HallAB_2017","HMP_2019_ibdmdb","IjazUZ_2017","IaniroG_2022","LiJ_2014","NielsenHB_2014","VilaAV_2018")
  remove_studies <- remove_studies[! remove_studies %in% c(study)]
  se <- curatedMetagenomicAnalyses::makeSEforCondition(cond, removestudies=remove_studies, dataType = data_type)
  print(paste0("Next study condition:", cond, " /// Body site: ", unique(colData(se)$body_site)))
  print(with(colData(se), table(study_name, study_condition)))
  cat("\n \n")
  flattext <- select(as.data.frame(colData(se)), c("study_name", "study_condition", "subject_id"))
  rownames(flattext) <- colData(se)$sample_id
  flattext <- cbind(flattext, data.frame(t(assay(se))))
  write.csv(flattext, file = paste0("studies/",cond, "_", study,"_", data_type,".csv"))
}

library(dplyr)
library(tidyr)
library(readr)

PPP <- read_csv('./PPP_with_FIPS.csv')

PPP$RuralUrbanIndicator <- ifelse(PPP$RuralUrbanIndicator == 'R', 1, 0) 

county_data <- PPP %>%
group_by(BorrowerFIPS) %>%
summarise_at(.,.vars = vars(CurrentApprovalAmount, ForgivenessAmount), 
.funs = list(sum = sum, mean = mean), na.rm = T)

rural_pcts <- PPP %>%
group_by(BorrowerFIPS) %>%
summarize(rural_pct = sum(RuralUrbanIndicator)/length(RuralUrbanIndicator))

county_data <- county_data %>%
merge(rural_pcts, by = 'BorrowerFIPS')

unr <- read.csv("./unemployment_clean.csv", header = T)%>%
filter(!(is.na(X2019_q234.q1) | is.na(X2020_q234.q1) | is.na(X2021_q234.q1)))
covid <- read.csv("covid_by_county.csv", header = T)

county_data <- county_data %>%
merge(covid, by.x = 'BorrowerFIPS', by.y = 'fips') %>%
merge(unr, by = 'BorrowerFIPS') %>%
dplyr::select(-c('X'))

county_data <- county_data %>%
mutate(Total_loan_bil = CurrentApprovalAmount_sum / 1e9,
Forgiven_loan_bil = ForgivenessAmount_sum / 1e9,
Rural_loan_pct = rural_pct,
Total_case = cases,
Total_death = deaths,
unr_change2020 = X2020_q234.q1,
unr_change2019 = X2019_q234.q1) %>%
dplyr::select(-c("CurrentApprovalAmount_sum",'ForgivenessAmount_sum',
"rural_pct",'cases','deaths','X2020_q234.q1','X2019_q234.q1'))

county_data %>% write.csv("county_data_final.csv")
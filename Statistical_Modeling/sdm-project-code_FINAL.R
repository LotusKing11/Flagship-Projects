# Data: https://data.cms.gov/provider-compliance/cost-report/hospital-provider-cost-report
# Data Dictionary: https://data.cms.gov/resources/hospital-provider-cost-report-data-dictionary
# Multi-level data: Upper level: State
#                   Lower level: Year


#Import the libraries
library(readr)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(lme4)
library(car)


getwd()
# Read & preprocess data
df_14 <- read.csv("CSV_2014_Hospital_Cost_Report.csv")
df_14$year <- "2014"
df_15 <- read.csv("CSV_2015_Hospital_Cost_Report.csv")
df_15$year <- "2015"
df_16 <- read.csv("CSV_2016_Hospital_Cost_Report.csv")
df_16$year <- "2016"
df_17 <- read.csv("CSV_2017_Hospital_Cost_Report.csv")
df_17$year <- "2017"
df_18 <- read.csv("CSV_2018_Hospital_Cost_Report.csv")
df_18$year <- "2018"
df_combined <- bind_rows(df_14, df_15, df_16, df_17, df_18)
str(df_combined)
message("Total no of records = ",count(df_combined))


## rename the provider type and type of control to the meaningful names from data dictionary

df_combined$Provider.Type <-
  recode_factor(
    df_combined$Provider.Type,
    `1` = "General Short Term",
    `2` = "General Long Term",
    `3` = "Cancer",
    `4` = "Psychiatric",
    `5` = "Rehabilitation",
    `6` = "Religious Non-Medical Health Care Institution",
    `7` = "Children",
    `8` = "Alcohol and Drug",
    `9` = "Other"
  )
df_combined$Provider.Type<-relevel(df_combined$Provider.Type,"General Short Term")
df_combined$Type.of.Control <-
  recode_factor(
    df_combined$Type.of.Control,
    `1` = "Voluntary Nonprofit-Church",
    `2` = "Voluntary Nonprofit-Other",
    `3` = "Proprietary-Individual",
    `4` = "Proprietary-Corporation",
    `5` = "Proprietary-Partnership",
    `6` = "Proprietary-Other",
    `7` = "Governmental-Federal",
    `8` = "Governmental-City-County",
    `9` = "Governmental-County",
    `10` = "Governmental-State",
    `11` = "Governmental-Hospital District",
    `12` = "Governmental-City",
    `13` = "Governmental-Other"
  )

df_combined$Type.of.Control<-relevel(df_combined$Type.of.Control,"Proprietary-Individual")

## this is a cost report of all the hospitals with fiscal start and end date
## for our analysis we are considering the hospital that are reported with a
## range of 364 days->1 year i.e 90% of the dataset
df<-df_combined
df$noOfDays <-
  as.Date(df$Fiscal.Year.End.Date, format <-
            "%m/%d/%Y") - as.Date(df$Fiscal.Year.Begin.Date, format <-
                                    "%m/%d/%Y") == 364

df <- df[df$noOfDays == TRUE, ]


message("Total no of records with fiscal range of 1 year = ",count(df))
#Handling Na values
#remove rows with na from y variable-Cost.To.Charge.Ratio
colSums(is.na(df))

df <- df[!is.na(df$Cost.To.Charge.Ratio), ]

message("Total no of records removing na from Cost.To.Charge.Ratio = ",count(df))


## verify the dataset and remove invalid records. Here Cost.To.Charge.Ratio is calculated
## manually and compared with actual y variable. Mismatch records are removed
df$verifyC2C <-
  round((
    df$Total.Costs / df$Combined.Outpatient...Inpatient.Total.Charges
  ) - (df$Cost.To.Charge.Ratio),
  1
  )
df <- df[df$verifyC2C == 0, ]
df <- df[df$Cost.To.Charge.Ratio < 100, ]

message("Total no of records after verifying Cost.To.Charge.Ratio = ",count(df))


df <- df[!is.na(df$Total.Days..V...XVIII...XIX...Unknown.), ]


df$Total.Days.Title.V <-
  ifelse(is.na(df$Total.Days.Title.V), 0, df$Total.Days.Title.V)

df <-df[!is.na(df$Total.Days.Title.XVIII), ]

df <-df[!is.na(df$Total.Days.Title.XIX),]

message("Total no of records removing na from both the titles = ",count(df))
## calculate unknown in total days
df$total_days_with_titles <-
  (df$Total.Days.Title.V) + (df$Total.Days.Title.XVIII) + (df$Total.Days.Title.XIX)
df$total_days_unknown <-
  (df$Total.Days..V...XVIII...XIX...Unknown.) - (df$total_days_with_titles)


df$total_days_unknown <-
  ifelse(df$total_days_unknown==0, 1, df$total_days_unknown)



df$Total.Days.XVIII.medicare.ratio <-
  df$Total.Days.Title.XVIII / df$Total.Days..V...XVIII...XIX...Unknown.
df$Total.Days.XIX.medicaid.ratio <-
  df$Total.Days.Title.XIX / df$Total.Days..V...XVIII...XIX...Unknown.
df$Total.Days.V.ratio <-
  df$Total.Days.Title.V / df$Total.Days..V...XVIII...XIX...Unknown.
df$Total.Days.unknown.ratio <-
  df$total_days_unknown / df$Total.Days..V...XVIII...XIX...Unknown.

df<-df[!is.na(df$Total.Assets), ]

message("Total no of records after removing na from totalassets = ",count(df))

df<-df[!is.na(df$Total.Current.Liabilities), ]
df<-df[!is.na(df$Total.Long.Term.Liabilities), ]

df<-df[!(df$Total.Current.Liabilities<0), ]
df<-df[!(df$Total.Long.Term.Liabilities<0), ]
message("Total no of records after removing na from liabiities = ",count(df))

df$debt.to.asset.ratio <-
  (df$Total.Current.Liabilities + df$Total.Long.Term.Liabilities) / df$Total.Assets

df<-df[df$debt.to.asset.ratio>0,]

message("Total no of records after cleaning debt.to.asset.ratio = ",count(df))

df<-df[df$Total.Income>0,]

df<-df[!is.na(df$Total.Income), ]

message("Total no of records after cleaning Total.Income = ",count(df))


df<-df[df$Total.Unreimbursed.and.Uncompensated.Care>0,]

df<-df[!is.na(df$Total.Unreimbursed.and.Uncompensated.Care), ]

message("Total no of records after cleaning Total.Unreimbursed.and.Uncompensated.Care = ",count(df))



df$Type.of.Control<-relevel(df$Type.of.Control,"Proprietary-Individual")
## factor the char features
df$State.Code <- factor(df$State.Code)
df$State.Code <- relevel(df$State.Code,"FL")
df$Rural.Versus.Urban <-
  factor(df$Rural.Versus.Urban)
df$year <- factor(df$year)

df$Provider.Type <- as.factor(df$Provider.Type)
df$Type.of.Control <-
  as.factor(df$Type.of.Control)


## export the combined raw dataset
write.csv(df_combined, "hospitals_df_for_analysis.csv")

## export the dataset after cleaning
write.csv(df, "hospitals_df_for_analysis.csv")

## selective features from the predictor table
required_cols <- c(
  'rpt_rec_num',
  'Hospital.Name',
  'State.Code',
  'Rural.Versus.Urban',
  'Provider.Type',
  'Type.of.Control',
  'FTE...Employees.on.Payroll',
  'Total.Days.Title.V',
  'Total.Days.Title.XVIII',
  'Total.Days.Title.XIX',
  'Total.Days..V...XVIII...XIX...Unknown.',
  'Total.Days.XVIII.medicare.ratio',
  'Total.Days.XIX.medicaid.ratio',
  'Total.Days.V.ratio',
  'Total.Days.unknown.ratio',
  'Number.of.Beds',
  'Total.Bed.Days.Available',
  'Total.Discharges.Title.V',
  'Total.Discharges.Title.XVIII',
  'Total.Discharges.Title.XIX',
  'Total.Discharges..V...XVIII...XIX...Unknown.',
  'Cost.of.Charity.Care',
  'Total.Bad.Debt.Expense',
  'Cost.of.Uncompensated.Care',
  'Total.Unreimbursed.and.Uncompensated.Care',
  'Overhead.Non.Salary.Costs',
  'Depreciation.Cost',
  'Total.Costs',
  'Inpatient.Total.Charges',
  'Outpatient.Total.Charges',
  'Combined.Outpatient...Inpatient.Total.Charges',
  'Wage.Related.Costs..Core.',
  'Total.Salaries..adjusted.',
  'Cash.on.Hand.and.in.Banks',
  'Total.Current.Assets',
  'Total.fixed.Assets',
  'Total.Assets',
  'Total.Current.Liabilities',
  'Total.Long.Term.Liabilities',
  'Inpatient.Revenue',
  'Outpatient.Revenue',
  'Less.Total.Operating.Expense',
  'Total.Income',
  'Cost.To.Charge.Ratio',
  'debt.to.asset.ratio',
  'Net.Revenue.from.Medicaid',
  'year',
  'total_days_unknown',
  'Health.Information.Technology.Designated.Assets'
)

length(colnames(df))
# 138 features in total

length(required_cols)
# required features are 50

## creating a dataframe with the required columns for analysis - not all columns will be used in modeling.
hospitals_df <- df[, c(required_cols)]
## prepare a temp dataset for correlation plot
hospitals_df_filtered_na <- na.omit(hospitals_df)
colSums(is.na(hospitals_df_filtered_na))
summary(hospitals_df_filtered_na)

correlation_cols <- c(
  'FTE...Employees.on.Payroll',
  'Number.of.Beds',
  'Total.Days.XVIII.medicare.ratio',
  'Total.Days.XIX.medicaid.ratio',
  'Total.Days.V.ratio',
  'Total.Days.unknown.ratio',
  'Total.Bed.Days.Available',
  'Total.Discharges.Title.V',
  'Total.Discharges.Title.XVIII',
  'Total.Discharges.Title.XIX',
  'Cost.of.Charity.Care',
  'Total.Bad.Debt.Expense',
  'Total.Unreimbursed.and.Uncompensated.Care',
  'Overhead.Non.Salary.Costs',
  'Depreciation.Cost',
  'Inpatient.Total.Charges',
  'Outpatient.Total.Charges',
  'Total.Salaries..adjusted.',
  'Cash.on.Hand.and.in.Banks',
  'Total.Current.Assets',
  'Total.fixed.Assets',
  'Total.Assets',
  'Inpatient.Revenue',
  'Outpatient.Revenue',
  'Less.Total.Operating.Expense',
  'Total.Income',
  'Cost.To.Charge.Ratio',
  'debt.to.asset.ratio',
  'Net.Revenue.from.Medicaid',
  'Health.Information.Technology.Designated.Assets'
)
corr_df <- hospitals_df_filtered_na[, correlation_cols]
correlation_output <- cor(corr_df)
write.csv(correlation_output, "hospital_report_correlation.csv")

revised_correlation_cols<-c(
  'Total.Days.XVIII.medicare.ratio',
  'Total.Days.XIX.medicaid.ratio',
  'Total.Days.unknown.ratio',
  'Total.Unreimbursed.and.Uncompensated.Care',
  'debt.to.asset.ratio',
  'Total.Income',
  'Health.Information.Technology.Designated.Assets'
)

corr_revised_df <- hospitals_df_filtered_na[, revised_correlation_cols]
correlation_revised_output <- cor(corr_revised_df)
write.csv(correlation_revised_output, "hospital_report_revised_correlation.csv")


base_model <- lmer(
  log(Cost.To.Charge.Ratio) ~  Rural.Versus.Urban +
    Provider.Type +
    Type.of.Control +
    (1 | year) + (1 | State.Code),
  data = df,
  REML = FALSE
)
summary(base_model)
vif(base_model)
ranef(base_model)

model_c2c <- lmer(
  log(Cost.To.Charge.Ratio) ~  Rural.Versus.Urban +
    Provider.Type +
    Type.of.Control +
    log(Total.Days.XIX.medicaid.ratio) +
    log(Total.Days.XVIII.medicare.ratio) +
    log(Total.Days.unknown.ratio) +
    log(debt.to.asset.ratio) +
    (1 | year) + (1 | State.Code),
  data = df,
  REML = FALSE
)
summary(model_c2c)
vif(model_c2c)
ranef(model_c2c)

hit_df<-df[df$Health.Information.Technology.Designated.Assets>0,]

hit_df<-hit_df[!is.na(df$Health.Information.Technology.Designated.Assets), ]

message("Total no of records after cleaning Health.Information.Technology.Designated.Assets = ",count(hit_df))


model_hit <- lmer(
  log(Cost.To.Charge.Ratio) ~  Rural.Versus.Urban +
    Provider.Type +
    Type.of.Control +
    log(Total.Days.XIX.medicaid.ratio) +
    log(Total.Days.XVIII.medicare.ratio) +
    log(Total.Days.unknown.ratio) +
    log(Health.Information.Technology.Designated.Assets)+
    log(debt.to.asset.ratio) +
    (1 | year) + (1 | State.Code),
  data = hit_df,
  REML = FALSE
)
summary(model_hit)
vif(model_hit)
ranef(model_hit)

length(which(hit_df$Health.Information.Technology.Designated.Assets==0))


unreimbursed_uncomp_model <- lmer(
  log(Total.Unreimbursed.and.Uncompensated.Care) ~  Rural.Versus.Urban +
    Provider.Type +
    Type.of.Control +
    log(Total.Days.XIX.medicaid.ratio) +
    log(Total.Days.XVIII.medicare.ratio) +
    log(Total.Days.unknown.ratio) +
    log(debt.to.asset.ratio) +
    (1 | year) + (1 | State.Code),
  data = df,
  REML = FALSE
)
summary(unreimbursed_uncomp_model)
vif(unreimbursed_uncomp_model)
ranef(unreimbursed_uncomp_model)


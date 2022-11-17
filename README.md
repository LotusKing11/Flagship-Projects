# Flagship-Projects
A collection of projects that showcase some of my best, most in depth work. This readme provides an executive summary of each project. 
The Unabridged project reports and codebase are included in the respective folders. 

1. Predictive Modeling - Predicting Housing Insecurity for Medicare Enrollees

Humana, a leading health insurance provider in the United States, is committed to ensuring that social needs do not determine health outcomes. 
One of the most concerning Health Related Social Needs (HRSN) is housing insecurity. In 2019, more than 30% of homeowners were paying more than 
30% of their monthly income on rent or mortgage payments. Housing insecurity disproportionately affects certain social groups. In order to create 
more equitable access to health care, Humana is attempting to better predict housing insecurity based on available individual customer health and 
financial attributes.
Housing Insecurity has worsened in recent years, driven by multiple socio-economic factors. Rapidly rising home prices, housing shortages, and 
inflation are just a few of the issues contributing to the growing prevalence of housing insecurity. Housing insecurity is a broad term that 
encompasses multiple qualifying factors. They include criterion such as ratio of housing cost and income, substandard housing, presence of sub-families, 
homelessness and more.

The objective of our analysis is to use data to predict medicare member housing insecurity, illuminate important contributing factors, 
and provide recommendations to help housing insecure members achieve their best health.

We approached the problem in four phases:
  1. Initial Data Review and Exploratory Analysis
  2. Domain Research  
  3. ML Modeling
  4. Interpretation and Recommendations

We created an initial base model that took into account all 800+ variables. We improved upon that model by examining prior research on medical 
conditions with the highest patient cost burden, common health issues among the housing insecure, including mental health diseases, and 
investigating early life experiences associated with level of housing. Based on findings from this domain research, we grouped the variables 
into categories, examined correlation between them and built a set of predictors that we felt was most appropriate for further analysis. 
Feature importance calculation via model output was also used to provide the highest accuracy with minimal model features.
Of all models used, a random forest model of our curated set of predictors produced the highest AUC value on our validation set at 0.6952. 
Other models used include XG Boost, Ada Boost and Keras DNN. Results of all models are discussed in detail in subsequent sections of this paper.

Our recommendations include focusing on four primary areas:
  • Actions to remediate housing insecurity risks for specific social groups as identified in this
  analysis at a societal level
  • Actions to remediate housing insecurity risks for specific social groups as identified in this
  analysis at a societal level
  • Actions to remediate indirect health effects of housing insecurity
  • What can Humana do about it?

2. Statistical Modeling- Factors that Affect Hospital Cost to Charge Ratio


The health-care industry in the United States is the most heavily invested in industry sector. Every year, the US government spends ~$3.65 trillion 
on federally funded healthcare programs and initiatives. Most prominent among them is Medicare, which is the predominant form of health insurance 
used by senior citizens. Furthermore, the advent of COVID-19 has brought health-care sector improvement to the forefront of the American agenda. 
In the past 10 years, 136 rural hospitals have closed due to financial insolvency. This has a major negative impact on communities that depend on those hospitals.
Our dataset consists of cost reports that hospitals from around the country submit to the Centers for Medicare & Medicaid Services (CMS). Our analysis examines data from 18,944 hospitals from across all 50 states and 3 territories compiled over the course of five years (2014-2018).
In our analysis, we consider the impact of key variables on the most commonly used healthcare industry metric to assess financial health - the Cost to Charge Ratio. Variables include, but are not limited to, Type of Control, Medicare & Medicaid Ratio, Rural vs Urban designation and Health IT Asset value. We employ Linear Mixed Effects models, controlling for random and fixed effects, to quantify and convey insights.
Key findings include Type of Control being the most significant predictor, a 20+% disparity in Cost to Charge Ratio between Rural vs Urban hospitals, and the favorable effect of investing in Health IT.
This analysis walks the reader through all major steps in the process from data cleaning and feature engineering to model building, their interpretations, and finally recommendations.

3. Text Analytics

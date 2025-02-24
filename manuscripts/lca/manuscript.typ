#import "./template.typ": *

#show: article.with(
  title: "The Maximal Expected Benefit of SARS-CoV-2 Interventions Among University Students: A Simulation Study Using Latent Class Analysis",
  header-title: "The Maximal Expected Benefit of SARS-CoV-2 Interventions Among University Students",
  authors: (
    "Callum R.K. Arnold": (
      affiliation: ("PSU-Bio", "CIDD"),
      corresponding: "true",
      email: "contact\@callumarnold.com",
    ),
    "Nita Bharti": (
     affiliation: ("PSU-Bio", "CIDD"),
    ),
    "Cara Exten": (
      affiliation: ("PSU-Nursing"),
    ),
    "Meg Small": (
      affiliation: ("PSU-HHD", "PSU-SSRI"),
    ),
    "Sreenidhi Srinivasan": (
      affiliation: ("CIDD", "Huck"),
    ),
    "Suresh V. Kuchipudi": (
      affiliation: ("Pitt-ID"),
    ),
    "Vivek Kapur": (
      affiliation: ("CIDD","Huck", "PSU-Animal-Sci"),
    ),
    "Matthew J. Ferrari": (
      affiliation: ("PSU-Bio", "CIDD"),
    ),
  ),
  affiliations: (
    "PSU-Bio": "Department of Biology, Pennsylvania State University, University Park, PA, USA 16802",
    "CIDD": "Center for Infectious Disease Dynamics, Pennsylvania State University, University Park, PA, USA 16802",
    "PSU-Nursing": "Ross & Carole Nese College of Nursing, Pennsylvania State University, University Park, PA, USA 16802",
    "PSU-HHD": "College of Health and Human Development, Pennsylvania State University, University Park, PA, USA 16802",
    "PSU-SSRI": "Social Science Research Institute, Pennsylvania State University, University Park, PA, USA 16802",
    "Huck": "Huck Institutes of the Life Sciences, Pennsylvania State University, University Park, PA, USA 16802",
    "Pitt-ID": "Department of Infectious Diseases and Microbiology, School of Public Health, University of Pittsburgh, Pittsburgh, PA, USA",
    "PSU-Animal-Sci": "Department of Animal Science, Pennsylvania State University, University Park, PA, USA 16802"
  ),
  keywords: ("Latent Class Analysis","SIR Model","Approximate Bayesian Computation","Behavioral Survey","IgG Serosurvey"),
  abstract: [
    Non-pharmaceutical public health measures (PHMs) were central to pre-vaccination efforts to reduce Severe Acute Respiratory Syndrome Coronavirus 2 (SARS-CoV-2) exposure risk; heterogeneity in adherence placed bounds on their potential effectiveness, and correlation in their adoption makes assessing the impact attributable to an individual PHM difficult. During the Fall 2020 semester, we used a longitudinal cohort design in a university student population to conduct a behavioral survey of intention to adhere to PHMs, paired with an IgG serosurvey to quantify SARS-CoV-2 exposure at the end of the semester. Using Latent Class Analysis on behavioral survey responses, we identified three distinct groups among the 673 students with IgG samples: 256 (38.04%) students were in the most adherent group, intending to follow all guidelines, 306 (46.21%) in the moderately-adherent group, and 111 (15.75%) in the least-adherent group, rarely intending to follow any measure, with adherence negatively correlated with seropositivity of 25.4%, 32.2% and 37.7%, respectively. Moving all individuals in an SIR model into the most adherent group resulted in a 77-96% reduction in seroprevalence, dependent on assumed assortativity. The potential impact of increasing PHM adherence was limited by the substantial exposure risk in the large proportion of students already following all PHMs.
  ],
  line-numbers: false,
  word-count: false
)

= Background
Within epidemiology, the importance of heterogeneity, whether that host, population, statistical, or environmental, has long been recognized @fletcherWhatHeterogeneityIt2007 @noldHeterogeneityDiseasetransmissionModeling1980 @trauerImportanceHeterogeneityEpidemiology2019 @zhangMonitoringRealtimeTransmission2022 @lloyd-smithSuperspreadingEffectIndividual2005.
For example, when designing targeted interventions, it is crucial to understand and account for differences that may exist within populations @woolhouseHeterogeneitiesTransmissionInfectious1997 @wangHeterogeneousInterventionsReduce2021 @mcdonaldImpactIndividuallevelHeterogeneity2016.
These differences can present in a variety of forms: heterogeneity in susceptibility, transmission, response to guidance, and treatment effects etc.; all of which affect the dynamics of an infectious disease @fletcherWhatHeterogeneityIt2007 @noldHeterogeneityDiseasetransmissionModeling1980 @woolhouseHeterogeneitiesTransmissionInfectious1997 @seveliusBarriersFacilitatorsEngagement2014 @tuschhoffDetectingQuantifyingHeterogeneity2023 @delaneyStrategiesAdoptedGay2022 @andersonQuantifyingIndividuallevelHeterogeneity2022 @macdonaldInfluenceHLASupertypes2000 @elieSourceIndividualHeterogeneity2022.
While heterogeneity may exist on a continuous spectrum, it can be difficult to incorporate into analysis and interpretation, so individuals are often placed in discrete groups according to a characteristic that aims to represent the true differences @mossongSocialContactsMixing2008 @klepacContagionBBCFour2018 @daviesAgedependentEffectsTransmission2020 @haySerodynamicsPrimerSynthetic2024 @yangLifeCourseExposures2020.
When examining optimal influenza vaccination policy in the United Kingdom, Baguelin et al. @baguelinAssessingOptimalTarget2013 classified individuals within one of seven age groups.
Explicitly accounting for, and grouping, individuals by whether they inject drugs can help target interventions to reduce human immunodeficiency virus (HIV) and Hepatitis C Virus incidence @levittInfectiousDiseasesInjection2020.
Similarly, epidemiological models have demonstrated the potential for HIV pre-exposure prophylaxis to reduce racial disparities in HIV incidence @jennessAddressingGapsHIV2019.
Therefore, heterogeneity can be used to inform more complete theories of change, increasing intervention effectiveness @bryanBehaviouralScienceUnlikely2021

When discretizing a population for the purposes of inclusion within a mechanistic model, three properties need to be defined: 1) the number of groups, 2) the size of the groups, and 3) the differences between the groups.
Typically, as seen in the examples above, demographic data is used e.g., age, sex, race, ethnicity, socio-economic status, etc., often in conjunction with the contact patterns and rates @wangHeterogeneousInterventionsReduce2021 @seveliusBarriersFacilitatorsEngagement2014 @mossongSocialContactsMixing2008 @daviesAgedependentEffectsTransmission2020 @baguelinAssessingOptimalTarget2013 @jennessAddressingGapsHIV2019 @foxDisproportionateImpactsCOVID192023.
There are several reasons for this: the data is widely available, and therefore can be applied almost universally; it is easily understandable; and there are clear demarcations of the groups, addressing properties 1) and 2).
However, epidemiological models often aim to assess the effects of heterogeneity with respect to infection, e.g., "how does an individual’s risk tolerance affect their risk of infection for influenza?".
When addressing questions such as these, demographic data does not necessarily provide a direct link between the discretization method and the heterogeneous nature of the exposure and outcome, particularly if behavioral mechanisms are a potential driver.
Instead, it relies on assumptions and proxy measures e.g., an individual’s age approximates their contact rates, which in turn approximates their risk of transmission.
This paper demonstrates an alternative approach to discretizing populations for use within mechanistic models, highlighting the benefits of an interdisciplinary approach to characterize heterogeneity in a manner more closely related to the risk of infection.

In early 2020, shortly after the World Health Organization (WHO) declared the SARS-CoV-2 outbreak a public health emergency of international concern @worldhealthorganizationStatementSecondMeeting, universities across the United States began to close their campuses and accommodations, shifting to remote instruction @MapCoronavirusSchool2020 @collegianTIMELINEPennState2021.
By Fall 2020, academic institutions transitioned to a hybrid working environment (in-person and online), requiring students to return to campuses @adamsReturnUniversityCampuses2020 @haddenWhatTop25 @thenewyorktimesTrackingCoronavirusColleges2020.
In a prior paper @arnoldLongitudinalStudyImpact2022 we documented the results of a large prospective serosurvey conducted in State College, home to The Pennsylvania State University (PSU) University Park (UP) campus.
We examined the effect of 35,000 returning students (representing a nearly 20% increase in the county population @unitedstatescensusbureauCensusBureauQuickFacts2019) on the community infection rates, testing serum for the presence of anti-Spike Receptor Binding Domain (S/RBD) IgG, indicating prior exposure @longAntibodyResponsesSARSCoV22020.
Despite widespread concern that campus re-openings would lead to substantial increases in surrounding community infections @adamsReturnUniversityCampuses2020 @lopmanModelingStudyInform2021 @benneyanCommunityCampusCOVID192021, very little sustained transmission was observed between the two geographically coincident populations @arnoldLongitudinalStudyImpact2022.

Given the high infection rate observed among the student body (30.4% seroprevalence), coupled with the substantial heterogeneity in infection rates between the two populations, we hypothesized that there may be further variation in exposure within the student body, resulting from behavioral heterogeneity.
Despite extensive messaging campaigns conducted by the University @pennsylvaniastateuniversityMaskPack2021, it is unlikely that all students equally adhered to public health guidance regarding SARS-CoV-2 transmission prevention.
We use students’ responses to the behavioral survey to determine and classify individuals based on their intention to adhere to public health measures (PHMs).
We then show that these latent classes are correlated with SARS-CoV-2 seroprevalence.
Finally, we parameterize a mechanistic model of disease transmission within and between these groups, and explore the impact of public health guidance campaigns, such as those conducted at PSU @pennsylvaniastateuniversityMaskPack2021.
We show that interventions designed to increase student compliance with PHMs would likely reduce overall transmission, but the relatively high initial compliance limits the scope for improvement via PHM adherence alone.

= Methods
== Design, Setting, and Participants
This research was conducted with PSU Institutional Review Board approval and in accordance with the Declaration of Helsinki, and informed consent was obtained for all participants.
The student population has been described in detail previously @arnoldLongitudinalStudyImpact2022, but in brief, students were eligible for the student cohort if they were: ≥ 18 years old; fluent in English; capable of providing their own consent; residing in Centre County at the time of recruitment (October 2020) with the intention to stay through April 2021; and officially enrolled as PSU UP students for the Fall 2020 term.
Upon enrollment, students completed a behavioral survey in REDCap @harrisREDCapConsortiumBuilding2019 to assess adherence and attitudes towards public health guidance, such as attendance at gatherings, travel patterns, and non-pharmaceutical interventions.
Shortly after, they were scheduled for a clinic visit where blood samples were collected.
Students were recruited via word-of-mouth and cold-emails.

== Outcomes
The primary outcome was the presence of S/RBD IgG antibodies, measured using an indirect isotype-specific (IgG) screening ELISA developed at PSU @gontuQuantitativeEstimationIgM2020.
An optical density (absorbance at 450 nm) higher than six standard deviations above the mean of 100 pre-SARS-CoV-2 samples collected in November 2019, determined a threshold value of 0.169 for a positive result.
Comparison against virus neutralization assays and RT-PCR returned sensitivities of 98% and 90%, and specificities of 96% and 100%, respectively @gontuLimitedWindowDonation2021.
Further details in the Supplement of the previous paper @arnoldLongitudinalStudyImpact2022.

== Statistical Methods
To identify behavioral risk classes, we fit a range of latent class analysis (LCA) models (two to seven class models) to the student’s behavioral survey responses, using the poLCA package @linzerPoLCAPackagePolytomous2011 in the R programming language, version 4.3.3 (2024-02-29) @rcoreteamLanguageEnvironmentStatistical2021.
We considered their answers regarding the frequency with which they intended to engage in the following behaviors to be #emph[a priori] indicators of behavioral risk tolerance: wash hands with soap and water for at least 20s; wear a mask in public; avoid touching their face with unwashed hands; cover cough and sneeze; stay home when ill; seek medical attention when experiencing symptoms and call in advance; stay at least 6 feet (about 2 arms lengths) from other people when outside of their home; and, stay out of crowded places and avoid mass gatherings of more than 25 people.
The behavioral survey collected responses on the Likert scale of: Never, Rarely, Sometimes, Most of the time, and Always.
For all PHMs, Always and Most of the time accounted for \> 80% of responses (with the exception of intention to stay out of crowded places and avoid mass gatherings, where Always and Most of the time accounted for 78.8% of responses).
To reduce the parameter space of the LCA and minimize overfitting, the behavioral responses were recoded as Always and Not Always.
Measures of SARS-CoV-2 exposure e.g., IgG status, were not included in the LCA model fitting, as they reflect the outcome of interest.
We focused on responses regarding intention to follow behaviors because this information can be feasibly collected during a public health campaign for a novel or emerging outbreak; it has also been shown that intentions are well-correlated with actual behaviors for coronavirus disease 2019 (COVID-19) public health guidelines, as well as actions that have short-term benefits @connerDoesIntentionStrength2024 @mcdonaldRecallingIntendingEnact2017.
We examined the latent class models using Bayesian Information Criterion, which is a commonly recommended as part of LCA model evaluation @wellerLatentClassAnalysis2020 @nylund-gibsonTenFrequentlyAsked20181213, to select the model that represented the best balance between parsimony and maximal likelihood fit.

Using the best-fit LCA model, we performed multivariate logistic regression of modal class assignment against IgG seropositivity to assess the association between the latent classes and infection.
This "three-step" approach is recommended over the "one-step" LCA model fit that includes the outcome of interest as a covariate in the LCA model @nylund-gibsonTenFrequentlyAsked20181213 @bolckEstimatingLatentStructure2004a.
The following variables were determined a priori to be potential risk factors for exposure @arnoldLongitudinalStudyImpact2022: close proximity (6 feet or less) to an individual who tested positive for SARS-CoV-2; close proximity to an individual showing key COVID-19 symptoms (fever, cough, shortness of breath); lives in University housing; ate in a restaurant in the past 7 days; ate in a dining hall in the past 7 days; only ate in their room/apartment in the past 7 days; travelled in the 3 months prior to returning to campus; and travelled since returning to campus for the Fall term.
Variables relating to attending gatherings were not included in the logistic regression due to overlap with intention variables of the initial LCA fit.
Missing variables were deemed "Missing At Random" and imputed using the mice package @vanbuurenMiceMultivariateImputation2011, as described in the supplement of the previous paper @arnoldLongitudinalStudyImpact2022.
To examine the effect of modal class assignment, we computed the GLM results of 100 simulations where class assignment was drawn according to each individual's probability of class membership, resulting from the LCA fitting process.
The percentage of simulations where class membership p-values $lt.eq$ 0.05 were computed, and the mice package was used to produce pooled odds ratios and associated 95% confidence intervals.

We parameterized a deterministic compartmental Susceptible-Infected-Recovered (SIR) model using approximate Bayesian computation (ABC) against the seroprevalence within each latent class.
The recovery rate was set to 8 days (@tbl-sir-parameters).
Diagonal values of the transmission matrix were constrained such that $beta_(H H) lt.eq beta_(M M) lt.eq beta_(L L)$ (#emph[H] represents high-adherence to public health guidelines, and #emph[M] and #emph[L] represent medium- and low-adherence, respectively), with the following parameters fit: the transmission matrix diagonals, a scaling factor for the off-diagonal values ($phi.alt$), and a scaling factor for the whole transmission matrix ($rho$).
The off-diagonal values are equal to a within-group value (diagonal) multiplied by a scaling factor ($phi.alt$).
This scaling factor can either multiply the within-group beta value of the source group (e.g., $beta_(H L) = phi.alt dot.op beta_(L L)$; @eq-transmission-matrix\A), or the recipient group (e.g., $beta_(L H) = phi.alt dot.op beta_(L L)$; @eq-transmission-matrix\B), each with a different interpretation.

#set math.equation(numbering: "1")
#let boldred(x) = text(fill: rgb("#8B0000"), $bold(#x)$)

$
rho mat(
  beta_(H H), beta_(H M), beta_(H L) ;
  beta_(M H), beta_(M M), beta_(M L) ;
  beta_(L H), beta_(L M), beta_(L L) ;
)
&&arrow rho mat(
  beta_(H H), phi.alt beta_(M M), boldred(phi.alt beta_(L L)) ;
  phi.alt beta_(H H), beta_(M M), boldred(phi.alt beta_(L L)) ;
  phi.alt beta_(H H), phi.alt beta_(M M), boldred(beta_(L L)) ;
) &&#text[mixing structure] bold(A)\
&&arrow rho mat(
  beta_(H H), phi.alt beta_(H H), phi.alt beta_(H H) ;
  phi.alt beta_(M M), beta_(M M), phi.alt beta_(M M) ;
  boldred(phi.alt beta_(L L)), boldred(phi.alt beta_(L L)), boldred(beta_(L L)) ;
) &&#text[mixing structure] bold(B)\
$
<eq-transmission-matrix>

The former assumes that between-group transmission is dominated by the transmissibility of the source individuals, implying that adherence to the PHMs primarily prevents onwards transmission, rather than protecting against infection.
The latter assumes that between-group transmission is dominated by the susceptibility of the recipient individuals, implying that adherence to the PHMs primarily prevents infection, rather than protecting against onwards transmission.
A range of between-group scaling values ($phi.alt$) were simulated to perform sensitivity analysis for the degree of assortativity.
Results are only shown for matrix structure $bold("A")$, but alternative assumptions about between-group mixing can be found in the supplement (@fig-abc-distance-whiskers-rows, @fig-intervention-rows, @fig-abc-distance-whiskers-constant, @fig-intervention-constant).
To examine the effect of an intervention to increase PHM adherence, we redistributed a proportion of low- and medium adherence individuals to the high adherence latent class, i.e., a fully effective intervention is equivalent to a single-group SIR model of high adherent individuals.
Model fitting and simulation was conducted using the Julia programming language, version 1.10.5 @bezansonJuliaFreshApproach2017.

= Results
== Demographics
Full details can be found in the prior paper @arnoldLongitudinalStudyImpact2022, but briefly: 1410 returning students were recruited, 725 were enrolled, and 684 students completed clinic visits for serum collection between 26 October and 21 December 2020.
Of these, 673 students also completed the behavioral survey between 23 October and 8 December 2020.
The median age of the participants was 20 years (IQR: 19-21), 64.5% identified as female and 34.6% as male, and 81.9% identified as white.
A large proportion (30.4%) were positive for IgG antibodies, and 93.5% (100) of the 107 students with a prior positive test reported testing positive only after their return to campus.

== LCA Fitting
Of the 673 participants, most students intended to always mask (81.0%), always cover their coughs/sneezes (81.9%), and always stay home when ill (78.2%) (@tbl-plan-adherence).
Two of the least common intentions were social distancing by maintaining a distance of at least 6 feet from others outside of their home, avoiding crowded places and mass gatherings \> 25 people (43.4% and 53.1% respectively), and avoiding face-touching with unwashed hands (43.5%).

The four- and the three-class LCA models had the lowest BIC respectively (@tbl-lca-fits).
Examining the four-class model, there was minimal difference in the classification of individuals, relative to the three-class model.
In the four-class model, the middle class (of the three-class model) was split into two groups with qualitatively similar class-conditional item response probabilities i.e., conditional on class membership, the probability of responding "Always" to a given question, except for hand washing and avoiding face-touching with unwashed hands (@tbl-lca-props_4-class).

We fit a logistic regression model to predict binary IgG serostatus that included inferred class membership, in addition to other predictor variables we previously identified in @arnoldLongitudinalStudyImpact2022.
The mean and median BIC and AIC indicated similar predictive ability of the three- and four-class LCA models (@tbl-lca-glm-fits).
Given these factors, the three-class model was selected for use in simulation for parsimony, requiring fewer assumptions and parameters to fit.

In the three-class model, approximately 15.75% of individuals were members of the group that rarely intended to always follow the PHMs, 38.04% intended to always follow all guidelines, and the remaining 46.21% mostly intended to mask, test, and manage symptoms, but not distance or avoid crowds (@tbl-lca-props).
We have labelled the three classes as "Low-", "High-" and "Medium-Adherence" groups, respectively, for ease of interpretation.
Examining the class-conditional item response probabilities, the Medium Adherence class had a probability of 0.88 of always wearing a mask in public, but a probability of only 0.19 of social distancing when outside of their homes, for example.
Calculating the class-specific seroprevalence, the Low Adherence group had the highest infection rates (37.7%, 95% Binomial CI: 28.5-47.7%), the medium adherence the next highest (32.2%, 95% Binomial CI: 27.0-37.7%), and the most adherent group experienced the lowest infection rates (25.4%, 95% Binomial CI: 20.2-31.1%).
Incorporating latent class membership into the imputed GLM model described in our previous paper (30) retained the relationship between adherence and infection.
Relative to the least adherent group, the Medium Adherence group experienced a non-significant reduction in infection risk (aOR, 95% CI: 0.73, 0.45-1.18), and the most adherent group a significant reduction (aOR, 95% CI: 0.59, 0.36-0.98) (@tbl-lca-mice-fit).
When class assignment was determined probabilistically, similar relationships were observed in the pooled results of logistic regression without confounders, relative to the least adherent group: Medium Adherence group (OR, 95% CI: 0.77, 0.47-1.28); and the High Adherence group (OR, 95% CI: 0.60, 0.36-0.99).
66% of the High Adherence group simulations resulted in a p-value $lt.eq$ 0.05.

== Compartmental Model
The ABC distance distributions indicated that near-homogeneous levels of between-group mixing better fit the data (@fig-abc-distance-whiskers).
After model parameterization (@tbl-sir-parameters, @tbl-beta-params-cols, @tbl-beta-params-rows, @tbl-beta-params-constant), we examined the effect of increasing adherence to public health guidance.
Moving all individuals into the High Adherence class resulted in a 77-96% reduction in final size; when low-moderate between-group mixing is simulated, a fully effective intervention results in approximately 96% (95th percentiles: 88-99%) reduction in final seroprevalence, and when between-group mixing is as likely as within-group mixing, a 89% (95th percentiles: 34-99%) reduction is observed (@fig-intervention).

= Discussion
In this interdisciplinary analysis, we collected behavioral data from surveys and integrated it with serosurveillance results.
This approach allowed us to use LCA to categorize a population’s transmission potential with measures related to risk tolerance and behavior.
The LCA model was fit without inclusion of infection status data, but class membership was correlated with IgG seroprevalence.
The classes that were the most adherent to PHMs experienced the lowest infection rates, and the least adherent exhibited the highest seroprevalence.
As the logistic model cannot account for indirect effects resulting from between-class interactions, we parameterized a dynamical SIR model to explore the effect of interventions of varying degrees of effectiveness.

Although a four-class LCA model was a marginally better fit for the data, there were not substantial differences in class assignment relative to the three-class LCA model.
The three-class model was selected for use in simulation for parsimony, requiring fewer assumptions and parameters to fit.
Upon parametrizing the compartmental model, smaller ABC distance values were observed for moderate to high levels of between-group mixing, implying some degree of assortativity in our population, though the exact nature cannot be determined from our data.
Examining the three classes, 38% of individuals already intended to always follow all PHMs.
As a result, only 62% of the study population could have their risk reduced with respect to the PHMs surveyed.
Further, the infection rates observed in the High Adherence group indicates that even a perfectly effective intervention aimed at increasing adherence to non-pharmaceutical PHMs (i.e., after the intervention, all individuals always followed every measure) would not eliminate transmission in a population, an observation that aligns with prior COVID-19 research @flaxmanEstimatingEffectsNonpharmaceutical2020a @banholzerEstimatingEffectsNonpharmaceutical2021 @braunerInferringEffectivenessGovernment2021 @geUntanglingChangingImpact2022.
The extent to which the infection in the High Adherence group is a result of mixing with lower adherence classes cannot be explicitly described, but the sensitivity analysis allows for an exploration of the effect and ABC fits suggest low-moderate levels of between-groups mixing occurred.
Varying the structure of the transmission matrix yielded very similar quantitative and qualitative results (@fig-abc-distance-whiskers-rows, @fig-intervention-rows, @fig-abc-distance-whiskers-constant, @fig-intervention-constant).

Examining the impact of increasing adherence to PHMs (modeled as increasing the proportion of the population in the High Adherence class), a fully effective intervention saw between a 77-96% reduction in the final size of the simulation outbreak.
We note that the effect at a fully effective intervention is conceptually analogous the population attributable fraction (PAF) proposed by @brooks-pollockDefiningPopulationAttributable2017; though rather than quantifying the impact of removing one risk group, as in @brooks-pollockDefiningPopulationAttributable2017, we consider the impact of all individuals moving to the low-risk group.
Each set of simulations for a given degree of assortativity has a different associated set of parameter values for the transmission matrix.
The difference in the magnitude of the achievable reduction at a given level of intervention for the different assortativity levels is attributed to the difference in the corresponding fitted parameters (@tbl-beta-params-cols, @tbl-beta-params-rows, @tbl-beta-params-constant).
With higher levels of between-group mixing, the initial SIR parameterization generally results in lower transmission parameters for the High-High adherence interactions, as more infections in the High Adherence group originate from interactions with Low and Medium Adherence individuals.
Increasing adherence, therefore, results in a greater reduction of the overall transmission rate than in simulations with less assortativity.

== Limitations and Strengths
The student population was recruited using convenience sampling, and therefore may not be representative of the wider population.
Those participating may have been more cognizant and willing to follow public health guidelines.
Similarly, because of the University’s extensive messaging campaigns and efforts to increase access to non-pharmaceutical measures @pennsylvaniastateuniversityMaskPack2021, such as lateral flow and polymerase-chain reaction diagnostic tests, the students likely had higher adherence rates than would be observed in other populations.
However, these limitations are not inherent to the modeling approach laid out, and efforts to minimize them would likely result in stronger associations and conclusions due to larger differences in the latent behavioral classes and resulting group infection rates.

It is well known that classification methods, like LCA, can lead to the "naming fallacy" @wellerLatentClassAnalysis2020, whereby groups are assigned and then specific causal meaning is given to each cluster, affecting subsequent analyses and interpretation of results.
In this paper, this effect is reduced by virtue of the analysis plan being pre-determined, and the relationship with the outcome showing a positive association with the classes in the mechanistically plausible direction (i.e., increasing adherence to PHMs results in reduced infection rates).
Our decision to conduct the simulation analysis with the three-class model was, in part, to avoid the potential bias that would arise from naming or assigning an order to the two intermediate risk groups.

Despite these limitations, this work presents a novel application of a multidisciplinary technique, outlining how alternate data sources can guide future model parameterization and be incorporated into traditional epidemiological analysis, particularly within demographically homogeneous populations where there is expected or observed heterogeneity in transmission dynamics.
This is particularly important in the design of interventions that aim to target individual behaviors, allowing the categorization of populations into dynamically-relevant risk groups and aiding in the efficient use of resources through targeted actions.
Future research should consider including perceived agency and efficacy for PHM adherence.

#pagebreak()

= Additional Information
== Funding
This work was supported by funding from the Office of the Provost and the Clinical and Translational Science Institute, Huck Life Sciences Institute, and Social Science Research Institutes at the Pennsylvania State University.
The project described was supported by the National Center for Advancing Translational Sciences, National Institutes of Health, through Grant UL1 TR002014.
The content is solely the responsibility of the authors and does not necessarily represent the official views of the NIH.
The funding sources had no role in the collection, analysis, interpretation, or writing of the report.

== Conflicts of Interest and Financial Disclosures
The authors declare no conflicts of interest.

== Data Access, Responsibility, and Analysis
Callum Arnold and Dr. Matthew J. Ferrari had full access to all the data in the study and take responsibility for the integrity of the data and the accuracy of the data analysis.
Callum Arnold and Dr. Matthew J. Ferrari (Department of Biology, Pennsylvania State University) conducted the data analysis.

== Data Availability
The datasets generated during and/or analyzed in the primary stages are not publicly available as they contain personally identifiable information, but are available from the corresponding author on reasonable request.
All simulation code is readily available at https://github.com/arnold-c/The-Maximal-Expected-Benefit-of-SARScov2-intervention.


#pagebreak()

#bibliography(
  title: "References",
  style: "elsevier-vancouver",
  "LCA.bib"
)

#pagebreak()

= Author Contributions
#emph[Conceptualization:] CA, MJF

#emph[Data curation:] CA, MJF

#emph[Formal analysis:] CA, MJF

#emph[Funding acquisition:] MJF

#emph[Investigation:] NB, CE, MS, SS, SK, VS

#emph[Methodology:] CA, NB, MJF

#emph[Project administration:] MJF

#emph[Software:] CA, MJF

#emph[Supervision:] MJF

#emph[Validation:] CA, MJF

#emph[Visualization:] CA, MJF

#emph[Writing - original draft:] CA

#emph[Writing - review and editing:] all authors.

= Acknowledgements
+ Florian Krammer, Mount Sinai, USA for generously providing the transfection plasmid pCAGGS-RBD
+ Scott E. Lindner, Allen M. Minns, Randall Rossi produced and purified RBD
+ The D4A Research Group: Dee Bagshaw, Clinical & Translational Science Institute, Cyndi Flanagan, Clinical Research Center and the Clinical & Translational Science Institute; Thomas Gates, Social Science Research Institute; Margeaux Gray, Dept. of Biobehavioral Health; Stephanie Lanza, Dept. of Biobehavioral Health and Prevention Research Center; James Marden, Dept. of Biology and Huck Institutes of the Life Sciences; Susan McHale, Dept. of Human Development and Family Studies and the Social Science Research Institute; Glenda Palmer, Social Science Research Institute; Connie J. Rogers, Dept. of Nutritional Sciences; Rachel Smith, Dept. of Communication Arts and Sciences and Huck Institutes of the Life Sciences; and Charima Young, Penn State Office of Government and Community Relations.
+ The authors thank the following for their assistance in the lab: Sophie Rodriguez, Natalie Rydzak, Liz D. Cambron, Elizabeth M. Schwartz, Devin F. Morrison, Julia Fecko, Brian Dawson, Sean Gullette, Sara Neering, Mark Signs, Nigel Deighton, Janhayi Damani, Mario Novelo, Diego Hernandez, Ester Oh, Chauncy Hinshaw, B. Joanne Power, James McGee, Riëtte van Biljon, Andrew Stephenson, Alexis Pino, Nick Heller, Rose Ni, Eleanor Jenkins, Julia Yu, Mackenzie Doyle, Alana Stracuzzi, Brielle Bellow, Abriana Cain, Jaime Farrell, Megan Kostek, Amelia Zazzera, Sara Ann Malinchak, Alex Small, Sam DeMatte, Elizabeth Morrow, Ty Somberger, Haylea Debolt, Kyle Albert, Corey Price, Nazmiye Celik

#pagebreak()

= Figures
== Figure 1

#figure(
  image(
    "./manuscript_files/plots/fig-1_abc-distance-whiskers_copy-cols.png",
    width: 100%
  ),
  caption: [Distribution of the distance from the ABC fits, with the minimum and maximum distances illustrated by the whiskers, and the median distance by the point.
Between-group mixing of 1.0 equates to between-group mixing as likely as within-group mixing],
)
<fig-abc-distance-whiskers>

== Figure 2

#figure(
  image(
    "./manuscript_files/plots/fig-2_intervention-stacked-bar_copy-cols.png",
    width: 100%
  ),
  caption: [
A) The reduction in final infection size across a range of intervention effectiveness (1.0 is a fully effective intervention), accounting for a range of assortativity.
Between-group mixing of 1.0 equates to between-group mixing as likely as within-group mixing.
  Each line represents the median reduction (of 200 simulations) resulting from from an intervention, and is associated with a $beta$ matrix specific to the degree of between-group mixing illustrated; B) The relative distribution of group sizes at three levels of intervention effectiveness (0.0, 0.5, 1.0).
],
)
<fig-intervention>

#pagebreak()

= Tables
== Table 1

#let intention_table = csv("./manuscript_files/tables/intention-responses.csv")

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    ..intention_table.flatten()
  ),
  caption: [Participants' intention to always or not always follow 8 public health measures],
)
<tbl-plan-adherence>

#pagebreak()

== Table 2

#let lca_fit_table = csv("./manuscript_files/tables/lca-fits.csv")

#figure(
  table(
    columns: 4,
    ..lca_fit_table.flatten()
  ),
  caption: [Log likelihood, AIC, and BIC of two to seven class LCA model fits],
)
<tbl-lca-fits>

#pagebreak()

== Table 3

#let lca_glm_fit_table = csv("./manuscript_files/tables/lca-glm-fits.csv")

#figure(
  table(
    columns: 5,
    ..lca_glm_fit_table.flatten()
  ),
  caption: [Mean and median AIC and BIC of multiply-imputed logistic regressions for two to seven class LCA models against IgG serostatus],
)
<tbl-lca-glm-fits>

#pagebreak()

== Table 4

#let lca_irp_table = csv("./manuscript_files/tables/lca-item-response-probs.csv")
#let lca_irp_fill_table = csv("./manuscript_files/tables/lca-item-response-probs_fill.csv")
#let lca_irp_colors_table = csv("./manuscript_files/tables/lca-item-response-probs_colors.csv")

#figure(
  table(
    columns: 4,
    align: (left, horizon, horizon, horizon),
    fill: (x, y) => {
      if y > 0 {
        let cell_color = lca_irp_fill_table.at(y).at(x)
        rgb(cell_color)
      }
    },
    table.cell(fill: gray)[Measure \ Intention to Always:],
    table.cell(fill: rgb("#2f0f3e"))[#text(fill: rgb("#ffffff"))[Low Adherence]],
    table.cell(fill: rgb("#911f63"))[#text(fill: rgb("#ffffff"))[Medium Adherence]],
    table.cell(fill: rgb("#e05d53"))[#text(fill: rgb("#ffffff"))[High Adherence]],
    ..for ((val), (text_color)) in lca_irp_table.slice(1).flatten().zip(lca_irp_colors_table.slice(1).flatten()) {
      if text_color == "" {
        if val == "Group Size" or val == "Seroprevalence" {
        (table.cell[#text(weight: "bold")[#val]],)
        } else {
        (table.cell[#val],)
        }
      } else {
        (table.cell[#text(fill: rgb(text_color))[#val]],)
      }
    }
  ),
  caption: [Class-conditional item response probabilities shown in the main body of the table for a three-class LCA model, with footers indicating the size of the respective classes, and the class-specific seroprevalence],
)
<tbl-lca-props>

#pagebreak()

== Table 5

#let mice_glm_table = csv("./manuscript_files/tables/mice-glm-table.csv")

#figure(
  table(
    columns: 2,
    align: (left, center),
    ..mice_glm_table.flatten()
  ),
  caption: [Adjusted odds ratio (aOR) for risk factors of infection among the returning PSU UP student cohort],
)
<tbl-lca-mice-fit>

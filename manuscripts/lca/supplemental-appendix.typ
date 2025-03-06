#import "./template.typ": *

#show: article.with(
  title: "Latent Class Analysis Identifies Risk Groups to Model the Expected Benefits of SARS-CoV-2 Interventions Among University Students",
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
  line-numbers: true,
  word-count: false
)

#show figure.where(kind: image): set figure(supplement: "Supplemental Figure")
#show figure.where(kind: table): set figure(supplement: "Supplemental Table")
#set math.equation(
  numbering: "1",
  supplement: "Supplemental Equation"
)
#let boldred(x) = text(fill: rgb("#8B0000"), $bold(#x)$)



= Methods
== SIR Model Structure

To examine the potential benefits of increasing adherence to public health measures, a susceptible-infected-recovered (SIR) model was parameterized against the latent class groups and their respective exposure rates (seroprevalence estimates).
Approximate Bayesian Computation Rejection Sampling (ABC) was used to parameterize the beta-transmission matrix, according to a pre-determined mixing structured.

In the main body of the text, we present the results for the three-class model that corresponds to a scenario where public health measures (PHMs) reduce onwards risk of transmission (@eq-matrix-structures-all\A), rather than conferring protection for the practitioner (@eq-matrix-structures-all\B).
Another alternative uses a single scaled value of $beta_(L L)$, representing all between-group interactions experiencing the same risk of transmission that is a fraction of the transmission observed between Low Adherence individuals (@eq-matrix-structures-all\C).

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
&&arrow rho mat(
  beta_(H H), boldred(phi.alt beta_(L L)), boldred(phi.alt beta_(L L)) ;
  boldred(phi.alt beta_(L L)), beta_(M M), boldred(phi.alt beta_(L L)) ;
  boldred(phi.alt beta_(L L)), boldred(phi.alt beta_(L L)), beta_(L L) ;
) &&#text[mixing structure] bold(C)\
$
<eq-matrix-structures-all>

During the ABC process, the values of $rho$ and $beta$ were initially sampled from Uniform distributions between 0 and 1 for a given value of $phi$ (the degree of assortativity that is pre-specified as part of the sensitivity analysis), with a constraint that $beta_(M M) gt.eq beta_(H H)$ and $beta_(L L) = 1$.
Values of $rho times beta$ can be found in @tbl-beta-params-cols, @tbl-beta-params-rows, @tbl-beta-params-constant, representing the median and 95th percentiles for the pre-intervention within-group mixing values.

#figure(
  table(
    columns: 2,
    align: (left, horizon),
    [Parameters], [Values],
    [Infectious period], [8 days],
    [Population size], [673],
    [Low Adherence group size], [106],
    [Medium Adherence group size], [311],
    [High Adherence group size], [256],
    [Low Adherence group seroprevalence], [37.7%],
    [Medium Adherence group seroprevalence], [32.2%],
    [High Adherence group seroprevalence], [25.4%]
  ),
  caption: [Parameter values for the Susceptible-Infected-Recovered dynamical transmission model],
)
<tbl-sir-parameters>

= Results
== LCA Model Fitting

#let lca_irp_table = csv("./supplemental_files/tables/lca-item-response-probs.csv")
#let lca_irp_fill_table = csv("./supplemental_files/tables/lca-item-response-probs_fill.csv")
#let lca_irp_colors_table = csv("./supplemental_files/tables/lca-item-response-probs_colors.csv")

#figure(
  table(
    columns: (40%, auto, auto, auto, auto),
    align: (left, horizon, horizon, horizon, horizon),
    fill: (x, y) => {
      if y > 0 {
        let cell_color = lca_irp_fill_table.at(y).at(x)
        rgb(cell_color)
      }
    },
    table.cell(fill: gray)[Measure \ Intention to Always:],
    table.cell(fill: rgb("#2f0f3e"))[#text(fill: rgb("#ffffff"))[Low Adherence]],
    table.cell(fill: rgb("#911f63"))[#text(fill: rgb("#ffffff"))[Low-Medium Adherence]],
    table.cell(fill: rgb("#F7B32B"))[#text(fill: rgb("#ffffff"))[Medium-High Adherence]],
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
  caption: [Class-conditional item response probabilities shown in the main body of the table for a four-class LCA model, with footers indicating the size of the respective classes, and the class-specific seroprevalence],
)
<tbl-lca-props_4-class>

== LCA Confounder Associations

#let lca_confounders = csv("./supplemental_files/tables/lca-confounders.csv").flatten()

#figure(
  table(
    columns: 7,
    [Risk Factor],[Response],[Low Adherence (N=106)],[Medium Adherence (N=311)],[High Adherence (N=256)],[Overall (N=673)],[p-value],
    table.cell(rowspan: 2)[Close proximity to known COVID-19 Positive individual],
    [No],[49 (46.2%)],[140 (45.0%)],[144 (56.3%)],[333 (49.5%)],table.cell(rowspan: 2)[0.021],
    [Yes],[57 (53.8%)],[171 (55.0%)],[112 (43.8%)],[340 (50.5%)],
    table.cell(rowspan: 3)[Close proximity to individual showing COVID-19 symptoms],
    [No],[65 (61.3%)],[216 (69.5%)],[187 (73.0%)],[468 (69.5%)],table.cell(rowspan: 3)[0.029],
    [Yes],[40 (37.7%)],[95 (30.5%)],[69 (27.0%)],[204 (30.3%)],
    [Missing],[1 (0.9%)],[0 (0%)],[0 (0%)],[1 (0.1%)],
    table.cell(rowspan: 3)[Lives in University housing],
    [No],[74 (69.8%)],[232 (74.6%)],[188 (73.4%)],[494 (73.4%)],table.cell(rowspan: 3)[0.189],
    [Yes],[31 (29.2%)],[79 (25.4%)],[68 (26.6%)],[178 (26.4%)],
    [Missing],[1 (0.9%)],[0 (0%)],[0 (0%)],[1 (0.1%)],
    table.cell(rowspan: 3)[Traveled in the 3 months prior to campus arrival],
    [No],[53 (50.0%)],[117 (37.6%)],[116 (45.3%)],[286 (42.5%)],table.cell(rowspan: 3)[0.121],
    [Yes],[50 (47.2%)],[181 (58.2%)],[134 (52.3%)],[365 (54.2%)],
    [Missing],[3 (2.8%)],[13 (4.2%)],[6 (2.3%)],[22 (3.3%)],
    table.cell(rowspan: 2)[Traveled since campus arrival],
    [No],[40 (37.7%)],[116 (37.3%)],[104 (40.6%)],[260 (38.6%)],table.cell(rowspan: 2)[0.715],
    [Yes],[66 (62.3%)],[195 (62.7%)],[152 (59.4%)],[413 (61.4%)],
    table.cell(rowspan: 3)[Ate in a dining hall in the past 7 days],
    [No],[83 (78.3%)],[255 (82.0%)],[210 (82.0%)],[548 (81.4%)],table.cell(rowspan: 3)[0.503],
    [Yes],[22 (20.8%)],[56 (18.0%)],[44 (17.2%)],[122 (18.1%)],
    [Missing],[1 (0.9%)],[0 (0%)],[2 (0.8%)],[3 (0.4%)],
    table.cell(rowspan: 3)[Ate in a restaurant in the past 7 days],
    [No],[58 (54.7%)],[153 (49.2%)],[130 (50.8%)],[341 (50.7%)],table.cell(rowspan: 3)[0.532],
    [Yes],[47 (44.3%)],[157 (50.5%)],[126 (49.2%)],[330 (49.0%)],
    [Missing],[1 (0.9%)],[1 (0.3%)],[0 (0%)],[2 (0.3%)],
    table.cell(rowspan: 3)[Only ate in their room in the past 7 days],
    [No],[35 (33.0%)],[106 (34.1%)],[90 (35.2%)],[231 (34.3%)],table.cell(rowspan: 3)[0.243],
    [Yes],[70 (66.0%)],[205 (65.9%)],[166 (64.8%)],[441 (65.5%)],
    [Missing],[1 (0.9%)],[0 (0%)],[0 (0%)],[1 (0.1%)],
  ),
  caption: [Crude associations with confounders by latent class membership. P-value calculated using Chi-square test, correcting for small expected cell values using Monte Carlo simulations.]
)
<tbl-lca-confounders>



== Matrix Structure Sensitivity Analysis

Below are results for alternative scenarios of mixing matrix structures, which show qualitatively similar results to the main body of the text, with slight changes in the distribution in the Approximate Bayesian Computation distance metrics and best-fit level of between-group mixing.

=== Eq 1A (PHMs Reduce Transmission)

#let copy_cols_beta_table = csv("./supplemental_files/tables/beta-dist-table_copy-cols.csv").flatten()

#figure(
  two_header_table(
    columns: (auto, auto, auto, auto),
    align: (horizon, horizon, horizon, horizon),
    [], table.cell(colspan: 3)[Between-Group Mixing],
    [$rho times beta$ Parameter], ..copy_cols_beta_table.slice(1, 4),
    [$rho times beta_(H H)$], ..copy_cols_beta_table.slice(5, 8),
    [$rho times beta_(M M)$], ..copy_cols_beta_table.slice(9, 12),
    [$rho times beta_(L L)$], ..copy_cols_beta_table.slice(13),
  ),
  caption: [
  PHMs reduce onwards transmission.
  Pre-intervention median (lower and upper 95th percentile) $rho times beta$ within-group parameter values at no, high, and the best-fit level of between-group mixing.],
)
<tbl-beta-params-cols>

=== Eq 1B (PHMs Confer Protection)

#figure(
  image(
    "./supplemental_files/plots/abc-distance-whiskers_copy-rows.png",
    width: 100%
  ),
  caption: [PHMs confer protection to the practitioner. Distribution of the distance from the ABC fits, with the minimum and maximum distances illustrated by the whiskers, and the median distance by the point. Between-group mixing of 1.0 equates to between-group mixing as likely as within-group mixing],
)
<fig-abc-distance-whiskers-rows>

#let copy_rows_beta_table = csv("./supplemental_files/tables/beta-dist-table_copy-rows.csv").flatten()

#figure(
  two_header_table(
    columns: (auto, auto, auto, auto),
    align: (horizon, horizon, horizon, horizon),
    [], table.cell(colspan: 3)[Between-Group Mixing],
    [$rho times beta$ Parameter], ..copy_rows_beta_table.slice(1, 4),
    [$rho times beta_(H H)$], ..copy_rows_beta_table.slice(5, 8),
    [$rho times beta_(M M)$], ..copy_rows_beta_table.slice(9, 12),
    [$rho times beta_(L L)$], ..copy_rows_beta_table.slice(13),
  ),
  caption: [
  PHMs confer protection to the practitioner.
  Pre-intervention median (lower and upper 95th percentile) $rho times beta$ within-group parameter values at no, high, and the best-fit level of between-group mixing.
],
)
<tbl-beta-params-rows>

#figure(
  image(
    "./supplemental_files/plots/intervention-stacked-bar_copy-rows.png",
    width: 100%
  ),
    caption: [
PHMs confer protection to the practitioner.
A) The reduction in final infection size across a range of intervention effectiveness (1.0 is a fully effective intervention), accounting for a range of assortativity.
Between-group mixing of 1.0 equates to between-group mixing as likely as within-group mixing.
  Each line represents the median reduction (of 200 simulations) resulting from from an intervention, and is associated with a $beta$ matrix specific to the degree of between-group mixing illustrated; B) The relative distribution of group sizes at three levels of intervention effectiveness (0.0, 0.5, 1.0).
],
)
<fig-intervention-rows>


#pagebreak()

=== Eq 1C (Identical Off-Diagonal Values)

#figure(
  image(
    "./supplemental_files/plots/abc-distance-whiskers_constant.png",
    width: 100%
  ),
  caption: [
    Identical off-diagonal values. Distribution of the distance from the ABC fits, with the minimum and maximum distances illustrated by the whiskers, and the median distance by the point. Between-group mixing of 1.0 equates to between-group mixing as likely as within-group mixing
  ],
)
<fig-abc-distance-whiskers-constant>

#let copy_constant_beta_table = csv("./supplemental_files/tables/beta-dist-table_constant.csv").flatten()

#figure(
  two_header_table(
    columns: (auto, auto, auto, auto),
    align: (horizon, horizon, horizon, horizon),
    [], table.cell(colspan: 3)[Between-Group Mixing],
    [$rho times beta$ Parameter], ..copy_constant_beta_table.slice(1, 4),
    [$rho times beta_(H H)$], ..copy_constant_beta_table.slice(5, 8),
    [$rho times beta_(M M)$], ..copy_constant_beta_table.slice(9, 12),
    [$rho times beta_(L L)$], ..copy_constant_beta_table.slice(13),
  ),
  caption: [
    Identical off-diagonal values.
  Pre-intervention median (lower and upper 95th percentile) $rho times beta$ within-group parameter values at no, high, and the best-fit level of between-group mixing.
],
)
<tbl-beta-params-constant>

#figure(
  image( "./supplemental_files/plots/intervention-stacked-bar_constant.png", width: 100% ),
  caption: [
  Identical off-diagonal values.
A) The reduction in final infection size across a range of intervention effectiveness (1.0 is a fully effective intervention), accounting for a range of assortativity.
Between-group mixing of 1.0 equates to between-group mixing as likely as within-group mixing.
  Each line represents the median reduction (of 200 simulations) resulting from from an intervention, and is associated with a $beta$ matrix specific to the degree of between-group mixing illustrated; B) The relative distribution of group sizes at three levels of intervention effectiveness (0.0, 0.5, 1.0).
],
)
<fig-intervention-constant>

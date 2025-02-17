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
      affiliation: ("CIDD","PSU-Vet"),
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
    "PSU-Vet": "Department of Veterinary and Biomedical Sciences, Pennsylvania State University, University Park, PA, USA 16802",
    "PSU-Animal-Sci": "Department of Animal Science, Pennsylvania State University, University Park, PA, USA 16802"
  ),
  keywords: ("Latent Class Analysis","SIR Model","Approximate Bayesian Computation","Behavioral Survey","IgG Serosurvey"),
  line-numbers: true,
  word-count: false
)

= Results
== LCA Model Fitting

#let lca_irp_table = csv("./supplemental_files/tables/lca-item-response-probs.csv")
#let lca_irp_fill_table = csv("./supplemental_files/tables/lca-item-response-probs_fill.csv")
#let lca_irp_colors_table = csv("./supplemental_files/tables/lca-item-response-probs_colors.csv")

#figure(
  table(
    // columns: 5,
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
  supplement: [Supplemental Table]
)
<tbl-lca-props_4-class>

== Matrix Structure Sensitivity Analysis
<matrix-structure-sensitivity-analysis>
In the main body of the text, we present the results for the three-class model that corresponds to a scenario where public health measures (PHMs) reduce onwards risk of transmission (Supplemental Eq 1A), rather than conferring protection for the practitioner (Supplemental Eq 1B). Another alternative uses a single scaled value of $beta_(L L)$, representing all between-group interactions experiencing the same risk of transmission that is a fraction of the transmission observed between Low Adherence individuals (Supplemental Eq 1C).

#set math.equation(numbering: "1")
#let boldred(x) = text(fill: rgb("#8B0000"), $bold(#x)$)

$
rho mat(
  beta_(H H), beta_(H M), beta_(H L) ;
  beta_(M H), beta_(H M), beta_(M L) ;
  beta_(L H), beta_(H M), beta_(L L) ;
)
&&arrow rho mat(
  beta_(H H), phi.alt beta_(M M), boldred(phi.alt beta_(L L)) ;
  phi.alt beta_(H H), beta_(M M), boldred(phi.alt beta_(L L)) ;
  phi.alt beta_(H H), phi.alt beta_(M M), boldred(beta_(L L)) ;
) &&#text[mixing structure] bold(A)\
&&arrow rho mat(
  beta_(H H), phi.alt beta_(H H), phi.alt beta_(H H) ;
  phi.alt beta_(M M), beta_(M M), beta_(M M) ;
  boldred(phi.alt beta_(L L)), boldred(phi.alt beta_(L L)), boldred(beta_(L L)) ;
) &&#text[mixing structure] bold(B)\
&&arrow rho mat(
  beta_(H H), boldred(phi.alt beta_(L L)), boldred(phi.alt beta_(L L)) ;
  boldred(phi.alt beta_(L L)), beta_(M M), boldred(phi.alt beta_(L L)) ;
  boldred(phi.alt beta_(L L)), boldred(phi.alt beta_(L L)), beta_(L L) ;
) &&#text[mixing structure] bold(C)\
$
Below are results for alternative scenarios, which show qualitatively similar results to the main body of the text, albeit with a wider distribution in the Approximate Bayesian Computation distance metrics.

=== Eq 1A (PHMs Reduce Transmission)

#let copy_cols_beta_table = csv("./supplemental_files/tables/beta-dist-table_copy-cols.csv").flatten()

#figure(
  two_header_table(
    columns: (auto, auto, auto, auto),
    align: (horizon, horizon, horizon, horizon),
    [], table.cell(colspan: 3)[Between Group Mixing],
    [$rho times beta$ Parameter], ..copy_cols_beta_table.slice(1, 4),
    [$rho times beta_(H H)$], ..copy_cols_beta_table.slice(5, 8),
    [$rho times beta_(M M)$], ..copy_cols_beta_table.slice(9, 12),
    [$rho times beta_(L L)$], ..copy_cols_beta_table.slice(13),
  ),
  caption: [
  PHMs reduce onwards transmission.
  Pre-intervention median (lower and upper 95th percentile) $rho times beta$ within-group parameter values at no, high, and the best-fit level of between-group mixing.],
  supplement: [Supplemental Table]
)
<tbl-beta-params-cols>

=== Eq 1B (PHMs Confer Protection)

#figure(
  image(
    "./supplemental_files/plots/abc-distance-whiskers_copy-rows.png",
    width: 100%
  ),
  caption: [PHMs confer protection to the practitioner. Distribution of the distance from the ABC fits, with the minimum and maximum distances illustrated by the whiskers, and the median distance by the point. Between-group mixing of 1.0 equates to between-group mixing as likely as within-group mixing],
  supplement: [Supplemental Figure]
)
<fig-abc-distance-whiskers-rows>

#let copy_rows_beta_table = csv("./supplemental_files/tables/beta-dist-table_copy-rows.csv").flatten()

#figure(
  two_header_table(
    columns: (auto, auto, auto, auto),
    align: (horizon, horizon, horizon, horizon),
    [], table.cell(colspan: 3)[Between Group Mixing],
    [$rho times beta$ Parameter], ..copy_rows_beta_table.slice(1, 4),
    [$rho times beta_(H H)$], ..copy_rows_beta_table.slice(5, 8),
    [$rho times beta_(M M)$], ..copy_rows_beta_table.slice(9, 12),
    [$rho times beta_(L L)$], ..copy_rows_beta_table.slice(13),
  ),
  caption: [
  PHMs confer protection to the practitioner.
  Pre-intervention median (lower and upper 95th percentile) $rho times beta$ within-group parameter values at no, high, and the best-fit level of between-group mixing.
],
  supplement: [Supplemental Table]
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
  supplement: [Supplemental Figure]
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
  supplement: [Supplemental Figure]
)
<fig-abc-distance-whiskers-constant>

#let copy_constant_beta_table = csv("./supplemental_files/tables/beta-dist-table_constant.csv").flatten()

#figure(
  two_header_table(
    columns: (auto, auto, auto, auto),
    align: (horizon, horizon, horizon, horizon),
    [], table.cell(colspan: 3)[Between Group Mixing],
    [$rho times beta$ Parameter], ..copy_constant_beta_table.slice(1, 4),
    [$rho times beta_(H H)$], ..copy_constant_beta_table.slice(5, 8),
    [$rho times beta_(M M)$], ..copy_constant_beta_table.slice(9, 12),
    [$rho times beta_(L L)$], ..copy_constant_beta_table.slice(13),
  ),
  caption: [
    Identical off-diagonal values.
  Pre-intervention median (lower and upper 95th percentile) $rho times beta$ within-group parameter values at no, high, and the best-fit level of between-group mixing.
],
  supplement: [Supplemental Table]
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
  supplement: [Supplemental Figure]
)
<fig-intervention-constant>

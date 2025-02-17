# %%
library(targets)
library(tidyverse)
library(janitor)
library(gt)
library(table1)

source(here::here("src", "student_latent-class-functions.R"))

# %%
withr::with_dir(here::here(), {
  targets::tar_load(student_lca_plan_data, store = "store_lca")
  targets::tar_load(student_lca_plan_vars, store = "store_lca")
  targets::tar_load(polca_plan_tibble, store = "store_lca")
  targets::tar_load(
    modal_lca_w1_conf_mice_plan_fit_statistics_comparison_table,
    store = "store_lca"
  )
  targets::tar_load(lca_seroprevalence_table, store = "store_lca")
  targets::tar_load(lca_mice_glm_table, store = "store_lca")

  targets::tar_load(student_modal_lca_plan_data_4, store = "store_lca")
  targets::tar_load(polca_plan_class_probs_4, store = "store_lca")
  targets::tar_load(polca_plan_class_prevs_4, store = "store_lca")
  targets::tar_load(polca_plan_class_order_4, store = "store_lca")

  targets::tar_load(student_modal_lca_plan_data_3, store = "store_lca")
})

# %%
supplemental_tables_path <- here::here("manuscripts", "lca", "supplemental_files", "tables")

if (!(dir.exists(supplemental_tables_path))) {
  dir.create(supplemental_tables_path, recursive = TRUE)
}

# %%
lca_irp_tables <- make_lca_presentation_table(
  student_modal_lca_plan_data_4,
  polca_plan_class_probs_4,
  polca_plan_class_prevs_4,
  polca_plan_class_order_4,
  class_names = c("Low Adherence", "Low-Medium Adherence", "Medium-High Adherence", "High Adherence"),
  class_colors = c("#2F0F3E", "#911F63", "#F7B32B", "#E05D53"),
  output = "raw"
)

write_csv(
  lca_irp_tables[["data"]],
  file = file.path(supplemental_tables_path, "lca-item-response-probs.csv")
)

write_csv(
  lca_irp_tables[["fill"]],
  file = file.path(supplemental_tables_path, "lca-item-response-probs_fill.csv")
)

write_csv(
  lca_irp_tables[["colors"]],
  file = file.path(supplemental_tables_path, "lca-item-response-probs_colors.csv")
)

# %%
lca_confounder_labels <- list(
  variables = list(
    wave_1_close_covid_pos = "Close proximity to known COVID-19 Positive individual",
    wave_1_close_covid_symp = "Close proximity to individual showing COVID-19 symptoms",
    wave_1_uni_house = "Lives in University housing",
    wave_1_travel_3mo_prior = "Traveled in the 3 months prior to campus arrival",
    wave_1_travel_since_sem = "Traveled since campus arrival",
    wave_1_eat_din_hall = "Ate in a dining hall in the past 7 days",
    wave_1_eat_rest = "Ate in a restaurant in the past 7 days",
    wave_1_eat_room = "Only ate in their room in the past 7 days"
  ),
  strata = list(
    `3` = "Low Adherence",
    `1` = "Medium Adherence",
    `2` = "High Adherence",
    `Overall` = "Overall"
  )
)

lca_confounder_data <- student_modal_lca_plan_data_3 %>%
  dplyr::mutate(
    wave_1_uni_house = dplyr::case_when(
      wave_1_uni_house == "Not Uni housing" ~ "No",
      wave_1_uni_house == "Uni housing" ~ "Yes",
    )
  )
lca_confounder_strata <- c(
  split(lca_confounder_data, lca_confounder_data$latent_class),
  list(Overall = lca_confounder_data)
)

pvalue <- function(x, ...) {
  dat <- bind_rows(
    purrr::map(x, ~ data.frame(value = .)),
    .id = "group"
  )

  set.seed(12345)
  p <- dplyr::filter(dat, group != "Overall") %>%
    janitor::tabyl(group, value) %>%
    janitor::chisq.test(., simulate.p.value = TRUE) %>%
    purrr::pluck(., "p.value")
  return(c("", scales::label_pvalue()(p)))
}

lca_confounder_table <- table1(
  lca_confounder_strata,
  labels = lca_confounder_labels,
  data = lca_confounder_data,
  extra.col = list(`p-value` = pvalue)
)

lca_confounder_df <- data.frame(lca_confounder_table) %>%
  rename(
    "p-value" = "p.value",
    "Risk Factor" = "X."
  ) %>%
  rename_with(.fn = ~ stringr::str_replace(., "[.]", " "))

colnames(lca_confounder_df) <- paste(colnames(lca_confounder_df), lca_confounder_df[1, ])

write_csv(
  lca_confounder_df[-1, ],
  file.path(supplemental_tables_path, "lca-confounders.csv"),
)

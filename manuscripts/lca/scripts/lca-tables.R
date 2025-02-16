# %%
library(targets)
library(tidyverse)
library(janitor)
library(gt)

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
  targets::tar_load(polca_plan_lca_fits, store = "store_lca")
  targets::tar_load(lca_seroprevalence_table, store = "store_lca")
  targets::tar_load(lca_mice_glm_table, store = "store_lca")

  targets::tar_load(student_modal_lca_plan_data_3, store = "store_lca")
  targets::tar_load(polca_plan_class_probs_3, store = "store_lca")
  targets::tar_load(polca_plan_class_prevs_3, store = "store_lca")
  targets::tar_load(polca_plan_class_order_3, store = "store_lca")
})

# %%
tables_path <- here::here("manuscripts", "lca", "manuscript_files", "tables")

if (!(dir.exists(tables_path))) {
  dir.create(tables_path, recursive = TRUE)
}

# %%
intention_responses <- student_lca_plan_data %>%
  pivot_longer(
    cols = all_of(student_lca_plan_vars),
    names_to = "ph_meas",
    values_to = "response"
  ) %>%
  mutate(
    response = dplyr::case_when(
      response == 1 ~ "Not Always",
      response == 2 ~ "Always",
    )
  ) %>%
  relabel_behaviors(., ph_meas) %>%
  janitor::tabyl(`Intention to always:`, response, show_na = FALSE) %>%
  janitor::adorn_percentages(denominator = "row") %>%
  janitor::adorn_pct_formatting(digits = 2) %>%
  janitor::adorn_ns(position = "front")

write_csv(
  intention_responses,
  file = file.path(tables_path, "intention-responses.csv")
)

# %%
write_csv(
  polca_plan_lca_fits,
  file = file.path(tables_path, "lca-fits.csv")
)

# %%
lca_glm_fits <- modal_lca_w1_conf_mice_plan_fit_statistics_comparison_table %>%
  mutate(across(
    .cols = -Classes,
    .fns = ~ round(.x, digits = 2)
  ))

write_csv(
  lca_glm_fits,
  file = file.path(tables_path, "lca-glm-fits.csv")
)

# %%
lca_irp_tables <- make_lca_presentation_table(
  student_modal_lca_plan_data_3,
  polca_plan_class_probs_3,
  polca_plan_class_prevs_3,
  polca_plan_class_order_3,
  class_names = c("Low Adherence", "Medium Adherence", "High Adherence"),
  output = "raw"
)

write_csv(
  lca_irp_tables[["data"]],
  file = file.path(tables_path, "lca-item-response-probs.csv")
)

write_csv(
  lca_irp_tables[["fill"]],
  file = file.path(tables_path, "lca-item-response-probs_fill.csv")
)

write_csv(
  lca_irp_tables[["colors"]],
  file = file.path(tables_path, "lca-item-response-probs_colors.csv")
)

# %%
write_csv(
  lca_mice_glm_table,
  file = file.path(tables_path, "mice-glm-table.csv")
)

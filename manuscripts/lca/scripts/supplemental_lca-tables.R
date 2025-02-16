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
  targets::tar_load(lca_seroprevalence_table, store = "store_lca")
  targets::tar_load(lca_mice_glm_table, store = "store_lca")

  targets::tar_load(student_modal_lca_plan_data_4, store = "store_lca")
  targets::tar_load(polca_plan_class_probs_4, store = "store_lca")
  targets::tar_load(polca_plan_class_prevs_4, store = "store_lca")
  targets::tar_load(polca_plan_class_order_4, store = "store_lca")
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

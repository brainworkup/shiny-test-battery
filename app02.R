# Below is a single-file app.R example that does what you described:
# 	•	Shiny dashboard with 3 pages:
# 	1.	Patient info
# 	2.	Test selection (by template battery + individual test toggles)
# 	3.	Review + PDF download
# 	•	Text boxes for patient name, age, battery type, and referral.
# 	•	Test batteries structured per your example, with required tests flagged.
# 	•	PDF download implemented via an on-the-fly R Markdown template. You can adapt this easily to Quarto/Typst (see comment in code).

# app.R

# Core packages
library(shiny)
library(shinydashboard)
library(dplyr)
library(rmarkdown)
library(knitr)

# -------------------------------------------------------------------
# 1. Test catalog (adapt as needed)
# -------------------------------------------------------------------

tests <- data.frame(
  battery_group = c(
    # Phase 1A
    rep("Phase 1A", 5),
    # Phase 2A
    rep("Phase 2A", 18),
    # Full A / KP NP Full A
    rep("Full A", 25),
    # Step-down (poor effort / dementia)
    rep("Step-down", 5),
    # PVTs (generic pool)
    rep("PVTs", 10)
  ),
  phase = c(
    # Phase 1A
    rep("Phase 1A", 5),
    # Phase 2A
    rep("Phase 2A", 18),
    # Full A
    rep("Full A", 25),
    # Step-down
    rep("Step-down", 5),
    # PVTs
    rep("N/A", 10)
  ),
  test_name = c(
    # Phase 1A
    "WRAT-5 Word Reading (ppt)",
    "RBANS (QI)",
    "Clock Drawing (ppt)",
    "Trails A/B (ppt)",
    "Questionnaires (Google Forms)",

    # Phase 2A
    "CVLT-3 Immediate & Short Delay (QI)",
    "WMS-IV Visual Reproduction I (QI)",
    "WAIS-IV Digit Span (QI)",
    "WAIS-IV Coding (QI)",
    "WAIS-IV Symbol Search (QI)",
    "CVLT-3 Long Delay (QI)",
    "WMS-IV Visual Reproduction II, Recognition & Copy (QI)",
    "CVLT-3 Forced Choice (QI)",
    "D-KEFS Verbal Fluency (QI)",
    "WMS-IV Logical Memory I (QI)",
    "D-KEFS Color-Word Interference (QI)",
    "WAIS-IV Visual Puzzles (QI)",
    "WAIS-IV Matrix Reasoning (QI)",
    "WMS-IV Logical Memory II (QI)",
    "WAIS-IV Arithmetic (QI)",
    "WAIS-IV Vocabulary (QI)",
    "WAIS-IV Similarities (QI)",
    "BNT/NAB (ppt)",

    # Full A / KP NP Full A
    "WRAT-5 Word Reading (ppt)",
    "CVLT-3 Immediate & Short Delay (QI)",
    "WMS-IV Visual Reproduction I (QI)",
    "Trails A/B (ppt)",
    "WAIS-IV Digit Span (QI)",
    "CVLT-3 Long Delay (QI)",
    "WMS-IV Visual Reproduction II, Recognition & Copy (QI)",
    "WAIS-IV Coding (QI)",
    "WAIS-IV Symbol Search (QI)",
    "CVLT-3 Forced Choice (QI)",
    "D-KEFS Verbal Fluency (QI)",
    "WMS-IV Logical Memory I (QI)",
    "D-KEFS Color-Word Interference (QI)",
    "WMS-IV Logical Memory II (QI)",
    "WAIS-IV Visual Puzzles (QI)",
    "WAIS-IV Matrix Reasoning (QI)",
    "WAIS-IV Arithmetic (QI)",
    "WAIS-IV Vocabulary (QI)",
    "WAIS-IV Similarities (QI)",
    "BNT/NAB (ppt)",
    "WCST-64 (PARiConnect)",
    "Clock Drawing (ppt)",
    "NAB Judgment",
    "ACS Word Choice (ppt)",
    "REY-15 (ppt)",

    # Step-down battery
    "RBANS",
    "MoCA",
    "Clock Drawing (ppt)",
    "Trails A/B (ppt)",
    "NAB Judgment",

    # Performance Validity Tests (PVTs) pool
    "ACS Word Choice (ppt)",
    "CVLT PVT indices",
    "Rey 15 (ppt)",
    "Reliable Digit Span (RDS)",
    "WCST PVT indices",
    "Color-Word Interference PVT indices",
    "Trails PVT indices",
    "BVMT PVT indices",
    "WMS VR Rec. & LM Rec. PVT indices",
    "NAB / HRB PVT indices"
  ),
  required = c(
    # Phase 1A (required = TRUE)
    TRUE, TRUE, TRUE, TRUE, TRUE,

    # Phase 2A (per your ** list)
    TRUE,  # CVLT-3 Immediate & Short Delay
    TRUE,  # WMS-IV Visual Reproduction I
    TRUE,  # WAIS-IV Digit Span
    TRUE,  # WAIS-IV Coding
    TRUE,  # WAIS-IV Symbol Search
    TRUE,  # CVLT-3 Long Delay
    TRUE,  # WMS-IV VR II Rec & Copy
    TRUE,  # CVLT-3 Forced Choice
    TRUE,  # D-KEFS Verbal Fluency
    FALSE, # WMS LM I
    TRUE,  # D-KEFS C-W Interference
    FALSE, # WAIS Visual Puzzles
    FALSE, # WAIS Matrix Reasoning
    FALSE, # WMS LM II
    FALSE, # WAIS Arithmetic
    FALSE, # WAIS Vocabulary
    FALSE, # WAIS Similarities
    TRUE,  # BNT/NAB

    # Full A (per your ** list)
    TRUE,  # WRAT
    TRUE,  # CVLT Immed + SD
    TRUE,  # WMS VR I
    TRUE,  # Trails
    TRUE,  # WAIS Digit Span
    TRUE,  # CVLT LD
    TRUE,  # WMS VR II Rec & Copy
    TRUE,  # WAIS Coding
    FALSE, # WAIS Symbol Search
    TRUE,  # CVLT Forced Choice
    TRUE,  # D-KEFS Verbal Fluency
    FALSE, # WMS LM I
    TRUE,  # D-KEFS Color-Word
    FALSE, # WMS LM II
    FALSE, # WAIS Visual Puzzles
    FALSE, # WAIS Matrix Reasoning
    FALSE, # WAIS Arithmetic
    FALSE, # WAIS Vocabulary
    FALSE, # WAIS Similarities
    TRUE,  # BNT/NAB
    FALSE, # WCST-64
    FALSE, # Clock Drawing
    FALSE, # NAB Judgment
    FALSE, # ACS Word Choice (req only for lien cases)
    FALSE, # Rey-15

    # Step-down
    TRUE,  # RBANS (or MoCA if can't)
    FALSE, # MoCA
    TRUE,  # Clock
    TRUE,  # Trails
    FALSE, # NAB Judgment

    # PVTs – none strictly required by default
    rep(FALSE, 10)
  ),
  notes = c(
    # Phase 1A
    "Phase 1A; required",
    "Phase 1A; required",
    "Phase 1A; required",
    "Phase 1A; required",
    "Phase 1A; required",

    # Phase 2A
    "Phase 2A; required",
    "Phase 2A; required",
    "Phase 2A; required",
    "Phase 2A; required",
    "Phase 2A; required",
    "Phase 2A; required",
    "Phase 2A; required",
    "Phase 2A; required",
    "Phase 2A; required",
    "Phase 2A; optional",
    "Phase 2A; required",
    "Phase 2A; optional",
    "Phase 2A; optional",
    "Phase 2A; optional",
    "Phase 2A; optional",
    "Phase 2A; optional",
    "Phase 2A; optional",
    "Phase 2A; required",

    # Full A
    "Full A; required",
    "Full A; required",
    "Full A; required",
    "Full A; required",
    "Full A; required",
    "Full A; required",
    "Full A; required",
    "Full A; required",
    "Full A; optional",
    "Full A; required",
    "Full A; required",
    "Full A; optional",
    "Full A; required",
    "Full A; optional",
    "Full A; optional",
    "Full A; optional",
    "Full A; optional",
    "Full A; optional",
    "Full A; optional",
    "Full A; required",
    "Full A; optional",
    "Full A; optional",
    "Full A; optional",
    "Full A; optional (required for lien cases only)",
    "Full A; optional",

    # Step-down
    "Step-down; required (or MoCA if cannot complete RBANS)",
    "Step-down; optional; use if RBANS not feasible",
    "Step-down; required",
    "Step-down; required",
    "Step-down; optional",

    # PVTs
    "PVT pool",
    "PVT pool",
    "PVT pool",
    "PVT pool",
    "PVT pool",
    "PVT pool",
    "PVT pool",
    "PVT pool",
    "PVT pool",
    "PVT pool"
  ),
  stringsAsFactors = FALSE
)

# ---- Extend test catalog with new batteries ----

additional_tests <- tibble::tribble(
  ~battery_group,                             ~phase,                          ~test_name,                                                                              ~required, ~notes,

  # ---------------- Full A / KP NP Full A (Spanish) ----------------
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "Trails A/B (send trails sheets)",                                                      TRUE,      "Full A Spanish; core processing speed / set-shifting; send trails sheets",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WAIS-IV Digit Span (QI)",                                                              TRUE,      "Full A Spanish; core attention/working memory",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WAIS-IV Coding (Spanish; QI)",                                                         TRUE,      "Full A Spanish; required processing speed subtest",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WAIS-IV Symbol Search (Spanish; QI)",                                                  TRUE,      "Full A Spanish; required processing speed subtest",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "BNE Story Memory",                                                                     TRUE,      "Batería Neuropsicológica en Español (BNE); story memory",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "BNE Verbal Fluency",                                                                   TRUE,      "BNE verbal fluency",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "BNE List Learning",                                                                    TRUE,      "BNE list learning / verbal memory",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "BNE Stroop",                                                                           TRUE,      "BNE Stroop; inhibition / cognitive control",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WAIS-IV Visual Puzzles (Spanish; QI)",                                                 FALSE,     "Spanish-adapted WAIS-IV Visual Puzzles",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WAIS-IV Matrix Reasoning (Spanish; QI)",                                               FALSE,     "Spanish-adapted WAIS-IV Matrix Reasoning",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WAIS-IV Arithmetic (Spanish; QI)",                                                     FALSE,     "Spanish-adapted WAIS-IV Arithmetic",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WAIS-IV Vocabulary (Spanish; QI)",                                                     FALSE,     "Spanish-adapted WAIS-IV Vocabulary",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WAIS-IV Similarities (Spanish; QI)",                                                   FALSE,     "Spanish-adapted WAIS-IV Similarities",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WCST-64 (Spanish; PARiConnect)",                                                       FALSE,     "WCST-64 Spanish version via PARiConnect",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "Boston Naming (Spanish; TBD)",                                                         FALSE,     "Spanish Boston Naming; parameters TBD (\"??\" in notes)",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "WMS-III (Spanish; TBD)",                                                               FALSE,     "WMS-III Spanish; details TBD",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "CVLT (Spanish; TBD)",                                                                  FALSE,     "Spanish CVLT; details TBD",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "RBANS (Spanish; TBD)",                                                                 FALSE,     "Spanish RBANS; details TBD",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "Clock Drawing (ppt)",                                                                  TRUE,      "Spanish Full A; clock drawing (PPT)",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "TOMM",                                                                                 FALSE,     "PVT; Spanish battery context",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "Beck Anxiety (Spanish)",                                                               TRUE,      "Spanish Beck Anxiety",
  "Full A / KP NP Full A (Spanish)",          "Full A Spanish",                "Beck Depression (Spanish)",                                                            TRUE,      "Spanish Beck Depression",

  # ---------------- Full A Seizure/Full A (or D) TBI ----------------
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "Word Choice / Reliable Digit Span (WISC-V for kids)",                                  TRUE,      "Full A Seizure/TBI; PVT / effort; use Word Choice or WISC-V RDS in kids",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "WRAT-IV Reading / WIAT-IV Full D (for kids)",                                          TRUE,      "Full A Seizure/TBI; basic academic screening; WRAT-IV vs WIAT-IV in kids",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "WAIS-IV (8-subtest FSIQ)",                                                             TRUE,      "Full A Seizure/TBI; core WAIS-IV FSIQ (8-subtest)",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "CVLT-3 (50-item Recognition List) / CVLT-C",                                           TRUE,      "Full A Seizure/TBI; verbal learning (adult CVLT-3 vs CVLT-C for kids)",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "WMS-IV Logical Memory (LM) / VPA (for left temporal lobe cases)",                      TRUE,      "Full A Seizure/TBI; LM / VPA for temporal lobe epilepsy cases",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "BVMT-R / WMS-IV Visual Reproduction",                                                  TRUE,      "Full A Seizure/TBI; visual learning/memory (BVMT-R or WMS VR)",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "Boston Naming Test (BNT; 60 items; PPVT-5 if Vocab < 7 for kids)",                     TRUE,      "Full A Seizure/TBI; naming; PPVT-5 substitution in low-vocab kids",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "Trails A & B / D-KEFS (for kids)",                                                     TRUE,      "Full A Seizure/TBI; Trails or D-KEFS variants in kids",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "FAS / D-KEFS Verbal Fluency (for kids)",                                               TRUE,      "Full A Seizure/TBI; phonemic verbal fluency; D-KEFS for kids",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "Animals (semantic fluency)",                                                           TRUE,      "Full A Seizure/TBI; semantic fluency (\"Animals ride\")",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "Rey-O Complex Figure (copy only; copy & recall for kids)",                             TRUE,      "Full A Seizure/TBI; Rey-O copy; copy + recall in kids",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "D-KEFS Color-Word Interference",                                                       TRUE,      "Full A Seizure/TBI; D-KEFS CWIT",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "Grooved Pegboard",                                                                     FALSE,     "Full A Seizure/TBI; optional; Kettering requests, not Texas Children’s",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "QOLIE-31 (seizure only)",                                                              TRUE,      "Full A Seizure/TBI; QOLIE-31 for seizure cases",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "BDI / GDS",                                                                            TRUE,      "Full A Seizure/TBI; depression screening (BDI or GDS)",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "BAI / GAI",                                                                            TRUE,      "Full A Seizure/TBI; anxiety screening (BAI or GAI)",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "MMPI-3",                                                                               FALSE,     "Full A Seizure/TBI; optional personality inventory (PRN)",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "WCST-64",                                                                              FALSE,     "Full A Seizure/TBI; optional WCST-64",
  "Full A Seizure/TBI",                       "Full A Seizure/TBI",            "Judgment of Line Orientation (JOLO; short form)",                                      FALSE,     "Full A Seizure/TBI; optional JOLO short form",

  # ---------------- Full D / KP NP Full D ----------------
  # Symptom inventories (sent out in advance)
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "BASC-3 (Q-global)",                                                                    TRUE,      "Full D; broad behavior rating; Q-global; ages 2–25",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "BRIEF-A (PARiConnect)",                                                                TRUE,      "Full D; adult executive function rating (BRIEF-A)",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "ABAS-3 (WPS)",                                                                         TRUE,      "Full D; adaptive functioning (ABAS-3; self + informant)",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "BAARS (BAARS Form; 19+)",                                                              TRUE,      "Full D; adult ADHD rating (BAARS)",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "SRS-2 (WPS)",                                                                          TRUE,      "Full D; autism-related social responsiveness (SRS-2)",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "MIGDAS-2 Questionnaire (parent/caregiver; shortened Google Form)",                    TRUE,      "Full D; parent/caregiver MIGDAS-2 questionnaire",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "CARS-2 (Clinician rating)",                                                            TRUE,      "Full D; CARS-2 clinician rating scale",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "BAI (18+ mood questionnaire)",                                                         TRUE,      "Full D; Beck Anxiety Inventory for adults",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "BDI-II (18+ mood questionnaire)",                                                      TRUE,      "Full D; Beck Depression Inventory-II for adults",
  "Full D / KP NP Full D",                    "Full D – Symptom inventories",  "PCL (PTSD checklist; 18+)",                                                            TRUE,      "Full D; PTSD Checklist for DSM (PCL) for adults",

  # Cognitive testing (Full D)
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WAIS-IV Coding (QI)",                                                                  TRUE,      "Full D; WAIS-IV Coding (QI); mail response sheet if remote",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WAIS-IV Symbol Search (QI)",                                                           TRUE,      "Full D; WAIS-IV Symbol Search (QI); mail response sheet if remote",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WAIS-IV Visual Puzzles (QI)",                                                          TRUE,      "Full D; WAIS-IV Visual Puzzles",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WAIS-IV Similarities (QI)",                                                            TRUE,      "Full D; WAIS-IV Similarities",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WAIS-IV Matrix Reasoning (QI)",                                                        TRUE,      "Full D; WAIS-IV Matrix Reasoning",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WAIS-IV Vocabulary (QI)",                                                              TRUE,      "Full D; WAIS-IV Vocabulary",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WAIS-IV Digit Span (QI)",                                                              TRUE,      "Full D; WAIS-IV Digit Span",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WAIS-IV Arithmetic (QI)",                                                              TRUE,      "Full D; WAIS-IV Arithmetic",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "Raven’s 2 Progressive Matrices (Nonverbal)",                                           FALSE,     "Full D; nonverbal reasoning (Raven’s 2); optional",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "D-KEFS Color-Word Interference (QI)",                                                 TRUE,      "Full D; D-KEFS CW interference",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "D-KEFS Verbal Fluency (QI)",                                                           FALSE,     "Full D; D-KEFS Verbal Fluency; optional (use when indicated)",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "CVLT-3",                                                                              FALSE,     "Full D; CVLT-3 verbal learning (ages 16+)",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WIAT-4 Word Reading (PPT)",                                                            FALSE,     "Full D; WIAT-4 Word Reading (ages 4–50)",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WIAT-4 Spelling",                                                                      FALSE,     "Full D; WIAT-4 Spelling",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WIAT-4 Numerical Operations",                                                          FALSE,     "Full D; WIAT-4 Numerical Operations",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WIAT-4 Reading Comprehension (PPT)",                                                   FALSE,     "Full D; WIAT-4 Reading Comprehension",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WIAT-4 Math Problem Solving (PPT)",                                                    FALSE,     "Full D; WIAT-4 Math Problem Solving",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WRAT-5 Word Reading (QI; ages 51+)",                                                   FALSE,     "Full D; WRAT-5 Word Reading for 51+ (use WIAT-4 if under 51)",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WRAT-5 Spelling (QI; ages 51+)",                                                       FALSE,     "Full D; WRAT-5 Spelling for 51+",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "WRAT-5 Math Computation (QI; ages 51+)",                                               FALSE,     "Full D; WRAT-5 Math Computation for 51+",
  "Full D / KP NP Full D",                    "Full D – Cognitive testing",    "MIGDAS-2 Interview (hard copy; ages 3+)",                                              TRUE,      "Full D; MIGDAS-2 direct interview (hard copy)"
)

# Bind into existing tests and regenerate IDs/labels
tests <- dplyr::bind_rows(tests, additional_tests)

tests$test_id <- seq_len(nrow(tests))

tests$label <- ifelse(
  tests$required,
  paste0("\u2605 ", tests$test_name),
  tests$test_name
)

battery_choices <- unique(tests$battery_group)

# tests$test_id <- seq_len(nrow(tests))

# Helper labels: prefix required tests with a star
# tests$label <- ifelse(
#   tests$required,
#   paste0("\u2605 ", tests$test_name),  # ★
#   tests$test_name
# )

# battery_choices <- unique(tests$battery_group)

# -------------------------------------------------------------------
# 2. R Markdown template for PDF (you can swap to Quarto if desired)
# -------------------------------------------------------------------

test_sheet_rmd <- '
---
title: "Neuropsychological Test Battery"
output: pdf_document
params:
  patient_name: ""
  age: ""
  battery_type: ""
  referral: ""
  selected_tests: NULL
echo: false
---

## Patient Information

**Name:** `r params$patient_name`
**Age:** `r params$age`
**Battery type:** `r params$battery_type`

**Referral question:**
`r params$referral`

---

## Selected Tests

```{r echo = FALSE}
library(dplyr)
library(knitr)

tests <- params$selected_tests

if (is.null(tests) || nrow(tests) == 0) {
  cat("No tests selected.")
} else {
  tests |>
    arrange(battery_group, phase, test_name) |>
    select(battery_group, phase, test_name, required, notes) |>
    mutate(
      Required = ifelse(required, "Yes", "No")
    ) |>
    select(Battery = battery_group,
           Phase = phase,
           Test = test_name,
           Required,
           Notes = notes) |>
    kable()
}
'

# NOTE: If you prefer Quarto + Typst, you can instead:

#- write a .qmd template here

#- call quarto::quarto_render() inside the downloadHandler

# —————————————————————––

# 3. UI

# —————————————————————––

ui <- dashboardPage(
  dashboardHeader(title = "Neuropsych Test Battery Builder"),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Patient info", tabName = "patient", icon = icon("user")),
      menuItem("Select tests", tabName = "tests", icon = icon("list-check")),
      menuItem("Review & download", tabName = "review", icon = icon("file-pdf"))
    )
  ),
  dashboardBody(
    tabItems(
      # –––––––– Page 1: Patient info ––––––––
      tabItem(
        tabName = "patient",
        fluidRow(
          box(
            title = "Patient Information",
            width = 6,
            textInput("patient_name", "Patient name"),
            textInput("age", "Age"),
            selectInput(
              "battery_type",
              "Battery type",
              choices = battery_choices,
              selected = "Phase 1A"
            ),
            textAreaInput("referral", "Referral question / brief case description",
                           rows = 4)
          ),
          box(
            title = "Instructions",
            width = 6,
            status = "info",
            solidHeader = TRUE,
            p("1. Enter basic patient information."),
            p("2. On the next page, choose a battery template and customize the test list."),
            p("3. Review the selected tests and download a PDF test sheet.")
          )
        )
      ),

      # ---------------- Page 2: Select tests ----------------
      tabItem(
        tabName = "tests",
        fluidRow(
          box(
            title = "Battery template",
            width = 4,
            selectInput(
              "template_battery",
              "Start from a template battery:",
              choices = battery_choices,
              selected = "Phase 1A"
            ),
            helpText("Choosing a template pre-selects the tests used in that battery.")
          ),
          box(
            title = "Selected template details",
            width = 8,
            tableOutput("template_table")
          )
        ),
        fluidRow(
          box(
            title = "Customize tests",
            width = 12,
            helpText("Tests with a star (★) are typically required in that template, but you may deviate based on clinical judgment."),
            checkboxGroupInput(
              "selected_tests",
              label = "Select tests for this patient:",
              choices = setNames(tests$test_id, tests$label),
              selected = tests$test_id[tests$battery_group == "Phase 1A"]
            )
          )
        )
      ),

      # ---------------- Page 3: Review & download ----------------
      tabItem(
        tabName = "review",
        fluidRow(
          box(
            title = "Summary",
            width = 7,
            tableOutput("summary_table")
          ),
          box(
            title = "Download",
            width = 5,
            h4("Download test sheet as PDF"),
            helpText("Make sure you have a working LaTeX installation (e.g., tinytex) for PDF rendering."),
            downloadButton("download_pdf", "Download PDF")
          )
        )
      )
    )

  )
)

# —————————————————————––

# 4. Server

# —————————————————————––

server <- function(input, output, session) {

# When template battery changes, pre-select those tests

observeEvent(input$template_battery, {
req(input$template_battery)
ids <- tests$test_id[tests$battery_group == input$template_battery]
updateCheckboxGroupInput(
session,
"selected_tests",
selected = ids
)
})

# Data frame of tests in the selected template battery (for display)

template_tests <- reactive({
req(input$template_battery)
tests |>
filter(battery_group == input$template_battery) |>
arrange(phase, test_name)
})

output$template_table <- renderTable({
tt <- template_tests()
if (nrow(tt) == 0) return(NULL)

tt |>
  transmute(
    Battery = battery_group,
    Phase = phase,
    Test = test_name,
    Required = ifelse(required, "Yes", "No"),
    Notes = notes
  )

})

# Data frame of currently selected tests (across all batteries)

selected_tests_df <- reactive({
req(input$selected_tests)
tests |>
filter(test_id %in% input$selected_tests) |>
arrange(battery_group, phase, test_name)
})

output$summary_table <- renderTable({
st <- selected_tests_df()
if (nrow(st) == 0) return(NULL)

st |>
  transmute(
    Battery = battery_group,
    Phase = phase,
    Test = test_name,
    Required = ifelse(required, "Yes", "No"),
    Notes = notes
  )

})

# Download handler for PDF test sheet

output$download_pdf <- downloadHandler(
filename = function() {
nm <- ifelse(nzchar(input$patient_name),
gsub("\\s+", "_", input$patient_name),
"test_battery")
paste0(nm, "_test_sheet.pdf")
},
content = function(file) {
# Write temporary Rmd
tmp_dir <- tempdir()
rmd_path <- file.path(tmp_dir, "test_sheet.Rmd")
writeLines(test_sheet_rmd, con = rmd_path)

  params <- list(
    patient_name   = input$patient_name,
    age            = input$age,
    battery_type   = input$battery_type,
    referral       = input$referral,
    selected_tests = selected_tests_df()
  )

  rmarkdown::render(
    input        = rmd_path,
    output_file  = file,
    params       = params,
    envir        = new.env(parent = globalenv()),
    quiet        = TRUE
  )
}

)
}

# —————————————————————––

# 5. Run the app

# —————————————————————––

shinyApp(ui, server)

# You can drop this into `app.R` and run with:

# ```r
# # shiny::runApp("~/neuro2/test_battery_app.R")
# ```
# To switch to Quarto+Typst later, you would:
	# •	Replace test_sheet_rmd with a .qmd template string (or external file).
	# •	Swap rmarkdown::render() for quarto::quarto_render() in the downloadHandler.
	# •	Point input at the .qmd file and pass the same params list.

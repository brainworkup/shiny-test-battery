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
    rep("Phase 2A", 15),
    # Full A / KP NP Full A
    rep("Full A", 19),
    # Step-down (poor effort / dementia)
    rep("Step-down", 5),
    # PVTs (generic pool)
    rep("PVTs", 10)
  ),
  phase = c(
    # Phase 1A
    rep("Phase 1A", 5),
    # Phase 2A
    rep("Phase 2A", 15),
    # Full A
    rep("Full A", 19),
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

tests$test_id <- seq_len(nrow(tests))

# Helper labels: prefix required tests with a star
tests$label <- ifelse(
  tests$required,
  paste0("\u2605 ", tests$test_name),  # ★
  tests$test_name
)

battery_choices <- unique(tests$battery_group)

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
---

## Patient Information

**Name:** `r params$patient_name`  
**Age:** `r params$age`  
**Battery type:** `r params$battery_type`  

**Referral question:**  
`r params$referral`

---

## Selected Tests

```{r}
library(dplyr)
library(knitr)

tests <- params$selected_tests

if (is.null(tests) || nrow(tests) == 0) {
  cat("No tests selected.")
} else {
  tests %>%
    arrange(battery_group, phase, test_name) %>%
    select(battery_group, phase, test_name, required, notes) %>%
    mutate(
      Required = ifelse(required, "Yes", "No")
    ) %>%
    select(Battery = battery_group,
           Phase = phase,
           Test = test_name,
           Required,
           Notes = notes) %>%
    kable()
}

’

NOTE: If you prefer Quarto + Typst, you can instead:

- write a .qmd template here

- call quarto::quarto_render() inside the downloadHandler

—————————————————————––

3. UI

—————————————————————––

ui <- dashboardPage(
dashboardHeader(title = “Neuropsych Test Battery Builder”),
dashboardSidebar(
sidebarMenu(
id = “tabs”,
menuItem(“Patient info”, tabName = “patient”, icon = icon(“user”)),
menuItem(“Select tests”, tabName = “tests”, icon = icon(“list-check”)),
menuItem(“Review & download”, tabName = “review”, icon = icon(“file-pdf”))
)
),
dashboardBody(
tabItems(
# –––––––– Page 1: Patient info ––––––––
tabItem(
tabName = “patient”,
fluidRow(
box(
title = “Patient Information”,
width = 6,
textInput(“patient_name”, “Patient name”),
textInput(“age”, “Age”),
textInput(“battery_type”, “Battery type (e.g., Phase 1A, Full A, Step-down)”),
textAreaInput(“referral”, “Referral question / brief case description”,
rows = 4)
),
box(
title = “Instructions”,
width = 6,
status = “info”,
solidHeader = TRUE,
p(“1. Enter basic patient information.”),
p(“2. On the next page, choose a battery template and customize the test list.”),
p(“3. Review the selected tests and download a PDF test sheet.”)
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

—————————————————————––

4. Server

—————————————————————––

server <- function(input, output, session) {

When template battery changes, pre-select those tests

observeEvent(input$template_battery, {
req(input$template_battery)
ids <- tests$test_id[tests$battery_group == input$template_battery]
updateCheckboxGroupInput(
session,
“selected_tests”,
selected = ids
)
})

Data frame of tests in the selected template battery (for display)

template_tests <- reactive({
req(input$template_battery)
tests %>%
filter(battery_group == input$template_battery) %>%
arrange(phase, test_name)
})

output$template_table <- renderTable({
tt <- template_tests()
if (nrow(tt) == 0) return(NULL)

tt %>%
  transmute(
    Battery = battery_group,
    Phase = phase,
    Test = test_name,
    Required = ifelse(required, "Yes", "No"),
    Notes = notes
  )

})

Data frame of currently selected tests (across all batteries)

selected_tests_df <- reactive({
req(input$selected_tests)
tests %>%
filter(test_id %in% input$selected_tests) %>%
arrange(battery_group, phase, test_name)
})

output$summary_table <- renderTable({
st <- selected_tests_df()
if (nrow(st) == 0) return(NULL)

st %>%
  transmute(
    Battery = battery_group,
    Phase = phase,
    Test = test_name,
    Required = ifelse(required, "Yes", "No"),
    Notes = notes
  )

})

Download handler for PDF test sheet

output$download_pdf <- downloadHandler(
filename = function() {
nm <- ifelse(nzchar(input$patient_name),
gsub(”\s+”, “_”, input$patient_name),
“test_battery”)
paste0(nm, “_test_sheet.pdf”)
},
content = function(file) {
# Write temporary Rmd
tmp_dir <- tempdir()
rmd_path <- file.path(tmp_dir, “test_sheet.Rmd”)
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

—————————————————————––

5. Run the app

—————————————————————––

shinyApp(ui, server)

You can drop this into `app.R` and run with:

```r
shiny::runApp("~/neuro2/test_battery_app.R")

To switch to Quarto+Typst later, you would:
	•	Replace test_sheet_rmd with a .qmd template string (or external file).
	•	Swap rmarkdown::render() for quarto::quarto_render() in the downloadHandler.
	•	Point input at the .qmd file and pass the same params list.

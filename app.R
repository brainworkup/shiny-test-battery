# =============================================================================
# Neuropsych Test Battery Builder - Refactored
# =============================================================================
# A Shiny app for selecting neuropsychological test batteries
# Features:
#   - Centralized test catalog (lookup table)
#   - Battery definitions with required/optional tests
#   - Modular UI components
#   - Tidyverse syntax throughout
# =============================================================================

# Core packages
library(shiny)
library(shinydashboard)
library(dplyr)
library(tibble)
library(tidyr)
library(purrr)
library(stringr)
library(rmarkdown)
library(knitr)
library(quarto)

# =============================================================================
# 1. TEST CATALOG - Single source of truth for all tests
# =============================================================================
# Each test has a unique ID, canonical name, domain, and administration info

test_catalog <- tibble::tribble(
 ~test_id, ~test_name, ~domain, ~admin_format, ~age_range, ~notes,
  
 # --- Cognitive Screening ---
 "rbans", "RBANS", "Cognitive Screening", "QI", "12-89", "Repeatable Battery for Assessment of Neuropsychological Status",
 "moca", "MoCA", "Cognitive Screening", "Paper", "18+", "Montreal Cognitive Assessment",
 "clock", "Clock Drawing", "Cognitive Screening", "PPT", "All", "Clock drawing test",
  
 # --- Premorbid Functioning ---
 "wrat5_reading", "WRAT-5 Word Reading", "Premorbid/Achievement", "PPT", "5-85+", "Wide Range Achievement Test-5",
 
 # --- Academic Achievement ---
 "wiat4_reading", "WIAT-4 Word Reading", "Achievement", "PPT", "4-50", "Wechsler Individual Achievement Test-4",
 "wiat4_spelling", "WIAT-4 Spelling", "Achievement", "QI", "4-50", "",
 "wiat4_numerical", "WIAT-4 Numerical Operations", "Achievement", "QI", "4-50", "",
 "wiat4_reading_comp", "WIAT-4 Reading Comprehension", "Achievement", "PPT", "4-50", "",
 "wiat4_math_ps", "WIAT-4 Math Problem Solving", "Achievement", "PPT", "4-50", "",
 "wrat5_spelling", "WRAT-5 Spelling", "Achievement", "QI", "51+", "Use for ages 51+",
 "wrat5_math", "WRAT-5 Math Computation", "Achievement", "QI", "51+", "Use for ages 51+",
  
 # --- Intelligence/Cognitive (WAIS-IV/V) ---
 "wais_digit_span", "WAIS-IV Digit Span", "Attention/Working Memory", "QI", "16-90", "",
 "wais_coding", "WAIS-IV Coding", "Processing Speed", "QI", "16-90", "Mail response sheet if remote",
 "wais_symbol_search", "WAIS-IV Symbol Search", "Processing Speed", "QI", "16-90", "Mail response sheet if remote",
 "wais_visual_puzzles", "WAIS-IV Visual Puzzles", "Perceptual Reasoning", "QI", "16-90", "",
 "wais_matrix", "WAIS-IV Matrix Reasoning", "Perceptual Reasoning", "QI", "16-90", "",
 "wais_arithmetic", "WAIS-IV Arithmetic", "Working Memory", "QI", "16-90", "",
 "wais_vocabulary", "WAIS-IV Vocabulary", "Verbal Comprehension", "QI", "16-90", "",
 "wais_similarities", "WAIS-IV Similarities", "Verbal Comprehension", "QI", "16-90", "",
 "wais_fsiq_8", "WAIS-IV (8-subtest FSIQ)", "Intelligence", "QI", "16-90", "Full scale IQ",
  
 # --- Intelligence/Cognitive (WISC-V) ---
 "wisc_matrix", "WISC-V Matrix Reasoning", "Fluid Reasoning", "PPT", "6-16", "",
 "wisc_vocabulary", "WISC-V Vocabulary", "Verbal Comprehension", "PPT", "6-16", "",
 "wisc_figure_weights", "WISC-V Figure Weights", "Fluid Reasoning", "PPT", "6-16", "",
 "wisc_visual_puzzles", "WISC-V Visual Puzzles", "Visual Spatial", "PPT", "6-16", "",
 "wisc_coding", "WISC-V Coding", "Processing Speed", "PPT", "6-16", "Mail response sheet",
 "wisc_symbol_search", "WISC-V Symbol Search", "Processing Speed", "PPT", "6-16", "Mail response sheet",
 "wisc_similarities", "WISC-V Similarities", "Verbal Comprehension", "QI", "6-16", "",
 "wisc_digit_span", "WISC-V Digit Span", "Working Memory", "QI", "6-16", "",
  
 # --- Intelligence/Cognitive (WPPSI-IV) ---
 "wppsi_information", "WPPSI-IV Information", "Verbal Comprehension", "QI", "2-7", "",
 "wppsi_similarities", "WPPSI-IV Similarities", "Verbal Comprehension", "QI", "4-7", "",
 "wppsi_block_design", "WPPSI-IV Block Design", "Visual Spatial", "PPT", "2-7", "Mail blocks",
 "wppsi_matrix", "WPPSI-IV Matrix Reasoning", "Fluid Reasoning", "PPT", "4-7", "",
 "wppsi_picture_memory", "WPPSI-IV Picture Memory", "Working Memory", "PPT", "2-7", "",
 "wppsi_bug_search", "WPPSI-IV Bug Search", "Processing Speed", "PPT", "4-7", "Mail response sheet",
 "wppsi_cancellation", "WPPSI-IV Cancellation", "Processing Speed", "PPT", "4-7", "Mail response sheet",
  
 # --- Nonverbal Intelligence ---
 "ravens2", "Raven's 2 Progressive Matrices", "Nonverbal Reasoning", "QI", "4+", "Nonverbal",
  
 # --- Memory (Verbal) ---
 "cvlt3_immediate", "CVLT-3 Immediate & Short Delay", "Verbal Memory", "QI", "16-90", "",
 "cvlt3_long_delay", "CVLT-3 Long Delay", "Verbal Memory", "QI", "16-90", "",
 "cvlt3_forced_choice", "CVLT-3 Forced Choice", "Effort/Validity", "QI", "16-90", "PVT",
 "cvlt3_full", "CVLT-3", "Verbal Memory", "QI", "16+", "Full CVLT-3",
 "cvlt3_recognition_50", "CVLT-3 (50-item Recognition)", "Verbal Memory", "QI", "16-90", "",
 "cvltc", "CVLT-C", "Verbal Memory", "QI", "5-16", "Children's version",
 "wms_lm1", "WMS-IV Logical Memory I", "Verbal Memory", "QI", "16-90", "",
 "wms_lm2", "WMS-IV Logical Memory II", "Verbal Memory", "QI", "16-90", "",
 "wms_vpa", "WMS-IV Verbal Paired Associates", "Verbal Memory", "QI", "16-90", "For left temporal lobe cases",
  
 # --- Memory (Visual) ---
 "wms_vr1", "WMS-IV Visual Reproduction I", "Visual Memory", "QI", "16-90", "",
 "wms_vr2", "WMS-IV Visual Reproduction II, Recognition & Copy", "Visual Memory", "QI", "16-90", "",
 "bvmtr", "BVMT-R", "Visual Memory", "QI", "18-79", "Brief Visuospatial Memory Test-Revised",
 "rocft_copy", "Rey-O Complex Figure (Copy)", "Visuoconstruction", "Paper", "6-89", "",
 "rocft_full", "Rey-O Complex Figure (Copy & Recall)", "Visual Memory", "Paper", "6-89", "Copy and recall",
  
 # --- Executive Function ---
 "dkefs_vf", "D-KEFS Verbal Fluency", "Executive Function", "QI", "8-89", "",
 "dkefs_cwit", "D-KEFS Color-Word Interference", "Executive Function", "QI", "8-89", "",
 "trails_ab", "Trails A/B", "Processing Speed/Executive", "PPT", "9-89", "",
 "wcst64", "WCST-64", "Executive Function", "PARiConnect", "6.5-89", "",
 "fas_fluency", "FAS Verbal Fluency", "Executive Function", "Paper", "All", "Phonemic fluency",
 "animals_fluency", "Animals (Semantic Fluency)", "Executive Function", "Paper", "All", "",
  
 # --- Language ---
 "bnt", "Boston Naming Test (60 items)", "Language", "PPT", "All", "",
 "bnt_nab", "BNT/NAB Naming", "Language", "PPT", "All", "Older adult PPT has BNT; younger has NAB",
 "nab_naming", "NAB Naming", "Language", "PPT", "All", "",
 "ppvt5", "PPVT-5", "Receptive Language", "PPT", "2.5-90+", "Use if Vocab < 7 for kids",
 "evt3", "EVT-3", "Expressive Language", "PPT", "2.5-90+", "",
  
 # --- Visuospatial ---
 "jolo_short", "Judgment of Line Orientation (Short)", "Visuospatial", "Paper", "All", "",
 "nab_judgment", "NAB Judgment", "Judgment/Executive", "Paper", "All", "",
  
 # --- Motor ---
 "grooved_peg", "Grooved Pegboard", "Motor", "Paper", "5-89", "",
  
 # --- Performance Validity Tests (PVTs) ---
 "acs_word_choice", "ACS Word Choice", "Effort/Validity", "PPT", "16+", "PVT",
 "rey15", "Rey 15-Item Test", "Effort/Validity", "PPT", "All", "PVT",
 "rds", "Reliable Digit Span (RDS)", "Effort/Validity", "Embedded", "All", "Embedded PVT",
 "tomm", "TOMM", "Effort/Validity", "Paper", "16+", "Test of Memory Malingering",
 "cvlt_pvt", "CVLT PVT Indices", "Effort/Validity", "Embedded", "All", "Embedded",
 "wcst_pvt", "WCST PVT Indices", "Effort/Validity", "Embedded", "All", "Embedded",
 "cwit_pvt", "D-KEFS CWIT PVT Indices", "Effort/Validity", "Embedded", "All", "Embedded",
 "trails_pvt", "Trails PVT Indices", "Effort/Validity", "Embedded", "All", "Embedded",
 "bvmt_pvt", "BVMT PVT Indices", "Effort/Validity", "Embedded", "All", "Embedded",
 "wms_pvt", "WMS VR Rec. & LM Rec. PVT Indices", "Effort/Validity", "Embedded", "All", "Embedded",
 "nab_pvt", "NAB/HRB PVT Indices", "Effort/Validity", "Embedded", "All", "Embedded",
 "wisc_rds", "WISC-V RDS", "Effort/Validity", "Embedded", "6-16", "For children",
  
 # --- Behavioral Rating Scales ---
 "basc3", "BASC-3", "Behavioral/Emotional", "Q-global", "2-25", "Parent/Teacher/Self forms",
 "brief2", "BRIEF-2", "Executive Function Rating", "PARiConnect", "5-18", "",
 "briefa", "BRIEF-A", "Executive Function Rating", "PARiConnect", "18-90", "Adult version",
 "briefp", "BRIEF-P", "Executive Function Rating", "PARiConnect", "2-5", "Preschool version",
 "abas3", "ABAS-3", "Adaptive Functioning", "WPS", "0-89", "",
 "srs2", "SRS-2", "Autism/Social", "WPS", "2.5+", "Social Responsiveness Scale",
 "baars", "BAARS-IV", "ADHD Rating", "Google Form", "19+", "Barkley Adult ADHD Rating Scale",
 "adhd_rs_preschool", "ADHD Rating Scale IV (Preschool)", "ADHD Rating", "Google Form", "3-5", "",
  
 # --- Mood/Personality ---
 "bai", "BAI", "Anxiety", "Paper/Drive", "17+", "Beck Anxiety Inventory",
 "bdi2", "BDI-II", "Depression", "Paper/Drive", "13+", "Beck Depression Inventory-II",
 "gai", "GAI", "Anxiety", "Paper", "65+", "Geriatric Anxiety Inventory",
 "gds", "GDS", "Depression", "Paper", "65+", "Geriatric Depression Scale",
 "pcl", "PCL-5", "PTSD", "Google Form", "18+", "PTSD Checklist",
 "pai", "PAI", "Personality", "QI", "18+", "Personality Assessment Inventory",
 "mmpi3", "MMPI-3", "Personality", "QI", "18+", "",
 "mcmi4", "MCMI-IV", "Personality", "QI", "18+", "Millon Clinical Multiaxial Inventory",
 "maci2", "MACI-II", "Personality (Adolescent)", "QI", "13-19", "",
 "mpaci", "M-PACI", "Personality (Pre-Adolescent)", "QI", "9-12", "",
  
 # --- ASD-Specific ---
 "migdas2_q", "MIGDAS-2 Questionnaire", "ASD Assessment", "Google Form", "3+", "Parent/caregiver",
 "migdas2_interview", "MIGDAS-2 Interview", "ASD Assessment", "Paper/PPT", "3+", "",
 "cars2", "CARS-2", "ASD Assessment", "Clinician", "2+", "Clinician rating scale",
  
 # --- Seizure/Quality of Life ---
 "qolie31", "QOLIE-31", "Quality of Life (Seizure)", "Paper", "18+", "Quality of Life in Epilepsy",
  
 # --- Diagnostic Interviews ---
 "mini7", "MINI 7.0.2", "Diagnostic Interview", "Clinician", "18+", "",
 "mini_kid", "MINI-KID 7.0.2", "Diagnostic Interview", "Clinician", "6-17", "",
 "dsm_ccs", "DSM-5 Cross-Cutting Symptom", "Screening", "Google Form", "All", "",
  
 # --- Questionnaires (General) ---
 "questionnaires_gf", "Questionnaires (Google Forms)", "Intake/History", "Google Form", "All", "",
  
 # --- Spanish Batteries ---
 "wais_coding_sp", "WAIS-IV Coding (Spanish)", "Processing Speed", "QI", "16-90", "Spanish version",
 "wais_symbol_sp", "WAIS-IV Symbol Search (Spanish)", "Processing Speed", "QI", "16-90", "Spanish version",
 "wais_visual_puzzles_sp", "WAIS-IV Visual Puzzles (Spanish)", "Perceptual Reasoning", "QI", "16-90", "Spanish version",
 "wais_matrix_sp", "WAIS-IV Matrix Reasoning (Spanish)", "Perceptual Reasoning", "QI", "16-90", "Spanish version",
 "wais_arithmetic_sp", "WAIS-IV Arithmetic (Spanish)", "Working Memory", "QI", "16-90", "Spanish version",
 "wais_vocabulary_sp", "WAIS-IV Vocabulary (Spanish)", "Verbal Comprehension", "QI", "16-90", "Spanish version",
 "wais_similarities_sp", "WAIS-IV Similarities (Spanish)", "Verbal Comprehension", "QI", "16-90", "Spanish version",
 "bne_story", "BNE Story Memory", "Verbal Memory", "Paper", "All", "Batería Neuropsicológica en Español",
 "bne_fluency", "BNE Verbal Fluency", "Executive Function", "Paper", "All", "BNE",
 "bne_list", "BNE List Learning", "Verbal Memory", "Paper", "All", "BNE",
 "bne_stroop", "BNE Stroop", "Executive Function", "Paper", "All", "BNE",
 "wcst64_sp", "WCST-64 (Spanish)", "Executive Function", "PARiConnect", "6.5-89", "Spanish version",
 "bnt_sp", "Boston Naming (Spanish)", "Language", "TBD", "All", "Details TBD",
 "wms3_sp", "WMS-III (Spanish)", "Memory", "TBD", "All", "Details TBD",
 "cvlt_sp", "CVLT (Spanish)", "Verbal Memory", "TBD", "All", "Details TBD",
 "rbans_sp", "RBANS (Spanish)", "Cognitive Screening", "TBD", "All", "Details TBD",
 "beck_anxiety_sp", "Beck Anxiety (Spanish)", "Anxiety", "Paper", "17+", "Spanish version",
 "beck_depression_sp", "Beck Depression (Spanish)", "Depression", "Paper", "13+", "Spanish version"
)

# =============================================================================
# 2. BATTERY DEFINITIONS - Reference tests by ID
# =============================================================================
# Each battery is a list with:
#   - description: Brief description
#   - age_group: Target age range
#   - required: Vector of test_ids that are required
#   - optional: Vector of test_ids that are optional

battery_definitions <- list(
  
  # --- Phase 1A ---
  "Phase 1A" = list(
   description = "Brief screening battery",
   age_group = "Adult",
   required = c("wrat5_reading", "rbans", "clock", "trails_ab", "questionnaires_gf"),
   optional = character(0)
 ),
  
  # --- Phase 2A ---
  "Phase 2A" = list(
   description = "Extended adult neuropsychological battery",
   age_group = "Adult",
   required = c(
     "cvlt3_immediate", "wms_vr1", "wais_digit_span", "wais_coding",
     "wais_symbol_search", "cvlt3_long_delay", "wms_vr2", "cvlt3_forced_choice",
     "dkefs_vf", "dkefs_cwit", "bnt_nab"
   ),
   optional = c(
     "wms_lm1", "wais_visual_puzzles", "wais_matrix", "wms_lm2",
     "wais_arithmetic", "wais_vocabulary", "wais_similarities",
     "wcst64", "nab_judgment", "acs_word_choice", "rey15"
   )
 ),
  
  # --- Full A / KP NP ---
  "Full A / KP NP" = list(
   description = "Full adult neuropsychological battery",
   age_group = "Adult",
   required = c(
     "wrat5_reading", "cvlt3_immediate", "wms_vr1", "trails_ab",
     "wais_digit_span", "cvlt3_long_delay", "wms_vr2", "wais_coding",
     "cvlt3_forced_choice", "dkefs_vf", "dkefs_cwit", "bnt_nab"
   ),
   optional = c(
     "wais_symbol_search", "wms_lm1", "wms_lm2", "wais_visual_puzzles",
     "wais_matrix", "wais_arithmetic", "wais_vocabulary", "wais_similarities",
     "wcst64", "clock", "nab_judgment", "acs_word_choice", "rey15"
   )
 ),
  
  # --- Step-down Battery ---
  "Step-down (Dementia/Poor Effort)" = list(
   description = "Abbreviated battery for dementia or poor effort",
   age_group = "Adult",
   required = c("rbans", "clock", "trails_ab"),
   optional = c("moca", "nab_judgment")
 ),
  
  # --- Full A Spanish ---
  "Full A (Spanish)" = list(
   description = "Full adult battery - Spanish version (IN PROGRESS)",
   age_group = "Adult",
   required = c(
     "trails_ab", "wais_digit_span", "wais_coding_sp", "wais_symbol_sp",
     "bne_story", "bne_fluency", "bne_list", "bne_stroop", "clock",
     "beck_anxiety_sp", "beck_depression_sp"
   ),
   optional = c(
     "wais_visual_puzzles_sp", "wais_matrix_sp", "wais_arithmetic_sp",
     "wais_vocabulary_sp", "wais_similarities_sp", "wcst64_sp",
     "bnt_sp", "wms3_sp", "cvlt_sp", "rbans_sp", "tomm"
   )
 ),
  
  # --- Full A Seizure/TBI ---
  "Full A Seizure/TBI" = list(
   description = "Full battery for seizure or TBI evaluation",
   age_group = "Adult/Child",
   required = c(
     "acs_word_choice", "wrat5_reading", "wais_fsiq_8", "cvlt3_recognition_50",
     "wms_lm1", "bvmtr", "bnt", "trails_ab", "fas_fluency", "animals_fluency",
     "rocft_copy", "dkefs_cwit", "qolie31", "bdi2", "bai"
   ),
   optional = c("grooved_peg", "mmpi3", "wcst64", "jolo_short", "wisc_rds")
 ),
  
  # --- Full D Adult ---
  "Full D (Adult 17+)" = list(
   description = "Full developmental battery - Adult",
   age_group = "Adult 17+",
   required = c(
     # Symptom inventories
     "basc3", "briefa", "abas3", "baars", "srs2", "migdas2_q", "cars2",
     "bai", "bdi2", "pcl",
     # Cognitive
     "wais_coding", "wais_symbol_search", "wais_visual_puzzles",
     "wais_similarities", "wais_matrix", "wais_vocabulary",
     "wais_digit_span", "wais_arithmetic", "dkefs_cwit", "migdas2_interview"
   ),
   optional = c(
     "ravens2", "dkefs_vf", "cvlt3_full",
     "wiat4_reading", "wiat4_spelling", "wiat4_numerical",
     "wiat4_reading_comp", "wiat4_math_ps",
     "wrat5_reading", "wrat5_spelling", "wrat5_math"
   )
 ),
  
  # --- Full D Child 6-16 ---
  "Full D (Child 6-16)" = list(
   description = "Full developmental battery - School age",
   age_group = "Child 6-16",
   required = c(
     # Symptom inventories
     "basc3", "brief2", "abas3", "srs2", "migdas2_q",
     # Cognitive
     "wisc_matrix", "wisc_vocabulary", "wisc_figure_weights",
     "wisc_visual_puzzles", "wisc_coding", "wisc_symbol_search",
     "wisc_similarities", "wisc_digit_span", "dkefs_cwit",
     "migdas2_interview", "cars2"
   ),
   optional = c(
     "ravens2", "dkefs_vf", "cvltc",
     "wiat4_reading", "wiat4_spelling", "wiat4_numerical",
     "wiat4_reading_comp", "wiat4_math_ps"
   )
 ),
  
  # --- Full D Child 4-5 ---
  "Full D (Child 4-5)" = list(
   description = "Full developmental battery - Preschool",
   age_group = "Child 4-5",
   required = c(
     # Symptom inventories
     "basc3", "briefp", "abas3", "adhd_rs_preschool", "srs2", "migdas2_q",
     # Cognitive
     "wppsi_information", "wppsi_similarities", "wppsi_block_design",
     "wppsi_matrix", "wppsi_picture_memory", "wppsi_bug_search",
     "wppsi_cancellation", "migdas2_interview", "cars2"
   ),
   optional = c(
     "ravens2", "wiat4_reading", "wiat4_spelling", "wiat4_numerical",
     "wiat4_reading_comp", "wiat4_math_ps", "cvltc"
   )
 ),
  
  # --- Full D Child 2-3 ---
  "Full D (Child 2-3)" = list(
   description = "Full developmental battery - Toddler",
   age_group = "Child 2-3",
   required = c(
     "basc3", "briefp", "abas3", "srs2", "migdas2_q",
     "wppsi_information", "wppsi_similarities", "wppsi_block_design",
     "wppsi_matrix", "wppsi_picture_memory", "wppsi_bug_search",
     "wppsi_cancellation", "migdas2_interview", "cars2"
   ),
   optional = character(0)
 ),
  
  # --- Full D Pediatric Seizure ---
  "Full D Pediatric Seizure (6-16)" = list(
   description = "Full developmental battery for pediatric seizure",
   age_group = "Child 6-16",
   required = c(
     "basc3", "brief2", "abas3", "srs2",
     "wisc_matrix", "wisc_vocabulary", "wisc_figure_weights",
     "wisc_visual_puzzles", "wisc_coding", "wisc_symbol_search",
     "wisc_similarities", "wisc_digit_span", "dkefs_cwit", "cvltc",
     "rocft_full", "evt3", "ppvt5",
     "wiat4_reading", "wiat4_spelling", "wiat4_numerical",
     "wiat4_reading_comp", "wiat4_math_ps"
   ),
   optional = c("migdas2_q", "migdas2_interview", "cars2", "dkefs_vf")
 ),
  
  # --- Phase 1D Adult ---
  "Phase 1D (Adult 17+)" = list(
   description = "Phase 1D screening - Adult",
   age_group = "Adult 17+",
   required = c(
     "basc3", "briefa", "abas3", "baars", "srs2",
     "wais_coding", "wais_visual_puzzles", "wais_symbol_search",
     "wais_similarities", "wais_matrix", "wais_vocabulary", "wais_digit_span",
     "dkefs_cwit", "wiat4_reading", "wiat4_spelling", "wiat4_numerical"
   ),
   optional = c("ravens2", "dkefs_vf", "cvlt3_full", "bai", "bdi2", "pcl", "dsm_ccs")
 ),
  
  # --- Phase 1D Child 6-16 ---
  "Phase 1D (Child 6-16)" = list(
   description = "Phase 1D screening - School age",
   age_group = "Child 6-16",
   required = c(
     "basc3", "brief2", "abas3", "srs2",
     "wisc_matrix", "wisc_vocabulary", "wisc_figure_weights",
     "wisc_visual_puzzles", "wisc_coding", "wisc_symbol_search",
     "wisc_similarities", "wisc_digit_span", "dkefs_cwit",
     "wiat4_reading", "wiat4_spelling", "wiat4_numerical"
   ),
   optional = c("ravens2", "cvltc", "dkefs_vf")
 ),
  
  # --- Phase 1D Preschool ---
  "Phase 1D (Preschool 4-5)" = list(
   description = "Phase 1D screening - Preschool",
   age_group = "Child 4-5",
   required = c(
     "basc3", "briefp", "adhd_rs_preschool", "srs2",
     "wppsi_block_design", "wppsi_information", "wppsi_matrix",
     "wppsi_bug_search", "wppsi_cancellation", "wppsi_picture_memory",
     "wppsi_similarities"
   ),
   optional = c("ravens2")
 ),
  
  # --- Phase 2D LD Adult ---
  "Phase 2D LD (Adult)" = list(
   description = "Phase 2D Learning Disability - Adult",
   age_group = "Adult",
   required = c(
     "wiat4_reading", "wiat4_spelling", "wiat4_numerical",
     "wiat4_math_ps", "wiat4_reading_comp"
   ),
   optional = character(0)
 ),
  
  # --- Phase 2D ASD Adult ---
  "Phase 2D ASD (Adult)" = list(
   description = "Phase 2D Autism Spectrum - Adult",
   age_group = "Adult",
   required = c("migdas2_q", "migdas2_interview", "cars2"),
   optional = character(0)
 ),
  
  # --- KP Dev Child 2-5 ---
  "KP Dev (Child 2-5)" = list(
   description = "KP Developmental - Early childhood",
   age_group = "Child 2-5",
   required = c(
     "basc3", "abas3", "srs2", "migdas2_q",
     "wppsi_information", "wppsi_similarities", "wppsi_block_design",
     "wppsi_matrix", "wppsi_picture_memory", "wppsi_bug_search",
     "wppsi_cancellation", "migdas2_interview", "cars2"
   ),
   optional = c("ravens2")
 ),
  
  # --- KP Dev Child 6-16 ---
  "KP Dev (Child 6-16)" = list(
   description = "KP Developmental - School age",
   age_group = "Child 6-16",
   required = c(
     "basc3", "abas3", "srs2", "migdas2_q",
     "wisc_matrix", "wisc_vocabulary", "wisc_figure_weights",
     "wisc_visual_puzzles", "wisc_coding", "wisc_symbol_search",
     "wisc_similarities", "wisc_digit_span",
     "migdas2_interview", "cars2"
   ),
   optional = c("ravens2")
 ),
  
  # --- KP Dev Adult ---
  "KP Dev (Adult 17+)" = list(
   description = "KP Developmental - Adult",
   age_group = "Adult 17+",
   required = c(
     "basc3", "abas3", "baars", "srs2", "migdas2_q", "cars2",
     "wais_coding", "wais_symbol_search", "wais_visual_puzzles",
     "wais_similarities", "wais_matrix", "wais_vocabulary",
     "wais_digit_span", "wais_arithmetic", "migdas2_interview"
   ),
   optional = c("ravens2", "briefa", "bai", "bdi2", "pcl")
 ),
  
  # --- KP Psych MH Adult ---
  "KP Psych MH (Adult)" = list(
   description = "KP Psychological/Mental Health - Adult",
   age_group = "Adult",
   required = c("mini7", "pai", "bai", "bdi2"),
   optional = c("mcmi4", "mmpi3", "pcl", "baars", "briefa")
 ),
  
  # --- KP Psych MH Child ---
  "KP Psych MH (Child)" = list(
   description = "KP Psychological/Mental Health - Child",
   age_group = "Child 6-17",
   required = c("basc3", "abas3", "mini_kid", "maci2"),
   optional = c("brief2", "mpaci")
 ),
  
  # --- KP Psych ADHD/ASD Adult ---
  "KP Psych ADHD/ASD (Adult 17+)" = list(
   description = "KP ADHD/ASD evaluation - Adult",
   age_group = "Adult 17+",
   required = c(
     "basc3", "briefa", "abas3", "baars", "srs2", "migdas2_q",
     "bai", "bdi2", "pcl", "migdas2_interview", "cars2"
   ),
   optional = c(
     "wais_coding", "wais_symbol_search", "wais_visual_puzzles",
     "wais_similarities", "wais_matrix", "wais_vocabulary",
     "wais_digit_span", "wais_arithmetic", "ravens2",
     "dkefs_cwit", "dkefs_vf", "cvlt3_full"
   )
 ),
  
  # --- KP Psych ADHD/ASD Child 6-16 ---
  "KP Psych ADHD/ASD (Child 6-16)" = list(
   description = "KP ADHD/ASD evaluation - School age",
   age_group = "Child 6-16",
   required = c(
     "basc3", "brief2", "abas3", "srs2", "migdas2_q",
     "migdas2_interview", "cars2"
   ),
   optional = c(
     "wisc_matrix", "wisc_vocabulary", "wisc_figure_weights",
     "wisc_visual_puzzles", "wisc_coding", "wisc_symbol_search",
     "wisc_similarities", "wisc_digit_span", "ravens2",
     "dkefs_cwit", "dkefs_vf", "cvltc"
   )
 ),
  
  # --- KP Psych ADHD/ASD Child 4-5 ---
  "KP Psych ADHD/ASD (Child 4-5)" = list(
   description = "KP ADHD/ASD evaluation - Preschool",
   age_group = "Child 4-5",
   required = c(
     "basc3", "briefp", "abas3", "adhd_rs_preschool", "srs2", "migdas2_q",
     "migdas2_interview", "cars2"
   ),
   optional = c(
     "wppsi_information", "wppsi_similarities", "wppsi_block_design",
     "wppsi_matrix", "wppsi_picture_memory", "wppsi_bug_search",
     "wppsi_cancellation", "cvltc", "ravens2"
   )
 ),
  
  # --- KP Psych ADHD/ASD Child 2-3 ---
  "KP Psych ADHD/ASD (Child 2-3)" = list(
   description = "KP ADHD/ASD evaluation - Toddler",
   age_group = "Child 2-3",
   required = c(
     "basc3", "briefp", "abas3", "srs2", "migdas2_q",
     "migdas2_interview", "cars2"
   ),
   optional = c(
     "wppsi_information", "wppsi_similarities", "wppsi_block_design",
     "wppsi_matrix", "wppsi_picture_memory", "wppsi_bug_search",
     "wppsi_cancellation"
   )
 ),
  
  # --- PVT Pool ---
  "PVT Pool" = list(
   description = "Performance Validity Tests - Add as needed",
   age_group = "All",
   required = character(0),
   optional = c(
     "acs_word_choice", "cvlt_pvt", "rey15", "rds", "wcst_pvt",
     "cwit_pvt", "trails_pvt", "bvmt_pvt", "wms_pvt", "nab_pvt",
     "tomm", "wisc_rds"
   )
 )
)

# Generate battery choices vector
battery_choices <- names(battery_definitions)

# Validate that all test_ids in batteries exist in catalog
validate_batteries <- function() {
  catalog_ids <- test_catalog$test_id
  missing_tests <- list()
  
  for (battery_name in names(battery_definitions)) {
    battery <- battery_definitions[[battery_name]]
    all_ids <- c(battery$required, battery$optional)
    missing <- setdiff(all_ids, catalog_ids)
    if (length(missing) > 0) {
      missing_tests[[battery_name]] <- missing
    }
  }
  
  if (length(missing_tests) > 0) {
    message("WARNING: Some test IDs in battery definitions are not in the test catalog:")
    for (battery_name in names(missing_tests)) {
      message(sprintf("  %s: %s", battery_name, paste(missing_tests[[battery_name]], collapse = ", ")))
    }
  }
  
  invisible(missing_tests)
}

# Run validation on load
missing_tests <- validate_batteries()


# =============================================================================
# 3. HELPER FUNCTIONS
# =============================================================================

#' Get tests for a battery with full details
#' @param battery_name Name of the battery
#' @return Tibble with test details
get_battery_tests <- function(battery_name) {
 if (!battery_name %in% names(battery_definitions)) {
   return(tibble(
     test_id = character(),
     test_name = character(),
     domain = character(),
     admin_format = character(),
     age_range = character(),
     notes = character(),
     required = logical(),
     battery = character()
   ))
 }
  
 battery <- battery_definitions[[battery_name]]
  
 # Get required tests (only those that exist in catalog)
 required_df <- test_catalog |>
   filter(test_id %in% battery$required) |>
   mutate(required = TRUE, battery = battery_name)
  
 # Get optional tests (only those that exist in catalog)
 optional_df <- test_catalog |>
   filter(test_id %in% battery$optional) |>
   mutate(required = FALSE, battery = battery_name)
  
 result <- bind_rows(required_df, optional_df) |>
   # Remove any rows with NA in critical columns
   filter(!is.na(test_id), !is.na(test_name)) |>
   arrange(desc(required), domain, test_name)
 
 return(result)
}

#' Create display label for test (with star for required)
#' @param test_name Test name
#' @param required Logical indicating if required
#' @return Character string with formatted label
format_test_label <- function(test_name, required) {
 # Handle NAs and NULL
 if (length(test_name) == 0) return(character(0))
 
 # Replace NA test names with placeholder
 test_name <- ifelse(is.na(test_name), "[Unknown Test]", test_name)
 required <- ifelse(is.na(required), FALSE, required)
 
 ifelse(required, paste0("\u2605 ", test_name), test_name)
}

#' Safely assign names to choice vectors (no NA names)
#' @param values Vector of values for inputs
#' @param labels Vector of labels; NA/blank replaced with placeholder
#' @param placeholder Fallback label text
safe_set_names <- function(values, labels, placeholder = "[Unknown Test]") {
  values <- as.character(values)
  labels <- as.character(labels)
  keep <- !(is.na(values) | values == "")
  values <- values[keep]
  labels <- labels[keep]
  labels[is.na(labels) | labels == ""] <- placeholder
  setNames(values, labels)
}


# =============================================================================
# 4. SHINY MODULES
# =============================================================================

# --- Test Selection Module ---

#' UI for test selection module
testSelectionUI <- function(id) {
 ns <- NS(id)
 tagList(
   fluidRow(
     box(
       title = "Battery Template",
       width = 4,
       status = "primary",
       solidHeader = TRUE,
       selectInput(
         ns("template_battery"),
         "Select a battery template:",
         choices = battery_choices,
         selected = "Phase 1A"
       ),
       uiOutput(ns("battery_info")),
       hr(),
       actionButton(ns("select_required"), "Select Required Only", 
                    class = "btn-info", width = "100%"),
       br(), br(),
       actionButton(ns("select_all"), "Select All Tests", 
                    class = "btn-success", width = "100%"),
       br(), br(),
       actionButton(ns("clear_all"), "Clear All", 
                    class = "btn-warning", width = "100%")
     ),
     box(
       title = "Available Tests",
       width = 8,
       status = "info",
       solidHeader = TRUE,
       helpText("★ = Required test in this battery. Check/uncheck to customize."),
       tabsetPanel(
         id = ns("test_tabs"),
         tabPanel("Required", 
                  div(style = "max-height: 400px; overflow-y: auto;",
                      checkboxGroupInput(ns("required_tests"), 
                                         label = NULL, 
                                         choices = character(0))
                  )),
         tabPanel("Optional",
                  div(style = "max-height: 400px; overflow-y: auto;",
                      checkboxGroupInput(ns("optional_tests"), 
                                         label = NULL, 
                                         choices = character(0))
                  )),
         tabPanel("All Tests",
                  div(style = "max-height: 400px; overflow-y: auto;",
                      checkboxGroupInput(ns("all_tests"), 
                                         label = NULL, 
                                         choices = character(0))
                  ))
       )
     )
   )
 )
}

#' Server for test selection module
testSelectionServer <- function(id, selected_battery = reactive("Phase 1A")) {
 moduleServer(id, function(input, output, session) {
   ns <- session$ns
    
   # Reactive: current battery tests
   battery_tests <- reactive({
     req(input$template_battery)
     get_battery_tests(input$template_battery)
   })
    
   # Reactive: battery info
   battery_info <- reactive({
     req(input$template_battery)
     battery_definitions[[input$template_battery]]
   })
    
   # Display battery info
   output$battery_info <- renderUI({
     info <- battery_info()
     if (is.null(info)) return(NULL)
      
     tagList(
       tags$p(tags$strong("Description: "), info$description),
       tags$p(tags$strong("Age Group: "), info$age_group),
       tags$p(tags$strong("Required: "), length(info$required), " tests"),
       tags$p(tags$strong("Optional: "), length(info$optional), " tests")
     )
   })
    
   # Update checkboxes when battery changes
   observeEvent(input$template_battery, {
     tests <- battery_tests()
     if (nrow(tests) == 0) {
       # Clear all checkboxes if no tests
       updateCheckboxGroupInput(session, "required_tests",
                                choices = character(0), selected = character(0))
       updateCheckboxGroupInput(session, "optional_tests",
                                choices = character(0), selected = character(0))
       updateCheckboxGroupInput(session, "all_tests",
                                choices = character(0), selected = character(0))
       return()
     }
      
     # Required tests
     req_tests <- tests |> filter(required)
     if (nrow(req_tests) > 0) {
      req_choices <- safe_set_names(req_tests$test_id, 
                                    format_test_label(req_tests$test_name, TRUE))
       req_selected <- req_tests$test_id
     } else {
       req_choices <- character(0)
       req_selected <- character(0)
     }
      
     # Optional tests
     opt_tests <- tests |> filter(!required)
     if (nrow(opt_tests) > 0) {
      opt_choices <- safe_set_names(opt_tests$test_id,
                                    format_test_label(opt_tests$test_name, FALSE))
     } else {
       opt_choices <- character(0)
     }
      
     # All tests combined
    all_choices <- safe_set_names(tests$test_id,
                                  format_test_label(tests$test_name, tests$required))
      
     # Update inputs
     updateCheckboxGroupInput(session, "required_tests",
                              choices = req_choices,
                              selected = req_selected)
      
     updateCheckboxGroupInput(session, "optional_tests",
                              choices = opt_choices,
                              selected = character(0))
      
     updateCheckboxGroupInput(session, "all_tests",
                              choices = all_choices,
                              selected = req_selected)
   })
    
   # Sync selections across tabs
   observeEvent(input$all_tests, {
     tests <- battery_tests()
     if (nrow(tests) == 0) return()
     
     selected <- input$all_tests
     if (is.null(selected)) selected <- character(0)
      
     req_ids <- tests |> filter(required) |> pull(test_id)
     opt_ids <- tests |> filter(!required) |> pull(test_id)
      
     updateCheckboxGroupInput(session, "required_tests",
                              selected = intersect(selected, req_ids))
     updateCheckboxGroupInput(session, "optional_tests",
                              selected = intersect(selected, opt_ids))
   }, ignoreNULL = FALSE)
    
   # Action buttons
   observeEvent(input$select_required, {
     tests <- battery_tests()
     if (nrow(tests) == 0) return()
     
     req_ids <- tests |> filter(required) |> pull(test_id)
     updateCheckboxGroupInput(session, "all_tests", selected = req_ids)
     updateCheckboxGroupInput(session, "required_tests", selected = req_ids)
     updateCheckboxGroupInput(session, "optional_tests", selected = character(0))
   })
    
   observeEvent(input$select_all, {
     tests <- battery_tests()
     if (nrow(tests) == 0) return()
     
     all_ids <- tests$test_id
     req_ids <- tests |> filter(required) |> pull(test_id)
     opt_ids <- tests |> filter(!required) |> pull(test_id)
     
     updateCheckboxGroupInput(session, "all_tests", selected = all_ids)
     updateCheckboxGroupInput(session, "required_tests", selected = req_ids)
     updateCheckboxGroupInput(session, "optional_tests", selected = opt_ids)
   })
    
   observeEvent(input$clear_all, {
     updateCheckboxGroupInput(session, "all_tests", selected = character(0))
     updateCheckboxGroupInput(session, "required_tests", selected = character(0))
     updateCheckboxGroupInput(session, "optional_tests", selected = character(0))
   })
    
   # Return selected tests
   return(reactive({
     selected_ids <- input$all_tests
     if (is.null(selected_ids) || length(selected_ids) == 0) {
       return(tibble())
     }
      
     battery_tests() |>
       filter(test_id %in% selected_ids) |>
       arrange(desc(required), domain, test_name)
   }))
 })
}


# --- Summary Table Module ---

#' UI for summary table module
summaryTableUI <- function(id) {
 ns <- NS(id)
 tagList(
   tableOutput(ns("summary_table")),
   br(),
   verbatimTextOutput(ns("summary_stats"))
 )
}

#' Server for summary table module
summaryTableServer <- function(id, selected_tests) {
 moduleServer(id, function(input, output, session) {
    
   output$summary_table <- renderTable({
     tests <- selected_tests()
     if (is.null(tests) || nrow(tests) == 0) {
       return(data.frame(Message = "No tests selected"))
     }
      
     tests |>
       transmute(
         Test = test_name,
         Domain = domain,
         Format = admin_format,
         `Age Range` = age_range,
         Required = ifelse(required, "Yes", "No"),
         Notes = notes
       )
   })
    
   output$summary_stats <- renderPrint({
     tests <- selected_tests()
     if (is.null(tests) || nrow(tests) == 0) {
       cat("No tests selected")
       return()
     }
      
     n_required <- sum(tests$required)
     n_optional <- sum(!tests$required)
     n_total <- nrow(tests)
      
     cat(sprintf("Total tests selected: %d\n", n_total))
     cat(sprintf("  Required: %d\n", n_required))
     cat(sprintf("  Optional: %d\n", n_optional))
     cat(sprintf("\nDomains covered: %s\n", 
                 paste(unique(tests$domain), collapse = ", ")))
   })
 })
}


# =============================================================================
# 5. QUARTO TEMPLATE
# =============================================================================

test_sheet_qmd <- '
---
title: "Neuropsychological Test Battery"
format: 
  typst:
    toc: false
params:
  patient_name: ""
  age: ""
  battery_type: ""
  referral: ""
  selected_tests: NULL
---

## Patient Information

**Name:** `r params$patient_name`  \
**Age:** `r params$age`  \
**Battery Type:** `r params$battery_type`  \

**Referral Question:**
`r params$referral`

---

## Selected Tests

```{r}
#| echo: false

library(dplyr)
library(knitr)
library(tibble)

tests <- params$selected_tests
tests <- tryCatch(as_tibble(tests), error = function(e) tibble())

if (nrow(tests) == 0) {
  cat("No tests selected.")
} else {
  tests |>
    arrange(desc(required), domain, test_name) |>
    transmute(
      Test = test_name,
      Domain = domain,
      Format = admin_format,
      Required = ifelse(required, "Yes", "No"),
      Notes = notes
    ) |>
    kable()
}
```

---

## Summary

```{r echo = FALSE, results = "asis"}
if (!is.null(tests) && nrow(tests) > 0) {
  n_req <- sum(tests$required)
  n_opt <- sum(!tests$required)
  cat(sprintf("- Total tests: %d\\n", nrow(tests)))
  cat(sprintf("- Required: %d\\n", n_req))
  cat(sprintf("- Optional: %d\\n", n_opt))
  cat(sprintf("\\n- Domains: %s\\n", paste(unique(tests$domain), collapse = ", ")))
}
```
'


# =============================================================================
# 6. UI
# =============================================================================

ui <- dashboardPage(
 dashboardHeader(title = "Neuropsych Test Battery Builder"),
  
 dashboardSidebar(
   sidebarMenu(
     id = "tabs",
     menuItem("Patient Info", tabName = "patient", icon = icon("user")),
     menuItem("Select Tests", tabName = "tests", icon = icon("list-check")),
     menuItem("Review & Download", tabName = "review", icon = icon("file-pdf"))
   ),
   hr(),
   div(style = "padding: 10px;",
       tags$small("v2.0 - Refactored with modules and lookup tables")
   )
 ),
  
 dashboardBody(
   # Custom CSS
   tags$head(
     tags$style(HTML("
       .content-wrapper { background-color: #f4f4f4; }
       .box { border-radius: 5px; }
       .checkbox label { font-weight: normal; }
     "))
   ),
    
   tabItems(
     # --- Page 1: Patient Info ---
     tabItem(
       tabName = "patient",
       fluidRow(
         box(
           title = "Patient Information",
           width = 6,
           status = "primary",
           solidHeader = TRUE,
           textInput("patient_name", "Patient Name"),
           textInput("age", "Age"),
           selectInput(
             "battery_type",
             "Default Battery Type",
             choices = battery_choices,
             selected = "Phase 1A"
           ),
           textAreaInput("referral", "Referral Question / Case Description",
                         rows = 4,
                         placeholder = "Enter referral question and relevant background...")
         ),
         box(
           title = "Instructions",
           width = 6,
           status = "info",
           solidHeader = TRUE,
           tags$ol(
             tags$li("Enter basic patient information on this page."),
             tags$li("Select a battery template and customize tests on the next page."),
             tags$li("Review selected tests and download a PDF test sheet.")
           ),
           hr(),
           tags$p(tags$strong("Battery Types:")),
           tags$ul(
             tags$li(tags$strong("Phase 1A/2A:"), " Adult screening/extended batteries"),
             tags$li(tags$strong("Full A:"), " Full adult neuropsychological battery"),
             tags$li(tags$strong("Full D:"), " Developmental batteries (age-stratified)"),
             tags$li(tags$strong("KP Dev/Psych:"), " Kaiser Permanente specific batteries")
           )
         )
       )
     ),
      
     # --- Page 2: Test Selection ---
     tabItem(
       tabName = "tests",
       testSelectionUI("test_selection")
     ),
      
     # --- Page 3: Review & Download ---
     tabItem(
       tabName = "review",
       fluidRow(
         box(
           title = "Selected Tests Summary",
           width = 8,
           status = "primary",
           solidHeader = TRUE,
           summaryTableUI("summary")
         ),
         box(
           title = "Download Options",
           width = 4,
           status = "success",
           solidHeader = TRUE,
           h4("Download Test Sheet"),
           helpText("Generate a PDF of the selected test battery."),
           helpText(tags$em("Note: Requires TYPST LaTeX (e.g., tinytex) for PDF rendering.")),
           br(),
           downloadButton("download_pdf", "Download PDF", class = "btn-success btn-lg"),
           hr(),
           h4("Export Test List"),
           downloadButton("download_csv", "Download CSV", class = "btn-info")
         )
       )
     )
   )
 )
)


# =============================================================================
# 7. SERVER
# =============================================================================

server <- function(input, output, session) {
  
 # Initialize test selection module
 selected_tests <- testSelectionServer("test_selection")
  
 # Initialize summary module
 summaryTableServer("summary", selected_tests)
  
 # Sync battery type from patient page
 observeEvent(input$battery_type, {
   updateSelectInput(session, "test_selection-template_battery",
                     selected = input$battery_type)
 })
  
 # PDF Download Handler
 output$download_pdf <- downloadHandler(
   filename = function() {
     nm <- if (nzchar(input$patient_name)) {
       gsub("\\s+", "_", input$patient_name)
     } else {
       "test_battery"
     }
     paste0(nm, "_test_sheet.pdf")
   },
   content = function(file) {
    # Write temporary Quarto file in a non-symlinked temp dir to avoid cleanup issues on macOS
    tmp_dir <- tempfile(tmpdir = "/var/tmp", pattern = "quarto_test_sheet_")
    dir.create(tmp_dir, recursive = TRUE, showWarnings = FALSE)
    on.exit(unlink(tmp_dir, recursive = TRUE, force = TRUE), add = TRUE)
    qmd_path <- file.path(tmp_dir, "test_sheet.qmd")
    writeLines(test_sheet_qmd, con = qmd_path)
      
     params <- list(
       patient_name   = input$patient_name,
       age            = input$age,
       battery_type   = input$battery_type,
       referral       = input$referral,
       selected_tests = selected_tests()
     )
      
     outfile <- file.path(tmp_dir, basename(file))
     quarto::quarto_render(
       input         = qmd_path,
       output_format = "typst",
       output_file   = basename(file),
       execute_params = params,
       execute_dir   = tmp_dir,
       quiet         = TRUE
     )
     file.copy(outfile, file, overwrite = TRUE)
    }
  )
  
 # CSV Download Handler
 output$download_csv <- downloadHandler(
   filename = function() {
     nm <- if (nzchar(input$patient_name)) {
       gsub("\\s+", "_", input$patient_name)
     } else {
       "test_battery"
     }
     paste0(nm, "_tests.csv")
   },
   content = function(file) {
     tests <- selected_tests()
     if (is.null(tests) || nrow(tests) == 0) {
       tests <- tibble(Message = "No tests selected")
     } else {
       tests <- tests |>
         transmute(
           Test = test_name,
           Domain = domain,
           Format = admin_format,
           Age_Range = age_range,
           Required = ifelse(required, "Yes", "No"),
           Notes = notes
         )
     }
     write.csv(tests, file, row.names = FALSE)
   }
 )
}


# =============================================================================
# 8. RUN APP
# =============================================================================

shinyApp(ui, server)

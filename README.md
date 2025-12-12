# Shiny Test Battery

A Shiny web application for building and managing neuropsychological test batteries.

## Description

This application allows clinicians to create customized neuropsychological test batteries based on predefined templates. It includes patient information entry, test selection from various battery categories (Phase 1A, Phase 2A, Full A, Step-down, and PVTs), and generates a downloadable PDF test sheet.

The app is built using Shiny and shinydashboard, with PDF generation handled via R Markdown.

## Features

- **Patient Information**: Input patient name, age, battery type, and referral details.
- **Test Selection**: Choose from template batteries or customize individual tests. Required tests are marked with a star (★).
- **PDF Download**: Generate and download a PDF test sheet summarizing the selected tests and patient information.

## Batteries Included

- **Phase 1A**: Basic screening tests (WRAT-5, RBANS, Clock Drawing, Trails, Questionnaires)
- **Phase 2A**: Comprehensive assessment (CVLT-3, WMS-IV, WAIS-IV subtests, etc.)
- **Full A**: Full neuropsychological evaluation
- **Step-down**: For cases of poor effort or dementia (RBANS, MoCA, etc.)
- **PVTs**: Performance Validity Tests pool

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/brainworkup/shiny-test-battery.git
   cd shiny-test-battery
   ```

2. Install required R packages:
   ```r
   install.packages(c("shiny", "shinydashboard", "dplyr", "rmarkdown", "knitr"))
   ```

3. For PDF generation, install LaTeX (e.g., TinyTeX):
   ```r
   install.packages("tinytex")
   tinytex::install_tinytex()
   ```

## Usage

Run the Shiny app:
```r
shiny::runApp("app.R")
```

The app will open in your default web browser. Navigate through the tabs to enter patient info, select tests, and download the PDF.

## Files

- `app.R`: Main Shiny application file (single-file app).
- `test_battery_app.R`: Alternative version of the app.
- `Biggie_test_sheet-1.pdf`: Sample PDF output.
- `shiny-test-battery.code-workspace`: VS Code workspace configuration.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is open source. Please check the license file for details.

Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-12-12 06:23:18
Current User's Login: brainworkup
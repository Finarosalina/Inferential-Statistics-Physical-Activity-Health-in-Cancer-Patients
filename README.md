# Inferential Statistics: Physical Activity & Health in Cancer Patients
**HINTS 7 · Wilcoxon · Mann-Whitney U · R**

Analysis of physical activity levels and self-reported health in U.S. cancer patients using real-world survey data (HINTS 7, 2024). Two hypothesis tests are implemented and interpreted under a clinical research significance threshold (α = 0.01).

---

## Dataset

**Health Information National Trends Survey 7 (HINTS 7)** — National Cancer Institute, 2024.  
Public dataset: [https://hints.cancer.gov](https://hints.cancer.gov)

- Total survey respondents: n = 7,278 U.S. adults  
- Analysis subset: n = **1,045 confirmed cancer patients** (`EverHadCancer == "Yes"`, valid responses on both key variables)

> The `.rda` file is not included in this repository due to size. Download it directly from the NCI HINTS portal and place it in the working directory before running the script.

---

## Scenarios

### Scenario A — One-sample Wilcoxon signed-rank test
**Question:** Do cancer patients meet the WHO recommended 150 min/week of moderate physical activity?

- H₀: median ≥ 150 min/week  
- H₁: median < 150 min/week (left-tailed)  
- Result: **Reject H₀** · Median = 90 min/week · V = 205,464 · p = 5.27×10⁻⁹

### Scenario B — Mann-Whitney U test (Wilcoxon rank-sum)
**Question:** Do physically active cancer patients report better perceived health than sedentary ones?

- Groups: Active (≥150 min/week, n = 393) vs. Sedentary (<150 min/week, n = 652)
- Outcome: `GeneralHealth` recoded to ordinal scale (1 = Excellent → 5 = Poor)
- H₀: no difference in health distribution between groups  
- H₁: active group has better health (left-tailed)  
- Result: **Reject H₀** · W = 91,134 · p < 2.2×10⁻¹⁶

---

## Key Findings

- More than half of cancer patients do not meet WHO physical activity guidelines
- The distribution is highly right-skewed (mean = 176 min/week vs. median = 90 min/week), consistent with oncological fatigue and treatment side effects
- Active patients show significantly better self-reported health, with higher proportion of Excellent/Very Good ratings
- Effect size (Rosenthal's r) and confidence intervals included as extensions

---

## Usage

```r
# Set your local path to the HINTS 7 .rda file
setwd("your/local/path/to/HINTS7_folder")
load("hints7_public.rda")

# Then run est_infere.R sequentially
source("est_infere.R")
```

**Dependencies:**
```r
install.packages(c("ggplot2", "dplyr", "rstatix"))
```

---

## Methods

| Step | Description |
|------|-------------|
| Normality check | Shapiro-Wilk test → non-normal → non-parametric tests |
| Scenario A | Wilcoxon signed-rank (one-sample, left-tailed) |
| Scenario B | Mann-Whitney U / Wilcoxon rank-sum (two independent groups, left-tailed) |
| α threshold | 0.01 (standard in clinical oncology research) |
| Effect size | Rosenthal's r via `rstatix::wilcox_effsize()` |

---

## Repository Structure

```
├── est_infere.R          # Main analysis script
├── README.md             # This file
└── (hints7_public.rda)   # Not included — download from hints.cancer.gov
```

---

## Author

**María Pais Fajín** · Biomedical Data Scientist  
Master's in Data Analysis & Interpretation · UNIR · 2026  
[GitHub: Finarosalina](https://github.com/Finarosalina)

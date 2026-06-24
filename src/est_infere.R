# ══════════════════════════════════════════════════════════════════════════════
# Inferential Statistics: Physical Activity & Health in Cancer Patients
# Dataset: HINTS 7 (NCI, 2024) — https://hints.cancer.gov
# Author:  María Pais Fajín · UNIR Master's in Data Analysis · 2026
# ══════════════════════════════════════════════════════════════════════════════
# Dependencies: ggplot2, dplyr, rstatix
# Usage: set your local path below, then source() or run sequentially
# ══════════════════════════════════════════════════════════════════════════════

library(ggplot2)
library(dplyr)
library(rstatix)

# ── LOAD DATA ─────────────────────────────────────────────────────────────────
# Set path to the folder containing hints7_public.rda (downloaded from hints.cancer.gov)
# setwd("your/local/path/to/HINTS7_folder")
load("hints7_public.rda")


# ── EXPLORATION ───────────────────────────────────────────────────────────────
dim(public)       # rows and columns
names(public)     # 515 variable names
str(public)       # variable types
head(public, 5)


# ── DATA PREPARATION ──────────────────────────────────────────────────────────

# Remove NAs in key variables
df <- subset(public,
             !is.na(WeeklyMinutesModerateExercise) & !is.na(GeneralHealth))
dim(df)

# Filter confirmed cancer patients
cancer <- subset(df, EverHadCancer == "Yes")
nrow(cancer)

# Convert WeeklyMinutesModerateExercise: factor → numeric (non-ascertained → NA)
cancer$MinEjercicio <- as.numeric(as.character(cancer$WeeklyMinutesModerateExercise))
sum(is.na(cancer$MinEjercicio))
summary(cancer$MinEjercicio)

# Convert GeneralHealth: ordinal factor → numeric (1=Excellent … 5=Poor)
cancer$SaludNum <- as.numeric(factor(cancer$GeneralHealth,
                                     levels = c("Excellent", "Very good", "Good", "Fair", "Poor")))
table(cancer$SaludNum, useNA = "always")

# Final filter: drop remaining NAs in both variables
cancer <- subset(cancer, !is.na(MinEjercicio) & !is.na(SaludNum))
nrow(cancer)  # expected: 1,045


# ── SCENARIO A: ONE POPULATION ────────────────────────────────────────────────
# Question: do cancer patients meet the WHO 150 min/week recommendation?
# H₀: median ≥ 150 min/week  |  H₁: median < 150 min/week  |  α = 0.01

# Normality check → rules out t-test
shapiro.test(cancer$MinEjercicio)

# Descriptive statistics
cat("n =",       nrow(cancer), "\n")
cat("Mean =",    round(mean(cancer$MinEjercicio), 2), "min/week\n")
cat("Median =",  median(cancer$MinEjercicio), "min/week\n")
cat("SD =",      round(sd(cancer$MinEjercicio), 2), "\n")
cat("Range =",   min(cancer$MinEjercicio), "-", max(cancer$MinEjercicio), "\n")

# Histogram
hist(cancer$MinEjercicio,
     main = "Weekly exercise minutes (cancer patients)",
     xlab = "Minutes/week", col = "steelblue", breaks = 30)
abline(v = 150, col = "red", lwd = 2, lty = 2)

# Wilcoxon signed-rank test (left-tailed)
# H₁: median < 150 → patients do NOT meet the recommendation
wilcox.test(cancer$MinEjercicio, mu = 150, alternative = "less")

# With confidence interval for the pseudomedian
wilcox.test(cancer$MinEjercicio, mu = 150, alternative = "less", conf.int = TRUE)


# ── SCENARIO B: TWO INDEPENDENT POPULATIONS ───────────────────────────────────
# Question: do active cancer patients report better health than sedentary ones?
# H₀: no difference  |  H₁: active < sedentary in SaludNum  |  α = 0.01

# Create groups
cancer$Grupo <- ifelse(cancer$MinEjercicio >= 150, "Activo", "Sedentario")
table(cancer$Grupo)

# Descriptive statistics by group
tapply(cancer$SaludNum, cancer$Grupo, mean)
tapply(cancer$SaludNum, cancer$Grupo, median)
tapply(cancer$SaludNum, cancer$Grupo, sd)

# Boxplot
boxplot(SaludNum ~ Grupo, data = cancer,
        main = "Perceived health: active vs. sedentary (cancer patients)",
        ylab = "Health (1=Excellent, 5=Poor)",
        col = c("lightgreen", "salmon"),
        names = c("Active (≥150 min)", "Sedentary (<150 min)"))

# Mann-Whitney U test (Wilcoxon rank-sum, left-tailed)
wilcox.test(SaludNum ~ Grupo, data = cancer, alternative = "less")

# With confidence interval for the location shift
wilcox.test(SaludNum ~ Grupo, data = cancer, alternative = "less", conf.int = TRUE)

# Effect size: Rosenthal's r
cancer %>% wilcox_effsize(SaludNum ~ Grupo)

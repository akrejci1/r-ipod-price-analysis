# Econometric Analysis of iPod Auction Prices

This is my first R project, focused on analyzing the determinants of Apple iPod auction prices. The goal of the project was to apply multiple linear regression modeling, hypothesis testing, and model diagnostics to real-world auction data.

## Project Description

The analysis explores how various factors—such as product condition, color, number of bidders, seller reputation, and reserve price—affect the final closing price of an iPod. The project demonstrates a step-by-step econometric approach, from basic specification to complex models involving interaction terms and omitted variable bias correction.

## Data Preparation

The original dataset of 1,225 observations was filtered to ensure a comparable sample. The final dataset contains 575 observations, restricted to:
* 4GB memory capacity.
* Colors with at least 10% representation (Pink, Blue, Silver, Green).
* Clearly defined condition (Used, Refurbished, New).
* Items without serious defects.

## Econometric Modeling

The project progresses through several modeling stages:

1. **Basic Specification:** 
   Tested the core attributes (condition, scratches, and number of bidders) using the formula:
   $$ \text{PRICE} = \beta_0 + \beta_1 \cdot \text{NEW} + \beta_2 \cdot \text{REFUND} + \beta_3 \cdot \text{SCRATCH} + \beta_4 \cdot \text{BIDRS} + \epsilon $$
2. **The Role of Color:** Demonstrated the necessity of using dummy variables for nominal data rather than numerical assignment, proving that color is jointly significant in determining price.
3. **Seller Reputation:** Tested multiple theories regarding seller feedback. Revealed a threshold effect where reputation only impacts price after a seller accumulates more than 100 ratings.
4. **Reserve Price:** Addressed omitted variable bias by adding the reserve price. It was found that the reserve price acts strongly as a signal of quality, rather than just a minimum threshold.
5. **Final Model Optimization:** The final specification (Model 8) includes an interaction term between the condition of the item and the reserve price ($\text{NEW} \times \text{RESERV}$), passing the RESET test ($p = 0.146$) and achieving an adjusted $R^2$ of 0.534.

## Key Findings

* **Condition Premium:** New and refurbished items carry a significant price premium over used items, while scratches apply a predictable penalty.
* **Competition:** The number of bidders significantly increases the final price, but this effect is stronger for new items than used ones.
* **Reputation Threshold:** A high positive feedback percentage increases the price by approximately $0.08 per percentage point, but only if the seller has a feedback score over 100.
* **Quality Signaling:** The reserve price signals quality. This signaling effect is much stronger for used iPods (where quality is uncertain) than for new iPods (which are homogeneous).

## How to Run

1. Download the R script and the `ipod.xlsx` dataset.
2. Ensure both files are in the same working directory.
3. Install the required R packages if you do not have them.
4. Run the script in RStudio or your preferred R environment.

## Technologies

* R
* `readxl` (Data import)
* `car` (Hypothesis testing)
* `lmtest` (Diagnostic testing)

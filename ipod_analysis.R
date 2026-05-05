rm(list = ls())
cat("\014")

library(readxl)
library(car)
library(lmtest)

#  1: Data Preparation

data <- read_excel("ipod.xlsx")

color_table <- table(data$COLOR)
color_percent <- round(prop.table(color_table) * 100, 1)

data_filtered <- subset(data, 
                        COLOR %in% c(1, 3, 4, 5) &
                        MEMORY == 4 &
                        COND %in% c(1, 4, 5) &
                         DESCR %in% c(0, 1))

summary(data_filtered)

table(data_filtered$COLOR)
table(data_filtered$COND)
table(data_filtered$DESCR)

aggregate(PRICE ~ COND, data_filtered, mean)
aggregate(PRICE ~ COLOR, data_filtered, mean)

#  2: Basic Model

data_filtered$NEW <- ifelse(data_filtered$COND == 5, 1, 0)
data_filtered$REFUND <- ifelse(data_filtered$COND == 4, 1, 0)
data_filtered$SCRATCH <- ifelse(data_filtered$DESCR == 0, 1, 0)

model_1 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS, data = data_filtered)
summary(model_1)

cor(data_filtered$TIME, data_filtered$PRICE)
model_time <- lm(PRICE ~ TIME, data = data_filtered)
summary(model_time)

linearHypothesis(model_1, "NEW - 4*REFUND = 0")
coef(model_1)
coef(model_1)["NEW"] / coef(model_1)["REFUND"]

data_filtered$NEW_BIDRS <- data_filtered$NEW * data_filtered$BIDRS
model_1.1 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + NEW_BIDRS, 
             data = data_filtered)
summary(model_1.1)

resettest(model_1.1, power = 2:3, type = "fitted")

# 3: The Role of Color

model_2 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + COLOR, 
              data = data_filtered)
summary(model_2)

data_filtered$BLUE <- ifelse(data_filtered$COLOR == 3, 1, 0)
data_filtered$SILVER <- ifelse(data_filtered$COLOR == 4, 1, 0)
data_filtered$GREEN <- ifelse(data_filtered$COLOR == 5, 1, 0)

model_3 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + BLUE + SILVER + GREEN, 
              data = data_filtered)
summary(model_3)

linearHypothesis(model_3, c("BLUE = 0", "SILVER = 0", "GREEN = 0"))

# 4: Seller Reputation

data_filtered$HIGH_FEEDSCOR <- ifelse(data_filtered$FEEDSCOR > 100, 1, 0)
data_filtered$FEEDPERC_HIGH <- data_filtered$FEEDPERC * data_filtered$HIGH_FEEDSCOR
data_filtered$FEEDSCOR_ABOVE100 <- ifelse(data_filtered$FEEDSCOR > 100, 
                                          data_filtered$FEEDSCOR - 100, 
                                          0)
data_filtered$FEEDPERC_SCORE_ABOVE <- data_filtered$FEEDPERC * data_filtered$FEEDSCOR_ABOVE100

model_4 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + 
                          BLUE + SILVER + GREEN +
                          FEEDPERC + FEEDPERC_HIGH + FEEDPERC_SCORE_ABOVE,
                        data = data_filtered)

summary(model_4)

# 5: Reserve Price

model_5_base <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + 
                     BLUE + SILVER + GREEN +
                     FEEDPERC_HIGH,
                   data = data_filtered)

summary(model_5_base)
resettest(model_5_base)

model_5 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + 
                BLUE + SILVER + GREEN +
                FEEDPERC_HIGH +
                RESERV,
              data = data_filtered)

summary(model_5)
resettest(model_5)

cor(data_filtered$RESERV, data_filtered$BIDRS)
cor(data_filtered$RESERV, data_filtered$NEW)

# 6: Final Model

mean(data_filtered$BIDRS)
mean(data_filtered$FEEDPERC_HIGH)
mean(data_filtered$RESERV)

new_ipod <- data.frame(
  NEW = 1,
  REFUND = 0,
  SCRATCH = 0,
  BIDRS = mean(data_filtered$BIDRS),
  BLUE = 0,
  SILVER = 0,
  GREEN = 1,
  FEEDPERC_HIGH = mean(data_filtered$FEEDPERC_HIGH),
  RESERV = mean(data_filtered$RESERV)
)

predicted_price <- predict(model_5, newdata = new_ipod)
print(predicted_price)

predicted_interval <- predict(model_5, newdata = new_ipod, 
                              interval = "confidence", level = 0.95)
print(predicted_interval)


min_ipod <- data.frame(
  NEW = 0,           
  REFUND = 0,        
  SCRATCH = 1,       
  BIDRS = min(data_filtered$BIDRS),  
  BLUE = 0,
  SILVER = 1,        
  GREEN = 0,
  FEEDPERC_HIGH = 0, 
  RESERV = min(data_filtered$RESERV)
)

min_price <- predict(model_5, newdata = min_ipod)
print(min_price)

cat("Min BIDRS:", min(data_filtered$BIDRS), "\n")
cat("Min RESERV:", min(data_filtered$RESERV), "\n")

data_filtered$RESERV2 <- data_filtered$RESERV^2

model_6 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + 
                BLUE + SILVER + GREEN +
                FEEDPERC_HIGH +
                RESERV + RESERV2,
              data = data_filtered)

summary(model_6)
resettest(model_6)


data_filtered$LOG_RESERV <- log(data_filtered$RESERV + 1) # +1 kvůli RESERV=0.01

model_7 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + 
                BLUE + SILVER + GREEN +
                FEEDPERC_HIGH +
                LOG_RESERV,
              data = data_filtered)

summary(model_7)
resettest(model_7)

model_8 <- lm(PRICE ~ NEW + REFUND + SCRATCH + BIDRS + 
                 SILVER +
                 FEEDPERC_HIGH +
                 RESERV + NEW:RESERV,
               data = data_filtered)

summary(model_8)
resettest(model_8)

county_data <- read.csv("./county_data_final.csv")

model1 <- lm(unr_change2020 ~ Forgiven_loan_bil + 
                            Rural_loan_pct + 
                            I(Total_case/1e6), 
            data = county_data)

summary(model1)

model2 <- lm(unr_change2020 ~ Forgiven_loan_bil + 
                            Rural_loan_pct + 
                            I(Total_case/1e6) + 
                            unr_change2019,
            data = county_data)

summary(model2)

png("./output/intial_res_fitted.png")

plot(model2,1)

dev.off()

png("./output/intial_qq.png")

plot(model2,2)

dev.off()

y_trans <- function(x) log(x + (abs(min(x))) + 1)

model3 <- lm(y_trans(unr_change2020) ~ log(Forgiven_loan_bil) + 
                                    Rural_loan_pct + 
                                    log((Total_death/1e6) + 1) + 
                                    y_trans(unr_change2019),
            data = county_data)

summary(model3)

png("./output/final_res_fitted.png")

plot(model3,1)

dev.off()

png("./output/final_qq.png")

plot(model3,2)

dev.off()
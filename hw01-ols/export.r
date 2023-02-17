setwd("/Users/turx/Projects/machine-teaching-23sp/hw01-ols")
library(readxl)
library(tidyverse)
data <- read_excel("Data_Extract_From_World_Development_Indicators.xlsx")
data <- data %>%
    na_if("..") %>%
    rename(c_name = "Country Name", c_code = "Country Code", "2017" = "2017 [YR2017]", "2018" = "2018 [YR2018]") %>%
    pivot_longer(cols = paste(c(1990, 2000, c(2010:2019))), names_to = "year", values_to = "gdp") %>%
    filter(`Series Name` == "GDP (current US$)", `Series Code` == "NY.GDP.MKTP.CD") %>%
    select(-`Series Name`, -`Series Code`) %>%
    drop_na() %>%
    mutate(gdp = as.numeric(gdp), year = as.numeric(year)) %>%
    group_by(c_code)
usa <- data %>%
    filter(c_code == "USA") %>%
    ungroup() %>%
    select(year, gdp)
write.csv(usa, "RUIXUAN.csv")

ols_regression <- function(x, y) {
    x <- as.matrix(x)
    y <- as.matrix(y)
    m <- (mean(x * y) - mean(x) * mean(y)) / (mean(x^2) - mean(x)^2)
    b <- mean(y) - m * mean(x)
    return(list(m = m, b = b))
}
l_ols <- ols_regression(usa$year, usa$gdp)
write(paste("y = ", l_ols$m, "x + ", l_ols$b, sep = ""), "RUIXUAN_model.txt")

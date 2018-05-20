# Source: https://coinmetrics.io/data-downloads/

# Getting daily prices of a bunch of crypto currencies
library(readr)
library(dplyr)
library(stringr)
library(rebus)
library(lubridate)
library(corrplot)
setwd("pandas/datetime/raw_data")

combine_data <- function() {
  i <- 1
  for(file in list.files()) {
    dat <- read_csv(file) %>%
      select(date, `price(USD)`) %>%
      mutate(coin = str_remove(file, DOT %R% "csv"))
    name_coin <- unique(dat$coin)
    colnames(dat) <- c("date", paste0(toupper(name_coin), "_price"), "remove")
    dat <- dat %>% select(-one_of("remove"))
    if (i == 1) {
      join_data <- dat
    } else if (file == "btc.csv") {
      btc <- dat %>% mutate(date = as.Date(date, format = "%m/%d/%y"))
    } else {
      join_data <- merge(join_data, dat, by = "date", all = TRUE)
    }
    i <- i + 1
  }
  join_dat <- left_join(btc, join_data)
  return(join_dat)
}

final_data <- combine_data()
write_csv(final_data, "../crypto_prices.csv")

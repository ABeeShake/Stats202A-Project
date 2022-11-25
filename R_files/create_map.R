library(ggplot2)
library(tidyr)
library(dplyr)
library(optparse)
library(sf)
library(tmap)

option_list <- list(

    make_option(c('-d','--data'), type = "character", default = NULL,
    help = "dataset file name")

)

opt_parser <- OptionParser(option_list)

opt <- parse_args(opt_parser)

PPP_data <- 
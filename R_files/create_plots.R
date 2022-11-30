library(dplyr)
library(tidyr)
library(readr)
library(splancs)
library(maps)
library(MASS)
library(mapproj)

#Loading full Loan Level Dataset

PPP <- read_csv('./PPP_with_FIPS.csv')

system('R CMD SHLIB ./C_files/kde.c')

dyn.load('./C_files/kde.so')

#1D KDE function

kde <- function(x,m){

    x <- as.double(x)

    m <- as.integer(m)

    g <- as.double(seq(min(x),max(x),length.out = m))

    n <- as.integer(length(x))

    bw <- as.double(1.06 * min(sd(x),IQR(x)) * n^(-1/5))

    y <- double(m)

    a <- .C('KDE',n=n,m=m,x=x,g=g,y=y,bw=bw)

    return(a$y)

}

#KDE of Forgiven Amount and Total Amount

total <- PPP$CurrentApprovalAmount / 1e6
m <- 1000

est1 <- kde(total, m)

forgive <- PPP[!is.na(PPP$ForgivenessAmount),'ForgivenessAmount'] %>% 
    pull() / 1e6

est2 <- kde(forgive, m)

png("./output/approvalvsforgive_kde.png")

plot(c(min(total),max(total)), c(0,200),
type = 'n',
xlab = '$100k',
ylab = 'Density')
lines(seq(min(total),max(total),length.out = m), est1,
col = 'red')
lines(seq(min(forgive),max(forgive),length.out = m), est2,
col = 'blue')
title('KDE of Total Loan Amount and Forgiven Amount')
legend("topright",legend = c("Total Loan Amount",'Forgiven Amount'),
col = c('red','blue'),
lty = c(1,1))

dev.off()

rm(list = c("PPP", "total", "forgive", "est1", "est2"))

#Load Unemployment Data

unr <- read.csv("./unemployment_clean.csv", header = T)%>%
filter(!(is.na(X2019_q234.q1) | is.na(X2020_q234.q1) | is.na(X2021_q234.q1)))

#KDE of Unemployment by Year

unr_change2019 <- unr$`X2019_q234.q1`
unr_change2020 <- unr$`X2020_q234.q1`
unr_change2021 <- unr$`X2021_q234.q1`

est2019 <- kde(unr_change2019, m)
est2020 <- kde(unr_change2020, m)
est2021 <- kde(unr_change2021,m)

png("./output/change_unr_year.png")

plot(c(-10,10),c(0,4),
type = 'n',
xlab = 'Change in Unemployment Rate',
ylab = 'Density')
lines(seq(min(unr_change2019),max(unr_change2019),length.out=m),
est2019,
col = 'red')
lines(seq(min(unr_change2020),max(unr_change2020),length.out=m),
est2020,
col = 'blue')
lines(seq(min(unr_change2021),max(unr_change2021),length.out=m),
est2021,
col = '#067006')
legend("topright", legend = c("2019","2020","2021"),
col = c("red","blue","#067006"),
lty = c(1,1,1))
title("Change in Unemployment from Q2-4 to Q1")

dev.off()

rm(list = c("unr_change2019","unr_change2020","unr_change2021","est2019","est2020",'est2021'))

# Load Mapping Data

mapping <- read.csv("./mapping_data.csv", header = T) %>%
filter(!(BorrowerState %in% c('HI','PR','AK','AS','GU','VI'))) %>%
dplyr::select(lat,long)

# 2D KDE Loan Map

lat <- mapping$lat
long <- -1 * abs(mapping$long)

xy <- as.points(long,lat)

k <- MASS::kde2d(long, lat, n = m,
                lims = c(c(-125,-65), c(25,50)))

png("./output/loan_kde_map.png")

filled.contour(k,
plot.axes = {
    axis(1)
    axis(2)
    map('county','.', add=T)
},
col = hcl.colors(16,'spectral'),
xlim = c(-125,-65),
ylim = c(25,50),
)
title("Density of PPP Loans Across the US")

dev.off()

rm(list = c("mapping", "lat", "long", "k", "xy"))

# Load County Data

county_data <- read.csv("./county_data_final.csv")

# Kernel Regression

system('R CMD SHLIB ./C_files/kre.c')

dyn.load('./C_files/kre.so')

krg <- function(x,y,m, g = NULL, bw = NULL){

    x <- as.double(x)
    y <- as.double(y)

    n <- as.integer(length(x))
    m <- as.integer(m)

    
    if(is.null(g)){ 
        g <- as.double(seq(min(x),max(x),length.out = m))
    }

    if(is.null(bw)){
        bw <- as.double(1.06 * min(sd(x),IQR(x)) * n^(-1/5))
    }

    est <- double(m)

    a <- .C('NW_estimate', x=x,y=y,n=n,b=bw,g=g,m=m,est=est)

    return(a)

}

kern_reg <- function(x,y,m,g = NULL, bw = NULL, ci = F){

    r <- krg(x,y,m,g,bw)

    bw <- r$b
    g <- r$g
    estimate <- r$est

    if(ci == T){

        n <- length(x)

        res_mat <- matrix(nrow = m, ncol = 200)

        rownames(res_mat) <- paste0("m",1:m)

        for (i in 1:200){        

            indices <- sample(1:n, 2000, replace = T)

            x_samp <- x[indices]
            y_samp <- y[indices]

            a <- krg(x_samp,y_samp,m,g = g, bw = bw)

            res_mat[,i] <- a$est
        }

        conf_ints <- res_mat %>%
        apply(1,quantile, probs = c(.025, .975), na.rm = T) %>%
        t()

        return(list(est = estimate, conf_ints = conf_ints))
    }

    return(estimate)

}

# Create Kernel Regression Plots

y_trans <- function(x) log(x + (abs(min(x))) + 1)

x <- log(county_data$Forgiven_loan_bil)

y <- y_trans(county_data$unr_change2020)

bw <- sqrt(.25*bw.nrd(x)^2 + .25*bw.nrd(y)^2)

z <- kern_reg(x,y,1000,bw=bw,ci=T)

png("./output/unr_log_forgive.png")

plot(c(min(x),max(x)),
c(1.7,3.5),
type = 'n',
xlab = 'Log($ Forgiven (bil))',
ylab = 'Log(Change in Unemployment)')
lines(seq(min(x),max(x),length.out = 1000),
z$est,
col = 'red')
lines(seq(min(x),max(x),length.out = 1000),
z$conf_ints[,1],
col = 'blue')
lines(seq(min(x),max(x),length.out = 1000),
z$conf_ints[,2],
col = 'blue')
title("Log(Change in Unemployment) vs Log(Forgiven Loan Amount)")
legend("topright",legend = c("Kernel Regression", "Confidence Interval"),
col = c("red","blue"), lty = c(1,1))

dev.off()

x <- log((county_data$Total_death / 1e6)+1)

y <- y_trans(county_data$unr_change2020)

bw <- 5*sqrt(.25*bw.nrd(x)^2 + .25*bw.nrd(y)^2)

z <- kern_reg(x,y,1000,bw=bw,ci=T)

png("./output/unr_log_death.png")

plot(c(min(x),max(x)),
c(2.2,4),
type = 'n',
xlab = 'Log(2020 COVID Deaths (Mil))',
ylab = 'Log(Change in Unemployment)')
lines(seq(min(x),max(x),length.out = 1000),
z$est,
col = 'red')
lines(seq(min(x),max(x),length.out = 1000),
z$conf_ints[,1],
col = 'blue')
lines(seq(min(x),max(x),length.out = 1000),
z$conf_ints[,2],
col = 'blue')
title("Log(Change in Unemployment) vs Log(Total COVID Deaths)")
legend("topright",legend = c("Kernel Regression", "Confidence Interval"),
col = c("red","blue"), lty = c(1,1))

dev.off()

x <- county_data$Rural_loan_pct

y <- y_trans(county_data$unr_change2020)

bw <- .5*sqrt(.25*bw.nrd(x)^2 + .25*bw.nrd(y)^2)

z <- kern_reg(x,y,1000,bw=bw,ci=T)

png("./output/rural_unr.png")

plot(c(min(x),max(x)),
c(2,3),
type = 'n',
xlab = 'Rural Lending %',
ylab = 'Log(Change in Unemployment)')
lines(seq(min(x),max(x),length.out = 1000),
z$est,
col = 'red')
lines(seq(min(x),max(x),length.out = 1000),
z$conf_ints[,1],
col = 'blue')
lines(seq(min(x),max(x),length.out = 1000),
z$conf_ints[,2],
col = 'blue')
title("Log(Change in Unemployment) vs Rural Lending %")
legend("topright",legend = c("Kernel Regression", "Confidence Interval"),
col = c("red","blue"), lty = c(1,1))

dev.off()
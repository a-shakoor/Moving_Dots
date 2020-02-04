install.packages("Rcpp")
install.packages("dplyr")
library(dplyr)
library(ggplot2)
library(prospectr)
library(gridExtra)
library(ggpubr)
rawfile <- read.csv("C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Aly11-18-19/gaze_positions.csv")
eventtimes <- read.csv("C:/Users/ashaq/Documents/GitHub/Moving_Dots/Results/Aly11-18-19/EventTimes-18-Nov-2019_15-03-41.csv")


# Filter Confidence
rawfile <- filter(rawfile, rawfile$confidence > .8)
rawfiletrimmed <- rawfile[neededVar]

# Throw out first 5 trials
eventtimes <- filter(eventtimes, eventtimes$trial > 5)


# Get Trial Time Boundaries (on off of trial)
plotcounter = 1;
plots <- list()
#for(trial in eventtimes[[1]]) {
#  if(trial > 5 & trial < 50) {
  trial = 40
    thisTrial = eventtimes[trial,]
    singDotOnPupil = (thisTrial$cohOnSys + thisTrial$singDotOnAdj) - thisTrial$startSys + thisTrial$startPupil
    singDotOffPupil = (thisTrial$singDotOffAdj - thisTrial$singDotOnAdj) + singDotOnPupil
    neededVar <- c("gaze_timestamp", "norm_pos_x", "norm_pos_y")
    trialGaze <- filter(rawfiletrimmed, rawfiletrimmed[[1]] > singDotOnPupil 
                        & rawfiletrimmed[[1]] < singDotOffPupil)
    ggplot(data=trialGaze, aes(x=trialGaze$gaze_timestamp, y=trialGaze$norm_pos_x)) +
        geom_line() + 
        geom_point()
    # sg <- savitzkyGolay(X = trialGaze,1,1,3)
#    }
#}
# ggarrange(plotlist = plots)


###Run an ssanova on a dataframe with time points, F0 values, and some grouping variable (in this case, native language)
###Plot the modeled pitch contours with ribbons corresponding to 95% confidence intervals 
###Tuuli Morrill, January 2015

library(gss)
library(ggplot2)

### data frame here is called "scoop", read in from Praat output, with added column specifying grouping variable (in this case, native language)

### Normalize pitch by subject (in this case, "Filename")
scoop <- within(scoop, NormPitch <-ave(F0, Filename, FUN=function(x) scale(x, scale=FALSE)))
### Check contents of data frame
head(scoop)
levels(scoop$NativeLang)
summary(scoop)
### Convert time points to numeric format (for some reason they were not being read correctly from Praat output)
scoop$PointNumber <- as.numeric(as.character(scoop$PointNumber))

### Run ssanova with time point, native language, and interaction between the two
scoopmodel <- ssanova(NormPitch ~ PointNumber + NativeLang + PointNumber:NativeLang, data = scoop)

### Create modeled contours
grid <- expand.grid(PointNumber = seq(0,1000, length = 1000), NativeLang = c("Arabic", "English","Korean","Mandarin"))
grid$Pitch.Fit <- predict(scoopmodel, newdata = grid, se = T)$fit
grid$Pitch.SE <-predict(scoopmodel, newdata = grid, se = T)$se.fit

### Plot contours with ribbons - ggplot settings
theme_g<-theme(axis.title.x = element_text(face="bold", size=18, vjust = 0),
      axis.text.x  = element_text(angle = 0, hjust =0.4, vjust=1, size=18),
      axis.title.y = element_text(face="bold", size=18, vjust = 0.3),
      axis.text.y  = element_text(hjust = 0.4,vjust=0.3, size=18),
      plot.title = element_text(lineheight=1.0, size = 20, face="bold"),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line( size=.1, color="black" ))
      
### Insert text on plot
phrase = grobTree(textGrob("She can scoop", x=0.08,  y=0.1, hjust=0,
  gp=gpar(col="black", fontsize=12)))
phrase1 = grobTree(textGrob("these things", x=0.35,  y=0.1, hjust=0,
  gp=gpar(col="black", fontsize=12)))
phrase2 = grobTree(textGrob("into three red bags", x=0.58,  y=0.1, hjust=0,
  gp=gpar(col="black", fontsize=12)))
      
### Actual plot      
ggplot(grid, aes(x=PointNumber, colour = NativeLang))+ 
  geom_line(aes(y=Pitch.Fit), lwd = 1, alpha = 0.5)+ 
  geom_ribbon(aes(ymax = Pitch.Fit + (1.96*Pitch.SE), ymin = Pitch.Fit - (1.96*Pitch.SE), colour = NativeLang, fill = NativeLang), alpha = 0.5) +
   scale_color_manual(values=c("tan3","orchid4","skyblue4", "palegreen4"))+
   scale_fill_manual(values=c("tan3","orchid4","skyblue4", "palegreen4"))+
  xlab("Time")+
  ylab("Pitch (semitones)")+
  annotation_custom(phrase)+
  annotation_custom(phrase1)+
  annotation_custom(phrase2)+
  ggtitle("She can scoop these things into three red bags...")+
  theme_g
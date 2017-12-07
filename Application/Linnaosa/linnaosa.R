require("rgdal")
require("maptools")
require("ggplot2")
require("plyr")
library("rgeos")
#donwload and unzip file from maa-amet:
#http://geoportaal.maaamet.ee/est/Andmed-ja-kaardid/Haldus-ja-asustusjaotus-p119.html
#file that "Asustusüksus SHP" 
#read in file
eesti = readOGR(dsn= getwd(), layer="asustusyksus_20161201")
#get only linnaosa for Tallinn, otherwise too many points
linnaosa=eesti[eesti$TYYP==6&eesti$ONIMI=="Tallinn",]
#simple plot
plot(linnaosa)
#solve encoding issues:
linnaosa$ANIMI=gsub("Ć¤","ä",linnaosa$ANIMI)
linnaosa$ANIMI=gsub("Ćµ","õ",linnaosa$ANIMI)
linnaosa$ANIMI=gsub("Ć¼","õ",linnaosa$ANIMI)
#make it edible for ggplot, use name of linnaosa for id (variable ANIMI)
linnaosa@data$id = linnaosa@data$ANIMI
linnaosa.points = fortify(linnaosa, region="id")
linnaosa.df = join(linnaosa.points, linnaosa@data, by="id")
#random data to plot
randData=data.frame(linnaosa=unique(linnaosa$ANIMI), 
                    data=sample(c(1000:3000),
                                size=length(unique(unique(linnaosa$ANIMI)))))
#need centroids to plot data centre of linnaosa
tsentroidid = as.data.frame(gCentroid(linnaosa,byid=TRUE))
tsentroidid$linnaosa<-linnaosa$ANIMI
dataToPlot<-join(randData, tsentroidid)

#make data discrete
dataToPlot$dataDiscrete<-cut(dataToPlot$data, 
                             breaks=c(1000,1500,2000,2500,3000), 
                             labels=c("1000-1500","1500-2000", "2000-2500","2500-3000"))

#plot
p<-ggplot(dataToPlot, aes(fill=dataDiscrete))+
  geom_map(aes(map_id=linnaosa), map=linnaosa.df, color="black")+
  expand_limits(x=linnaosa.df$long, y=linnaosa.df$lat)+
  coord_fixed()+#keep lat and long fixed
  geom_text(aes(label=as.factor(data),x=x, y=y), data=dataToPlot)+
  #remove unecessay, drag legend to bottopm
  theme(axis.title=element_blank(), axis.text=element_blank(),line=element_blank(), panel.background=element_blank())+ 
  ggtitle("Random data for linnaosa")+ #paneme juurde nime
  scale_fill_brewer("Random data") +#little bit nicer colors
  annotate("text", x = 541400, y =6578473 , label = c("Map: Maa-amet, 01.12.2016"), size=3)
#save
ggsave(p, file="linnaosa.png", height=2, width=3, scale=3)


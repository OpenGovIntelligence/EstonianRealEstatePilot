data=read.csv("tallinn_business_registry_Tallinn_only_fixed.csv", sep=",")
#keep only address for geocoding
data=as.data.frame(as.character(data$Aadress.tekstina.kehtiv))

#geocode
#looping
base_url="http://inaadress.maaamet.ee/inaadress/gazetteer?address="
x_coord=c()
y_coord=c()
ads_oid=c()
for (i in 1:nrow(data)) {#takes a lot of time
  url=paste0(base_url, gsub(" ","%2C",data[i,1]))
  pars=content(GET(url), "parsed")
  if (length(pars)==0) {
    cat("Working on row",i, "no coordinates found", "\n")
    x_coord[i]=NA
    y_coord[i]=NA
    ads_oid[i]=NA
    next
  }
  x_coord[i]=pars$addresses[[1]]$viitepunkt_x
  y_coord[i]=pars$addresses[[1]]$viitepunkt_y
  ads_oid[i]=pars$addresses[[1]]$ads_oid
  cat("Working on row",i, "x: ", x_coord[i], "y: ",y_coord[i], "\n")
}

data2=as.data.frame(data[1:i,])
data2$x=x_coord
data2$y=y_coord
data2$ads_oid=ads_oid
#just in case save
write.table(data2, "data_geocoded.csv", sep=";", row.names=F)
saveRDS(object = data2, "geocoded.RDS")

#add to original dataset
original=read.csv("tallinn_business_registry_Tallinn_only_fixed.csv", sep=",")
original$x=x_coord
original$y=y_coord
original$ads_oid=ads_oid
write.table(original, "tallinn_business_registry_Tallinn_only_fixed_gecoded.csv", sep=";",
            row.names=F)

#mach with address data
tallinn=read.csv("tallinn_address_fixed.csv", sep=",")
#tallinn=tallinn[, c("Lat","Lon" ,"ADS_OID" ,"TAISAADRESS")]

#how many match in dataset
matcher=merge(tallinn, original, by.x="ADS_OID", by.y="ads_oid")
write.table(matcher,"tallinn_address_ehitisregister_merged.csv", sep=";",row.names=F)
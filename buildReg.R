buildReg=function(ticker,start,factors){
  ret=try(getSymbols(ticker,auto.assign=FALSE,from=as.Date(start)))
  if(class(ret)[1]=="try-error"){
    ##Catch error here with:
    #error handling later
    print("ah shit.")
    return("fuck")
  }else{
    ret=ret[,6]
    names(ret)[1]="price"
    ret$ret=NA
    for ( i in 2:nrow(ret)){
      ret$ret[i]=as.numeric(ret$price[i])/as.numeric(ret$pric[i-1])-1
    }
    ret=na.omit(ret$ret)
    
    out=(merge(ret,factors,all=c(TRUE,FALSE)))
    
    return(out)
  }
}
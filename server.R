library(shiny)
library(quantmod)
library(xts)
library(rugarch)
library(stargazer)
#Load a bunch of useful goodies. Gosh I LOVE stargazer...

shinyServer(function(input, output) {
  #The following code is static/non-reactive. Nothing fancy here
  source("buildReg.R")
  download.file("http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_daily.zip","factors.zip")
  
  factors=unz("factors.zip","F-F_Research_Data_Factors_daily.txt")
  factors=read.table(factors,header=TRUE,skip=4,fill=TRUE)
  n=nrow(factors)-1
  
  factors=unz("factors.zip","F-F_Research_Data_Factors_daily.txt")
  factors=read.table(factors,header=TRUE,skip=4,fill=TRUE,nrows=n)
  row.names(factors)=(as.Date(row.names(factors),format="%Y%m%d"))
  names(factors)[names(factors)=="Mkt.RF"]="MarketPremium"
  
  
  factors=as.xts(factors/100,dateFormat="Date")
  
  #Here buildReg returns an xts object that had adjusted
  #   reg=reactive({buildReg(ticker,start,factors)})
  
  reg=reactive({buildReg(input$ticker,input$dateRange[1],factors)[paste(input$dateRange[1],"/",input$dateRange[2],sep="")]})
  
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$ticker,'.csv', sep='')
    },
    content = function(con) {
      write.zoo(reg(),con,index.name="date")
    }
  )
  
  modelCAPM=reactive(lm(I(ret-RF)~MarketPremium,data=reg()))
  modelFF3=reactive(lm(I(ret-RF)~MarketPremium+SMB+HML,data=reg()))
  
  output$regTable <- renderPrint({
    #stargazer(model,dep.var.labels=ticker,type="text",title="Fama-French 3-Factor Model")
    
    
    stargazer(modelCAPM(),modelFF3(),dep.var.labels=input$ticker,type="html",title=paste("Factor Loadings from",range(index(reg()))[1],"to",range(index(reg()))[2],":"))
    
  })
  
  
  
  spec=ugarchspec(
    variance.model=list(
      model='sGARCH',
      garchOrder=c(1,1),
      submodel=NULL,
      external.regressors=NULL,
      variance.targeting=FALSE
    ),
    mean.model=list(
      armaOrder=c(0,0),
      include.mean=FALSE,
      archm=FALSE,
      archpow=0,
      arfima=FALSE,
      external.regressors=NULL,
      archex=FALSE
    ),
    distribution.model='sstd',
  )
  
  fit=reactive({ugarchfit(spec=spec,data=log(1+reg()$ret))})
    
  garchWhichPlot=reactive({
    switch(input$garchPlotType,
           "Seris with 1% VaR limites"=2,
           "QQ-Plot"=9
           )
  })
  
  output$garchPlot=renderPlot({
    plot(fit(),which=garchWhichPlot())
  })
  
})

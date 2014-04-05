
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Quick Quants"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    textInput(inputId="ticker",
              label="Enter the ticker of the stock you're interested in:",
              value="AAPL"
                ),
    helpText("Do you need to ",a("find your ticker",target="_blank",href="http://finance.yahoo.com/q?s=&ql=1"),"?"),
    dateRangeInput(inputId="dateRange",
              label="Get data starting from:",
              start=(Sys.Date()-365*2),
              min="1927-01-01",
              startview="decade"
              ),
    downloadButton(outputId="downloadData",label="Download Data"),
    helpText("Data sourced from Ken French's website."),
    downloadButton(outputId="downloadReport",label="Download Report"),
    helpText("The first results may take a while... as the monkey works to download and clean the required data... Things should be pretty smooth for any subsequent tickers. Some weird things happyen when the download button is clicked prematurely..."),
    img(src="monkey.jpg",height=180),
    br(),
    br(),
    br(),
    selectInput(inputId="garchPlotType",label="What do you want to see for the GARCH?",
                choices=list(
                  "Series with 1% VaR limites",
                  "QQ-Plot"
                  ),
                selected="Seris with 1% VaR limites",
                multiple=FALSE)
  ),
                                                                                                                                            
  # Show a plot of the generated distribution
  mainPanel(
    htmlOutput("regTable"),
    plotOutput("garchPlot")
  )
))



library(shiny)
library(plotly)
# Define UI for application 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Investment Simulator"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      h4("Place the amounts invested each year, you can either put a single number,
         for the same amount to be invested each year, 
         or a series of numbers separated by commas to change the amounts each year."),
      h6("Note: if your number of amounts you put in does not match the amount of years 
         invested, the number of years will update to the number of amounts"),
      textAreaInput("amounts","Amounts Per Year", value = "19000"),
      #' note, all text Area Inputs are as character, so expect to s
      #' see as.numeric throughout the server.R 
      br(),
      numericInput(inputId = "years",label = "Years to Invest",min = 1, max = 100,value = 8),
      br(),
      h4("Input the return rates (three percent would be 3 not 0.03), you can either put a single
         number, for the same growth rate each year, or a series of numbers separated
         by commas to change the return rates each year"),
      h6("Note: if your number of return rates does not match the amount of years invested,
         the average return rate will be used for all years"),
      textAreaInput("return.rates",label = "Return Rates", value = ""),
      br(),
      radioButtons("rateschoice","Choose Return Rates Method:",
                   c(
                     "Manual" = "Manual",
                     "Uniform" = "uniform",
                     "Gaussian" = "normal"
                   ),
                   selected = "Manual"),
      
      conditionalPanel("input.rateschoice == 'uniform'",
                       br(),
                         h4("Input a range of values for the return rates"),
                         h6("Note: consider the mean of your range, values will
                            be sampled with replacement"),
                        sliderInput("rates.unif.range",label = "Set Range of Rates",
                                    min = -20, max = 20, value = c(-6,18)) 
                       ),
      conditionalPanel("input.rateschoice == 'normal'",
                       br(),
                       h4("Select your mean and standard deviation for return rates"),
                       h6("Note: normally distributed, not truncated"),
                       numericInput("rates.normal.mean",label = "Set Mean",
                                    min = -10, max = 20, value = 6),
                       numericInput("rates.normal.sd",label = "Set Dtandard Deviation",
                                    min = -10, max = 20, value = 5)
                       ),
    actionButton("begin","Run")
    ),
    # Show 
    mainPanel(
      tabsetPanel(
       # tabPanel("Input Inspection",   
      #  textOutput("inspection")),      # see output$inspection
        tabPanel("Balance Growth",  
          plotlyOutput("balanceplot")
          ),
        tabPanel("Compound Interest",
          plotlyOutput("growthplot")      
                 ),
        tabPanel("Returns",
        dataTableOutput("annual.invest.vs.growth.difference")
        )
    )
  
))))

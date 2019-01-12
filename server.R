
library(shiny)
library(ggplot2)
library(ggthemes)

# Define server logic 
shinyServer(function(input, output,session){
   
  set.seed(4)
  #' seed is set for when the app opens. So that reproducibility is possible, 
  #' but not forced. 
  

  the.amounts <- reactive({ 
    temp. = c(as.numeric(unlist(strsplit(input$amounts,","))))
    #' splits the text by , converts to vector than changes to numeric type. 
    temp.
  })
    
  observeEvent(input$begin,{
    if(length(the.amounts) > 1){
  updateNumericInput(session = session, inputId = "years", value = length(the.amounts()))
  }
    })
  
  the.years <- reactive({ 
    as.numeric(input$years)
    #' should read as updated from the.amounts()
    })
  the.returns <- reactive({ 
    # conditional on choice of rate structure
    #' typically manually input, but can also be uniformly or normally distributed. 
    #' 
    
    if(input$rateschoice == "uniform"){
      #' if uniform, get the ranges from the conditional panel, and sample between them
      #' with replacement. 
      #' 
      conditional_return_rates = sample(input$rates.unif.range[1]:input$rates.unif.range[2],
                                        size = input$years,replace = TRUE)
    } else if(input$rateschoice == "normal"){
      #' if normal get the mean and standard deviation 
      conditional_return_rates  = rnorm(n = input$years, 
                                        mean = input$rates.normal.mean,
                                        sd = input$rates.normal.sd)
    } else{ 
      conditional_return_rates = as.numeric(input$return.rates)
      }
    
    conditional_return_rates
    })
  
  #output$inspection <- renderPrint({
  #  t = c(the.amounts(),the.years(),the.returns())
  #  s = sapply(t,class)
  #  print(c(t,s))
  #})  # used in dev to verify object classes were as expected. 
  
  balances.data <- eventReactive(input$begin, {
    #' takes all of the inputs and applies the invest function
    #' note, depending on rateschoice randomization may occur 
    #'
    #'
    temp. <- invest(amounts = the.amounts(),
                    years = the.years(),return = the.returns())
    #' returns a vector of balances, which calculations will be performed on
    #' including diff(), to compare to amounts invested. 
    
    x <- data.frame(years = 1:length(temp.), 
               balance = round(temp.,2),
               invested = round(the.amounts(),2),
               annual_change = c(
                 NA, # will be swapped with actual first year annual change
                 round(diff(temp.),2) # difference
               ))
    x$annual_change[1] <- x$balance[1]
        # fixing the missing value to be the growth from $0 to year 1 balance. 
    
    x # output x 
  })
  
  output$balanceplot <- renderPlotly({
    temp. = balances.data()
    #' I do this to ensure $ [] and [[]] work on reactive object 
    
    g <- ggplot(data = temp., aes(x = years, y = balance)) + geom_point() + geom_line()
     # geom_line(aes(colour = "a"))
          # base plot, years versus balance with points and lines 
    g <- g + geom_line(data = temp., aes(x = years, y = cumsum(invested))) #,colour = "b"))
    g <- g  # + scale_colour_manual(name = "",
            #                  values = c("a" = "green4", "b" = "black"),
             #                 labels = c("Growth of Total Balance",
               #                          "Inflation Only Comparison"))
    g <- g + theme_economist()
    
    #' plotly does not retain aes mapping. So some traces are required 
    #convert to plotly object with economist theme
    # had to comment out everything related to scale_colour_manual 
    # leaving in the code for future update where scale can be passed through to 
    # ggplotly() 
    
    p <- ggplotly(g,tooltip = c("balance","invested"))
    p <- layout(p, showlegend = TRUE)
    p <- add_trace(p = p, data = temp., x =~years, y =~balance, mode = "lines",
                   name = "Growth of Total Balance",showlegend = TRUE)
    p <- add_trace(p = p, data = temp., x =~years, y=~cumsum(invested), mode = "lines",
                   name = "Inflation Only Comparison",showlegend = TRUE)
    
    #  print as plotly
    config(p,collaborate = FALSE,cloud = FALSE,displaylogo = FALSE,
           modeBarButtonsToRemove = c("zoom2d","pan2d","select2d","lasso2d",
                                      "zoomIn2d","zoomOut2d","autoScale2d",
                                     "hoverCompareCartesian","toggleHover","toggleSpikelines"))
    
    })
  
  output$growthplot <- renderPlotly({ 
    temp. = balances.data()
    g <- ggplot(data = temp., aes(x = years, y = invested)) + geom_line()
    # add a line for the amounts invested each year, may be horizontal. 
    g <- g + geom_line(data = temp., aes(x = years, y = annual_change))
    # add line for annual balance changes, may be below invested line for rough years. 
    g <- g + theme_economist()
    
    #' plotly does not retain aes mapping. So some traces are required 
    #convert to plotly object with economist theme
    # had to comment out everything related to scale_colour_manual 
    # leaving in the code for future update where scale can be passed through to 
    # ggplotly() 
    
    p <- ggplotly(g,tooltip = NULL)
    p <- layout(p, showlegend = TRUE)
    p <- add_trace(p = p, data = temp., x =~years, y =~invested, mode = "lines+markers",
                   name = "Amount Invested", showlegend = TRUE)
    p <- add_trace(p = p, data = temp., x =~years, y=~annual_change, mode = "lines+markers",
                   name = "Portfolio Change",showlegend = TRUE)
    
    #  print as plotly
    config(p,collaborate = FALSE,cloud = FALSE,displaylogo = FALSE,
           modeBarButtonsToRemove = c("zoom2d","pan2d","select2d","lasso2d",
                                      "zoomIn2d","zoomOut2d","autoScale2d",
                                      "hoverCompareCartesian","toggleHover","toggleSpikelines"))
    
    })
  
  output$annual.invest.vs.growth.difference <- renderDataTable({ 
    temp. <- balances.data()
    
    })
  
})





#' Functions used below 
#' 
#' 
#' 
#' 

invest <- function(amounts, years, return){
  #' This function takes either a single amount or an array of amounts 
  #  a single number of years
  #  and either a single return rate or an array of return rates
  #' (array lengths should be == to years or they will be mutated)
  #' and calculates the total amount of money after investing each amount 
  #' each year at each return rate
  #' #use whole numbers as the return rate, they will be made percent in function  
  if (length(amounts) != years){ 
    amounts = rep(amounts[1], years)
  }
  if(length(return) != length(amounts) | length(return) != years){ 
    return = rep(mean(return), years)
  }
  
  # start with 0 invested 
  invested = 0
  balance = NULL
  for(i in 1:years){ 
    # each year add your invested and new amount  and grow them 
    invested =  invested*(1+return[i]/100) + amounts[i]*(1+return[i]/100)
    balance = c(balance, invested)
  }
  return(balance)
}





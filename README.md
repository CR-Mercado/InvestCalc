# InvestCalc
Calculates investment streams with changing amounts and interest rates. 


# Design 

Allows for selection of 3 parameters: 

## Amounts 
The amount can be a single number (i.e. 19,000 the 2019 IRS 401k tax deferred limit) that will be repeated for every year, or it can be a stream of amounts, such as:  19,19,19,19,19,0,0,0,0,0 to identify how 5 years of payments grow in 10 years total, or similar. 

## Years 
The Years is set to how many years the investment(s) will grow - note: if the number of amounts > 1, then years will automatically update to match. So in the previous example, 5 amounts across 10 years would require 5 zeroes at the end. 

## Return Rates 
Return rates can be done in 3 ways: 

### Manual 
You put in the return rates, a single value will be repeated for all years or more than 1 value will be positionally matched to the i'th amount and i'th year. If the number of return rates does not equal the number of years, the average of the return rates will be used for all years instead. 

### Uniform 
Return rates will be drawn from a uniform distribution - selecting this radio button will open a conditional panel to select the range. Note: they are sampled with replacement. 

### Guassian
Return rates will be drawn from a normal distribution - selecting this radio button will open a conditional panel to select the mean and standard deviation. 

# Plots 
Two plots are generated:

## Balance Growth vs Inflation
A simple chart of years vs the balance, with a 0% (real) return rate line added for comparison.  

## Annual Change vs Investment
A simple chart of years vs annual change (the difference between balances) with the investments added. When annual change is less than invested amount, then a loss has occured in excess of the investment. 

# Table
The data is shown in the last tab. 

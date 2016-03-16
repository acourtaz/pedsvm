function out = Monthly(Princip,interest,quarterly,numb)

%calculates the monthly payment for a loan
%of sum P, with annual interest i
%with q payments per year for n years

out = (Princip*interest)/(quarterly*(1-((1+(interest/quarterly))^(-numb*quarterly))));


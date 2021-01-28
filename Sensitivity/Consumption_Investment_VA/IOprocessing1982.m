%{
NOTE: 
Data files are fixed format ASCII files.  Dollar values represent
100,000's of dollars at producers' prices.  Coefficients are
shown to seven places.  However, decimal points do not appear
explicitly in the file.
%}
%--------------------------------------------------------------------------
%% Set the Working Directory
clc
clear all

%Set the Working Directory
cd 'C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud\Sensitivity\Consumption_Investment_VA\2digit_tables1982/'

%--------------------------------------------------------------------------
%% Import the Industry (row) by Commodity (column) Total Requirements Table
all                                     = readtable('ndn0125/82-2dall.xlsx','ReadVariableNames',false);
temp                                    = all{1:end,3:end};
temp(isnan(temp))                       = 0;
all{1:end,3:end}                        = temp;

clearvars A temp

all.Properties.VariableNames{1}         = 'RowCode'  ;
all.Properties.VariableNames{2}         = 'ColCode' ; 
all.Properties.VariableNames{3}         = 'Use' ; 
all.Properties.VariableNames{4}         = 'Make' ; 
all.Properties.VariableNames{5}         = 'Margins' ; 
all.Properties.VariableNames{6}         = 'TranspMargins' ; 
all.Properties.VariableNames{7}         = 'SaleMargins' ; 
all.Properties.VariableNames{8}         = 'blank' ; 
all.Properties.VariableNames{9}         = 'CxIDR' ; 
all.Properties.VariableNames{10}         = 'NonscrapCoef' ; 
all.Properties.VariableNames{11}        = 'CxITransCoef' ; 
all.Properties.VariableNames{12}        = 'CxCDR' ;
all.Properties.VariableNames{13}        = 'CxCTR' ;
all.Properties.VariableNames{14}        = 'IxCTR' ;

%all.RowCode                             = categorical(all.RowCode);
%all.ColCode                             = categorical(all.ColCode);

IxCTR                                   = table(all.RowCode,all.ColCode,all.IxCTR);
IxCTR.Properties.VariableNames{1}       = 'IndustryCode' ;
IxCTR.Properties.VariableNames{2}       = 'CommodityCode';
IxCTR.Properties.VariableNames{3}       = 'ReqCoef';

IxCTR.ReqCoef                           = IxCTR.ReqCoef/10000000;

IxCTR                                   = unstack(IxCTR,'ReqCoef','CommodityCode','GroupingVariable','IndustryCode');
IxCTR                                   = sortrows(IxCTR);
temp                                    = IxCTR{:,2:end};
temp(isnan(temp))                       = 0;
IxCTR{1:end,2:end}                      = temp;
clearvars temp ans
%--------------------------------------------------------------------------
%% Build the Use Matrix
IO_use                                  = table(all.RowCode,all.ColCode,all.Use);
IO_use.Properties.VariableNames{1}      = 'CommodityCode';
IO_use.Properties.VariableNames{2}      = 'IndustryCode';
IO_use.Properties.VariableNames{3}      = 'InputUse';

IO_use                                  = unstack(IO_use,'InputUse','IndustryCode','GroupingVariable','CommodityCode');
IO_use.Properties.RowNames              = string(IO_use.CommodityCode);
IO_use.CommodityCode                    = categorical(IO_use.CommodityCode);
IO_use_commodities                      = IO_use.CommodityCode; 
IO_use_commodities                      = cellstr(IO_use_commodities);

temp                                    = IO_use{:,2:end};
temp(isnan(temp))                       = 0;
IO_use{1:end,2:end}                     = temp;
 
IO_use                                  = sortrows(IO_use);
clearvars temp ans

tot_pce                                 = sum(IO_use.x91);
tot_pfi                                 = sum(IO_use.x92);

tio                                     = sum(IO_use{1:end,2:86});
tva                                     = IO_use{'88',2:86}+IO_use{'89',2:86}+IO_use{'90',2:86};

drop_rows                               = {'88','89','90'};
IO_use(drop_rows,:)                     = [];

%% ------------------------------------------------------------------------
%Obtain the final consumption vector: row "i" contains final consumption of
%commodity "i"
exp                                       = IO_use(:,{'CommodityCode','x91','x92'});
exp.Properties.VariableNames{2}           = 'PersonalConsumptionExpenditures';
exp.Properties.VariableNames{3}           = 'PrivateFixedInvestment';

%% Do the Final Calculations
va_share                                  = tva./tio;
va_share(isnan(va_share))                 = 0;
%va_share                                  = IO_use{'tva',2:end}./IO_use{'tio',2:end};

plot(1:size(va_share,2),va_share)

%Construct a diagonal matrix <v> with VA shares in the diagonal and zeros
%otherwise
v                                         = diag(va_share);
R                                         = IxCTR{1:85,2:86};

ec                                        = v*R*exp{:,2};
ei                                        = v*R*exp{:,3};

sum(ec)/tot_pce
sum(ei)/tot_pfi

%% ------------------------------------------------------------------------
% Build a Table Containing the Final Data. 
Final_Expenditures_VA                                = IxCTR ;
Final_Expenditures_VA(:,2:end)                       = []; 
Final_Expenditures_VA(86:end,:)                      = []; 

Final_Expenditures_VA.Consunmption_VA                = ec;
Final_Expenditures_VA.Investmet_VA                   = ei;

clearvars -except Final_Expenditures_VA

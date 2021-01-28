%--------------------------------------------------------------------------
%% Set the Working Directory
clc
clear all

%Set the Working Directory
cd 'C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud\Sensitivity\Consumption_Investment_VA\2digit_tables1987\'

%--------------------------------------------------------------------------
%% Import the Industry (row) by Commodity (column) Total Requirements Table
IxCTR                                     = readtable('ndn0019/IXCTR.xlsx','Format','auto','ReadVariableNames',false);
IxCTR.Properties.VariableNames{1}         = 'IndustryCode'  ;
IxCTR.Properties.VariableNames{2}         = 'CommodityCode' ; 

IxCTR.IndustryCode                        = categorical(IxCTR.IndustryCode);
IxCTR.CommodityCode                       = categorical(IxCTR.CommodityCode);

IxCTR.Properties.VariableNames{3}         = 'TabRefNumber'; 
IxCTR.Properties.VariableNames{4}         = 'TRCoef';           %Total Requirements Coefficients
%IxCTR.TRCoef                              = str2double(IxCTR.TRCoef);

IxCTR.TabRefNumber                        = [];

IxCTR                                     = unstack(IxCTR,'TRCoef','CommodityCode','GroupingVariable','IndustryCode');
TR_industries                             = IxCTR.IndustryCode;
TR_industries                             = cellstr(TR_industries);
TR_commodities                            = IxCTR.Properties.VariableNames(2:end)';
%--------------------------------------------------------------------------
%% Build the Use Matrix
IO_use                                    = readtable('ndn0019/IOUSE.xlsx','Format','auto','ReadVariableNames',false);

IO_use.Properties.VariableNames{1}        = 'CommodityCode';
IO_use.Properties.VariableNames{2}        = 'IndustryCode'; 
IO_use.Properties.VariableNames{3}        = 'TabRefNumber'; %Table 2.--The Use of Commodities by Industries IO definition
IO_use.Properties.VariableNames{4}        = 'InputUse'; 

IO_use_full                               = IO_use;

IO_use                                    = unstack(IO_use,'InputUse','IndustryCode','GroupingVariable','CommodityCode');
IO_use.Properties.RowNames                = IO_use.CommodityCode;
IO_use.CommodityCode                      = categorical(IO_use.CommodityCode);
IO_use_commodities                        = IO_use.CommodityCode; 
IO_use_commodities                        = cellstr(IO_use_commodities);

tot_pce                                   = sum(IO_use.x91);
tot_pfi                                   = sum(IO_use.x92);

tio                                       = sum(IO_use{2:100,2:95});
tva                                       = IO_use{'88',2:95}+IO_use{'89',2:95}+IO_use{'90',2:95};

drop_rows                                 = {'88','89','90'};
IO_use(drop_rows,:)                       = [];

%% ------------------------------------------------------------------------
%Obtain the final consumption vector: row "i" contains final consumption of
%commodity "i"
exp                                       = IO_use(:,{'CommodityCode','x91','x92'});
exp.Properties.VariableNames{2}           = 'PersonalConsumptionExpenditures';
exp.Properties.VariableNames{3}           = 'PrivateFixedInvestment';

%% Do the Final Calculations
va_share                                  = tva./tio;
va_share(isnan(va_share))                 = 0;
va_share(isinf(va_share))                 = 0;


plot(1:size(va_share,2),va_share)

%Construct a diagonal matrix <v> with VA shares in the diagonal and zeros
%otherwise
v                                         = diag(va_share);
R                                         = IxCTR{:,2:97};

ec                                        = v*IxCTR{:,2:end}*exp{:,2};
ei                                        = v*IxCTR{:,2:end}*exp{:,3};

sum(ec)/tot_pce
sum(ei)/tot_pfi

%% ------------------------------------------------------------------------
% Build a Table Containing the Final Data. 
Final_Expenditures_VA                     = IxCTR ;
Final_Expenditures_VA(:,2:end)            = []; 

Final_Expenditures_VA.Consunmption_VA     = ec;
Final_Expenditures_VA.Investmet_VA        = ei;

clearvars -except Final_Expenditures_VA

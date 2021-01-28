%--------------------------------------------------------------------------
%% Set the Working Directory
clc
clear all

%Set the Working Directory
cd 'C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud\Sensitivity\Consumption_Investment_VA\2digit_tables1992\'

%--------------------------------------------------------------------------
%% Import the Industry (row) by Commodity (column) Total Requirements Table
IxCTR                                     = readtable('ndn0180/IXCTR.txt','Format','auto','ReadVariableNames',false);
IxCTR.Properties.VariableNames{1}         = 'IndustryCode'  ;
IxCTR.Properties.VariableNames{2}         = 'CommodityCode' ; 

IxCTR.IndustryCode                        = categorical(IxCTR.IndustryCode);
IxCTR.CommodityCode                       = categorical(IxCTR.CommodityCode);

IxCTR.Properties.VariableNames{3}         = 'TabRefNumber'; 
IxCTR.Properties.VariableNames{4}         = 'TRCoef';           %Total Requirements Coefficients
%IxCTR.TRCoef                              = str2double(IxCTR.TRCoef);

IxCTR.TabRefNumber                        = [];

%Reshape the Vector to Obtain the Total Requirements Matrix (Industry rows, Commodity Columns)
IxCTR_inv_temp                            = unstack(IxCTR,'TRCoef','IndustryCode','GroupingVariable','CommodityCode');
TR_commodities                            = IxCTR_inv_temp.CommodityCode;
TR_commodities                            = cellstr(TR_commodities);

clearvars IxCTR_inv_temp

IxCTR                                     = unstack(IxCTR,'TRCoef','CommodityCode','GroupingVariable','IndustryCode');
TR_industries                             = IxCTR.IndustryCode;
TR_industries                             = cellstr(TR_industries);

%--------------------------------------------------------------------------
%% Build the Use Matrix
IO_use                                    = readtable('ndn0180/IOUSE.txt','Format','auto');
IO_use.Properties.VariableNames{1}        = 'CommodityCode';
IO_use.Properties.VariableNames{2}        = 'IndustryCode'; 
IO_use.Properties.VariableNames{3}        = 'TabRefNumber'; %Table 2.--The Use of Commodities by Industries IO definition
IO_use.Properties.VariableNames{4}        = 'InputUse'; 
IO_use.Properties.VariableNames{5}        = 'MargTranspCosts'; 

IO_use_full                               = IO_use;

%Convert the data into a matrix with Commodities en the rows and Industries
%in the columns.
IO_use_inv_temp                           = unstack(IO_use,'InputUse','CommodityCode','GroupingVariable','IndustryCode');

IO_use_inv_temp.IndustryCode              = categorical(IO_use_inv_temp.IndustryCode);
IO_use_industries                         = IO_use_inv_temp.IndustryCode; 
IO_use_industries                         = cellstr(IO_use_industries);

clearvars IO_use_inv_temp

IO_use                                    = unstack(IO_use,'InputUse','IndustryCode','GroupingVariable','CommodityCode');
IO_use.Properties.RowNames                = IO_use.CommodityCode;
IO_use.CommodityCode                      = categorical(IO_use.CommodityCode);
IO_use_commodities                        = IO_use.CommodityCode; 
IO_use_commodities                        = cellstr(IO_use_commodities);

tot_pce                                   = sum(IO_use.x91);
tot_pfi                                   = sum(IO_use.x92);
%% ------------------------------------------------------------------------
%Obtain the final consumption vector: row "i" contains final consumption of
%commodity "i"
exp                                       = IO_use(:,{'CommodityCode','x91','x92'});
exp.Properties.VariableNames{2}           = 'PersonalConsumptionExpenditures';
exp.Properties.VariableNames{3}           = 'PrivateFixedInvestment';
%--------------------------------------------------------------------------
droprows_ind                              = setdiff(IO_use_industries,TR_industries)
droprows_com                              = setdiff(IO_use_commodities,TR_commodities)

exp(droprows_com,:)                       = [];
%--------------------------------------------------------------------------
%% Import Industry Labels (I have converted the .txt file into .xlsx to import it more easily)
IO_use_labels                             = readtable('ndn0180/io-code.xlsx','ReadVariableNames',false);
IO_use_labels.Properties.VariableNames{1} = 'CommodityCode';
IO_use_labels.Properties.VariableNames{2} = 'CommodityLabel'; 
IO_use_labels_commodities                 = IO_use_labels.CommodityCode;       
IO_use_labels.Properties.RowNames         = IO_use_labels.CommodityCode;
IO_use_labels.CommodityCode               = categorical(IO_use_labels.CommodityCode);
IO_use_labels.CommodityLabel              = categorical(IO_use_labels.CommodityLabel);

IO_use_labels_all                         = IO_use_labels;

IO_use_labels(droprows_ind,:)             = [];

IO_use                                    = join(IO_use_labels,IO_use,'Keys','CommodityCode');
IO_use(:,'CommodityCode')                 = [];

clearvars droprows IO_use_labels_vars IO_use_vars

%Compute Total Industry Output; Create a Numeric Variable to Store it and
%Add it to the Table
tio                                       = sum(IO_use{2:end,2:end});
tva                                       = IO_use{'88',2:end}+IO_use{'89',2:end}+IO_use{'90',2:end};

IO_use.CommodityLabel(end+1)              = 'Total Value Added';
IO_use.Properties.RowNames{end}           = 'tva';
IO_use{end,2:end}                         =  tva;

IO_use.CommodityLabel(end+1)              = 'Total Industry Output';
IO_use.Properties.RowNames{end}           = 'tio';
IO_use{end,2:end}                         =  tio;

%--------------------------------------------------------------------------
%% Drop Columns that do not have correspondence in TR table (using info in droprows_ind)
IO_use(:,strcat('x',droprows_ind))        = [];
%--------------------------------------------------------------------------
%% Do the Final Calculations
va_share                                  = IO_use{'tva',2:end}./IO_use{'tio',2:end};

i = 1:size(va_share,2);
plot(i,va_share)

%Construct a diagonal matrix <v> with VA shares in the diagonal and zeros
%otherwise
v                                         = diag(va_share);
R                                         = IxCTR{:,2:end};

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


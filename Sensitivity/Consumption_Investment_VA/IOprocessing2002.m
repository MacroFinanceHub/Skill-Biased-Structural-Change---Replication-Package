%--------------------------------------------------------------------------
%% Set the Working Directory
clc
clear all

%Set the Working Directory
cd 'C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud\Sensitivity\Consumption_Investment_VA\summarytables2002\'

%--------------------------------------------------------------------------
%% Import the Industry (row) by Commodity (column) Total Requirements Table
IxCTR                              = readtable('2002_Requirements_summary.xlsx','Sheet','IndByCom TR','Range','A5:EF138','Format','auto');

IxCTR.Properties.VariableNames{2}  = 'IndustryName';
IxCTR.Properties.VariableNames{1}  = 'IndustryCode';
IxCTR.Properties.RowNames          = IxCTR.IndustryCode;

ComCode_IxCTR                      = IxCTR.Properties.VariableNames(:,3:end)';
IndCode_IxCTR                      = IxCTR.IndustryCode;

IxCTR.IndustryCode                 = categorical(IxCTR.IndustryCode);
IxCTR.IndustryName                 = categorical(IxCTR.IndustryName);

IxCTR.IndustryCode                 = [];
% 133 Indsutries and 134 Commodities

%--------------------------------------------------------------------------
%% Import the Use Table at the Summary Level
IO_use                             = readtable('2002_IOMakeUse_summary.xlsx','Sheet','NAICSUseSummary','Range','A5:EH147','Format','auto');
IO_use.Properties.VariableNames{2} = 'CommodityName';
IO_use.Properties.VariableNames{1} = 'CommodityCode';
IO_use.Properties.RowNames         = IO_use.CommodityCode;
drop_match_TR                      = {' S003',' S009'};

IO_use(drop_match_TR,:)            = [];
B                                  = IO_use{1:140,3:135};
B                                  = B./B(140,:);
tot_pce                            = IO_use.F010(end);
tot_pfi                            = IO_use.F020(end);
B                                  = B(1:134,:); %134 x 133

ComCode_Use                        = IO_use.CommodityCode; 
IO_use.CommodityName               = categorical(IO_use.CommodityName);

%% Import the Make Table at the Summary Level
IO_make                            = readtable('2002_IOMakeUse_summary.xlsx','Sheet','NAICSMakeSummary','Range','A5:EF139');
W                                  = IO_make{2:end,3:end};
W                                  = W./W(134,:);
W(134,:)                           = [];

IO_use.Properties.VariableNames{2} = 'CommodityName';
IO_use.Properties.VariableNames{1} = 'CommodityCode';

ComCode_Use                        = IO_use.CommodityCode; 
IO_use.Properties.RowNames         = IO_use.CommodityCode;

IO_use.CommodityName               = categorical(IO_use.CommodityName);
%--------------------------------------------------------------------------
%Obtain the Final Consumption and Final Investment Vector: row "i" contains 
%final consumption/investment of commodity "i"

exp                                = IO_use(:,{'CommodityCode','CommodityName','F010','F020'});
exp.Properties.VariableNames{3}    = 'PersonalConsumptionExpenditures';
exp.Properties.VariableNames{4}    = 'PrivateFixedInvestment';

dropvars                           = {'T005','T006','T008',' V001',' V002',' V003'};
exp(dropvars,:)                    = [];

plot(1:1:size(exp,1),exp{1:end,end})

IO_use.T001                        = [];
IO_use.F010                        = [];
IO_use.F020                        = [];

TIO                                = IO_use(IO_use.CommodityName == 'Total industry output',:);
VA                                 = IO_use(IO_use.CommodityName == 'Total value added'    ,:);

%Build VA share of Total Output by Industry (133 Industries)
va_share                           = VA{:,3:end}./TIO{:,3:end};
plot(1:1:133,va_share)

%Construct a diagonal matrix <v> with VA shares in the diagonal and zeros
%otherwise
v                                 = diag(va_share);
%--------------------------------------------------------------------------
ec                                = v*IxCTR{1:end,2:end}*exp{1:end,3};
ei                                = v*IxCTR{1:end,2:end}*exp{1:end,4};

% Check if Total Match the Total in the IO Matrix
sum(ec)/tot_pce %0.9964
sum(ei)/tot_pfi %0.9886

%Check that the Total Requirements Matrix is Equivalent to the one
%Constructed using the Normalized Make and Use Tables
R_check                           = W*inv(eye(134,134) - B*W); % -> Perfect!
ec_alt                            = v*R_check*exp{1:end,3};

ec_alt                            = v*R_check*exp{1:end,3};
sum(ec_alt)/tot_pce

%% ------------------------------------------------------------------------
% Build a Table Containing the Final Data. 
Final_Expenditures_VA                     = IxCTR ;
Final_Expenditures_VA(:,2:end)            = []; 

Final_Expenditures_VA.Consunmption_VA     = ec;
Final_Expenditures_VA.Investmet_VA        = ei;

clearvars -except Final_Expenditures_VA

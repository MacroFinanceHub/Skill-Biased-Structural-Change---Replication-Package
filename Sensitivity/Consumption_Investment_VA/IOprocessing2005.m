%--------------------------------------------------------------------------
%% Set the Working Directory
clc
clear all

%Set the Working Directory
cd 'C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud\Sensitivity\Consumption_Investment_VA\summarytables2005\'

%--------------------------------------------------------------------------
%% Import the Industry (row) by Commodity (column) Total Requirements Table
IxCTR                              = readtable('IxC_TR_2005_AR_PROD_SUM.xls','Sheet','2005_alt','Range','A6:BW77','Format','auto');


IxCTR.Properties.VariableNames{2}  = 'IndustryName';
IxCTR.Properties.VariableNames{1}  = 'IndustryCode';
IxCTR.Properties.RowNames          =  IxCTR.IndustryCode;

ComCode_IxCTR                      = IxCTR.Properties.VariableNames(:,3:end)';
IndCode_IxCTR                      = IxCTR.IndustryCode;

IxCTR.IndustryCode                 = categorical(IxCTR.IndustryCode);
IxCTR.IndustryName                 = categorical(IxCTR.IndustryName);

IxCTR.IndustryCode                 = [];
% 71 Indsutries and 73 Commodities

%--------------------------------------------------------------------------
%% Import the Use Table at the Summary Level
IO_use                             = readtable('IO_Use_2005_AR_PROD_SUM.xls','Sheet','2005_alt','Range','A6:CV89','TreatAsEmpty',{'...'},'Format','auto');

%IO_use{1:end,3:end}(isnan(IO_use{1:end,3:end})) = 0;

IO_use.Properties.VariableNames{2} = 'CommodityName';
IO_use.Properties.VariableNames{1} = 'CommodityCode';
%IO_use.Properties.RowNames         = IO_use.CommodityCode;

B                                  = IO_use{1:83,3:96};
B                                  = B./B(83,:);
B(isnan(B))                        = 0;
B(isinf(B))                        = 0;
tot_pce                            = IO_use.F010(83); 
tot_pfi                            = IO_use.F02S(83)+IO_use.F02E(83)+IO_use.F02N(83)+IO_use.F02R(83);
B                                  = B(1:71,1:71); %71x94

ComCode_Use                        = IO_use.CommodityCode; 
IO_use.CommodityName               = categorical(IO_use.CommodityName);

%% Import the Make Table at the Summary Level
IO_make                            = readtable('IO_Make_2005_AR_PROD_SUM.xls','Sheet','2005_alt','Range','A6:BX78','TreatAsEmpty',{'...'},'Format','auto');
IO_make{1:end,3:end}(isnan(IO_make{1:end,3:end})) = 0;
 
W                                  = IO_make{1:end,3:73};
W                                  = W./W(72,:);
W(isnan(W))                        = 0;
W(end,:)                           = [];

IO_use.Properties.VariableNames{2} = 'CommodityName';
IO_use.Properties.VariableNames{1} = 'CommodityCode';

ComCode_Use                        = IO_use.CommodityCode; 
%IO_use.Properties.RowNames         = IO_use.CommodityCode;

IO_use.CommodityName               = categorical(IO_use.CommodityName);
%--------------------------------------------------------------------------
%Obtain the Final Consumption and Final Investment Vector: row "i" contains 
%final consumption/investment of commodity "i"

exp                                = IO_use(:,{'CommodityCode','CommodityName','F010','F02E','F02N','F02R'});
exp{1:end,3:end}(isnan(exp{1:end,3:end})) = 0 
exp.TInv                           = exp.F02E + exp.F02N + exp.F02R

exp.Properties.VariableNames{3}    = 'PersonalConsumptionExpenditures';
exp.Properties.VariableNames{7}    = 'PrivateFixedInvestment';

exp{1:end,3:end}(isnan(exp{1:end,3:end})) = 0
exp(74:83,:)                       = [];

%plot(1:1:size(exp,1),exp{1:end,end})

%IO_use.Var97                        = [];
%IO_use.Var98                        = [];
%IO_use.Var99                        = [];
%IO_use.Var100                      = [];
%IO_use.F02E00                      = [];
%IO_use.F02N00                      = [];
%IO_use.F02R00                      = [];
%IO_use.F02S00                      = [];

TIO                                = IO_use(IO_use.CommodityName == 'Total Industry Output',:);
VA                                 = IO_use(IO_use.CommodityName == 'Total Value Added',:);

%Build VA share of Total Output by Industry (133 Industries)
va_share                           = VA{:,3:73}./TIO{:,3:73};
plot(1:1:71,va_share)

%Construct a diagonal matrix <v> with VA shares in the diagonal and zeros
%otherwise
v                                 = diag(va_share);
%--------------------------------------------------------------------------
ec                                = v*IxCTR{1:end,2:end}*exp{1:end,3};
ei                                = v*IxCTR{1:end,2:end}*exp{1:end,7};
ec(isnan(ec))                     = 0;
ei(isnan(ei))                     = 0;

% Check if Total Match the Total in the IO Matrix
sum(ec)/tot_pce 
sum(ei)/tot_pfi 


%Check that the Total Requirements Matrix is Equivalent to the one
%Constructed using the Normalized Make and Use Tables
R_check                           = W*inv(eye(71,71) - B*W); % -> Perfect!
ec_alt                            = v*R_check*exp{1:71,3};

ec_alt(isnan(ec_alt))             = 0;
sum(ec_alt)/tot_pce

%% ------------------------------------------------------------------------
% Build a Table Containing the Final Data. 
Final_Expenditures_VA                     = IxCTR ;
Final_Expenditures_VA(:,2:end)            = []; 

Final_Expenditures_VA.Consunmption_VA     = ec;
Final_Expenditures_VA.Investmet_VA        = ei;

clearvars -except Final_Expenditures_VA
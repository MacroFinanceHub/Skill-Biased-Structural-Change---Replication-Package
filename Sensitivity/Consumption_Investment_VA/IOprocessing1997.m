%--------------------------------------------------------------------------
%% Set the Working Directory
clc
clear all

%Set the Working Directory
cd 'C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud\Sensitivity\Consumption_Investment_VA\summarytables1997\'

%--------------------------------------------------------------------------
%% Import the Use Table at the Summary Level

IO_use                             = readtable('IOUseSummary.xlsx','Sheet','Sheet1','Range','A7:EJ147');

%Replace Missing Values
for i = 3:size(IO_use,2) ; IO_use.(i)(isnan(IO_use.(i))) = 0; end

tot_pce                            = IO_use.F010(end);
tot_pfi                            = IO_use.F020(end);

IO_use.Properties.VariableNames{1} = 'IndustryCode';
IO_use.Properties.VariableNames{2} = 'IndustryName';

IO_use.Properties.RowNames         = IO_use.IndustryCode;
IO_use.IndustryName                = categorical(IO_use.IndustryName);
IO_use.IndustryCode                = [];

TIO                                = IO_use{'T008',2:132};
VA                                 = IO_use{'T006',2:132};

%% Build VA share of Total Output by Industry (131 Industries)
va_share                           = VA./TIO;
i                                  = 1:1:131;
plot(1:1:size(va_share,2),va_share)

%Construct a diagonal matrix <v> with VA shares in the diagonal and zeros
%otherwise
v                                  = diag(va_share);

%% Obtain the final consumption vector: row "i" contains final consumption of
%commodity "i"
exp                                = IO_use(:,{'IndustryName','F010','F020'});
exp                                = exp{1:134,2:3}; %drop totals (134 Commodities)

%% Import the Industry (row) by Commodity (column) Total Requirements Table
IxCTR                              = readtable('IndByComTRSum.xlsx','Sheet','Sheet1','Range','A7:EF138');
R                                  = IxCTR{1:end,3:end};
%--------------------------------------------------------------------------
ec                                 = v*R*exp(:,1);
ei                                 = v*R*exp(:,2);

sum(ec)/tot_pce
sum(ei)/tot_pfi

%% ------------------------------------------------------------------------
% Build a Table Containing the Final Data. 
Final_Expenditures_VA                     = IxCTR ;
Final_Expenditures_VA(:,2:end)            = []; 

Final_Expenditures_VA.Consunmption_VA     = ec;
Final_Expenditures_VA.Investmet_VA        = ei;

clearvars -except Final_Expenditures_VA
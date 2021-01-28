clc
clear all

%--------------------------------------------------------------------------
%% Set the Working Directory
cd '/home/nacho/Dropbox/historical_IO_tables/summarytables1997/'

%% Import the Make Use Table at the Summary Level

IO_use                              = readtable('IOUseSummary.xlsx','Sheet','Sheet1','Range','A6:EJ147');
IO_use.Properties.VariableNames{1}  = 'IndustryCode';
IO_use.Properties.VariableNames{2}  = 'IndustryName';

IO_use(1,:)                         = [];
IO_use.Properties.RowNames          = IO_use.IndustryName;
IO_use.IndustryCode                 = categorical(IO_use.IndustryCode);
IO_use.IndustryName                 = [];

for i = 2:size(IO_use,2)
IO_use.(i) = str2double(IO_use.(i));
IO_use.(i)(isnan(IO_use.(i))) = 0;
end

TIO                                 = IO_use{'Total industry output',2:132};
VA                                  = IO_use{'Total value added'    ,2:132};

%% Build VA share of Total Output by Industry (131 Industries)
va_share                            = VA./TIO;
i                                   = 1:1:131;
plot(i,va_share)

%% Construct a diagonal matrix <v> with VA shares in the diagonal and zeros
%otherwise
v                                   = diag(va_share);

%% Obtain the final consumption vector: row "i" contains final consumption of
%commodity "i"
exp                                  = IO_use(:,{'IndustryCode','PersonalConsumptionExpenditures','PrivateFixedInvestment'});
%drop totals (134 Industries)

%% Import the Total Requirements Table
%Rows:      138 Industries  ->    S001,S002,          S005     ,S007
%Columns:   134 Commodities ->    S001,S002,S003,S004,S005,S006,S007

TR_IbC                               = readtable('IndByComTRSum.xlsx','Sheet','Sheet1','Range','A6:EF138');
TR_IbC.Properties.VariableNames{1}   = 'IndustryCode';
TR_IbC.Properties.VariableNames{2}   = 'IndustryName';
TR_IbC(1,:)                          = [];
TR_IbC.IndustryCode                  = categorical(TR_IbC.IndustryCode);
TR_IbC.Properties.RowNames           = TR_IbC.IndustryName;
TR_IbC.IndustryName                  = [];

for i = 2:size(TR_IbC,2)
TR_IbC.(i) = str2double(TR_IbC.(i));
TR_IbC.(i)(isnan(TR_IbC.(i))) = 0;
end

R                                    = TR_IbC{1:131,2:end};
%--------------------------------------------------------------------------
ec                                   = v*R*exp{1:134,2};
ei                                   = v*R*exp{1:134,3};

tot_pce                              = IO_use.PersonalConsumptionExpenditures(end);
tot_pfi                              = IO_use.PrivateFixedInvestment(end);

sum(ec)/tot_pce
sum(ei)/tot_pfi
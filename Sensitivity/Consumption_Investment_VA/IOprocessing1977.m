clc
clear all

%Set the Working Directory
cd 'C:\Users\lezjv\Dropbox\BKR\Nacho\Data_Appendix\REStud\Sensitivity\Consumption_Investment_VA\2digit_tables1977/'
%--------------------------------------------------------------------------
Data_all        = readtable('77IO85-levelexcel/1977_Transactions_85-level_Data_check.xlsx');
Labels_all      = readtable('77IO85-levelexcel/1977_85_level_Industry_Code_Descriptions.xlsx','ReadVariableNames',false);

%Use table cell. Commodities row code; Industries column code
%Industry-by-commodity total requirements coefficients.  
%Industry (row) output required per dollar of each commodity (column) delivered to final demand. 

%% --------------------------------------------------------------------------
%% Build the Industry by Commodity Total Requirements Matrix
IxCTR                                     = Data_all;
IxCTR(:,3:6)                              = [];       
IxCTR.Properties.VariableNames{1}         = 'CommodityCode' ; 
IxCTR.Properties.VariableNames{2}         = 'IndustryCode'  ;

%IxCTR.IndustryCode                        = categorical(IxCTR.IndustryCode);
%IxCTR.CommodityCode                       = categorical(IxCTR.CommodityCode);
%IxCTR.IxC_Total_Req                       = str2double(IxCTR.IxC_Total_Req);

%Reshape the Vector to Obtain the Total Requirements Matrix (Industry rows, Commodity Columns)
IxCTR_inv_temp                            = unstack(IxCTR,'IxC_Total_Req','IndustryCode','GroupingVariable','CommodityCode');
TR_commodities                            = IxCTR_inv_temp.CommodityCode;
TR_commodities                            = cellstr(TR_commodities);       %85 Commodities (88 but 3 are VA components 88,89,90)

clearvars IxCTR_inv_temp

IxCTR                                     = unstack(IxCTR,'IxC_Total_Req','CommodityCode','GroupingVariable','IndustryCode');

IxCTR                                     = sortrows(IxCTR);

IxCTR.Properties.RowNames                 = IxCTR.IndustryCode; 
TR_industries                             = IxCTR.IndustryCode;
TR_industries                             = cellstr(TR_industries);        %85 Industries (94 but 9 are final uses 91-99)
IxCTR.IndustryCode                        = []; 

%Replace Missing Values
for i = 1:size(IxCTR,2) 
    IxCTR.(i)(isnan(IxCTR.(i))) = 0; 
end
%--------------------------------------------------------------------------
IxCTR(:,{'x88','x89','x90'})                              = [];
IxCTR({'91','92','93','94','95','96','97','98','99'},:)   = [];

%-------------------------------------------------------------------------
%% Build the Use Matrix
clc
IO_use                                    = Data_all(:,1:3);

IO_use.Properties.VariableNames{1}        = 'CommodityCode';
IO_use.Properties.VariableNames{2}        = 'IndustryCode'; 
IO_use.Properties.VariableNames{3}        = 'InputUse'; 

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

for i = 2:size(IO_use,2) 
    IO_use.(i)(isnan(IO_use.(i))) = 0; 
end

tot_pce                                   = sum(IO_use.x91);
tot_pfi                                   = sum(IO_use.x92);
%--------------------------------------------------------------------------
%% Import Industry Labels (I have converted the .txt file into .xlsx to import it more easily)
IO_use_labels                             = readtable('77IO85-levelexcel/1977_85_level_Industry_Code_Descriptions.xlsx','ReadVariableNames',false);
IO_use_labels.Properties.VariableNames{1} = 'CommodityCode';
IO_use_labels.Properties.VariableNames{2} = 'CommodityLabel'; 
IO_use_labels_commodities                 = IO_use_labels.CommodityCode;  
%IO_use_labels.CommodityCode              = cellstr(num2str(IO_use_labels.CommodityCode));

IO_use_labels.Properties.RowNames         = IO_use_labels.CommodityCode;
IO_use_labels.CommodityCode               = categorical(IO_use_labels.CommodityCode);
IO_use_labels.CommodityLabel              = categorical(IO_use_labels.CommodityLabel);

IO_use_labels_all                         = IO_use_labels;
IO_use_labels({'91','92','93','94','95','96','97','98','99'},:) = [];


%% Merge Labels With IO Use Table entries to complete the IO Use Table
IO_use                                    = join(IO_use_labels,IO_use,'Keys','CommodityCode');
IO_use(:,'CommodityCode')                 = [];

clearvars droprows IO_use_labels_vars IO_use_vars


%--------------------------------------------------------------------------
%Obtain the final consumption and investment vector: row "i" contains final consumption of
%commodity "i"
exp                                       = IO_use(:,{'CommodityLabel','x91','x92'});
exp.Properties.VariableNames{2}           = 'PersonalConsumptionExpenditures';
exp.Properties.VariableNames{3}           = 'PrivateFixedInvestment';

%Compute Total Industry Output; Create a Numeric Variable to Store it and
%Add it to the Table
tio                                       = sum(IO_use{1:end,2:end});
tva                                       = IO_use{'88',2:end}+IO_use{'89',2:end}+IO_use{'90',2:end};

IO_use.CommodityLabel(end+1)              = 'Total Value Added';
IO_use.Properties.RowNames{end}           = 'tva';
IO_use{end,2:end}                         =  tva;

IO_use.CommodityLabel(end+1)              = 'Total Industry Output';
IO_use.Properties.RowNames{end}           = 'tio';
IO_use{end,2:end}                         =  tio;

%-------------------------------------------------------------------------
%% Build the Make Matrix
clc
IO_make                                   = Data_all(:,1:4);
IO_make(:,3)                              = [];

IO_make.Properties.VariableNames{1}       = 'CommodityCode';
IO_make.Properties.VariableNames{2}       = 'IndustryCode'; 
IO_make.Properties.VariableNames{3}       = 'ComMake'; 

IO_make_full                              = IO_make;
IO_make                                   = unstack(IO_make,'ComMake','CommodityCode','GroupingVariable','IndustryCode');
IO_make.Properties.RowNames               = IO_make.IndustryCode;
IO_make                                   = sortrows(IO_make);
IO_make(:,{'x88','x89','x90'})            = [];
IO_make({'91','92','93','94','95','96','97','98','99'},:)          = [];

for i = 2:size(IO_make,2) 
    IO_make.(i)(isnan(IO_make.(i))) = 0; 
end

IO_make.IndustryCode = [];
Total_Com_Output     = sum(IO_make{1:end,1:end});
IO_make_matrix       = IO_make{1:end,1:end}./Total_Com_Output;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Now I can drop final uses
IO_use(:,{'x91','x92','x93','x94','x95','x96','x97','x98','x99'})          = [];

IO_use_matrix  = IO_use{1:85,2:end}./tio(:,1:85);
IO_use_matrix(isnan(IO_use_matrix))   = 0; 
IO_make_matrix(isnan(IO_make_matrix)) = 0; 

TR_matrix      = IO_make_matrix*(inv(eye(85,85)-IO_use_matrix*IO_make_matrix));

TR_matrix(isnan(TR_matrix)) = 0; 

%Do the Final Calculations
va_share                                  = IO_use{'tva',2:end}./IO_use{'tio',2:end};
va_share(isnan(va_share))                 = 0.0 ; 

i = 1:size(va_share,2);
plot(i,va_share)

%Construct a diagonal matrix <v> with VA shares in the diagonal and zeros
%otherwise
v                                         = diag(va_share);
R                                         = IxCTR{1:end,1:end};

ec                                        = v*R*exp{1:85,2};
ei                                        = v*R*exp{1:85,3};

ec_alt                                    = v*TR_matrix*exp{1:85,2};
ei_alt                                    = v*TR_matrix*exp{1:85,3};

sum(ec)/tot_pce
sum(ei)/tot_pfi

% THE CORRECT SERIES FOR CONSUMPTION AND INVESTMENT EXPENDITURES ARE ec_alt and
% ei_alt

%Notice there is a problem with the total requirements matrix. It seems
%that some of the coefficients are "too large". This is probably either to
%the way the data are stored or due to the way I imported them. 
%This can easily be solved by building the Industry by Commodity Total
%Requirements Matrix use the Make and Use Tables.

sum(ec_alt(1:79,:))/tot_pce
sum(ei_alt)/tot_pfi
%% ------------------------------------------------------------------------

%% ------------------------------------------------------------------------
% Build a Table Containing the Final Data. 
Final_Expenditures_VA                                = Labels_all;
Final_Expenditures_VA.Properties.VariableNames{1}    = 'CommodityCode' ; 
Final_Expenditures_VA.Properties.VariableNames{2}    = 'IndustryCode'  ;
Final_Expenditures_VA                                = Labels_all;
Final_Expenditures_VA(86:end,:)                      = []; 

Final_Expenditures_VA.Consunmption_VA                = ec_alt;
Final_Expenditures_VA.Investmet_VA                   = ei_alt;

clearvars -except Final_Expenditures_VA

%% RS
rs_clean = RS_data(:,["TIME_PERIOD_Period","OBS_VALUE_Value"]);
%rs_clean.TIME_PERIOD_Period = datetime(rs_clean.TIME_PERIOD_Period,'InputFormat','yyyy-MM');
%RS = convert(rs_clean,'q',Inf,'method',@mean);
ts = tseries(mm(1987,1):mm(2026,4),rs_clean.OBS_VALUE_Value);
RS = convert(ts,'q',Inf,'method',@mean);
%d = struct([RS])
db.RS = RS;


%% CPI
cpi_clean = HICP_HU(:,"HICPInflationRate_Total_Index_HICP_M_HU_N_000000_4D0_INX_");
ts = tseries(mm(1996,1):mm(2026,3),cpi_clean.HICPInflationRate_Total_Index_HICP_M_HU_N_000000_4D0_INX_);
CPI = convert(ts,'q',Inf,'method',@mean);
db.CPI = CPI;

%% CPI_RW
cpi_rw_clean = HICP_EU(:,"HICPInflationRate_Total_Index_HICP_M_U2_N_000000_4D0_INX_");
ts = tseries(mm(1996,1):mm(2026,4),cpi_rw_clean.HICPInflationRate_Total_Index_HICP_M_U2_N_000000_4D0_INX_);
CPI_RW = convert(ts,'q',Inf,'method',@mean);
db.CPI_RW = CPI_RW;

%% RS_RW
rs_rw_clean = EURIBOR(:,"Euribor3_month_HistoricalClose_AverageOfObservationsThroughPeriod_FM_Q_U2_EUR_RT_MM_EURIBOR3MD__HSTA_");
RS_RW = tseries(qq(1994,1):qq(2026,1),rs_rw_clean.Euribor3_month_HistoricalClose_AverageOfObservationsThroughPeriod_FM_Q_U2_EUR_RT_MM_EURIBOR3MD__HSTA_);
db.RS_RW = RS_RW;

%% GDP
gdp_clean = GDP(:,"Var3");
GDP = tseries(qq(1995,1):qq(2025,3),gdp_clean.Var3);
db.GDP = GDP;

%% GDP_RW
gdp_rw_clean = GDP(:,"Var2");
GDP_RW = tseries(qq(1995,1):qq(2025,3),gdp_rw_clean.Var2);
db.GDP_RW = GDP_RW;

%% S
s_clean = huf(:,"HungarianForint_EuroECBReferenceExchangeRate_EXR_Q_HUF_EUR_SP00_A_");
S = tseries(qq(1999,1):qq(2026,1),s_clean.HungarianForint_EuroECBReferenceExchangeRate_EXR_Q_HUF_EUR_SP00_A_);
db.S = S;

%% D4L_CPI_TAR
ts1 = tseries(qq(1996,1):qq(1996,4),23);
ts2 = tseries(qq(1997,1):qq(1997,4),18);
ts3 = tseries(qq(1998,1):qq(1998,4),14);
ts4 = tseries(qq(1999,1):qq(2000,4),10);
ts5 = tseries(qq(2001,1):qq(2001,4),7);
ts6 = tseries(qq(2002,1):qq(2002,4),4.5);
ts7 = tseries(qq(2003,1):qq(2004,4),3.5);
ts8 = tseries(qq(2005,1):qq(2005,4),4);
ts9 = tseries(qq(2006,1):qq(2006,4),3.5);
ts10 = tseries(qq(2007,1):qq(2026,1),3);
D4L_CPI_TAR = [ts1; ts2; ts3; ts4; ts5; ts6; ts7; ts8; ts9; ts10];
db.D4L_CPI_TAR = D4L_CPI_TAR;

%% Save Final CSV
dbsave(db,'data.csv');


%% Alternative: g3 approximately zero


%% Housekeeping
%clearvars
close all

addpath utils

%% Read the baseline model
[m, p, mss] = readmodel();

%% Forecast period
startfcast = qq(2023,1);
endfcast   = qq(2025,4);
fcastrange = startfcast:endfcast;



% 1. Construct the alternative input database


% Load filtered history / initial conditions
d = dbload('results/kalm_his_cut.csv');

% Load baseline forecast
df = dbload('results/baseline_cut.csv');

% Extract baseline forecast-period structural shocks
enames = get(m,'eList');
d_ = df*enames;

% Overlay baseline shocks onto the filtered-history database
d = dboverlay(d,d_);

% Store baseline for comparison
h = df;



% 2. Alternative monetary-policy rule


% Baseline:
% g1 = 0.70
% g2 = 1.20
% g3 = 0.25

% Alternative:
% g1 = 0.70
% g2 = 1.20
% g3 = 0.00

m_alt = m;

% Change only the output-gap coefficient
m_alt = assign(m_alt,'g3',0.005);

% Re-solve the model after changing the parameter
m_alt = solve(m_alt);
m_alt = sstate(m_alt);



% 3. Simulate alternative


% No SHK_RS intervention:
% the alternative keeps the baseline forecast-period
% monetary-policy shocks contained in d.SHK_RS.

s = simulate(m_alt,d,fcastrange,'anticipate',true);



% 4. Combine history and alternative forecast


d = dbextend(d,s);



% 5. Merge baseline and alternative


f = h & d;


%% Save results
dbsave('fcastdata_alt2.csv',f);



% 6. Diagnostics


disp('----------------------------------------')
disp('Alternative monetary policy experiment')
disp('----------------------------------------')
disp(['Baseline g3    = ',num2str(m.g3)])
disp(['Alternative g3 = ',num2str(m_alt.g3)])

disp(' ')
disp('Maximum absolute difference in policy rate:')
disp(max(abs(s.RS(fcastrange)-h.RS(fcastrange))))

disp(' ')
disp('Maximum absolute difference in output gap:')
disp(max(abs(s.L_GDP_GAP(fcastrange)-h.L_GDP_GAP(fcastrange))))

disp(' ')
disp('Maximum absolute difference in inflation:')
disp(max(abs(s.D4L_CPI(fcastrange)-h.D4L_CPI(fcastrange))))



% 7. Graphs and Tables


Tablerng = startfcast-3:startfcast+7;
Plotrng = startfcast-3:startfcast+11;
Histrng = startfcast-3:startfcast-1;

country = 'Hungary';
exchange = 'HUF/EUR';

alternative = 'Alternative';

%% Report
x = Report.new(country,'marks',{'Baseline';'Alternative'});

sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--';':'};
sty.axes.box = 'off';
sty.legend.location = 'Best';
sty.legend.Box = 'off';

x.figure(alternative,'subplot',[2,3],'style',sty,...
    'range',Plotrng,'dateformat','YYYY:P');

x.graph('Inflation, % qoq','legend',true);
x.series('',f.DLA_CPI);
x.highlight('',Histrng);

x.graph('Inflation, % y-o-y','legend',false);
x.series('',f.D4L_CPI);
x.highlight('',Histrng);

x.graph('Nom. Interest Rate, % p.a.','legend',false);
x.series('',f.RS);
x.highlight('',Histrng);

x.graph('Nom. Exchange Rate','legend',false);
x.series('',exp(f.L_S/100));
x.highlight('',Histrng);

x.graph('Output Gap, %','legend',false);
x.series('',f.L_GDP_GAP);
x.highlight('',Histrng);

x.graph('Monetary Conditions, %','legend',false);
x.series('',f.MCI);
x.highlight('',Histrng);

x.pagebreak();


%% Tables
TableOptions = {'range',Tablerng,'vline',startfcast-1,...
    'decimal',2,'dateformat','YYYY:P',...
    'long',true,'longfoot','---continued',...
    'longfootposition','right'};

x.table([alternative ' - Main Indicators'],TableOptions{:});

x.subheading('Inflation');
x.series('CPI ',f.D4L_CPI,'units','% (y-o-y)');
x.series('',f.DLA_CPI,'units','% (q-o-q)');

x.subheading('Nominal Interest Rates');
x.series('Policy Rate',f.RS,'units','% p.a.');
x.series('Policy Neutral Rate',f.RSNEUTRAL,'units','% p.a');

x.subheading('Nominal Exchange Rate');
x.series(exchange,exp(f.L_S/100),'units','level');
x.series('',f.L_S-f.L_S{-4},'units','% (y-o-y)');
x.series('',f.DLA_S,'units','% (q-o-q)');

x.pagebreak();

x.table([alternative ' - Main Indicators'],TableOptions{:});

x.subheading('Real Economy');
x.series('Output Gap',f.L_GDP_GAP,'units','%');
x.series('GDP Growth',f.L_GDP-f.L_GDP{-4},'units','% (y-o-y)');

x.subheading('Monetary Conditions');
x.series('Monetary Conditions',f.MCI,'units','%');
x.series('Real Interest Rate Gap ',f.RR_GAP,'units','p.p.');
x.series('Real Exchange Rate Gap',f.L_Z_GAP,'units','%');

x.pagebreak();

x.table([alternative 'Foreign Variables'],TableOptions{:});

x.subheading('European Monetary Union');
x.series('Inflation',f.DLA_CPI_RW,'units','% (q-o-q)');
x.series('Interest Rate',f.RS_RW,'units','%');
x.series('Output Gap',f.L_GDP_RW_GAP,'units','%');


x.publish('results/alternative_comparison2','display',false);

disp('Done!');

% LOSS FUNCTION

rng = startfcast:endfcast;

%% --- Baseline ---
pi_base  = h.D4L_CPI(rng);
tar_base = h.D4L_CPI_TAR(rng);
gap_base = h.L_GDP_GAP(rng);
rs_base  = h.RS(rng);

%% --- Alternative ---
pi_alt  = d.D4L_CPI(rng);
tar_alt = d.D4L_CPI_TAR(rng);
gap_alt = d.L_GDP_GAP(rng);
rs_alt  = d.RS(rng);

%% --- Historical standard deviations ---
hist_rng = startfcast-20:startfcast-1;

sigma_pi  = std(h.D4L_CPI(hist_rng));
sigma_gap = std(h.L_GDP_GAP(hist_rng));
sigma_drs = std(diff(h.RS(hist_rng)));

%% --- Weights ---
w_pi  = 0.7;
w_gap = 0.3;
w_drs = 0.1;

% Inflation loss

Lpi_base = ((pi_base-tar_base)/sigma_pi).^2;
Lpi_alt  = ((pi_alt-tar_alt)/sigma_pi).^2;

% Output-gap loss

Lgap_base = (gap_base/sigma_gap).^2;
Lgap_alt  = (gap_alt/sigma_gap).^2;

% Interest-rate movement loss

rs_base_ext = h.RS(startfcast-1:endfcast);
rs_alt_ext  = d.RS(startfcast-1:endfcast);

drs_base = diff(rs_base_ext);
drs_alt  = diff(rs_alt_ext);

Ldrs_base = (drs_base/sigma_drs).^2;
Ldrs_alt  = (drs_alt/sigma_drs).^2;

% Discount factor

beta = 0.95;

% Forecast horizon
T = length(rng);

% Discount weights: beta^0, beta^1, ..., beta^(T-1)
discount = beta.^(0:T-1)';

% Total discounted loss

Lt_base = w_pi*Lpi_base + w_gap*Lgap_base + w_drs*Ldrs_base;

Lt_alt = w_pi*Lpi_alt + w_gap*Lgap_alt + w_drs*Ldrs_alt;

% Apply discount factor period by period

L_base = sum(discount .* Lt_base);
L_alt  = sum(discount .* Lt_alt);

% Normalized alternative loss

L_alt_norm = L_alt/L_base;

% Report

fprintf('\n');
fprintf('----------------------------------------\n');
fprintf('Policy-rule loss function\n');
fprintf('----------------------------------------\n');

fprintf('Baseline loss       = %.4f\n', L_base);
fprintf('Alternative loss    = %.4f\n', L_alt);
fprintf('Normalized loss     = %.4f\n', L_alt_norm);
fprintf('Relative change     = %.2f %%\n', ...
    100*(L_alt_norm-1));

fprintf('\n');

fprintf('Baseline components:\n');
fprintf('  Inflation         = %.4f\n', sum(Lpi_base)*w_pi);
fprintf('  Output gap        = %.4f\n', sum(Lgap_base)*w_gap);
fprintf('  Rate variability  = %.4f\n', sum(Ldrs_base)*w_drs);

fprintf('\n');

fprintf('Alternative components:\n');
fprintf('  Inflation         = %.4f\n', sum(Lpi_alt)*w_pi);
fprintf('  Output gap        = %.4f\n', sum(Lgap_alt)*w_gap);
fprintf('  Rate variability  = %.4f\n', sum(Ldrs_alt)*w_drs);

fprintf('----------------------------------------\n');

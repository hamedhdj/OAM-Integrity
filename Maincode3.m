% % --- Retain previous parameter definitions ---
% lambda = 1.55e-6;   
% k = 2 * pi / lambda;
% z = 200;           
% w_gs = 2.0e-2;      
% w_ls_standard = 2.0e-2; 
% w_ls_LG_mock = 100e-2;
% Cn2_range = logspace(-16, -14, 50); 
% 
% % --- Retained Core Functions ---
% 
% % Function to calculate Coherence Length (rho0)
% calc_rho0 = @(Cn2) (0.546 * k^2 * z * Cn2) .^ (-3/5);
% 
% % Function to calculate Effective Beam Radius (W_eff) at the receiver
% % W_eff combines diffraction and turbulent spreading.
% % NOTE: The spread is independent of the Lorentz width (w_ls) in this common model,
% % but we can model a slightly larger diffractive spread for the SLG due to its structure.
% calc_W_eff = @(w_gs, rho0, is_SLG) sqrt( ...
%     (w_gs^2 * (1 + (z / (k*w_gs^2))^2) * (1 + 0.1 * is_SLG)) + ... % Diffractive Spread (+10% penalty for structured SLG)
%     (z^2 ./ (k^2 * rho0.^2)) ...                                   % Turbulent Spread
% );
% 
% %% --- 10. Simulation 6: Total Beam Spreading and Coherence Length (Figure 6) ---
% 
% rho0_range = calc_rho0(Cn2_range);
% 
% % 1. Calculate Beam Widths
% is_SLG_flag = 1; % Penalty factor for SLG
% is_LG_flag = 0;  % No penalty for LG
% 
% W_eff_SLG = calc_W_eff(w_gs, rho0_range, is_SLG_flag);
% W_eff_LG = calc_W_eff(w_gs, rho0_range, is_LG_flag);
% 
% % 2. Calculate Normalized Coherence Length (rho0 / w_gs) for plotting reference
% rho0_normalized = rho0_range / w_gs; 
% 
% % Normalize W_eff by the initial Gaussian waist for clearer comparison
% W_eff_SLG_norm = W_eff_SLG / w_gs;
% 
% W_eff_LG_norm = W_eff_LG / w_gs;
% 
% figure(6);
% 
% % Plot Beam Widths (normalized)
% loglog(Cn2_range, W_eff_SLG_norm, 'r-', 'LineWidth', 2, 'DisplayName', 'SLGVB Effective Radius (W_{eff} / w_{gs})');
% hold on;
% loglog(Cn2_range, W_eff_LG_norm, 'b--', 'LineWidth', 2, 'DisplayName', 'LG Benchmark Effective Radius');
% 
% % Plot Coherence Length (normalized)
% loglog(Cn2_range, rho0_normalized, 'k:', 'LineWidth', 2, 'DisplayName', '\rho_0 / w_{gs} (Atmospheric Coherence)');
% 
% % Add a horizontal line at y=1 for visual reference (initial waist size)
% loglog(Cn2_range, ones(size(Cn2_range)), 'g-.', 'DisplayName', 'Initial Waist (w_{gs})');
% 
% hold off;
% grid on;
% title('Macroscopic Spreading vs. Turbulence Strength');
% xlabel('Refractive Index Structure Constant C_n^2 (m^{-2/3})');
% ylabel('Normalized Radius (W_{eff} / w_{gs}) and Coherence (\rho_0 / w_{gs})');
% xlim([min(Cn2_range), max(Cn2_range)]);
% legend('Location', 'northeast');


%% FINAL REVISED MATLAB SCRIPT: SLGVB OAM Degradation Analysis

% --- 1. Define Physical and Beam Parameters ---
clear; close all;
lambda = 1.55e-6;   % Wavelength (1550 nm)
j = 1i;
k = 2 * pi / lambda;

% Standard Parameters for OAM Purity Analysis (Figures 1-5)
z_purity = 1000;          % Propagation distance for purity analysis (1 km)
w_gs = 2.0e-2;            % Standard Gaussian waist (2 cm)
w_ls_standard = 2.0e-2;   % Standard Lorentz width (2 cm)
w_ls_LG_mock = 100e-2;    % Mock LG
l_launch = 1;             % Launched topological charge

% Parameters for Beam Spreading Analysis (Figure 6)
z_spread = 200;           % Shorter distance to observe turbulent spread (200 m)
w_gs_spread = 2.0e-2;     % Gaussian waist for spreading analysis (2 cm)

% Turbulence Range (Cn2)
Cn2_range = logspace(-16, -14, 50); 


%% --- 2. Core Functions ---

% Function to calculate Coherence Length (rho0)
calc_rho0 = @(Cn2, Z) (0.546 * k^2 * Z * Cn2) .^ (-3/5);

% Function to calculate Effective Beam Radius (W_eff) at the receiver
calc_W_eff = @(w_gs, rho0, Z, is_SLG) sqrt( ...
    (w_gs^2 * (1 + (Z / (k*w_gs^2))^2) * (1 + 0.1 * is_SLG)) + ... % Diffractive Spread (+10% penalty for SLG structure)
    (Z^2 ./ (k^2 * rho0.^2)) ...                                   % Turbulent Spread
);

% Function to calculate OAM Purity P(l->l) with penalty for a, b orders
calc_Purity_l_l_general = @(l, w_ls, w_gs, Cn2, Z, a, b) ...
    1 ./ (1 + (abs(l).^2 .* (1 + a + b) .* (w_gs ./ w_ls) .* (Cn2 * 1e16).^1.2 .* (Z/1000)));

% Relative Scattering Distribution for Cross-Talk
calc_Relative_Scatter = @(l, m) exp(-(l-m).^2 / 1.5); 


%% --- 3. Simulation 1: Purity vs. Cn^2 (Figure 1: Comparison) ---

rho0_range_purity = calc_rho0(Cn2_range, z_purity);
a_fix = 1; b_fix = 0; % SLGVB(1,0)

l1_purity_std = calc_Purity_l_l_general(l_launch, w_ls_standard, w_gs, Cn2_range, z_purity, a_fix, b_fix);
w_ls_sharp = 0.5e-2;
l1_purity_sharp = calc_Purity_l_l_general(l_launch, w_ls_sharp, w_gs, Cn2_range, z_purity, a_fix, b_fix);
l1_purity_LG = calc_Purity_l_l_general(l_launch, w_ls_LG_mock, w_gs, Cn2_range, z_purity, a_fix, b_fix); 

figure(1);
semilogx(Cn2_range, l1_purity_std, 'r-', 'LineWidth', 2, 'DisplayName', 'SLGVB(1,0), w_{ls}=2cm');
hold on;
semilogx(Cn2_range, l1_purity_sharp, 'b--', 'LineWidth', 2, 'DisplayName', 'SLGVB(1,0), w_{ls}=0.5cm (Sharp)');
semilogx(Cn2_range, l1_purity_LG, 'k:', 'LineWidth', 2, 'DisplayName', 'LG Benchmark');
hold off;
grid on;
title('OAM Mode Purity P_{l\rightarrow l} vs. Turbulence Strength (l=1)');
xlabel('Refractive Index Structure Constant C_n^2 (m^{-2/3})');
ylabel('Mode Purity (P_{1\rightarrow 1})');
ylim([0, 1.05]);
legend('Location', 'southwest');


%% --- 4. Simulation 2: OAM Cross-Talk Spectrum (Figure 2) ---
Cn2_fixed = 1e-15; 
l_launch = 1;

P_l_l_fixed = calc_Purity_l_l_general(l_launch, w_ls_standard, w_gs, Cn2_fixed, z_purity, a_fix, b_fix);
P_loss = 1 - P_l_l_fixed;

m_modes = -4:4;
P_m_SLG = zeros(size(m_modes));
l_launch_idx = find(m_modes == l_launch);

P_scatter_relative = calc_Relative_Scatter(l_launch, m_modes);
P_scatter_relative(l_launch_idx) = 0; 
P_scatter_relative_norm = P_scatter_relative / sum(P_scatter_relative);

P_m_SLG(l_launch_idx) = P_l_l_fixed;
P_m_SLG(P_scatter_relative_norm > 0) = P_scatter_relative_norm(P_scatter_relative_norm > 0) * P_loss;

figure(2);
bar(m_modes, P_m_SLG, 'FaceColor', [0.7 0.1 0.1], 'DisplayName', 'SLGVB (l=1)');
title(sprintf('Received OAM Spectrum (C_n^2 = %.1e m^{-2/3})', Cn2_fixed));
xlabel('Received Topological Charge m');
ylabel('Normalized Power in Mode P_m');
grid on;
xticks(m_modes);
ylim([0, 1.05]);


%% --- 5. Simulation 3: Influence of Topological Charge |l| (Figure 3) ---
l_charges = [1, 2, 3];
a_fix = 1; b_fix = 0; 

purity_l_data = zeros(length(Cn2_range), length(l_charges));

for i = 1:length(l_charges)
    l = l_charges(i);
    purity_l_data(:, i) = calc_Purity_l_l_general(l, w_ls_standard, w_gs, Cn2_range, z_purity, a_fix, b_fix);
end

figure(3);
semilogx(Cn2_range, purity_l_data(:, 1), 'r-', 'LineWidth', 2, 'DisplayName', 'l=1');
hold on;
semilogx(Cn2_range, purity_l_data(:, 2), 'b--', 'LineWidth', 2, 'DisplayName', 'l=2');
semilogx(Cn2_range, purity_l_data(:, 3), 'k:', 'LineWidth', 2, 'DisplayName', 'l=3');
hold off;
grid on;
title('OAM Purity vs. Cn^2 for Different Topological Charges');
xlabel('Refractive Index Structure Constant C_n^2 (m^{-2/3})');
ylabel('Mode Purity (P_{l\rightarrow l})');
ylim([0, 0.4]); % Adjusted Y limit based on results
legend('Location', 'southwest');


%% --- 6. Simulation 4: Influence of Amplitude Order (a, b) (Figure 4) ---
l_fix = 1;
ab_orders = [0, 0; 1, 0; 2, 2];
order_labels = {'(0,0) [Lorentz-Gaussian]', '(1,0) [Dipole]', '(2,2) [Quadrupole]'};
purity_ab_data = zeros(length(Cn2_range), size(ab_orders, 1));

for i = 1:size(ab_orders, 1)
    a = ab_orders(i, 1);
    b = ab_orders(i, 2);
    purity_ab_data(:, i) = calc_Purity_l_l_general(l_fix, w_ls_standard, w_gs, Cn2_range, z_purity, a, b);
end

figure(4);
semilogx(Cn2_range, purity_ab_data(:, 1), 'g-', 'LineWidth', 2, 'DisplayName', order_labels{1});
hold on;
semilogx(Cn2_range, purity_ab_data(:, 2), 'r--', 'LineWidth', 2, 'DisplayName', order_labels{2});
semilogx(Cn2_range, purity_ab_data(:, 3), 'm:', 'LineWidth', 2, 'DisplayName', order_labels{3});
hold off;
grid on;
title('OAM Purity vs. Cn^2 for Different Amplitude Orders (l=1)');
xlabel('Refractive Index Structure Constant C_n^2 (m^{-2/3})');
ylabel('Mode Purity (P_{1\rightarrow 1})');
ylim([0, 0.55]); % Adjusted Y limit
legend('Location', 'southwest');


%% --- 7. Simulation 5: Optimal Lorentz-Gaussian Mixing Ratio (Figure 5) ---
l_fix = 1; a_fix = 1; b_fix = 0; 
w_ls_range = linspace(0.5e-2, 5e-2, 50);
ratio_range = w_ls_range / w_gs;

Cn2_weak = 1e-16;
Cn2_moderate = 5e-15;

Purity_weak = calc_Purity_l_l_general(l_fix, w_ls_range, w_gs, Cn2_weak, z_purity, a_fix, b_fix);
Purity_moderate = calc_Purity_l_l_general(l_fix, w_ls_range, w_gs, Cn2_moderate, z_purity, a_fix, b_fix);

figure(5);
plot(ratio_range, Purity_weak, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('Weak Turbulence (Cn^2=%.0e)', Cn2_weak));
hold on;
plot(ratio_range, Purity_moderate, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('Moderate Turbulence (Cn^2=%.0e)', Cn2_moderate));
hold off;
grid on;
title('OAM Purity vs. Structural Mixing Ratio (w_{ls} / w_{gs})');
xlabel('Structural Mixing Ratio w_{ls} / w_{gs}');
ylabel('Mode Purity (P_{1\rightarrow 1})');
ylim([0, 0.6]);


%% --- 8. Simulation 6: Total Beam Spreading and Coherence Length (Figure 6 - CORRECTED) ---

% --- Parameters for Beam Spreading Analysis (Figure 6) ---
z_spread = 500;           % New distance (500 m)
w_gs_spread = 1.0e-2;     % New Gaussian waist (1 cm)

% Turbulence Range for Spreading (extend the Cn2 range)
Cn2_range = logspace(-16, -13, 50);


rho0_range_spread = calc_rho0(Cn2_range, z_spread);

is_SLG_flag = 1; 
is_LG_flag = 0;  

W_eff_SLG = calc_W_eff(w_gs_spread, rho0_range_spread, z_spread, is_SLG_flag);
W_eff_LG = calc_W_eff(w_gs_spread, rho0_range_spread, z_spread, is_LG_flag);

W_eff_SLG_norm = W_eff_SLG / w_gs_spread;
W_eff_LG_norm = W_eff_LG / w_gs_spread;
rho0_normalized_spread = rho0_range_spread / w_gs_spread; 

figure(6);

% Plot Beam Widths (normalized)
loglog(Cn2_range, W_eff_SLG_norm, 'r-', 'LineWidth', 2, 'DisplayName', 'SLGVB Effective Radius (W_{eff} / w_{gs})');
hold on;
loglog(Cn2_range, W_eff_LG_norm, 'b--', 'LineWidth', 2, 'DisplayName', 'LG Benchmark Effective Radius');

% Plot Coherence Length (normalized)
loglog(Cn2_range, rho0_normalized_spread, 'k:', 'LineWidth', 2, 'DisplayName', '\rho_0 / w_{gs} (Atmospheric Coherence)');

% Add a horizontal line at the Diffractive Limit (W_d/w_gs) for z=200m
z_R_spread = pi * w_gs_spread^2 / lambda;
Wd_norm = sqrt(1 + (z_spread/z_R_spread)^2);
loglog(Cn2_range, Wd_norm * ones(size(Cn2_range)), 'g-.', 'DisplayName', 'Diffractive Limit');

hold off;
grid on;
title(sprintf('Macroscopic Spreading vs. Turbulence (z=%.0f m)', z_spread));
xlabel('Refractive Index Structure Constant C_n^2 (m^{-2/3})');
ylabel('Normalized Radius (W_{eff} / w_{gs}) and Coherence (\rho_0 / w_{gs})');
xlim([min(Cn2_range), max(Cn2_range)]);
legend('Location', 'southwest');
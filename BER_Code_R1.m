%% MATLAB Script to Plot New Figure 8 (BER vs. Structural Mixing Ratio)

clear; close all; clc;

% --- 1. Define Physical and System Parameters ---
lambda = 1.55e-6;           % Wavelength (1550 nm, FSO standard)
k = 2 * pi / lambda;        % Wave number
z = 1000;                   % Propagation distance (1 km)
l_launch = 1;               % Launched topological charge

w_gs = 2.0e-2;              % Source Gaussian Waist (2 cm)
R_range = linspace(0.25, 2.5, 200); % Structural Mixing Ratio range (w_ls / w_gs)
w_ls_range = R_range * w_gs;        % Corresponding w_ls values

% Turbulence Strength Constants (Cn2)
Cn2_weak = 1.0e-16;         % Weak turbulence
Cn2_moderate = 5.0e-15;     % Moderate turbulence

% Baseline Communication SNR (without turbulence fading)
SNR0_db = 26;               % Baseline SNR set to 26 dB 
SNR0_linear = 10^(SNR0_db / 10);

% --- 2. Core Mathematical Functions ---
% Standardized OAM purity model (P_l_l) yielding 33% purity at Cn2=1e-16 for w_ls=2cm
calc_Purity_l_l = @(l, w_ls, w_gs, Cn2) ...
    1 ./ (1 + 2.0 * (l^2 * (w_gs ./ w_ls) .* (Cn2 * 1e16).^1.2 .* (z/1000)));

% --- 3. Compute Purity, SNCR, and BER ---

% Case A: Weak Turbulence
P_l_l_weak = calc_Purity_l_l(l_launch, w_ls_range, w_gs, Cn2_weak);
% Signal-to-Noise-and-Crosstalk Ratio (SNCR) for single-channel OOK fading:
% SNCR = (P_l_l)^2 * SNR0
SNCR_weak = (P_l_l_weak.^2) * SNR0_linear;
BER_weak = 0.5 * erfc(sqrt(SNCR_weak) / (2 * sqrt(2)));

% Case B: Moderate Turbulence
P_l_l_mod = calc_Purity_l_l(l_launch, w_ls_range, w_gs, Cn2_moderate);
SNCR_mod = (P_l_l_mod.^2) * SNR0_linear;
% In moderate turbulence, severe crosstalk or signal degradation dominates:
BER_mod = 0.5 * erfc(sqrt(SNCR_mod) / (2 * sqrt(2)));

% --- 4. Plotting Figure 8 ---
figure(8);
semilogy(R_range, BER_weak, 'b-', 'LineWidth', 2, 'DisplayName', 'Weak Turbulence (C_n^2 = 1.0\times10^{-16} m^{-2/3})');
hold on;
semilogy(R_range, BER_mod, 'r--', 'LineWidth', 2, 'DisplayName', 'Moderate Turbulence (C_n^2 = 5.0\times10^{-15} m^{-2/3})');
hold off;

grid on;
title('Estimated BER vs. Structural Mixing Ratio (w_{ls}/w_{gs})');
xlabel('Structural Mixing Ratio w_{ls}/w_{gs}');
ylabel('Estimated Bit Error Rate (BER)');
xlim([0.25, 2.5]);
ylim([1e-10, 1]); % Standard log-scale axis range for communication BER curves
legend('Location', 'southwest');
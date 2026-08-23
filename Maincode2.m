%% Super Lorentz-Gaussian Vortex Beam (SLGVB) OAM Degradation Analysis
% Extension to include influence of launch charge and amplitude orders.

% --- 1. Define Physical and Beam Parameters (Retained) ---
clear; close all;
lambda = 1.55e-6;   
k = 2 * pi / lambda;
z = 1000;           
j = 1i;

% SLG Source Parameters 
w_gs = 2.0e-2;      
w_ls_standard = 2.0e-2; 
w_ls_LG_mock = 100e-2;  
w_ls_min = 0.5e-2;

% Turbulence Range (Cn2) 
Cn2_range = logspace(-16, -14, 50); 

%% --- 2. Core Functions (Modified to include A and B orders) ---

% Function to calculate OAM Purity P(l->l) with penalty for a, b orders
% Purity depends on l and structural complexity (a+b, w_gs/w_ls).
calc_Purity_l_l_general = @(l, w_ls, w_gs, Cn2, a, b) ...
    1 ./ (1 + (abs(l).^2 .* (1 + a + b) .* (w_gs ./ w_ls) .* (Cn2 * 1e16).^1.2 .* (z/1000)));

% Function to calculate Coherence Length (rho0)
calc_rho0 = @(Cn2) (0.546 * k^2 * z * Cn2) .^ (-3/5);


%% --- 7. Simulation 3: Influence of Topological Charge |l| (Figure 3) ---

l_charges = [1, 2, 3];
purity_l_data = zeros(length(Cn2_range), length(l_charges));

% Fix amplitude orders to (1, 0)
a_fix = 1;
b_fix = 0;

for i = 1:length(l_charges)
    l = l_charges(i);
    purity_l_data(:, i) = calc_Purity_l_l_general(l, w_ls_standard, w_gs, Cn2_range, a_fix, b_fix);
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
ylim([0, 0.4]);
legend('Location', 'northeast');


%% --- 8. Simulation 4: Influence of Amplitude Order (a, b) (Figure 4) ---

% Fix launch charge l=1
l_fix = 1;
ab_orders = [0, 0; 1, 0; 2, 2]; % SLG(0,0), SLG(1,0), SLG(2,2)
order_labels = {'(0,0) [Lorentz-Gaussian]', '(1,0) [Dipole]', '(2,2) [Quadrupole]'};
purity_ab_data = zeros(length(Cn2_range), size(ab_orders, 1));

for i = 1:size(ab_orders, 1)
    a = ab_orders(i, 1);
    b = ab_orders(i, 2);
    purity_ab_data(:, i) = calc_Purity_l_l_general(l_fix, w_ls_standard, w_gs, Cn2_range, a, b);
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
ylim([0, 0.5]);
legend('Location', 'northeast');


%% --- 9. Simulation 5: Optimal Lorentz-Gaussian Mixing Ratio (Figure 5) ---

% Fix launch charge l=1, Fix amplitude orders (1,0)
l_fix = 1;
a_fix = 1;
b_fix = 0;

% Ratio Range (e.g., Lorentz width from 0.5 cm to 5 cm)
w_ls_range = linspace(0.5e-2, 5e-2, 50);
ratio_range = w_ls_range / w_gs;

% Define fixed turbulence levels for comparison
Cn2_weak = 1e-16;
Cn2_moderate = 5e-15;

% Calculate Purity for fixed turbulence levels across the ratio range
Purity_weak = calc_Purity_l_l_general(l_fix, w_ls_range, w_gs, Cn2_weak, a_fix, b_fix);
Purity_moderate = calc_Purity_l_l_general(l_fix, w_ls_range, w_gs, Cn2_moderate, a_fix, b_fix);

figure(5);
plot(ratio_range, Purity_weak, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('Weak Turbulence (Cn^2=%.0e)', Cn2_weak));
hold on;
plot(ratio_range, Purity_moderate, 'r--', 'LineWidth', 2, 'DisplayName', sprintf('Moderate Turbulence (Cn^2=%.0e)', Cn2_moderate));
hold off;
grid on;
title('OAM Purity vs. Lorentz-Gaussian Ratio (w_{ls} / w_{gs})');
xlabel('Structural Mixing Ratio w_{ls} / w_{gs}');
ylabel('Mode Purity (P_{1\rightarrow 1})');
ylim([0, 0.6]);
legend('Location', 'southeast');
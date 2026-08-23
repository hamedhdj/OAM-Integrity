%% ADVANCED OAM ANALYSIS FIGURES (Figures 7, 8, 9)

% --- 1. Define Parameters (Consistent with previous sections) ---
% Assume standard parameters from Section 1 are loaded:
% z_purity = 1000; w_gs = 2.0e-2; Cn2_range, etc.

Cn2_moderate_fixed = 5e-15; % Moderate turbulence for coupling analysis
z_fixed = 1000;


%% --- 2. Simulation 7: Combined Penalty (l vs. a, b) (Figure 7) ---

l_test_charges = 1:5; % Test OAM charges
ab_orders = [0, 0; 1, 0; 2, 2]; % SLG(0,0), SLG(1,0), SLG(2,2)
order_labels = {'(0,0) [LGVB]', '(1,0) [Dipole]', '(2,2) [Quadrupole]'};

Purity_l_ab = zeros(length(l_test_charges), size(ab_orders, 1));

for j = 1:size(ab_orders, 1)
    a = ab_orders(j, 1);
    b = ab_orders(j, 2);
    
    for i = 1:length(l_test_charges)
        l = l_test_charges(i);
        % Calculate purity for a fixed, high turbulence level
        Purity_l_ab(i, j) = calc_Purity_l_l_general(l, w_ls_standard, w_gs, Cn2_moderate_fixed, z_fixed, a, b);
    end
end

figure(7);
plot(l_test_charges, Purity_l_ab(:, 1), 'g-o', 'LineWidth', 2, 'DisplayName', order_labels{1});
hold on;
plot(l_test_charges, Purity_l_ab(:, 2), 'r--x', 'LineWidth', 2, 'DisplayName', order_labels{2});
plot(l_test_charges, Purity_l_ab(:, 3), 'm:s', 'LineWidth', 2, 'DisplayName', order_labels{3});
hold off;
grid on;
title(sprintf('Combined Structural Penalty on Purity (Cn^2=%.0e)', Cn2_moderate_fixed));
xlabel('Launched Topological Charge |l|');
ylabel('Mode Purity (P_{l\rightarrow l})');
ylim([0, max(Purity_l_ab(:,1)) * 1.05]); % Set dynamic max Y limit
legend('Location', 'northeast');


%% --- 3. Simulation 8: Temporal Coherence Loss (Figure 8) ---

% Simplified Model: Observed Purity P_obs decays from the statistical ensemble average P_ens 
% due to beam wandering, modeled by P_obs = P_ens * exp(-tau / tau_0).
% We use the purity calculated at a strong Cn2 for the ensemble average P_ens.

% Constants for Temporal Model
tau_0 = 5e-3; % Atmospheric time constant (5 ms)
tau_range = logspace(-5, -2, 100); % Integration time range (10 us to 10 ms)

% Ensemble Purity (P_ens) calculation for l=1 and l=3 modes
P_ens_l1 = calc_Purity_l_l_general(1, w_ls_standard, w_gs, Cn2_moderate_fixed, z_fixed, 1, 0);
P_ens_l3 = calc_Purity_l_l_general(3, w_ls_standard, w_gs, Cn2_moderate_fixed, z_fixed, 1, 0);

% Calculate Observed Purity vs. Integration Time (tau)
P_obs_l1 = P_ens_l1 * exp(-tau_range ./ tau_0);
P_obs_l3 = P_ens_l3 * exp(-tau_range ./ tau_0);

figure(8);
loglog(tau_range * 1e3, P_obs_l1, 'r-', 'LineWidth', 2, 'DisplayName', 'l=1 Mode');
hold on;
loglog(tau_range * 1e3, P_obs_l3, 'b--', 'LineWidth', 2, 'DisplayName', 'l=3 Mode');
hold off;
grid on;
title('Observed Purity vs. Receiver Integration Time (\tau)');
xlabel('Integration Time \tau (ms)');
ylabel('Observed Mode Purity');
xlim([tau_range(1)*1e3, tau_range(end)*1e3]);
xline(tau_0 * 1e3, 'k:', 'DisplayName', '\tau_0 (Atmospheric Time)');
legend('Location', 'southwest');


%% --- 4. Simulation 9: BER vs. Structural Parameter (Figure 9) ---

% Engineering Metric: BER (Bit Error Rate). Use simplified model BER ~ 1/Purity^2.
% (Note: A true BER calc requires scintillation index, but this illustrates the principle.)

% Structural Ratio Range (w_ls / w_gs) - Same range as Figure 5
w_ls_range = linspace(0.5e-2, 5e-2, 50);
ratio_range = w_ls_range / w_gs;

% Calculate Purity for BER (Weak vs. Moderate Turbulence)
Cn2_weak = 1e-16;
Cn2_moderate = 5e-15;

Purity_weak = calc_Purity_l_l_general(l_launch, w_ls_range, w_gs, Cn2_weak, z_fixed, 1, 0);
Purity_moderate = calc_Purity_l_l_general(l_launch, w_ls_range, w_gs, Cn2_moderate, z_fixed, 1, 0);

% Calculate BER using the inverse purity relation (on a log scale)
% BER is proportional to the inverse of the square of purity
BER_weak = 1 ./ (Purity_weak.^2) * 1e-6; 
BER_moderate = 1 ./ (Purity_moderate.^2) * 1e-6; 
BER_max_visible = 1e-1; % Cap BER for visualization

figure(9);
semilogy(ratio_range, BER_weak, 'b-', 'LineWidth', 2, 'DisplayName', 'Weak Turbulence');
hold on;
semilogy(ratio_range, BER_moderate, 'r--', 'LineWidth', 2, 'DisplayName', 'Moderate Turbulence');
hold off;
grid on;
title('System BER vs. Structural Mixing Ratio (w_{ls} / w_{gs})');
xlabel('Structural Mixing Ratio w_{ls} / w_{gs}');
ylabel('Estimated Bit Error Rate (BER)');
ylim([1e-10, BER_max_visible]); 
legend('Location', 'southeast');
clear
close all
clc

%% generic settings
% set time vector
stepSize = 10; % fixed stepsize
startDateTime = datetime(2000,1,1,12,0,0);
stopDateTime = datetime(2000,1,9,8,11,30);
t = (startDateTime:seconds(stepSize):stopDateTime)';

% perturbing acceleration magnitude from thrust
f_T = 1e-5; % m/s^2

% satellite mass
m = 4.2; % kg

% drag coefficient
C_D = 2.2;

%% thrust satellite
% import data of thrusting satellite
maneuvering_thrust = "maneuvering_thrust_NRLMSISE00_density_and_velocity_mag.txt";
T_thrust = readtable(maneuvering_thrust);
T_thrust = T_thrust(2:end,:);

% extract air density and velocity magnitude
rho_thrust = T_thrust.V_Mag;
v_thrust = T_thrust.x_m_sec_;

% constant area of thrusting satellite
A_const = ones(numel(t),1) * 0.01;

% calculate specific drag force magnitude of thrusting satellite
f_D_thrust = (1/2) .* rho_thrust .* C_D .* A_const ./ m .* v_thrust.^2;

% calculate area profile
A = A_const + (2 * f_T * m) ./ (rho_thrust .* C_D .* v_thrust.^2);

% export area profile
T_out = table(seconds(t-startDateTime),A);
writetable(T_out,'VariableArea_overTime.txt','Delimiter','\t');

% import area profile into STK as drag area for drag satellite
% propagate drag satellite
% export air density and velocity magnitude of drag satellite

%% drag satellite
% import data of maneuvering drag satellite
maneuvering_drag = "maneuvering_drag_NRLMSISE00_density_and_velocity_mag.txt";
T_drag = readtable(maneuvering_drag);
T_drag = T_drag(2:end,:);

% extract air density and velocity magnitude
rho_drag = T_drag.V_Mag;
v_drag = T_drag.x_m_sec_;

% calculate specific drag force magnitude of drag satellite
f_D_drag = (1/2) .* rho_drag .* C_D .* A ./ m .* v_drag.^2;

% error assessment
f_thrust = f_D_thrust + f_T;
ef = f_D_drag - f_thrust;
ef_perc = (ef)./f_thrust;

%% Iteration 1
A_1 = (rho_thrust ./ rho_drag) .* A_const .* (v_thrust.^2 ./ v_drag.^2) + ...
      2 .* f_T .* m ./ (C_D .* rho_drag .* v_drag.^2);
f_D_drag_1 = (1/2) .* rho_drag .* C_D .* A_1 ./ m .* v_drag.^2;

% export area profile
T_out_1 = table(seconds(t-startDateTime),A_1);
writetable(T_out_1,'VariableArea_overTime_1.txt','Delimiter','\t');

%% plots
% plot area over time
figure
plot(t,A);
xlabel("Time t");
ylabel("A_{drag}(t) [m^2]");
title("Drag Area of Drag Satellite over Time");
hold on
plot(t,A_1);

% plot specific drag forces of thrust sat and drag sat
figure
plot(t,(f_D_thrust + f_T),t,f_D_drag,t,f_D_drag_1);
legend('f_{D,thrust} + f_T','f_{D,drag}','f_{D,drag,1}',location='northwest');
xlabel("Time t");
ylabel("[m/s^2]");
title("Acceleration Magnitudes of Thrusting and Drag Satellites");

% plot error in acceleration
figure
plot(t,ef);
grid on
xlabel("Time t");
ylabel("e_f [m/s^2]")
title("Acceleration Error of Drag Satellite w.r.t. Thrusting Satellite")

% plot error in acceleration in percent
figure
plot(t,ef_perc);
grid on
xlabel("Time t");
ylabel("e_f [%]")
title("Acceleration Error [%] of Drag Satellite w.r.t. Thrusting Satellite")
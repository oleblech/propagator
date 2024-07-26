% Verifying conversion of orbital elements to state vector in ECI
% Using example 4.7 on page 211 in "Orbital Mechanics for Engineering
% Students"

clear
close all
clc


h = 80000;      % km^2/s
e = 1.4;        
i = deg2rad(30);         % deg
RAAN = deg2rad(40);      % deg
w = deg2rad(60);         % deg
TA = deg2rad(30);        % deg

mu = 398600;  % m^3/s^2

a = h2a(h,e,mu); % m

elements = OrbitalElements([a,e,i,RAAN,w,TA], 'classical', mu);
stateVector1 = elements.toStateVector(mu);

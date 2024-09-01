clear
close all
clc

%% Define central body (e.g., Earth)
% WGS84
earthRadius = 6378136.3; % m 
gravitationalParameter = 3.986004415e14; % m^3/s^2
J2 = 0;
J2 = 1.0826261738521698e-3;

atmosphereModel = AtmosphereModel('none');
earth = CentralBody(earthRadius, gravitationalParameter, J2, atmosphereModel);

%% Define spacecraft using classical orbital elements, r_peri & r_apo, h_e
% Alternative initial condition definitions:
% conditionType = 'h_e';
% initialCondition = [5.234474772412042e+10,...   % h                    
%                     0.0291,...                  % e    
%                     deg2rad(67),...             % i        
%                     deg2rad(20),...             % RAAN        
%                     deg2rad(10),...             % w        
%                     deg2rad(0)];                % TA
% conditionType    = 'r_peri_r_apo';
% initialCondition = [earth.radius + 250e3,...    % r_peri
%                     earth.radius + 250e3,...    % r_apo
%                     deg2rad(97),...             % i
%                     deg2rad(20),...             % RAAN
%                     deg2rad(30),...             % w
%                     deg2rad(0)];               % TA
spacecraftMass = 4.2; % kg
dragArea = 0.15; % m^2
dragCoefficient = 2.2;
conditionType    = 'classical';
initialCondition = [earth.radius + 250e3,...    % a
                    0.0001,...                  % e
                    deg2rad(97),...             % i
                    deg2rad(20),...             % RAAN
                    deg2rad(30),...             % w
                    deg2rad(0)];                % TA

poi = PointOfInterest(-50, 45, 20, 20);

spacecraft = Spacecraft(spacecraftMass, dragArea, dragCoefficient, initialCondition, conditionType, earth, poi);

%% Define simulation
startTime = datetime(2000,1,1,12,0,0);
sampleTime = 10; % seconds
stopTime = startTime + hours(9);
altitudeLimit = 200e3; % m
maxStep = 10;
sim = Simulation(spacecraft, startTime, sampleTime, stopTime, altitudeLimit, maxStep);

%% Run simulation
% sim.plotTrajectory = true;
% sim.plotOrbitalElements = true;
sim.plotGroundTrack = true;
[trajectory,TE,YE,IE] = sim.run();


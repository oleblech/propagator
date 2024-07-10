clear
close all
clc

% Define central body (e.g., Earth)
earthMass = 5.974e24; % kg
earthRadius = 6.378e6; % m
J2 = 0;
J2 = 1.08262668e-3;
atmosphereModel = AtmosphereModel('USSA76');
earth = CentralBody(earthMass, earthRadius, J2, atmosphereModel);

% Define spacecraft using classical orbital elements, r_peri & r_apo, h_e
spacecraftMass = 4.2; % kg
dragArea = 0.15; % m^2
dragCoefficient = 2.2;
% conditionType    = 'classical';
% initialCondition = [earth.radius + 800e3,...    % a
%                     0.0001,...                  % e
%                     deg2rad(98.6),...           % i
%                     deg2rad(20),...             % RAAN
%                     deg2rad(10),...             % w
%                     deg2rad(0)];                % TA
conditionType    = 'r_peri_r_apo';
initialCondition = [earth.radius + 250e3,...    % r_peri
                    earth.radius + 300e3,...    % r_apo
                    deg2rad(97),...             % i
                    deg2rad(20),...             % RAAN
                    deg2rad(10),...             % w
                    deg2rad(0)];                % TA
% conditionType = 'h_e';
% initialCondition = [5.234474772412042e+10,...   % h                    
%                     0.0291,...                  % e    
%                     deg2rad(67),...             % i        
%                     deg2rad(20),...             % RAAN        
%                     deg2rad(10),...             % w        
%                     deg2rad(0)];                % TA        
spacecraft = Spacecraft(spacecraftMass, dragArea, dragCoefficient, initialCondition, conditionType, earth);

% Define propagator
timeStep = 10; % seconds
totalTime = 3600*3; % seconds
altitudeLimit = 200e3; % m
propagator = Propagator(spacecraft, earth, timeStep, totalTime, altitudeLimit);

% Run propagation
trajectory = propagator.propagate();

% Convert trajectory to orbital elements
elementsTrajectory = OrbitalElements.fromStateVector(trajectory, earth.gravitationalParameter);

% Plot central body and trajectory
f1 = figure;
hold on;
earth.plotCentralBody();
plot3(trajectory(:, 1), trajectory(:, 2), trajectory(:, 3), 'r', 'LineWidth', 0.5);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Spacecraft Trajectory around Earth');
grid on;
axis equal;

% Set fixed 3D view angle
azimuth = 45; % Azimuth angle
elevation = 30; % Elevation angle
view(azimuth, elevation);

% Plot orbital elements over time
f2 = figure;
subplot(3, 2, 1);
plot(linspace(0, totalTime, size(elementsTrajectory, 1)), elementsTrajectory(:, 1));
xlabel('Time (s)');
ylabel('Semi-major axis (m)');
title('Semi-major axis');

subplot(3, 2, 2);
plot(linspace(0, totalTime, size(elementsTrajectory, 1)), elementsTrajectory(:, 2));
xlabel('Time (s)');
ylabel('Eccentricity');
title('Eccentricity');

subplot(3, 2, 3);
plot(linspace(0, totalTime, size(elementsTrajectory, 1)), elementsTrajectory(:, 3));
xlabel('Time (s)');
ylabel('Inclination (rad)');
title('Inclination');

subplot(3, 2, 4);
plot(linspace(0, totalTime, size(elementsTrajectory, 1)), elementsTrajectory(:, 4));
xlabel('Time (s)');
ylabel('RAAN (rad)');
title('RAAN');

subplot(3, 2, 5);
plot(linspace(0, totalTime, size(elementsTrajectory, 1)), elementsTrajectory(:, 5));
xlabel('Time (s)');
ylabel('Argument of Periapsis (rad)');
title('Argument of Periapsis');

subplot(3, 2, 6);
plot(linspace(0, totalTime, size(elementsTrajectory, 1)), elementsTrajectory(:, 6));
xlabel('Time (s)');
ylabel('True Anomaly (rad)');
title('True Anomaly');

% Make figures fullscreen
set(f1,'WindowState','fullscreen');
pause(3);
set(f2,'WindowState','fullscreen');
clear
close all
clc

%% Define central body (e.g., Earth)
% WGS84
earthRadius = 6378136.3; % m 
gravitationalParameter = 3.986004415e14; % m^3/s^2
J2 = 0;
J2 = 1.08262617385216e-3;

atmosphereModel = AtmosphereModel('nrlmsise00');
earth = CentralBody(earthRadius, gravitationalParameter, J2, atmosphereModel);

%% Loop
totalRuntimeStart = tic;

N = 5;
for i = 1:N
    %% Define spacecraft using classical orbital elements, r_peri & r_apo or h_e
    tic;
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
    dragArea = linspace(0.01,0.15,N); % m^2
    dragCoefficient = 2.2;
    conditionType    = 'classical';
    initialCondition = [earth.radius + 350e3,...    % a
                        0.0001,...                  % e
                        deg2rad(97),...             % i
                        deg2rad(20),...             % RAAN
                        deg2rad(30),...             % w
                        deg2rad(0)];                % TA
    
    poi = PointOfInterest(-50, 45, 20, 20);
    
    spacecraft = Spacecraft(spacecraftMass, dragArea(i), dragCoefficient, initialCondition, conditionType, earth, poi);
    
    %% Define simulation
    startTime = datetime(2000,1,1,12,0,0);
    sampleTime = 30; % seconds
    stopTime = startTime + days(10);
    altitudeLimit = 200e3; % m
    maxStep = 30;
    sim = Simulation(spacecraft, startTime, sampleTime, stopTime, altitudeLimit, maxStep);
    
    %% Run simulation
    % sim.plotTrajectoryFlag = true;
    % sim.plotOrbitalElementsFlag = true;
    sim.plotGroundTrackFlag = true;
    [trajectory{i},TE{i},YE{i},IE{i}] = sim.run();

    toc;
    pause(1);
end
toc(totalRuntimeStart);

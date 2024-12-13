clear
close all
clc

tic;

%% Define central body (e.g., Earth)
% WGS84
earthRadius             = 6378136.3;        % m, from WGS84
gravitationalParameter  = 3.986004415e14;   % m^3/s^2, from WGS84
% J2                      = 0;
J2                      = 1.08262617385216e-3;
atmosphereModel         = AtmosphereModel('nrlmsise00');
angularVelocity         = 2*pi/(23*3600+56*60+4.09);

earth = CentralBody(earthRadius, gravitationalParameter, J2, atmosphereModel,angularVelocity);

%% Define target
targetLat       = 25.75;  % deg    
targetLon       = -80.25;   % deg   
targetHeight    = 20;   % deg       
targetWidth     = 20;   % deg

poi = PointOfInterest(targetLat,targetLon,targetHeight,targetWidth);

%% Define spacecraft initial state
startTime = datetime(2000,1,1,12,0,0);
altitude    = 350e3; % m
% horizontal flight path angle
gamma       = 0; % deg
% velocity azimuth angle
chi         = 60; % deg
% velocity magnitude
v_mag       = sqrt(earth.gravitationalParameter / (earth.radius + altitude));

initialCondition = OrbitalElements.fromMixedSpherical([poi.latitude poi.longitude altitude gamma chi v_mag],earth,startTime);

%% Define spacecraft mass and drag properties
spacecraftMass = 4.2; % kg
dragArea = 0.01; % m^2
dragCoefficient = 2.2;

spacecraft = Spacecraft(spacecraftMass, dragArea, dragCoefficient, initialCondition, 'classical', earth, poi);

%% Define simulation
sampleTime = 30; % seconds
stopTime = startTime + days(15);
altitudeLimit = 200e3; % m
maxStep = 10;

sim = Simulation(spacecraft, startTime, sampleTime, stopTime, altitudeLimit, maxStep);

%% Run simulation
% sim.plotTrajectoryFlag = true;
% sim.plotOrbitalElementsFlag = true;
sim.plotGroundTrackFlag = true;
[trajectory,trajLat,trajLon,TE,YE,IE] = sim.run();

toc;
save("target(25.75,-80.25)_alt(350e3)_chi(60)_days(15).mat")



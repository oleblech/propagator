%% Prepare workspace
clear
close all
clc

%% load propagated reference orbit and identify target latitude crossings
% load data
load("./sameInitAndTarget/target(25.75,-80.25)_alt(350e3)_chi(60)_days(15).mat");
% set time array
timeArray = sim.startTime:seconds(sim.sampleTime):sim.stopTime;

% Initialize empty arrays to store interpolated results
intersectTimes = [];
intersectLongitudes = [];

% Loop through latitude data to find target crossings
for i = 1:length(trajLat) - 1
    % Check if target latitude lies between trajLat(i) and trajLat(i+1)
    if (trajLat(i) < sim.spacecraft.poi.latitude && trajLat(i+1) > sim.spacecraft.poi.latitude) || ...
       (trajLat(i) > sim.spacecraft.poi.latitude && trajLat(i+1) < sim.spacecraft.poi.latitude)

        % Linear interpolation factor
        f = (sim.spacecraft.poi.latitude - trajLat(i)) / (trajLat(i+1) - trajLat(i));

        % Interpolate time, longitude, and argument of latitude at target latitude
        interpolatedTime = timeArray(i) + f * (timeArray(i+1) - timeArray(i));
        interpolatedLon = trajLon(i) + f * (trajLon(i+1) - trajLon(i));
        % Store interpolated values
        intersectTimes = [intersectTimes; interpolatedTime];
        intersectLongitudes = [intersectLongitudes; interpolatedLon];
    end
end

%% Calculate delta in longitude Delta_phi (deg) that has to be achieved by maneuvering satellite
Delta_phi = sim.spacecraft.poi.longitude - intersectLongitudes;

%% Calculate change in overflight time Delta_t (s)
Delta_t = deg2rad(Delta_phi)/sim.spacecraft.centralBody.angularVelocity;

%% Calculate arguments of latitude of overflight u_2 (rad)
t_2 = intersectTimes;
t_0 = sim.startTime;
mu = sim.spacecraft.centralBody.gravitationalParameter;
initialCondition = OrbitalElements.fromStateVector(sim.spacecraft.initialState,mu);
a_0 = initialCondition(1);
w_0 = initialCondition(5);
TA_0 = initialCondition(6);
u_0 = w_0 + TA_0;

u_2 = seconds(t_2 - t_0) * sqrt(mu/a_0^3) + u_0;

%% Calculate argument of latitude at the end of thrusting u_1 (rad)
% set pertubing acceleration magnitude
% (The equation eqs below are derived for the case the orbit is lowered. To
% look for solutions where the orbit is raised, the pertubing acceleration
% magnitude can just be set to a negative value. In theory this makes no
% sense, in practice it is the same as keeping the magnitude positive and
% deriving the equation eqs from scratch for the case where the orbit is
% raised)
A = 0.00001; % m/s^2

% Calculate argument of latitude at the end of thrusting u_1 (rad)
syms x
u_1 = zeros(numel(Delta_t),1);
for i = 1:numel(Delta_t)
    % time it takes reference satellite to reach desired final argument of latitude
    t_coast_ref = (u_2(i) - u_0)*sqrt(a_0^3/mu);
    % thrusting duration of maneuvering satellite
    t_thrust_maneuv = sqrt(mu)/A*((1/a_0^2 + 4/mu*A*(x - u_0))^(1/4) - a_0^(-1/2));
    % coasting duration of maneuvering satellite
    t_coast_maneuv = (u_2(i) - x)*sqrt(1/mu)*(1/a_0^2 + 4/mu*A*(x - u_0))^(-3/4);
    % change in overflight time Delta_t as a function of the argument of
    % latitude at the end of thrusting u_1
    eqn = Delta_t(i) == t_coast_ref - t_thrust_maneuv - t_coast_maneuv;
    % solve equation
    solution = vpasolve(eqn,x);
    % filter for legit solutions
    if ~isempty(solution)
        u_1(i) = solution;
    else
        u_1(i) = NaN;
    end
end

%% Calculate time of end of thrusting t_1
t_1 = t_2 - seconds((u_2 - u_1)*sqrt(a_0^3/mu));

%% Find indices of plausible maneuvers
plausible = find(t_2 > t_1 & t_1 > t_0);

%% Calculate results
% define important timing metrics
beginOfThrusting = repmat(startTime,[numel(plausible) 1]);
endOfThrusting = t_1(plausible);
thrustingDuration = endOfThrusting - beginOfThrusting;
timeOfOverflight = t_2(plausible) - seconds(Delta_t(plausible));
maneuverDuration = timeOfOverflight - beginOfThrusting;

%% Display results
% set up and plot table
T = table(plausible,beginOfThrusting,endOfThrusting,timeOfOverflight,thrustingDuration,maneuverDuration);
disp(T);

%% Plot ground track
sim.plotGroundTrack(trajLat,trajLon,"init","poi");

% plot latitude crossings
geoplot(repmat(sim.spacecraft.poi.latitude,numel(intersectLongitudes),1), intersectLongitudes, '*y', 'LineWidth', 2, 'DisplayName', 'Target Latitude Crossings');

% append numbers to latitude crossings
for i = 1:numel(intersectLongitudes)
    % Place text at each point, offset slightly for better visibility
    text(sim.spacecraft.poi.latitude, intersectLongitudes(i), num2str(i), 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end
save("./sameInitAndTarget/results_chi(60)_A(0.00001)_days(15).mat");

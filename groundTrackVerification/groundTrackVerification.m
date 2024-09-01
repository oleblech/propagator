clear
close all
clc

% load
load('llaMatlabJ2.mat')
load('llaStkJ2.mat')

% rename
% mat = llaMATLAB;
% stk = llaSTK;

mat = llaMatlabJ2;
stk = llaStkJ2;

%% initial LLA
% initial LLA Matlab
disp('Initial latitude MATLAB')
disp(degrees2dms(mat(1,1)));
disp('Initial longitude MATLAB')
disp(degrees2dms(mat(1,2)));
disp('Initial altitude MATLAB')
fprintf('%6.3f\n\n',mat(1,3));

% final LLA Matlab
disp('Final latitude MATLAB')
disp(degrees2dms(mat(end,1)));
disp('Final longitude MATLAB')
disp(degrees2dms(mat(end,2)));
disp('Final altitude MATLAB')
fprintf('%6.3f\n\n',mat(end,3));

%% final LLA
% initial LLA STK
disp('Initial latitude STK')
disp(degrees2dms(stk(1,1)));
disp('Initial longitude STK')
disp(degrees2dms(stk(1,2)));
disp('Initial altitude STK')
fprintf('%6.3f\n\n',stk(1,3));

% final LLA STK
disp('Final latitude STK')
disp(degrees2dms(stk(end,1)));
disp('Final longitude STK')
disp(degrees2dms(stk(end,2)));
disp('Final altitude STK')
fprintf('%6.3f\n\n',stk(end,3));

%% errors
% errors
eInitLat    = mat(1,1) - stk(1,1);
eInitLon    = mat(1,2) - stk(1,2);
eInitAlt    = mat(1,3) - stk(1,3);
eFinalLat   = mat(end,1) - stk(end,1);
eFinalLon   = mat(end,1) - stk(end,1);
eFinalAlt   = mat(end,3) - stk(end,3);

% errors in %
eInitLatPercent  = eInitLat  / 180 * 100;
eInitLonPercent  = eInitLon  / 360 * 100;
eFinalLatPercent = eFinalLat / 180 * 100;
eFinalLonPercent = eFinalLon / 360 * 100;

% display errors
disp('Error Init Latitude');
disp(degrees2dms(eInitLat));
disp('Error Init Latitude in %');
disp(eInitLatPercent);
disp('Error Init Longitude');
disp(degrees2dms(eInitLon));
disp('Error Init Longitude in %');
disp(eInitLonPercent);
disp('Error Init Altitude in m');
disp(eInitAlt);
disp('Error Final Latitude');
disp(degrees2dms(eFinalLat));
disp('Error Final Latitude in %');
disp(eFinalLatPercent);
disp('Error Final Longitude');
disp(degrees2dms(eFinalLon));
disp('Error Final Longitude in %');
disp(eFinalLonPercent);
disp('Error Final Altitude in m');
disp(eFinalAlt);

%% Max. Deviation LLA

error = mat - stk;

figure;
yyaxis left
plot(error(:,1:2));
xlabel('Time [h]');
set(gca,XTick=0:360*1.5:9*360);
set(gca,XTickLabel=xticks*10/3600);
ylabel('Latitude and Longitude [°]');
ylim([-20 10]);
xticks = xticks/10;
yyaxis right
plot(error(:,3))
ylabel('Altitude [m]');

grid on;
legend('Latitude','Longitude','Altitude');
title('Error: MATLAB - STK')

%% Max. Deviation ECI
load('MatTrajectoryJ2.mat');
load('StkTrajectoryJ2.mat');
rMat = MatTrajectoryJ2(:,1:3);
rStk = StkTrajectoryJ2(:,1:3);

r = rMat - rStk;

R = vecnorm(r,2,2);

figure;
plot(R,LineWidth=2);

xlabel('Time [h]');
set(gca,XTick=0:360*1.5:9*360);
set(gca,XTickLabel=xticks*10/360);

ylabel('Distance [km]');
set(gca,YTickLabel=yticks/1000);

grid on;
title('||r_{Matlab} - r_{STK}||_2')
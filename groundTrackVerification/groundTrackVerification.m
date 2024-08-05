clear
close all
clc

% load
load('LLA_STK.mat')
load('LLA_MATLAB.mat')

% rename
mat = llaMATLAB;
stk = llaSTK;

% get dms
latMatDms = degrees2dms(mat(:,1));
lonMatDms = degrees2dms(mat(:,2));
latStkDms = degrees2dms(stk(:,1));
lonStkDms = degrees2dms(stk(:,2));

% get latitudes
latMatInit = latMatDms(1,:);
latMatFinal= latMatDms(end,:);
latStkInit = latStkDms(1,:);
latStkFinal= latStkDms(end,:);

% get longitudes
lonMatInit = lonMatDms(1,:);
lonMatFinal= lonMatDms(end,:);
lonStkInit = lonStkDms(1,:);
lonStkFinal= lonStkDms(end,:);

% get altitudes
altMatInit = mat(1,3);
altMatFinal= mat(end,3);
altStkInit = stk(1,3);
altStkFinal= stk(end,3);

%% initial LLA
% initial LLA Matlab
disp('Initial latitude MATLAB')
disp(latMatDms(1,:));
disp('Initial longitude MATLAB')
disp(lonMatDms(1,:));
disp('Initial altitude MATLAB')
fprintf('%6.3f\n\n',altMatInit);

% final LLA Matlab
disp('Final latitude MATLAB')
disp(latMatDms(end,:));
disp('Final longitude MATLAB')
disp(lonMatDms(end,:));
disp('Final altitude MATLAB')
fprintf('%6.3f\n\n',altMatFinal);

%% final LLA
% initial LLA STK
disp('Initial latitude STK')
disp(latStkDms(1,:));
disp('Initial longitude STK')
disp(lonStkDms(1,:));
disp('Initial altitude STK')
fprintf('%6.3f\n\n',altStkInit);

% final LLA STK
disp('Final latitude STK')
disp(latStkDms(end,:));
disp('Final longitude STK')
disp(lonStkDms(end,:));
disp('Final altitude STK')
fprintf('%6.3f\n\n',altStkFinal);

%% errors
% errors
eInitLat    = latMatInit-latStkInit;
eInitLon    = lonMatInit-lonStkInit;
eInitAlt    = altMatInit-altStkInit;
eFinalLat   = latMatFinal-latStkFinal;
eFinalLon   = lonMatFinal-lonStkFinal;
eFinalAlt   = altMatFinal-altStkFinal;

% errors in %
eInitLatPercent = dms2degrees(eInitLat)/180*100;
eInitLonPercent = dms2degrees(eInitLon)/360*100;
eFinalLatPercent = dms2degrees(eFinalLat)/180*100;
eFinalLonPercent = dms2degrees(eFinalLon)/360*100;

% display errors
disp('Error Init Latitude in %');
disp(eInitLatPercent)
disp('Error Init Longitude in %');
disp(eInitLonPercent)
disp('Error Init Altitude in m')
disp(eInitAlt)
disp('Error Final Latitude in %');
disp(eFinalLatPercent)
disp('Error Final Longitude in %');
disp(eFinalLonPercent)
disp('Error Final Altitude in m')
disp(eFinalAlt)

%% Max. Deviation

error = mat-stk;
maxError = max(error);
maxLatErrorPercent = maxError(1)/180*100;
maxLonErrorPercent = maxError(2)/360*100;
maxAltError = maxError(3);

disp('max. lat error in %');
disp(maxLatErrorPercent);
disp('max. lon error in %');
disp(maxLonErrorPercent);
disp('max. alt error in m');
disp(maxAltError);


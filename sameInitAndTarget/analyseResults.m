close all
clear
clc

addpath('./../');
load('results_chi(60).mat')

T.altitudeOfOverflight = [287; 340; 229; 284; NaN; 324; NaN; NaN; 338; NaN; NaN; NaN; NaN; 291; NaN; NaN; NaN; 307]; % km
nonNaN = ~isnan(T.altitudeOfOverflight);
% special sets: one maneuver gives multiple revisits
ss1 = zeros(1,18);
ss2 = zeros(1,18);
ss1([2,9]) = 1;
ss2([1,14]) = 1;
ss1 = logical(ss1);
ss2 = logical(ss2);

% plot all solutions
figure
semilogy(hours(T.maneuverDuration),hours(T.thrustingDuration),'kx',Linewidth=2);
xlabel("Time to Revisit");
ylabel("Thrusting Duration");
grid on
ylim([1 5*24])
yticks([1 2 6 12 24 3*24 5*24]);
yticklabels(["1 h","2 h","6 h","12 h","1 d","3 d","5 d"]);
xlim([0 5.5*24]);
xticks(24:24:5*24);
xticklabels(["1 d","2 d","3 d","4 d","5 d",]);
legend("given solutions",Location="northwest");

% mark feasible solutions green, mark non-feasible solutions red
figure
% non-feasible
semilogy(hours(T.maneuverDuration(~nonNaN)),hours(T.thrustingDuration(~nonNaN)),'rx',Linewidth=2);
hold on
% feasible
semilogy(hours(T.maneuverDuration(nonNaN)),hours(T.thrustingDuration(nonNaN)),'gx',Linewidth=2);
xlabel("Time to Revisit");
ylabel("Thrusting Duration");
grid on
ylim([1 5*24])
yticks([1 2 6 12 24 3*24 5*24]);
yticklabels(["1 h","2 h","6 h","12 h","1 d","3 d","5 d"]);
xlim([0 5.5*24]);
xticks(24:24:5*24);
xticklabels(["1 d","2 d","3 d","4 d","5 d",]);
legend("non-feasible","feasible",Location="northwest");

% highlight special sets
figure
% non-feasible
semilogy(hours(T.maneuverDuration(~nonNaN)),hours(T.thrustingDuration(~nonNaN)),'rx',Linewidth=2);
hold on
% feasible without special sets
semilogy(hours(T.maneuverDuration(xor(nonNaN',or(ss1,ss2)))),hours(T.thrustingDuration(xor(nonNaN',or(ss1,ss2)))),'gx',Linewidth=2);
% special set 1
semilogy(hours(T.maneuverDuration(ss1)),hours(T.thrustingDuration(ss1)),'mo',Linewidth=2);
% special set 2
semilogy(hours(T.maneuverDuration(ss2)),hours(T.thrustingDuration(ss2)),'m^',Linewidth=2);
xlabel("Time to Revisit");
ylabel("Thrusting Duration");
grid on
ylim([1 5*24])
yticks([1 2 6 12 24 3*24 5*24]);
yticklabels(["1 h","2 h","6 h","12 h","1 d","3 d","5 d"]);
xlim([0 5.5*24]);
xticks(24:24:5*24);
xticklabels(["1 d","2 d","3 d","4 d","5 d",]);
legend("non-feasible","feasible","feasible, special set 1", "feasible, special set 2",Location="northwest");

% add altitude of overflight annotations
figure
% non-feasible
semilogy(hours(T.maneuverDuration(~nonNaN)),hours(T.thrustingDuration(~nonNaN)),'rx',Linewidth=2);
hold on
% feasible without special sets
semilogy(hours(T.maneuverDuration(xor(nonNaN',or(ss1,ss2)))),hours(T.thrustingDuration(xor(nonNaN',or(ss1,ss2)))),'gx',Linewidth=2);
% special set 1
semilogy(hours(T.maneuverDuration(ss1)),hours(T.thrustingDuration(ss1)),'mo',Linewidth=2);
% special set 2
semilogy(hours(T.maneuverDuration(ss2)),hours(T.thrustingDuration(ss2)),'m^',Linewidth=2);
xlabel("Time to Revisit");
ylabel("Thrusting Duration");
grid on
ylim([1 5*24])
yticks([1 2 6 12 24 3*24 5*24]);
yticklabels(["1 h","2 h","6 h","12 h","1 d","3 d","5 d"]);
xlim([0 5.5*24]);
xticks(24:24:5*24);
xticklabels(["1 d","2 d","3 d","4 d","5 d",]);
legend("non-feasible","feasible","feasible, special set 1", "feasible, special set 2",Location="northwest");
text(hours(T.maneuverDuration(nonNaN)) + 2,hours(T.thrustingDuration(nonNaN)),num2str(T.altitudeOfOverflight(nonNaN)) + " km");
title("Evaluated Solutions with approximate Altitude of Overflight")
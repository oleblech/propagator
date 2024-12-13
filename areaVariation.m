% load areaVariation.mat;

N = size(TE,2);
%% initialize
utcDateTimeContacts         = cell(1,N);
diffContacts                = cell(1,N);       
contactDurations            = cell(1,N);    
revisitTimes                = cell(1,N);
rtVec                       = [];
rtLabels                    = [];
maxSize                     = 0;

%% extract relevant data
for i = 1:N
    utcDateTimeContacts{i}  = startTime + seconds(TE{:,i});
    utcDateTimeContacts{i}  = utcDateTimeContacts{i}(IE{:,i} == 2);
    diffContacts{i}         = diff(utcDateTimeContacts{i});
    contactDurations{i}     = hours(diffContacts{i}(1:2:end));
    revisitTimes{i}         = hours(diffContacts{i}(2:2:end));
    rtVec                   = [rtVec; revisitTimes{i}];
    rtLabels                = [rtLabels; repmat(string(dragArea(i)),[numel(revisitTimes{i}), 1])];
    maxSize                 = max(size(revisitTimes{i},1),maxSize);
end

rtArray                     = zeros(maxSize,N);
for i = 1:N
    rtArray(1:size(revisitTimes{i},1),i) = revisitTimes{i};
end

%% create contact vector
timeGrid = startTime:seconds(30):stopTime;
% initialize contactVector
contactVector = zeros(N,size(timeGrid,2));
% loop through every satellite
for i = 1:N
    % loop through every contact
    for j = 1:2:length(utcDateTimeContacts{i})
        startIdx = find(timeGrid >= utcDateTimeContacts{i}(j), 1);
        endIdx = find(timeGrid <= utcDateTimeContacts{i}(j+1), 1, 'last');
        contactVector(i,startIdx:endIdx) = 1;
    end
end

% plot contactVector
figure
tiledlayout(5,1)
for i = 1:N
    nexttile;
    plot(contactVector(i,:));
    ylim([0 1.2]);
    ylabel('A = ' + string(dragArea(i)) + ' m^2');
    if i==1
        title('Contacts over Time');
    end
end
xlabel('10^4 seconds since start');
exportgraphics(gcf,'./Contacts over Time.pdf')

%% create boxplot
figure
boxplot(rtVec,rtLabels);
xlabel('drag area [m^2]');
ylabel('revisit time [h]');
title('Variation of Revisit Time due to Variation of Drag Area');
ylim([9.8 13.75]);
grid minor

exportgraphics(gca,'./Revisit Time over Drag Area.pdf')
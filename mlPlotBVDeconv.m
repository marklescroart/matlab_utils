function mlPlotBVDeconv(Data,Lines)

% Usage: mlPlotBVDeconv(Data)
%
% Input "Data" has to be in the form of a struct array, with the fields:
%
%  .Subject = subject's initials
%  .nGroups = number of curves to be plotted
%  .Colors  = Color look-up table for the plotted curves, in the form:
%              Curve1R Curve1G Curve1B
%              Curve2R Curve2G Curve2B
%              etc...
%              (Color values are 0-256 RGB Triples)
%  .Length  = length of each data set (should usually be 20)
%  .Data    = Actual Data, in the form of a cell array
%              {nGroups}(Length x 2)
%
% All this is the output of the function mlBV_FileReader
%
% Created by ML on 3.30.07


%% Input Check:
if ~exist('Data','var')
    error('I need some data to work with, bonehead.')
end
if ~exist('Lines','var')
    Lines = 1:Data.nGroups;
end

%% Plotting:
hDeconv = figure;

try
    Data.Betas = Data.Data;
    for iPct = 1:length(Data.Data)
        Data.Data{iPct} = Data.Betas{iPct}/Data.DC*100;
    end
    Flag.Pct = 1;
    Low = -.2;
    ylab = '% Signal change';
catch
    disp('Did not succeed in converting to % signal change...');
    Flag.Pct = 0;
    Low = -1;
    ylab = 'Beta Weights';
end

for iM = 1:length(Data.Data);
    Peak(iM) = max(max(Data.Data{iM}));
    %Low(iM) = min(min(Data.Data{iM}));
end
if Flag.Pct
    Peak = ceil(max(Peak*10))/10;
else
    Peak = ceil(max(Peak));
end
%Low = floor(min(Low));
set(gca, 'ylim',[Low Peak],'xlim',[0 Data.Length+1]); %'colororder',Data.Colors/255,
set(gca,'linewidth',1.5,'FontSize',18);
xlabel('Time from Stim Onset','FontSize',20);
ylabel(ylab,'FontSize',20);

title(['Subject ' Data.Subject ' ' Data.ROI ' Deconv Plot'],'FontSize',20);
hold all;
for iDeconv = Lines
    errorbar(Data.Data{iDeconv}(:,1),Data.Data{iDeconv}(:,2),'linewidth',1.5,'Color',Data.Colors(iDeconv,:)/255);
end
hold off;

whitebg(hDeconv,[1 1 1]);
set(gca,'linewidth',.5);
hold on;
plot(0:Data.Length+1,zeros(1,Data.Length+2),'w')
plot(0:Data.Length+1,ones(1,Data.Length+2),'w')
hold off;

try
    legend(Data.ConditionNames(Lines));
catch
    disp('No Condition Names found... no legend will be added');
end

% To plot maxes in bar graph:
%for ii = 1:4; test(ii) = mean(VV.Data{ii}(4:6)); end; figure; bar(test)
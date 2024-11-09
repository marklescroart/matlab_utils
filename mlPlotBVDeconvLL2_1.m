function mlPlotBVDeconvLL2_1(Data)

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

%% Modifying "Data" struct - averaging baselines into one

for ii = 1:6; 
    disp(ii)
    Curves(:,ii) = Data.Data{ii}(:,1); 
    SDs(:,ii) = Data.Data{ii}(:,2); 
end

Baselines = Curves(:,4:6)';
BaseSDs = SDs(:,4:6)';

NewBase(:,1) = mean(Baselines)';
NewBase(:,2) = sqrt(sum(BaseSDs.^2))';


Data.Data = {Data.Data{1:3} NewBase};
col = Data.Colors(1:3,1:3);
col(4,:) = Data.Colors(5,:);
Data.Colors = col;
Data.nGroups = 4;

%% Plotting:
hDeconv = figure;

set(gca,'colororder',Data.Colors/255, 'ylim',[-1 2],'xlim',[0 Data.Length+1]);
set(gca,'linewidth',1.5,'FontSize',18);
xlabel('Time from Stim Onset','FontSize',20);
ylabel('Beta weights','FontSize',20);

title(['Subject ' Data.Subject ' ' Data.ROI ' Deconv Plot'],'FontSize',20);
hold all;
for iDeconv = 1:Data.nGroups
    errorbar(Data.Data{iDeconv}(:,1),Data.Data{iDeconv}(:,2),'linewidth',1.5);
end
hold off;
whitebg(hDeconv,[0 0 0]);
set(gca,'linewidth',.5);
hold on;
plot(0:Data.Length+1,zeros(1,Data.Length+2),'w')
plot(0:Data.Length+1,ones(1,Data.Length+2),'w')
hold off;

legend('X Vertical Meridian','X Horizontal Meridian','Within-Quadrant','Same Position Twice');

% To plot maxes in bar graph:
%for ii = 1:4; test(ii) = mean(VV.Data{ii}(4:6)); end; figure; bar(test)
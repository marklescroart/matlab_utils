function mlTransformETData(InptFile,RealOffSet,UseCalRun)

% Usage: 
% Input a .eyeS file

%%% NOTES: 

%%%FLAGRANT CHEAT (to get ED in)
load '/Users/Work/Documents/Neuro_Docs/Projects-IUL/Play/AG_04_20_07/EyeData/AG_042007_SceneRep_mod.mat';

if ~exist('RealOffSet','var')
    RealOffSet = 250; %250 for KH's code; 304 For ML's code
end
if ~exist('UseCalrun','var')
    UseCalRun = 0;
end

ETDat = textread(InptFile);

%%% Creating temp values for XX and YY (XX1 and YY1), without NaNs
XX = ETDat(:,1);
XX1 = XX(find(~isnan(XX)));
YY = ETDat(:,2);
YY1 = YY(find(~isnan(YY)));
UpsideDown = -1;
%%% Use Calibration run:
if UseCalRun
    XLeft = mean( XX1( find(XX1 < mean(XX1)-40) ) );
    XRight = mean( XX1( find(XX1 > mean(XX1)+40) ) );
    XCenter = mean(XX1);

    YTop = mean( YY1( find(YY1 < mean(YY1)-40) ) );
    YBot = mean( YY1( find(YY1 > mean(YY1)+40) ) );
    YCenter = mean(YY1);

    DiffX(1) = abs(XCenter-XLeft);
    DiffX(2) = abs(XCenter-XRight);
    ETOffSetX = mean(DiffX);

    DiffY(1) = abs(YCenter-YTop);
    DiffY(2) = abs(YCenter-YBot);
    ETOffSetY = mean(DiffY);
    %%% Display Derived Calibration point values:
    % TileFigs(3);
    %
    % figure(1);
    % plot(XX1)
    % hold on;
    % plot(XLeft*ones(length(XX1)),'r-')
    % plot(XRight*ones(length(XX1)),'r-')
    % plot(XCenter*ones(length(XX1)),'r-')
    % hold off;
    %
    % figure(2);
    % plot(YY1,'g-')
    % hold on;
    % plot(YTop*ones(length(YY1)),'r-')
    % plot(YBot*ones(length(YY1)),'r-')
    % plot(YCenter*ones(length(YY1)),'r-')
    % hold off;

%%% Or if not:
else
    XLeft   = ET.calpts(1,1);
    XRight  = ET.calpts(3,1);
    XCenter = ET.calpts(5,1);
    YTop    = ET.calpts(1,2);
    YBot    = ET.calpts(9,2);
    YCenter = ET.calpts(5,2);
    ETOffSetX = ET.calpts(2,1)-ET.calpts(1,1);
    ETOffSetY = ET.calpts(7,2) - ET.calpts(6,2);
end

%%% To compare Derived calibration points against given calibration points:
figure;
plot(XX1);
hold on;
plot(ET.calpts(1,1)*ones(length(XX1)),'g-');
plot(ET.calpts(2,1)*ones(length(XX1)),'g-');
plot(ET.calpts(3,1)*ones(length(XX1)),'g-');
hold off;
title('X calibration point fit');
% (and then the same for y)
figure;
plot(YY1);
hold on;
plot(ET.calpts(1,2)*ones(length(XX1)),'g-');
plot(ET.calpts(4,2)*ones(length(XX1)),'g-');
plot(ET.calpts(7,2)*ones(length(XX1)),'g-');
hold off;
title('Y calibration point fit');

%% Actual transformation of values in code:


XX = XX-XCenter;
XX = XX/ETOffSetX * RealOffSet;
XX = XX+512;

YY = YY-YCenter;
YY = YY/ETOffSetY * UpsideDown * RealOffSet; % Because the MRI Eyetracker records y position negative as UP for some idiotic reason
YY = YY+384;

figure(3); 
plot(XX,YY);
set(gca,'xlim',[0 1024],'ylim',[0 768])

NewFile(:,1) = XX;
NewFile(:,2) = YY;

dlmwrite([InptFile(1:end-5) '_mod.eyeS'],NewFile,'delimiter','\t');




function mlET_TrialPlot(SubjID,Sub_Exp,RunNum,sf,Clip)

% Usage: mlET_TrialPlot(SubjID,Sub_Exp,RunNum,sf,Clip)
% 
% OK this is going to be particular to SceneRepresentation - make it
% general later
% 
% 
% (Still a work in progress)


if ~exist('SubjID','var')
    SubjID = 'DR';
end
if ~exist('Clip','var')
    Clip = [28 12]; % [beginning clip, end clip]
end
if ~exist('Sub_Exp','var')
    Sub_Exp = '/MRI_T1wSwap/';
end
if ~exist('sf','var')
    sf = 240;
end
if ~exist('RunNum','var')
    RunNum = 1;
end

% Possibly modifiable params:
fExt = 'ceyeS';
nSecPerTr = 2;
KillSecs = 1.9;
nLookBacks = 2;

pPath = ['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/'];
fPath = ['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/' Sub_Exp];
fldr = dir(['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/' Sub_Exp SubjID '*']);

%Files = mlStructExtract(dir([fPath fldr.name '/EyeData/*real.' fExt]),'name');
Files = mlStructExtract(dir([fPath fldr.name '/EyeData/*.' fExt]),'name');
%PRTlist = mlStructExtract(dir([fPath '/PRTs_RTCs_T1wSwap/*.prt']),'name');
PRTlist = mlStructExtract(dir([fPath fldr.name '/PRTs_RTCs/*.prt']),'name');

%PRTfile = [fPath 'PRTs_RTCs_T1wSwap/' PRTlist{RunNum}];
PRTfile = [fPath fldr.name '/PRTs_RTCs/' PRTlist{RunNum}];
ETfile = [fPath fldr.name '/EyeData/' Files{RunNum}];

% New, Temp: Trying to mkae sure the eye angle correlation that we're doing
% is not a pile of poop

EP1 = importdata([pPath 'Sub' SubjID 'EyePos1.txt']);
Emean = importdata([pPath 'Sub' SubjID 'EyeMean1.txt']);
EA = importdata([pPath 'Sub' SubjID 'EyeAngle.txt']);

RunIdx = (216*(RunNum-1)+1):216*RunNum; %assumes 216 trials
EP1 = EP1(RunIdx,:);
Emean = Emean(RunIdx,:);
EA = EA(RunIdx,:);

% Reading in Data:
disp(['Using PRT file: ' PRTfile]);
PP = BVQXfile(PRTfile);
TCm = mlBVPlotPRT(PRTfile,0);
for iC = 1:length(TCm); TC(iC) = find(TCm(iC,:)); end
TC = TC(nSecPerTr:nSecPerTr:end);


ED = importdata(ETfile);%[fPath 'VV_08_23_07/EyeData/VV_EyeData_Run1real.ceyeS']);
ED = ED(sf*Clip(1)+1:end-sf*Clip(2),:);

% Misc setup:
hh(1) = figure('Position',[41   316   709   517]);
hh(2) = figure('Position',[38   132   711   161]);

Cols = ['r' 'g' 'b' 'c' 'y' 'k'];
labels = {'Fixation','Saccade','Blink','Sac+Blink','Sm. Pursuit','Artifact'};

% Chopping off first two trials (not enough lookbacks, not analyzed in MRI,
% forget 'em)
RunPosData = importdata([fPath 'Run' num2str(RunNum) '.xls']);
if isstruct(RunPosData);
    StimPosData = RunPosData.Sheet1(3:end,2:2:8);
else
    StimPosData = RunPosData(3:end,2:2:8);
end

% stim pos will be: (Trial,xory,pos1or2,stim1or2)
StimPos(:,1,1,1) = round(512+100*cosd(StimPosData(:,1))); %S1P1x
StimPos(:,1,2,1) = round(512+100*cosd(StimPosData(:,2))); %S1P2x
StimPos(:,2,1,1) = round(384-100*sind(StimPosData(:,1))); %S1P1y
StimPos(:,2,2,1) = round(384-100*sind(StimPosData(:,2))); %S1P2y

StimPos(:,1,1,2) = round(512+100*cosd(StimPosData(:,3))); %S2P1x
StimPos(:,1,2,2) = round(512+100*cosd(StimPosData(:,4))); %S2P2x
StimPos(:,2,1,2) = round(384-100*sind(StimPosData(:,3))); %S2P1y
StimPos(:,2,2,2) = round(384-100*sind(StimPosData(:,4))); %S2P2y

% Circular (or Directional) statistics to average polar angles:
SASin = [mean(sind(StimPosData(:,1:2)),2),mean(sind(StimPosData(:,3:4)),2)];
SACos = [mean(cosd(StimPosData(:,1:2)),2),mean(cosd(StimPosData(:,3:4)),2)];
for iSA = 1:length(SASin)
    for iS12 = 1:2
        if SASin(iSA,iS12)>0 && SACos(iSA,iS12)>0
            SA(iSA,iS12) = atand(SASin(iSA,iS12)/SACos(iSA,iS12));
        elseif SACos(iSA,iS12) < 0
            SA(iSA,iS12) = atand(SASin(iSA,iS12)/SACos(iSA,iS12))+180;
        elseif SASin(iSA,iS12)<0 && SACos(iSA,iS12)>0
            SA(iSA,iS12) = atand(SASin(iSA,iS12)/SACos(iSA,iS12))+360;
        end
    end
end
SA = round(SA);

try

% Trial Loop:
for iTr = 1:length(ED)/(sf*nSecPerTr) - nLookBacks
    Idx = (iTr-1)*sf*nSecPerTr+1:iTr*sf*nSecPerTr-(KillSecs*sf);
    figure(hh(1));
    
    plot(StimPos(iTr,1,1,1),StimPos(iTr,2,1,1),'rs');
    hold on;
    plot(StimPos(iTr,1,2,1),StimPos(iTr,2,2,1),'r*');
    %plot(StimPos(iTr,1,1,2),StimPos(iTr,2,1,2),'gs');
    %plot(StimPos(iTr,1,2,2),StimPos(iTr,2,2,2),'g*');
    hold off;
    if strcmp(fExt,'ceyeS')
        % Plotting each point in the color-appropriate lablel:
        for iS = 1:length(Idx) %sf-1
            hold on;
            plot(ED(Idx(iS),1),ED(Idx(iS),2),'.','Color',Cols(ED(Idx(iS),4)+1));
            plot(ED(Idx(1),1),ED(Idx(1),2),'y.')
            hold off;
        end
    else
        figure(hh(1));
        hold on; 
        plot(ED(Idx,1),ED(Idx,2),'r.');
        plot(ED(Idx(1),1),ED(Idx(1),2),'y*')
        hold off;
    end
    %disp(sprintf('Point 1: (%.0f, %.0f)',ED(Idx(1),1),ED(Idx(1),2)));
    % new & Possibly unneccessary:
    hold on; 
    plot(EP1(iTr,1),EP1(iTr,2),'ys')
    plot(Emean(iTr,1),Emean(iTr,2),'y*')
    hold off;
    
    mlScreenFig([1024 768],128,1,1);
    title({['Trial number ' num2str(iTr) ' - ' PP.ConditionNames{TC(iTr)} ' Condition'],['Eye Angle = ' num2str(EA(iTr,1)) ', Stim Angle = ' num2str(SA(iTr,1))]})
    
    if strcmp(fExt,'ceyeS')
        % bar graph of labels for each point in the trial:
        figure(hh(2));
        for iC = 0:5;
            bb(iC+1) = length(find(ED(Idx,4)==iC))/(sf*nSecPerTr);
        end
        plot(1,1);
        for ib = 1:6;
            dum = zeros(ib,1);
            dum(end) = bb(ib);
            hold on; bar(dum,Cols(ib)); hold off;
        end
        set(gca,'xlim',[0 7],'xtick',[1 2 3 4 5 6],'xticklabel',labels,'ytick',[.1 .3 .5 .7 .9])
        ylabel('Percent of trial');
    end
    drawnow;
    mlQuitKeyTimer(GetSecs+.2);
    buttons = 0;
    while ~any(buttons); [a b buttons] = GetMouse; end
end

catch
    mlErrorCleanup;
    rethrow(lasterror);
end

function mlET_TrialPlot(SubjID,RunNum,StartAt,Sub_Exp,sf,Clip)

% Usage: mlET_TrialPlot(SubjID,RunNum,StartAt,Sub_Exp,sf,Clip)
% 
% This is going to be particular to LOScaleTrans - make it
% general later
% 
% 
% (Still a work in progress)
% Inputs     = {'SubjID','StartAt','Clip','Sub_Exp','sf','RunNum'};
% InptValues = {'BC'    , 1       ,[24 8],'MRI/'   ,240,1};
% mlDefaultInputs;
if ~exist('SubjID','var')
    SubjID = 'BC';
end
if ~exist('StartAt','var')
    StartAt = 1;
end
if ~exist('Clip','var')
    Clip = [28 8]; % [beginning clip, end clip]
end
if ~exist('Sub_Exp','var')||isempty(Sub_Exp)
    Sub_Exp = 'MRI/';
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
KillSecs = 1.4;
nLookBacks = 2; % NOTE: only information taken from the experiment record's .mat files 
                % need to be modified with this - "Clip" will take care of
                % removing extra trials from the beginning of ET data
pPath = ['/Users/Work/Documents/Neuro_Docs/Projects-IUL/LOScaleTrans/'];


% Leave the following alone (maybe): 

% Finding relevant files:
fPath = [pPath Sub_Exp];
fldr = dir([fPath SubjID '*']);
FileList = mlStructExtract(dir([fPath fldr.name '/EyeData/*.' fExt]),'name');
PRTlist = mlStructExtract(dir([fPath fldr.name '/PRTs_RTCs/*.prt']),'name');
PRTlist = grep(PRTlist,'-v','NoErrors','LOC');
PRTfile = [fPath fldr.name '/PRTs_RTCs/' PRTlist{RunNum}];
ETfile = [fPath fldr.name '/EyeData/' FileList{RunNum}];

% Reading in Data:
disp(['Using PRT file: ' PRTfile]);
PP = BVQXfile(PRTfile);
TCm = mlBV_PRTPlot(PRTfile,0);
for iC = 1:length(TCm); TC(iC) = find(TCm(iC,:)); end
TC = TC(nSecPerTr:nSecPerTr:end);

ET = importdata(ETfile);
ET = ET(sf*Clip(1)+1:end-sf*Clip(2),:);

% Figure setup:
hh(1) = figure('Position',[41   316   709   517]);
hh(2) = figure('Position',[38   132   711   161]);
load MLColorsOpenGL

% For plotting ET labels (according to dberg's conventions)
Cols = ['r' 'g' 'b' 'c' 'y' 'k'];
labels = {'Fixation','Saccade','Blink','Sac+Blink','Sm. Pursuit','Artifact'};

% loading subject's experiment data file:
ExpFiles = mlStructExtract(dir([fPath fldr.name '/PRTs_RTCs/' SubjID '*.mat']),'name');
load([fPath fldr.name '/PRTs_RTCs/' ExpFiles{RunNum}]);
CorrResp = mlStructExtract(ED.TA,'CorrResp');
CorrResp = CorrResp(nLookBacks+1:end);

% loading Stim Position Info:
StimPos = zeros(length(ED.TA),4);
for ii = 1:length(ED.TA); 
    [StimPos(ii,1),StimPos(ii,2)] = RectCenter(ED.TA(ii).ImRect(1,:)); 
    [StimPos(ii,3),StimPos(ii,4)] = RectCenter(ED.TA(ii).ImRect(2,:)); 
end
% Chopping off first two trials (not enough lookbacks, not analyzed in MRI, forget 'em):
StimPos = StimPos(1+nLookBacks:end,:);

try
    % Trial Loop:
    for iTr = StartAt:length(ET)/(sf*nSecPerTr)
        % Index for which ET points to plot:
        Idx = (iTr-1)*sf*nSecPerTr+1:iTr*sf*nSecPerTr-(KillSecs*sf);
        figure(hh(1));
        scatter(StimPos(iTr,[1 3]),StimPos(iTr,[2 4]),pi*25^2,[GLCol.Green;GLCol.Red]);
        text(StimPos(iTr,1),StimPos(iTr,2),'S1','Color','g');
        text(StimPos(iTr,3),StimPos(iTr,4),'S2','Color','r');
        if strcmp(fExt,'ceyeS')
            % Plotting each point in the color-appropriate lablel:
            for iS = 1:length(Idx) %sf-1
                hold on;
                plot(ET(Idx(iS),1),ET(Idx(iS),2),'.','Color',Cols(ET(Idx(iS),4)+1));
                plot(ET(Idx(1),1),ET(Idx(1),2),'y.')
                hold off;
            end
        else
            figure(hh(1));
            hold on;
            plot(ET(Idx,1),ET(Idx,2),'r.');
            plot(ET(Idx(1),1),ET(Idx(1),2),'y*')
            hold off;
        end
        %disp(sprintf('Point 1: (%.0f, %.0f)',ET(Idx(1),1),ET(Idx(1),2)));
        % new & Possibly unneccessary:
        %hold on;
        %plot(EP1(iTr,1),EP1(iTr,2),'ys')
        %plot(Emean(iTr,1),Emean(iTr,2),'y*')
        %hold off;

        mlScreenFig([1024 768],128,1,1);
        title({['Trial number ' num2str(iTr) ' - ' PP.ConditionNames{TC(iTr)} ' Condition'],['Response = ' num2str(CorrResp(iTr))]})

        if strcmp(fExt,'ceyeS')
            % bar graph of labels for each point in the trial:
            figure(hh(2));
            for iC = 0:5;
                bb(iC+1) = length(find(ET(Idx,4)==iC))/(sf*(nSecPerTr-KillSecs));
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
        %%% TEMPORARY:
        warning('off','all')
        figure(3); plot(ET(Idx,1:2));
        hold on; plot(1:.1*sf,400*ones(1,1:.1*sf),'r.'); hold off %.1 = imtime, 144 = .6 sec * 240 (sf)
        hold on; plot(144-.1*sf+1:144,400*ones(1,1:.1*sf),'r.'); hold off
        warning('on','all')
        %%% END TEMP.
        drawnow;
        mlQuitKeyTimer(GetSecs+.2);
        buttons = 0;
        while ~any(buttons); [a b buttons] = GetMouse; end
    end

catch
    mlErrorCleanup;
    rethrow(lasterror);
end

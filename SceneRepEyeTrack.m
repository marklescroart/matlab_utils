function SceneRepEyeTrack(SubjInits,RunNum,Sub_Exp,WhichPlot,binMsTime) %(inputfile,PRTfile,StimPos1File,binMsTime)

% Usage: SceneRepEyeTrack(SubjInits,RunNum [,Sub_Exp] [,WhichPlot] [,binMsTime])
% 
% Inputs & Default Values: 
% 
% SubjectInits - Subject Initials
% RunNum - Which Run of the experiment you're interested in 
% Sub_Exp - Which of the various versions of the Scene Representation experiment you're interested in. 
%           Default is 'MRI_GlobFeat/'. Other options are 'MRI_T1T2LD', 'MRI_T1T2Reg', 'MRI_T1T2ContrRev',
%           or 'MRI_T1wSwap'
% WhichPlot - What to plot. Default = 'None'; options: 'Bad Trials', 'Quick Look'
% binMSTime

%% Inputs:
if ~exist('SubjInits','var')
    SubjInits = 'KH';
end
if ~exist('Sub_Exp','var')
    Sub_Exp = 'MRI_GlobFeat/';
end
    
path = ['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/' Sub_Exp];
fldr = dir(['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/' Sub_Exp SubjInits '*']);
Files = mlStructExtract(dir([path fldr.name '/EyeData/*real.ceyeS']),'name');

if ~exist('RunNum','var')
    RunNum = 1;
end
if ~exist('WhichPlot','var')
    WhichPlot = 'None'; %'Bad Trials' %'Quick Look'; %
end
if ~exist('binMsTime','var')
    binMsTime = 100;
end

when = mlTitleTime;

sf = 240;
SkipTRs = 28;
EndTRs = 12;
SecPerCond = 2;
KillSecs = 1.3;   % Cuts this many seconds from end of condition, if,
                  % for example, you've got 1 second of images and then one
                  % second of fixation you don't care about

SecPerCond = 2;
maxDistFix = 50;
minDistStim = 60;

% PRTRun{1} = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/DR_04_19_07/1_VTCs/ResponseFile_Subject3_Run1_20070419T150502.prt';
% PRTRun{2} = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/DR_04_19_07/1_VTCs/ResponseFile_Subject3_Run2_20070419T151423.prt';
% PRTRun{3} = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/DR_04_19_07/1_VTCs/ResponseFile_Subject3_Run3_20070419T153442.prt';
% PRTRun{4} = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/DR_04_19_07/1_VTCs/ResponseFile_Subject3_Run4_20070419T154356.prt';

StateCountByCond = zeros(length(RunNum),6);

for iRun = RunNum;
    cheat = [1 2 3 4 5 6]; 
    inputfile = [path fldr.name '/EyeData/' Files{cheat(iRun)}];
    %PRTfile = PRTRun{iRun}; % may be useful for other code, so not deleted - but not used here.
    ETDat = textread(inputfile);
    RunPositions = [path 'Run' num2str(iRun) '.xls']
    RunPosData = importdata(RunPositions);

    %%% Cutting first and last part off data (no stim presented)
    ETDat = ETDat(SkipTRs*sf+1:end-EndTRs*sf,:);

    %%% First: Bin data into (binMsTime) bins
    binPerSec = 1000/binMsTime;
    datPtPerBin = sf/binPerSec;

    EyePos = zeros(length(ETDat)/(datPtPerBin),2);
    EyeState = zeros(length(ETDat)/(datPtPerBin),1); % This is based on Dave Berg's eye markup...
    for ii = 1:length(ETDat)/(datPtPerBin);
        II = ((ii-1)*datPtPerBin)+1:ii*datPtPerBin;
        EyePos(ii,1) = mean(ETDat(II,1));
        EyePos(ii,2) = mean(ETDat(II,2));

        if any(ETDat(II,4)==1)
            EyeState(ii) = 1;
        else
            EyeState(ii) = mode(ETDat(II,4));
        end
    end

    StimPosData = RunPosData.Sheet1(3:end,2:2:8); %Note: Added ".Sheet1" to the previous - for newer version of importdata in Matlab 7.4
    % stim pos will be: (Trial,xory,pos1or2,stim1or2)
    StimPos(:,1,1,1) = round(512-100*sin(StimPosData(:,1)*pi/180)); %S1P1x
    StimPos(:,1,2,1) = round(512-100*sin(StimPosData(:,2)*pi/180)); %S1P2x
    StimPos(:,2,1,1) = round(384+100*cos(StimPosData(:,1)*pi/180)); %S1P1y
    StimPos(:,2,2,1) = round(384+100*cos(StimPosData(:,2)*pi/180)); %S1P2y
    StimPos(:,1,1,2) = round(512-100*sin(StimPosData(:,3)*pi/180)); %S2P1x
    StimPos(:,1,2,2) = round(512-100*sin(StimPosData(:,4)*pi/180)); %S2P2x
    StimPos(:,2,1,2) = round(384+100*cos(StimPosData(:,3)*pi/180)); %S2P1y
    StimPos(:,2,2,2) = round(384+100*cos(StimPosData(:,4)*pi/180)); %S2P2y

    Condition = RunPosData.Sheet1(3:end,9);

    %%% Then: only when stimulus is ON:
    eCount = 1;
    ImOnEyePos = zeros(length(EyePos)/2,2);
    for jj = 1:length(EyePos);
        if mod(jj,2*binPerSec)<binPerSec+1 && mod(jj,2*binPerSec)>0
            ImOnIdx(eCount) = jj; % making sure that it does, indeed, get the right values
            ImOnEyePos(eCount,:) = EyePos(jj,:);
            eCount = eCount+1;
        end
    end

    %%% Then: when each condition is on
    %PRT = BVQXfile(PRTfile);
    nTrPerCond = 36 %PRT.Cond.NrOfOnOffsets;
    nConds = 6 %PRT.NrOfConditions;
    CondEyePos = zeros(length(EyePos)/(nConds*SecPerCond),2,nConds); % assumes all conditions appear an equal number of times - 
    % - The above does NOTHING right now -

    MeanDstS1Pos1 = zeros(length(StimPos),1);
    MeanDstS1Pos2 = zeros(length(StimPos),1);
    Dist2S1Pos1   = zeros(binPerSec*(SecPerCond-KillSecs),length(StimPos));
    Dist2S1Pos2   = zeros(binPerSec*(SecPerCond-KillSecs),length(StimPos));
    Dist2S2Pos1   = zeros(binPerSec*(SecPerCond-KillSecs),length(StimPos));
    Dist2S2Pos2   = zeros(binPerSec*(SecPerCond-KillSecs),length(StimPos));

    distFromFix   = zeros(binPerSec*(SecPerCond-KillSecs),length(StimPos));

    DistByCond = zeros(nTrPerCond+1,nConds);
    StateByCond = zeros(nTrPerCond+1,nConds);
    CondCount = ones(1,nConds);
    try
    for iTrial = 1:length(StimPos);
        TrIndex = (iTrial-1)*2*binPerSec+1:iTrial*2*binPerSec-KillSecs*binPerSec;
        %Calculating distance to S1, first position:
        XdistP1 = (EyePos(TrIndex,1)-StimPos(iTrial,1,1,1));
        YdistP1 = (EyePos(TrIndex,2)-StimPos(iTrial,2,1,1));
        Dist2S1Pos1(:,iTrial) = (XdistP1.^2+YdistP1.^2).^(.5);
        MeanDstS1Pos1(iTrial) = mean(Dist2S1Pos1(:,iTrial));
        %Calculating distance to S1, second position:
        XdistP2 = (EyePos(TrIndex,1)-StimPos(iTrial,1,2,1));
        YdistP2 = (EyePos(TrIndex,2)-StimPos(iTrial,2,2,1));
        Dist2S1Pos2 = (XdistP2.^2+YdistP2.^2).^(.5);
        MeanDstS1Pos2(iTrial) = mean(Dist2S1Pos2);

        % Just considering trials in which subject isn't fixating:
        XdistFromFix = EyePos(TrIndex,1)-512;
        YdistFromFix = EyePos(TrIndex,2)-384;
        distFromFix(:,iTrial)  = (XdistFromFix.^2+YdistFromFix.^2).^(.5);

        DistByCond(CondCount(Condition(iTrial)),Condition(iTrial)) = mean(distFromFix(:,iTrial));
        if any(EyeState(TrIndex)==1)
            StateByCond(CondCount(Condition(iTrial)),Condition(iTrial)) = 1;
        else
            StateByCond(CondCount(Condition(iTrial)),Condition(iTrial)) = mode(EyeState(TrIndex));
        end


        CondCount(Condition(iTrial)) = CondCount(Condition(iTrial))+1;
    end
    catch
        save DebugVars
        rethrow(lasterror)
    end
    
    for ii = 1:6;
        StateCountByCond(iRun,ii) = length(find(StateByCond(:,ii)==1));
    end
    
    save([SubjInits '_Run' num2str(iRun) '.mat'])
end

PercentBad = 100*sum(StateCountByCond)/144;

h1 = figure;
bar(PercentBad);
labels = {'Ident' 'Trans' 'Rel' 'Trans+Rel' 'New' 'Blank'};
set(gca,'ylim',[0 50],'xticklabel', labels,'fontsize', [20], 'fontname','Times');
set(h1,'Name',['Subject ' SubjInits ' Run ' num2str(RunNum)]);
xlabel('Condition','fontsize', [30], 'fontname','Times');
ylabel('Percent','fontsize', [30], 'fontname','Times');
title('Percent Saccades+Blinks+Artifacts by Condition','fontname','Times','fontsize', [30]);

%% Plots
switch WhichPlot
    case 'Quick Look'
        Pos = TileFigs(4);
        ql1 = figure('Position',Pos(1,:));
        plot(EyePos(:,1),EyePos(:,2),'b.');
        title(['Eye Position (all points), with data in ' num2str(binMsTime) ' ms bins']);
        set(ql1,'Name',['Subject ' SubjInits ' Run ' num2str(RunNum)]);
            %%% Put up Stim Position:
            iPos = 1;
            x_center = 512;
            y_center = 384;
            nPos = 8;
            ImRadius = 100;
            for tt = 0:360/nPos:360;
                PosX(iPos) = ImRadius*sind(tt) + x_center;
                PosY(iPos) = -ImRadius*cosd(tt) + y_center;
                iPos = iPos+1;
            end; clear tt; clear iPos;

            hold on;
            plot(PosX,PosY,'r.');
            hold off;
            mlScreenFig;

        ql2 = figure('Position',Pos(2,:));
        plot(ImOnEyePos(:,1),ImOnEyePos(:,2),'b.');
        title(['Eye Position (with stimulus on only), with data in ' num2str(binMsTime) ' ms bins']);
            %%% Put up Stim Position:
            iPos = 1;
            x_center = 512;
            y_center = 384;
            nPos = 8;
            ImRadius = 100;
            for tt = 0:360/nPos:360;
                PosX(iPos) = ImRadius*sind(tt) + x_center;
                PosY(iPos) = -ImRadius*cosd(tt) + y_center;
                iPos = iPos+1;
            end; clear tt; clear iPos;

            hold on;
            plot(PosX,PosY,'r.');
            hold off;
            mlScreenFig;
       set(ql2,'Name',['Subject ' SubjInits ' Run ' num2str(RunNum)]);
       
       ql3 = figure('Position',Pos(3,:));
       GoodOnes = find(~EyeState(ImOnIdx)); % That is, all the places where "EyeState" (From D. Berg's code) = 0 (that is, = fixation)
       plot(EyePos(GoodOnes,1),EyePos(GoodOnes,2),'b.');
       title({'Eye Position (During Fixation-Labeled Trials Only)'; ['with data in ' num2str(binMsTime) ' ms bins']});
            %%% Put up Stim Position:
            iPos = 1;
            x_center = 512;
            y_center = 384;
            nPos = 8;
            ImRadius = 100;
            for tt = 0:360/nPos:360;
                PosX(iPos) = ImRadius*sind(tt) + x_center;
                PosY(iPos) = -ImRadius*cosd(tt) + y_center;
                iPos = iPos+1;
            end; clear tt; clear iPos;

            hold on;
            plot(PosX,PosY,'r.');
            hold off;
            mlScreenFig;
       set(ql3,'Name',['Subject ' SubjInits ' Run ' num2str(RunNum)]);
       

    case 'By Condition'
        %%% Plotting Eye Position by condition:
        Pos = TileFigs(nConds);
        for iCdFig = 1:nConds
            figure('Position',Pos(iCdFig,:));
            plot(CondEyePos(:,1,iCdFig),CondEyePos(:,2,iCdFig));
            set(gca,'xlim',[0 1024],'ylim',[0 768]);
            title(['Eye Position - Cond' num2str(iCdFig) ' - Stim On Only - ' num2str(binMsTime) ' ms bins']);

            %%% Put up Stim Position:
            iPos = 1;
            x_center = 512;
            y_center = 384;
            nPos = 8;
            ImRadius = 100;
            for tt = 0:360/nPos:360;
                PosX(iPos) = ImRadius*sind(tt) + x_center;
                PosY(iPos) = -ImRadius*cosd(tt) + y_center;
                iPos = iPos+1;
            end; clear tt; clear iPos;

            hold on;
            plot(PosX,PosY,'r.');
            hold off;
        end
    case 'Bad Trials'
        try 
        YN = input(['There are ' num2str(length(find(EyeState ~=0))) ' bad trials. \n\nWould you like to continue? (y/n) \n\n' ],'s');
        if ~strcmpi(YN,'y')
            return
        end
        disp('Press space bar to continue after each trial...');
        Pos = TileFigs(3,2);
        hh = figure('Position',Pos(3,:));
        BadCount = 1;
        for iTrial = 1:length(StimPos)
            if EyeState(iTrial) ~= 0; %any(distFromFix(:,iTrial) > maxDistFix) %any(Dist2S1Pos1<minDistStim)||any(Dist2S1Pos2<minDist)
            
            TrIndex = (iTrial-1)*2*binPerSec+1+5:iTrial*2*binPerSec-KillSecs*binPerSec;

            BadCount = BadCount+1;

            figure(hh);
            plot(EyePos(TrIndex(1),1),EyePos(TrIndex(1),2),'y+');
            hold on;
            plot(EyePos(TrIndex,1),EyePos(TrIndex,2),'b-');
            plot(StimPos(iTrial,1,1,1),StimPos(iTrial,2,1,1),'r*');
            plot(StimPos(iTrial,1,2,1),StimPos(iTrial,2,2,1),'rs');
            plot(StimPos(iTrial,1,1,2),StimPos(iTrial,2,1,2),'g*');
            plot(StimPos(iTrial,1,2,2),StimPos(iTrial,2,2,2),'gs');
            plot(512,384,'y.');
            hold off;
            mlScreenFig(128,0);
            title({['Trial number ' num2str(iTrial) ' Condition ' num2str(Condition(iTrial))],['labeled as ' num2str(EyeState(iTrial))]})
            drawnow;
            mlQuitKeyTimer(GetSecs+.5);            
            [x y buttons] = GetMouse; while ~any(buttons); [x y buttons] = GetMouse; end
            %[x y z] = mlGetResponse(GetSecs+1000,GetSecs,KbName('Space'));

            end
        end
        catch
            save DebugVars
            rethrow(lasterror);
        end
    case 'Dist by Cond'
        % UNFINISHED: (as of 8.9.07)
        figure;
        Dist = mean(DistByCond);
        StdErr = std(DistByCond)/sqrt(length(DistByCond));
        barerrorbar({Dist'},{Dist',StdErr,'k+','linewidth',1.5});
        title(['Distance from fixation by Condition'])
        set(gca,'linewidth',1.5);


        figure;
        bar(StateCountByCond);
        title('Scurrilous events by condition (saccades, blinks, artifacts)');
        
        
    otherwise
        disp('No Plots this time.');
end  


save DebugVars;





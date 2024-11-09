function mlSceneRepEyeTrack(SubjInits,RunNum,Sub_Exp,ImUpTime,PlotResult) 

% Usage: mlSceneRepEyeTrack(SubjInits,RunNum,Sub_Exp,ImUpTime,PlotResult)
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

%{
Subjects:

Exp1:
AG DR LC

Exp3:
KH* SJ VV

* KH Run 2 has only 463 time points - for some reason it was stopped early

%}


% Inputs:
if ~exist('SubjInits','var')
    SubjInits = 'KH';
end
if ~exist('Sub_Exp','var')
    Sub_Exp = 'MRI_GlobFeat/';
    % or: 'MRI_T1wSwap/'
end
if ~exist('RunNum','var')
    RunNum = 1;
end
% if ~exist('binMsTime','var')
%     binMsTime = 100; % (1000/binMsTime) should be a whole number
% end
if ~exist('ImUpTime','var')
    ImUpTime = .7; % Number of seconds at the beginning of each trial for 
end                % which images are actually up
if ~exist('PlotResult','var')
    PlotResult = 0; 
end

% Other modifiables:
Record = 1;
TimeOfScan = mlTitleTime; 
WhichAnalysis = 'mlSceneRepET_SacEyeAngle'; %'mlSceneRepET_EyeAngle'; % 'mlSceneRepET_DB_ImTimeOnly'; % 'mlSceneRepET_DB'; %
fExt = 'ceyeS'; % format of ET data - .eyeS is two-column, pre-processed but still 60 hz data from USC magnet in 1024x768 screen coordinates
sf = 240;       % .ceyeS is resampled to 240 hz, and labeled (in the fourth column) with an event label by D. Berg's "markEye" code.
SkipTRs = 28;
EndTRs = 12;
nSecPerCond = 2;

if strcmp(Sub_Exp,'MRI_GlobFeat/');
    ImTime = .05;
    ISI = .5;
else
    ImTime = .2;
    ISI = .3;
end

pPath = ['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/'];
fPath = ['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/' Sub_Exp];
fldr = dir(['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/' Sub_Exp SubjInits '*']);
Files = mlStructExtract(dir([fPath fldr.name '/EyeData/*real.' fExt]),'name');

if length(Files) < max(RunNum)
    RunNum = 1:length(Files)
    disp(sprintf('There are only %d files in Subject %s''s folder',length(Files),SubjInits))
end

for iRun = RunNum; %1:length(Files)
    % Loading ET data for a given run, in the form specified by fExt:
    ET = importdata([fPath fldr.name '/EyeData/' Files{iRun}]);
    % Getting condition information from .xls files in parent directory:
    RunPositions = [fPath 'Run' num2str(iRun) '.xls'];
    RunPosData = importdata(RunPositions);
    if isstruct(RunPosData)
        RunPosData = RunPosData.Sheet1(3:end,:);
    else
        RunPosData = RunPosData(3:end,:);
    end
    Condition = RunPosData(:,9);
    
    nTrials = length(Condition);
    nTrPerCond = 36;    % PRT.Cond.NrOfOnOffsets;
    nConds = 6;         % PRT.NrOfConditions;
    
    % Accounting for bad run (runs?)
    if strcmp(SubjInits,'KH') && iRun==2
        EndTRs = 3;
    end
    % Cutting first and last part off data (no stim presented in those times, we don't care what eyes were doing)
    ET = ET(SkipTRs*sf+1:end-EndTRs*sf,:);
    
    eval(WhichAnalysis);
    
    

    
end

switch WhichAnalysis
    case {'mlSceneRepET_DB','mlSceneRepET_DB_ImTimeOnly'}
        if length(RunNum)>1
            StateCountByCond_all = sum(StateCountByCond_all);
            StateCountByCond_Sac = sum(StateCountByCond_Sac);
            disp({'All Fuglies per condition:'; num2str(StateCountByCond_all)})
            disp({'Saccades per condition:'; num2str(StateCountByCond_Sac)})
            PercentBad_all = 100*StateCountByCond_all/(nTrPerCond*length(RunNum));
            PercentBad_Sac = 100*StateCountByCond_Sac/(nTrPerCond*length(RunNum));
        else
            PercentBad_all = 100*StateCountByCond_all/nTrPerCond;
            PercentBad_Sac = 100*StateCountByCond_Sac/nTrPerCond;
        end
        if Record
            fid = fopen([pPath 'SceneRepETAnalysisDB.txt'],'a');
            fprintf(fid,'\n');
            fprintf(fid,'%s %10.2f%10.2f%10.2f%10.2f%10.2f%10.2f',SubjInits,PercentBad_Sac);
            fclose(fid);
        end
        if PlotResult
            h1 = figure('Position',[94   373   936   442]);
            subplot(211)
            labels = {'Ident' 'Trans' 'Rel' 'Trans+Rel' 'New' 'Blank'};
            bar(PercentBad_all);
            set(gca,'ylim',[0 25],'xticklabel', labels,'fontsize', [20], 'fontname','Times');
            set(h1,'Name',['Subject ' SubjInits ' Run ' num2str(RunNum)]);
            xlabel('Condition','fontsize', [30], 'fontname','Times');
            ylabel('Percent','fontsize', [30], 'fontname','Times');
            title('Percent Saccades+Blinks+Artifacts by Condition','fontname','Times','fontsize', [30]);
            subplot(212)
            bar(PercentBad_Sac);
            set(gca,'ylim',[0 25],'xticklabel', labels,'fontsize', [20], 'fontname','Times');
            set(h1,'Name',['Subject ' SubjInits ' Run ' num2str(RunNum)]);
            xlabel('Condition','fontsize', [30], 'fontname','Times');
            ylabel('Percent','fontsize', [30], 'fontname','Times');
            title('Percent Saccades per Condition','fontname','Times','fontsize', [30]);
            drawnow;
        end
    case 'mlSceneRepET_EyeAngle'
        EE = importdata([pPath 'Sub' SubjInits 'EyeAngle.txt']);
        EA = EE(:,1:2); % That is: Eye Angle
        SA = EE(:,3:4); % That is: Stim Angle
        %EyeAngle(EyeAngle<0) = 360+(EyeAngle(EyeAngle<0)); % Getting rid of negative angles
        [RhoS1, PvalS1] = corr(EA(:,1),SA(:,1));
        [RhoS2, PvalS2] = corr(EA(:,2),SA(:,2));
        if Record
            fid = fopen([pPath 'SceneRepETAnalysisEyeAngle.txt'],'a');
            fprintf(fid,'%s%10.2f%10.2f%10.2f%10.2f\n',SubjInits,RhoS1,PvalS1,RhoS2,PvalS2);
            fclose(fid);
        end
        %plot(MeanEyeMovement(:,1),'r.'); %mlScreenFig([1024 768],128,1,1);
    case 'mlSceneRepET_SacEyeAngle'
        EE = importdata([pPath 'Sub' SubjInits 'SacEyeAngle.txt']);
        EA = EE(:,1:2); % That is: Eye Angle
        SA = EE(:,3:4); % That is: Stim Angle
        Sidx1 = find(~isnan(EA(:,1)));
        Sidx2 = find(~isnan(EA(:,2)));
        %EyeAngle(EyeAngle<0) = 360+(EyeAngle(EyeAngle<0)); % Getting rid of negative angles
        [RhoS1, PvalS1] = corr(EA(Sidx1,1),SA(Sidx1,1));
        [RhoS2, PvalS2] = corr(EA(Sidx2,2),SA(Sidx2,2));
        if Record
            fid = fopen([pPath 'SceneRepETAnalysisSacEyeAngle.txt'],'a');
            fprintf(fid,'%s%10.2f%10.2f%10.2f%10.2f\n',SubjInits,RhoS1,PvalS1,RhoS2,PvalS2);
            fclose(fid);
        end
        
    case 'mlSceneRepET_EyePos'  
        plot(Xp1,Yp1,'r.'); mlScreenFig([1024 768],128,1,1);
        pctTrOverHalfDegSTD  = mean(pctTrOverHalfDegSTD); 
        pctTrOverHalfDegMove = mean(pctTrOverHalfDegMove);
        pctOverOneDegMove    = mean(pctOverOneDegMove);
        fid = fopen([pPath 'SceneRepETAnalysisEyePos.txt'],'a');
        fprintf(fid,'%3s %15.2f%15.2f%15.2f\n',SubjInits, pctTrOverHalfDegSTD, pctTrOverHalfDegMove, pctOverOneDegMove);
        fclose(fid);
        dlmwrite(['Sub_' SubjInits '_Run' num2str(RunNum) '_EyeSTD.txt'],[Ystd Xstd], '\t');
        save whachacallit
end

%Str = num2str(RunNum);
%RunNumsStr = Str(~isspace(Str));
%save([fPath 'Sub' SubjInits '_Run' RunNumsStr '_' WhichAnalysis '_ScRepET_DebugVars']);


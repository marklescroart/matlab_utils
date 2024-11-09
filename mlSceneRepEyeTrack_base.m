function mlSceneRepEyeTrack_base(SubjInits,RunNum,Sub_Exp,ImUpTime,PlotResult) %deleted: binMsTime,

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
TimeOfScan = mlTitleTime; 
WhichAnalysis = 'mlSceneRepET_DB';
fExt = 'ceyeS'; % format of ET data - .eyeS is two-column, pre-processed but still 60 hz data from USC magnet in 1024x768 screen coordinates
sf = 240;       % .ceyeS is resampled to 240 hz, and labeled (in the fourth column) with an event label by D. Berg's "markEye" code.
SkipTRs = 28;
EndTRs = 12;
nSecPerCond = 2;

path = ['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/' Sub_Exp];
fldr = dir(['/Users/Work/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/' Sub_Exp SubjInits '*']);
Files = mlStructExtract(dir([path fldr.name '/EyeData/*real.' fExt]),'name');



for iRun = RunNum; %1:length(Files)
    % Loading ET data for a given run, in the form specified by fExt:
    ET = importdata(Files{iRun});
    % Getting condition information from .xls files in parent directory:
    RunPositions = [path 'Run' num2str(iRun) '.xls'];
    RunPosData = importdata(RunPositions);
    Condition = RunPosData.Sheet1(3:end,9);
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
    case 'mlSceneRepET_DB'
        if length(RunNum)>1
            StateCountByCond = sum(StateCountByCond);
            disp({'Saccades per condition:'; num2str(StateCountByCond)})
            PercentBad = 100*StateCountByCond/(nTrPerCond*length(RunNum));
        else
            PercentBad = 100*StateCountByCond/nTrPerCond;
        end

        h1 = figure('Position',[94   373   936   442]);
        bar(PercentBad);
        labels = {'Ident' 'Trans' 'Rel' 'Trans+Rel' 'New' 'Blank'};
        set(gca,'ylim',[0 50],'xticklabel', labels,'fontsize', [20], 'fontname','Times');
        set(h1,'Name',['Subject ' SubjInits ' Run ' num2str(RunNum)]);
        xlabel('Condition','fontsize', [30], 'fontname','Times');
        ylabel('Percent','fontsize', [30], 'fontname','Times');
        title('Percent Saccades+Blinks+Artifacts by Condition','fontname','Times','fontsize', [30]);

end
save ScRepET_DebugVars;


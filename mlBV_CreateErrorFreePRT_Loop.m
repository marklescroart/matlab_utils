function mlBV_CreateErrorFreePRT_Loop

% Usage: mlBV_CreateNoErrPRTLoop
% 
% Call this function from within a PRT_RTCs folder that already contains
% the .mat files for a given subject. 
% 
% ML 2.1.08
warning([mfilename ':UsageWarning'],'This is still particular to a given experiment and needs modification. Use with caution.');
warning([mfilename ':UsageWarning'],'Don''t use this code if there are more .mat files in here than just Experiment data!');

RunMats = mlStructExtract(dir('*.mat'),'name');
nRuns = length(RunMats); % Should be 5 or 6 for LOScaleTrans
%For LOScTrans:
EndBlanks = 4; % 8 seconds - equivalent of 4 trials
LookBacks = 2;
TRperTrial = 2;
%ConditionNames = {'Fix' '0' '2.3' '4.5' '9' 'New Obj'};
color = {[111 111 111],[51 31 153],[255 195 0],[255 45 255],[177 0 0],[0 255 75]};
% EName = 'LOScTr_HugeImOnly';
% EName = 'LOScTr_BigImOnly';
EName = 'Test';

for ii = 1:nRuns
    load(RunMats{ii});
    % The following rely on ML conventions... And may not work for older
    % experiments...
    CorrResp = mlStructExtract(ED.TA,'CorrResp');
    OrderList = ED.OrderList;
    ExpName = sprintf('%s_%s_Run%g',ED.SubID,EName,ii);
    ConditionNames = ED.CondNames;
    mlBV_CreateErrorFreePRT(ExpName,OrderList,ConditionNames,color,EndBlanks,LookBacks,TRperTrial,CorrResp)
end

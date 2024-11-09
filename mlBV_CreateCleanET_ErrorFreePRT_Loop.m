function mlBV_CreateCleanET_ErrorFreePRT_Loop(HowStrict)

% Usage: mlBV_CreateCleanET_ErrorFreePRT_Loop
% 
% Call this function from within a PRT_RTCs folder that already contains
% the .mat files for a given subject. 
% 
% ML 2.1.08

%warning([mfilename ':UsageWarning'],'This is still particular to a given experiment and needs modification. Use with caution.');
%warning([mfilename ':UsageWarning'],'Don''t use this code if there are more .mat files in here than just Experiment data!');

switch HowStrict
    case 'VeryLiberal'
        ETDef = '2.0DegFromFix1.0DegFromStim.txt';
        Fields = 2;
    case 'Liberal'
        ETDef = '2.0DegFromFix2.0DegFromStim.txt';
        Fields = 1:2;
    case 'Medium'
        ETDef = '2.0DegFromFix2.0DegFromStim.txt';
        Fields = 1:4;
    case 'Strict'
        ETDef = '1.5DegFromFix2.0DegFromStim.txt';
        Fields = 1:4;
end

MATf = mlStructExtract(dir('*.mat'),'name');
TXTs = mlStructExtract(dir(['../EyeData/*' ETDef]),'name');
nRuns = length(MATf); % Should be 5 or 6 for LOScaleTrans
%For LOScTrans:
EndBlanks = 4; % 8 seconds - equivalent of 4 trials
LookBacks = 2;
TRperTrial = 2;
ConditionNames = {'Fixation' 'Ident' '2.3' '4.5' '9' 'New Obj'};
color = {[111 111 111],[51 31 153],[255 195 0],[255 45 255],[177 0 0],[0 255 75]};
EName = 'LOScTr_SmImOnly';
% EName = 'LOScTr_BigImOnly';
% EName = 'Test';

for ii = 1:nRuns
    load(MATf{ii});
    % The following rely on ML conventions... And may not work for older
    % experiments...
    CorrResp = mlStructExtract(ED.TA,'CorrResp');
    OrderList = ED.OrderList;
    ETPre = importdata(['../EyeData/' TXTs{ii}]);
    ETCut = zeros(length(CorrResp),1);
    ETCut(LookBacks+1:end) = any(ETPre(:,Fields),2);
    % Thought the following might be interesting - but nothing came of it.
    %PctErrBecauseOfBadEyePos = 100*length(find(~CorrResp&ETCut))/length(find(~CorrResp));
    %fprintf('%.1f Percent of errors due occurred on trials with eye artifacts in run %.0f.\n',PctErrBecauseOfBadEyePos,ii);
    if length(ETCut)~=length(CorrResp)||length(ETCut)~=length(OrderList)
        error('mismatched lengths for order list, responses, or ET Data. Please to check.')
    end
    ExpName = sprintf('%s_%s_Run%g',ED.SubID,EName,ii);
    mlBV_CreateCleanETPRT(ExpName,OrderList,ConditionNames,color,EndBlanks,LookBacks,TRperTrial,CorrResp,ETCut)
end

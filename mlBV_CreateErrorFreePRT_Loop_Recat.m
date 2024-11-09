function mlBV_CreateErrorFreePRT_Loop_Recat

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
ConditionNames = {'Fix' '0' '2.3' '4.5' '9' 'New Obj'};
color = {[111 111 111],[51 31 153],[255 195 0],[255 45 255],[177 0 0],[0 255 75]};
EName = 'LOScTr_BigImOnly_Recat';
% EName = 'LOScTr_BigImOnly';
% EName = 'Test';

for ii = 1:nRuns
    load(RunMats{ii});
    Rcell = mlStructExtract(ED.TA,'ImRect');
    Rmat = cell2mat(Rcell);
    R = Rmat(1:2:end,:);
    R(:,:,2) = Rmat(2:2:end,:);
    
    Xv = zeros(length(R),1);
    for iTr = 1:length(R)
        [x1,y1] = RectCenter(R(iTr,:,1));
        [x2,y2] = RectCenter(R(iTr,:,2));
        Xv(iTr) = ((x1>512)&x2<512)|((x1<512)&(x2>512));
    end
    C5 = find(ED.OrderList==5);
    %C4 = find(ED.OrderList==4);
    Xv(C5) = ~Xv(C5);
    CorrResp = mlStructExtract(ED.TA,'CorrResp');
    CorrResp(find(Xv)) = 0; % Re-classifying runs crossing vertical meridian as ERROR runs
    
    OrderList = ED.OrderList;
    ExpName = sprintf('%s_%s_Run%g',ED.SubID,EName,ii);
    mlBV_CreateErrorFreePRT(ExpName,OrderList,ConditionNames,color,EndBlanks,LookBacks,TRperTrial,CorrResp)
end

function mlBV_CreateCleanETPRT(ExpName,OrderList,ConditionNames,color,EndBlanks,LookBacks,TRperTrial,CorrResp,ETCut)

% Usage:
% mlCreateErrorFreePRT(ExpName,OrderList,ConditionNames,color,EndBlanks,LookBacks,TRperTrial,CorrResp,ETCut)
% 
%   Inputs: ExpName = String for name of experiment (e.g.,'ObjectFiles' or something like that)
%                     Should include run number!
%         OrderList = 1xnTrials (or 1xnBlocks) vector of condition numbers as
%                     they appear in the experiment. Each element in the
%                     vector should correspond to an equal interval of time
%                     (specified in TRperTrial) (For now !!!???)
%    ConditionNames = cell array of (string) condition names
%            Colors = cell array of ([R G B]) condition colors
%         EndBlanks = how many blank (intervals) should be tacked on to the
%                     end of the OrderList
%         LookBacks = How many lookbacks were incorporated into the balancing 
%                     of the experiment - that is, how many trials should be 
%                     excluded from the beginning for lack of lookbacks
%                     before them.
%        TRperTrial = TRs per trial 
%          CorrResp = 1xnTrials vector of 1s or 0s, for whether response
%                     for that trial was correct or not (0s will be put
%                     into an extra condition 
%             ETCut = 1xnTrials vector of 1s or 0s, for whether that trial
%                     contained Eye Tracking Dodginess (Excessive distance 
%                     from fixation, proximity to target, saccade or blink)                    
%                   
% 
% Created by ML 1.25.08

if nargin<9
    error('Please see usage; this function requires all inputs to be specified.')
end

nCondsOrig = length(ConditionNames);
nCondswETstep2 = 2*nCondsOrig-1; % Additions for Eye Tracking Exclusions
nCondswETandErrStep3 = 3*nCondsOrig-2; % Additions for error trials
GuaranteeMissInRunX = 3;

NewConds = ConditionNames;
NewColors = color;
Gray = [111 111 111];
NewOrderList = OrderList;



if min(NewOrderList) ~=1 || max(NewOrderList) ~= nCondsOrig
   error('Please check your OrderList, dumbass. Something is wrong.');
end

fName = [ExpName '_NoErrors_CleanET.prt'];

for iET = 2:nCondsOrig; %%%??? There's an assumption here about which condition is fixation. This causes bugs. Shit. 4.4.08, ML
    NewConds{iET+nCondsOrig-1}  = [NewConds{iET} ' ET Exclusion'];
    NewColors{iET+nCondsOrig-1} = floor(NewColors{iET}/2);
    ETIdx = (ETCut==1)&(OrderList==iET);
    NewOrderList(ETIdx) = OrderList(ETIdx)+nCondsOrig-1;
end

for iErr = 2:nCondsOrig;
    NewConds{iErr+2*(nCondsOrig-1)}  = [NewConds{iErr} ' Errors'];
    NewColors{iErr+2*(nCondsOrig-1)} = Gray;
    ErrIdx = (CorrResp==0)&(OrderList==iErr); 
    NewOrderList(ErrIdx) = OrderList(ErrIdx)+2*(nCondsOrig-1);
end

if min(NewOrderList) ~=1 || max(NewOrderList) ~= nCondswETandErrStep3
   warning([mfilename ':OrderListWacky'],'Missing last condition. Attempting to compensate.');
   GuaranteeMissInRunX = str2num(ExpName(end)); % This is going to cause bugs. Sorry.
end

% Amending OrderList to accomodate beginning chop-off of unbalanced trials
% (i.e., those without lookbacks) and ending fixation period:
nTrials = length(OrderList);
NewOrderListCut = zeros(nTrials-LookBacks+EndBlanks,1);
NewOrderListCut(1:length(NewOrderList)-LookBacks) = NewOrderList(LookBacks+1:end);
NewOrderListCut(end-EndBlanks+1:end) = 1; % or whatever is fixation

% Guaranteeing that at least one run will contain an error trial for each
% condition 
if str2num(ExpName(end))== GuaranteeMissInRunX
    ct = 1;
    for i = nCondswETstep2+1:nCondswETandErrStep3; 
        s(ct) = length(find(NewOrderListCut==i)); 
        ct = ct+1;
    end
    NoErrsNew = find(s==0);
    NoErrsOld = NoErrsNew+1;
    for e = 1:length(NoErrsNew)
        ErrorFreeCondition = find(NewOrderListCut==NoErrsOld(e));
        idx = round((length(ErrorFreeCondition)-1)*rand);
        NewOrderListCut(ErrorFreeCondition(idx)) = NewOrderListCut(ErrorFreeCondition(idx))+nCondswETstep2-1;
    end
end

% Checking up on Guaranteed presence of at least one trial per condition:
for iTest = 1:nCondswETandErrStep3
    TT(iTest) = length(find(NewOrderListCut==iTest));
    try
        cLabel{iTest} = NewConds{iTest}(1:5);
    catch
        cLabel{iTest} = NewConds{iTest}(1:end);
    end
end

if str2num(ExpName(end))== 1; %any(TT==0)
    fprintf('Trials per condition:\n');
    fprintf([repmat('%6s ',1,nCondswETandErrStep3) '\n'],cLabel{:})
end
fprintf([repmat('%6.0f ',1,nCondswETandErrStep3) '\n'],TT(:));


% Code from Bosco Tjan to actually write .prt file:

Pre_event_idx = 0; % 'Baseline/fixation' event before the actual experiment; indexed into event
Pre_event_nTR = 0; % count after the skipped volumes %%%!!! Taken care of by creation of 
Post_event_idx = 0;% "NewOrderListCut" above (with inclusion of "EndBlanks" zeros @ end)
Post_event_nTR = 0;


fout = fopen(fName,'w');
% fout = 1;

fprintf(fout, '\n');
fprintf(fout, 'FileVersion:        2\n');
fprintf(fout, '\n');
fprintf(fout, 'ResolutionOfTime:   Volumes\n');
fprintf(fout, '\n');
fprintf(fout, 'Experiment:         %s\n',ExpName);
fprintf(fout, '\n');
fprintf(fout, 'BackgroundColor:    0 0 0\n');
fprintf(fout, 'TextColor:          255 255 255\n');
fprintf(fout, 'TimeCourseColor:    255 255 255\n');
fprintf(fout, 'TimeCourseThick:    3\n');
fprintf(fout, 'ReferenceFuncColor: 0 0 80\n');
fprintf(fout, 'ReferenceFuncThick: 3\n');
fprintf(fout, '\n');
fprintf(fout, 'NrOfConditions:  %d\n',nCondswETandErrStep3);
fprintf(fout, '\n');

for i=1:nCondswETandErrStep3
   j = find(NewOrderListCut == i);
   fprintf(fout,'%s\n',NewConds{i});
   n = length(j);
   if Pre_event_idx == i && Pre_event_nTR > 0;
      n = n+1;
   end
   if Post_event_idx == i && Post_event_nTR > 0;
      n = n+1;
   end
   fprintf(fout,'%d\n',n);
   if Pre_event_idx == i && Pre_event_nTR > 0;
      fprintf(fout,'%d %d\n', [1 Pre_event_nTR]);
   end
   fprintf(fout,'%d %d\n', [(j(:)'-1)*TRperTrial+1; j(:)'*TRperTrial]+Pre_event_nTR);
   if Post_event_idx == i && Post_event_nTR > 0;
      fprintf(fout,'%d %d\n', [1 Post_event_nTR]+length(NewOrderListCut)*TRperTrial+Pre_event_nTR);
   end
   fprintf(fout,'Color: %d %d %d\n', NewColors{i});
   fprintf(fout,'\n');
end

if fout ~= 1
   fclose(fout);
end

function mlBV_PRT_Recategorize(ExpName,OrderList,ConditionNames,color,EndBlanks,LookBacks,TRperTrial,CorrResp)

% Usage:
% Hacky for now - modified from "mlBV_CreateErrorFreePRT" - add trials you
% wish to re-categorize as error trials in the CorrResp bit.
% 
% mlCreateErrorFreePRT(ExpName,OrderList,ConditionNames,color,EndBlanks,LookBacks,TRperTrial,CorrResp)
% 
%   Inputs: ExpName = String for name of experiment (e.g.,'ObjectFiles' or something like that)
%                     Should include run number!
%         OrderList = 1xnTrials (or 1xnBlocks) vector of condition numbers as
%                      they appear in the experiment. Each element in the
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
% 
% Created by ML 1.25.08

if nargin<8
    error('Please see usage; this function requires all inputs to be specified.')
end

nConds1 = length(ConditionNames);
nConds2 = 2*nConds1-1;
GuaranteeMissInRunX = 3;

NewConds = ConditionNames;
NewColors = color;
NewOrderList = OrderList;



if min(NewOrderList) ~=1 || max(NewOrderList) ~= nConds1
   error('Please check your OrderList, dumbass. Something is wrong.');
end

fName = [ExpName '_NoErrors.prt'];

for iReName = 2:nConds1; %%%??? There's an assumption here about which condition is fixation. This causes bugs. Shit. 4.4.08, ML
    NewConds{iReName+nConds1-1}  = [NewConds{iReName} ' Errors'];
    NewColors{iReName+nConds1-1} = floor(NewColors{iReName}/2);
    eIdx = (CorrResp==0)&(OrderList==iReName);
    NewOrderList(eIdx) = OrderList(eIdx)+nConds1-1;
end

if min(NewOrderList) ~=1 || max(NewOrderList) ~= nConds2
   warning([mfilename ':OrderListWacky'],'Something may have gone wrong with the modification of the OrderList. I''m terribly sorry.');
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
    for i = 1:nConds2; 
        s(i) = length(find(NewOrderListCut==i)); 
    end
    NoErrsNew = find(s==0);
    NoErrsOld = NoErrsNew-nConds1+1;
    for e = 1:length(NoErrsNew)
        ErrorFreeCondition = find(NewOrderListCut==NoErrsOld(e));
        idx = round((length(ErrorFreeCondition)-1)*rand);
        NewOrderListCut(ErrorFreeCondition(idx)) = NewOrderListCut(ErrorFreeCondition(idx))+nConds1-1;
    end
end
    
    
Pre_event_idx = 0; % 'Baseline/fixation' event before the actual experiment; indexed into event
Pre_event_nTR = 0; % count after the skipped volumes
Post_event_idx = 0;
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
fprintf(fout, 'NrOfConditions:  %d\n',nConds2);
fprintf(fout, '\n');

for i=1:nConds2
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

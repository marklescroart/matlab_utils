function mlBV_CreatePRT(ExpName,OrderList,ConditionNames,Colors,EndBlanks,LookBacks,TRperTrial)

% Usage: mlBV_CreatePRT(ExpName,OrderList,ConditionNames,Colors,EndBlanks,LookBacks,TRperTrial)
% 
% Inputs: ExpName = String for name of experiment (e.g.,'ObjectFiles' or something like that)
%                   Should include run number!
%       OrderList = 1xnTrials (or 1xnBlocks) vector of condition numbers as
%                   they appear in the experiment. Each element in the
%                   vector should correspond to an equal interval of time
%                   (specified in TRperTrial) (For now !!!???)
%  ConditionNames = cell array of (string) condition names
%          Colors = cell array of ([R G B]) condition colors
%       EndBlanks = how many blank (intervals) should be tacked on to the
%                   end of the OrderList
%       LookBacks = How many lookbacks were incorporated into the balancing 
%                   of the experiment - that is, how many trials should be 
%                   excluded from the beginning for lack of lookbacks
%                   before them.
%      TRperTrial = 
% 
% Created by ML 2.01.08

if nargin<7
    error('Please see usage; this function requires all inputs to be specified.')
end

nConds = length(ConditionNames);

if min(OrderList) ~=1 || max(OrderList) ~= nConds
   error('Please check your OrderList, dumbass. Something is wrong.');
end

fName = [ExpName '.prt'];

% Amending OrderList to accomodate beginning chop-off of unbalanced trials
% (i.e., those without lookbacks) and ending fixation period:
nTrials = length(OrderList);
OrderListCut = zeros(nTrials-LookBacks+EndBlanks,1);
OrderListCut(1:length(OrderList)-LookBacks) = OrderList(LookBacks+1:end);
OrderListCut(end-EndBlanks+1:end) = 1; % or whatever is fixation

Pre_event_idx = 0; % 'Baseline/fixation' event before the actual experiment; indexed into event
Pre_event_nTR = 0; % count after the skipped volumes
Post_event_idx = 0;
Post_event_nTR = 0;


fout = fopen(fName,'w');


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
fprintf(fout, 'NrOfConditions:  %d\n',nConds);
fprintf(fout, '\n');

for i=1:nConds
   j = find(OrderListCut == i);
   fprintf(fout,'%s\n',ConditionNames{i});
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
      fprintf(fout,'%d %d\n', [1 Post_event_nTR]+length(OrderListCut)*TRperTrial+Pre_event_nTR);
   end
   fprintf(fout,'Color: %d %d %d\n', Colors{i});
   fprintf(fout,'\n');
end

if fout ~= 1
   fclose(fout);
end

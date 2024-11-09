% mlSceneRepET_DB
% 
% This is based on Dave Berg's eye markup
% Needs vars: 
% ET (ET data from .ceyeS file)
% nTrials
% nSecPerCond
% ImUpTime
% Condition (must be nTrials long)
% nTrPerCond (num trials per condition)
% 
%  To be defined already.
% 
% Also: This runs in a loop, so watch what's happening with iRun variable
% and StateCountByCond variable.
% 
% Should be generalizable. Not tested yet as of 12.08.07.


EyeState = ET(:,4);
StateByCond = zeros(nTrPerCond+1,nConds);
CondCount = ones(1,nConds);

for iTrial = 1:nTrials;
    % Trial index (choosing the time points to bin together for this particular trial): 
    start  = (iTrial-1)*nSecPerCond*sf+1;
    finish = (iTrial-1)*nSecPerCond*sf+ImUpTime*sf;
    TrIndex = start:finish;

    if any(EyeState(TrIndex)==1) % This is a conservative tack to take (1 = saccade - so ANY tiny saccade counts)
        StateByCond(CondCount(Condition(iTrial)),Condition(iTrial)) = 1;
    else
        StateByCond(CondCount(Condition(iTrial)),Condition(iTrial)) = mode(EyeState(TrIndex));
    end

    CondCount(Condition(iTrial)) = CondCount(Condition(iTrial))+1;
end

for iCond = 1:nConds;
    StateCountByCond_all(iRun,iCond) = length(find(StateByCond(:,iCond)~=0)); 
    StateCountByCond_Sac(iRun,iCond) = length(find(StateByCond(:,iCond)==1)); 
end

% mlSceneRepET_DB_ImTimeOnly
% 
% This is based on Dave Berg's eye markup
% Needs vars: 
% ET (ET data from .ceyeS file)
% nTrials
% nSecPerTrial
% ImUpTime
% ImTime
% OL (must be nTrials long)
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
    start1  = (iTrial-1)*nSecPerTrial*sf+1;
    finish1 = (iTrial-1)*nSecPerTrial*sf+ImTime*sf;
    start2  = (iTrial-1)*nSecPerTrial*sf+ImTime*sf+ISI*sf+1;
    finish2 = (iTrial-1)*nSecPerTrial*sf+ImTime*sf+ISI*sf+ImTime*sf;

    TrIndex = [start1:finish1,start2:finish2];

    if any(EyeState(TrIndex)==1) % This is a conservative tack to take (1 = saccade - so ANY tiny saccade counts)
        StateByCond(CondCount(OL(iTrial)),OL(iTrial)) = 1;
    else
        StateByCond(CondCount(OL(iTrial)),OL(iTrial)) = mode(EyeState(TrIndex));
    end

    CondCount(OL(iTrial)) = CondCount(OL(iTrial))+1;
end

for iCond = 1:nConds;
    StateCountByCond_all(iRun,iCond) = length(find(StateByCond(:,iCond)~=0)); 
    StateCountByCond_Sac(iRun,iCond) = length(find(StateByCond(:,iCond)==1)); 
end



%{
Post-hoc stuff:         This data is taken from SceneRepETAnalysis.txt
 Ss = [       0.69      0.69      1.39      0.69      2.08     19.44;
17.36      7.64     10.42     13.19     13.89     14.58;
1.85      0.93      2.78      3.70      1.85      2.78;
0.93      0.93      0.00      1.39      2.31      3.70;
0.56      0.00      0.56      0.56      1.67      7.78;
2.22      2.78      2.78      3.33      3.89      3.89]

F(5df) = 1.18; P>.3

Modified to: 
      c1        c2        c3        c4        c5
Ss = [0.69      0.69      1.39      0.69      2.08;
      1.85      0.93      2.78      3.70      1.85;
      0.93      0.93      0.00      1.39      2.31;
      0.56      0.00      0.56      0.56      1.67;
      2.22      2.78      2.78      3.33      3.89]

[P,XX,Stats] = anova1(Ss) 


*** NEW, with new saccade min threshold: 

Ss = [7.64      4.17      4.17      6.25      8.33     29.17;
     24.31     18.75     20.14     27.08     25.69     27.78;
      7.41      6.48      9.26      9.26      6.48     11.11;
      9.26      8.33      6.94      8.80      7.87     10.65;
      7.78      8.89      9.44      8.89      8.33     17.78;
      8.33      8.33      8.89     12.22     12.22     12.78]

Ss = [7.64      4.17      4.17      6.25      8.33;
      7.41      6.48      9.26      9.26      6.48;
      9.26      8.33      6.94      8.80      7.87;
      7.78      8.89      9.44      8.89      8.33;
      8.33      8.33      8.89     12.22     12.22]


%}

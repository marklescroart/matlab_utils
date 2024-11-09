%% runs through design2bvprt for all sequences
% Relies on prefix being the same for all 


clear all

%% Variable Params:
whichFn = 'LOST';
whichDir = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/LOScaleTrans/Code/LOST_6Cond_HugeImOnly/';

Prefix.txt = 'LOScTr_6Cond_OrderList'; 
Prefix.prt = 'LOScTr_Run';
Destination = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/LOScaleTrans/MRI/';
Lookbacks = 2;
nFiles = 6;
nTrials = 216;
EndBlanks = 4; % 8 seconds - equivalent of 4 trials


%% Below here shouldn't need modification:

cd(whichDir);
TempOrd = zeros(nTrials,1);
Order = zeros(nTrials-Lookbacks+EndBlanks,1);

for ii = 1:nFiles
    %%% Reads from text files read into the program:
    TempOrd = importdata([Prefix.txt int2str(ii) '.txt']);
    %%% Drops first couple trials before lookbacks are established:
    Order(1:length(TempOrd)-Lookbacks) = TempOrd(Lookbacks+1:end);
    Order(end-EndBlanks+1:end) = 1; % or whatever is fixation
    csvwrite('PRTOrder.txt', Order);
    %%% Writes .prt files into specified directory:
    eval(['design2bvprt' whichFn '(''PRTOrder.txt'',[Destination Prefix.prt int2str(ii) ''.prt''])']);
    %eval(['design2bvprt' whichFn '(''PRTOrder.txt'',[''Test.prt''])']);
end

delete PRTOrder.txt

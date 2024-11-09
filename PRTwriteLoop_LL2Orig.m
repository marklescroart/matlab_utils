%% runs through design2bvprt for all sequences
% Relies on prefix being the same for all 


clear all

%% Variable Params:
whichFn = 'LOLat2_2f';
whichDir = '/Applications/MATLAB74/MarkCode/LO_LateralityII/';

Prefix.txt = 'LO_Lat2_2f_Order'; 
Prefix.prt = 'LO_Lat2_2f_Seq';
Destination = '/Users/Work/Desktop/LO_LatII.2/PRT_etc_f/';
Lookbacks = 3;
nFiles = 6;
nTrials = 125;
Kill = Lookbacks-1;


%% Below here shouldn't need modification:

cd(whichDir);
TempOrd = zeros(nTrials);
Order = zeros(nTrials-Kill);

for ii = 1:nFiles
    %%% Reads from text files read into the program:
    TempOrd = textread([Prefix.txt int2str(ii) '.txt']);
    %%% Drops first couple trials before lookbacks are established:
    Order = TempOrd(Lookbacks:end);
    csvwrite('PRTOrder.txt', Order);
    %%% Writes .prt files into specified directory:
    %eval(['design2bvprt' whichFn '(''PRTOrder.txt'',[Destination Prefix.prt int2str(ii) ''.prt''])']);
    eval(['design2bvprt' whichFn '(''PRTOrder.txt'',[''Test.prt''])']);
end

delete PRTOrder.txt

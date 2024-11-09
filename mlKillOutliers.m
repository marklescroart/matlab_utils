function OutptVector = mlKillOutliers(InptVector,nStdDevs,Method)

% Usage: OutPutVector = mlKillOutliers(InputVector [,nStandardDeviations])
%
% Removes outlying values (i.e., those more than "nStandardDeviations"
% (default is 2.5) from "Inputvector" and gives back an "OutputVector."
%
% Created by ML on 7.17.07

if ~exist('InptVector','var')
    error('I need something to work with here, folks. Please give me an input vector.');
end
if ~exist('nStdDevs','var')||isempty(nStdDevs)
    nStdDevs = 2.5;
end
if ~exist('Method','var')
    Method = 'Kill'; % Removes values entirely and returns a shorter vector
end


switch Method
    case 'Kill'
        GoodOnesHi = find(InptVector < nanmean(InptVector) + nStdDevs *nanstd(InptVector));
        GoodOnesLo = find(InptVector > nanmean(InptVector) - nStdDevs *nanstd(InptVector));
        GoodOnes = intersect(GoodOnesHi,GoodOnesLo);
        OutptVector = InptVector(GoodOnes);
    case 'NaN'
        BadOnesHi = find(InptVector > nanmean(InptVector) + nStdDevs *nanstd(InptVector));
        BadOnesLo = find(InptVector < nanmean(InptVector) - nStdDevs *nanstd(InptVector));
        OutptVector = InptVector;
        OutptVector([BadOnesHi;BadOnesLo]) = NaN;
       
end
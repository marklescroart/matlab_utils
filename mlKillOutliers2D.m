function OutptVector = mlKillOutliers2D(InptVector,nStdDevs)

% Usage: OutPutVector = mlKillOutliers(InputVector [,nStandardDeviations])
%
% Removes outlying values (i.e., those more than "nStandardDeviations"
% (default is 2.5) from "Inputvector" and gives back an "OutputVector."
%
% Created by ML on 7.17.07

if ~exist('InptVector','var')
    error('I need something to work with here, folks. Please give me an input vector.');
end
if ~exist('nStdDevs','var')
    nStdDevs = 2.5;
end

GoodOnesHi = find(InptVector < nanmean(InptVector(:)) + nStdDevs *nanstd(InptVector(:)));
GoodOnesLo = find(InptVector > nanmean(InptVector(:)) - nStdDevs *nanstd(InptVector(:)));

GoodOnes = intersect(GoodOnesHi,GoodOnesLo);

OutptVector = nan(size(InptVector));
OutptVector(GoodOnes) = InptVector(GoodOnes);
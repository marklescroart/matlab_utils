function mlBV_CreateContrast(CtrName,ContrastValues)

% Usage: mlBV_CreateContrast(CtrName,ContrastValues)
%
% Create Brain Voyager Contrast File (for comparing Beta values in BV gui)
% 
% NOTE that ContrastValues should contain zeros at the end for however many
% runs there were that went into the GLM... (one zero for each predictor
% associated with a run mean)
%
% Created by ML 2009.07.21

%%% Inputs:
if ~exist('CtrName','var')
    CtrName = 'NewContrast.ctr';
end



CC = BVQXfile('new:ctr');
CC.ContrastNames = {CtrName};
CC.NrOfValues = length(ContrastValues);
CC.ContrastValues = zeros(1,CC.NrOfValues);
CC.ContrastValues = ContrastValues;
CC.SaveAs(CtrName);

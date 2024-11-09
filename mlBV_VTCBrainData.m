function [BrainVox,BrainIdx] = mlBV_VTCBrainData(VtcData,Threshold)

% Usage: [BrainVox,BrainIdx] = mlBV_VTCBrainData(VtcData,Threshold)
% 
% Extracts timecourses for all brain voxels, determined by a simple
% Threshold (default=400). Returns a matrix that is 
% 
% tTimePoints x nVoxels
% 
% With all voxels being brain voxels.
% 
% Created by ML 2009.5.2


% Inputs: 
if ~exist('Threshold','var')
    Threshold = 400;
end

Vv = reshape(VtcData,[size(VtcData,1),numel(VtcData)/size(VtcData,1)]);

BrainIdx = mean(Vv)>Threshold;

BrainVox = Vv(:,BrainIdx);
function [NewVox,nIdent,Idx] = mlBV_UniqueVOIIndices(VOIf,VOIname,Res)

% Usage: [NewVox,nIdent,Idx] = mlBV_UniqueVOIIndices(VOIf,VOIname,Res)
% 
% Pulls unique BV matrix indices (i.e., 3x3x3 mm transformed voxel indices)
% from a BV Voi file, while maintaining original ordering (whatever that's
% worth). 
% 
% A better solution to finding unique voxel indices than matlab's "unique"
% function (which sorts the data in addition to finding unique values).
% 
% This function will also count the number of identical (3x3x3) indices for
% each 3x3x3 voxel, and return them in the "nIdent" vector (nIdent = 
% [n]umber of [Ident]ical voxels). 
% 
% Inputs: 
%           VOIf = VOI file name (string)
%        VOIname = VOI name (string) (better exist within VOI file)
% 
% Outputs: 
%         NewVox = New [nVoxels x 3] matrix of [x,y,z] matlab matrix
%                  coordinates
%         nIdent = [nVoxels x 1] vector, containing a count of how many
%                  1x1x1 voxels in the VOI resulted in an index to that
%                  3x3x3 voxel. Max should be 27 (for a full 3x3x3 cube).
%                  Not all voxels will have 27 (as of 6.14.09)
%            Idx = Index to original position of each unique time value. 
% 
% Created by ML 2009.06.14

if ~exist('Res','var')
    Res = 3; % Resolution of VTC / VMP. Defaults to 3x3x3 mm voxels.
end

% Getting files
BVvoi = BVQXfile(VOIf);
BVvoiNames = mlStructExtract(BVvoi.VOI,'Name');
WhichVOI = find(strcmpi(BVvoiNames,VOIname));

% Getting BV Voxel index list
BVVox = BVvoi.VOI(WhichVOI).Voxels;
BVvoi.ClearObject;
clear BVvoi;
% ...and converting it to matlab matrix indices
[MatVoxX,MatVoxY,MatVoxZ] = Tal2Matlab(BVVox(:,1),BVVox(:,2),BVVox(:,3),Res);
MatVox = [MatVoxX,MatVoxY,MatVoxZ];
clear MatVoxX MatVoxY MatVoxZ;

% Pre-allocate output variable:
NewVox = MatVox;
nVoxels = size(MatVox,1);

% Use "unique()" function to test (1) how many unique voxel coordinate
% triples there ought to be, and (2) how the result of this algorithm
% differs from the output of "unique()"
[UniqueResult,UniqueIdx] = unique(MatVox,'rows');
nUniqueVoxels = size(UniqueResult,1);

UniqueCt = 1;
for iVox = 1:nVoxels
    if all(isnan(NewVox(iVox,:)));
        continue % that is, if we've already designated this as identical to something else (by labeling it as NaN), skip to the next index
    end
    IdentIdx = (MatVox(:,1)==MatVox(iVox,1) & MatVox(:,2)==MatVox(iVox,2) & MatVox(:,3)==MatVox(iVox,3));
    SkipVox = find(IdentIdx);
    
    if length(SkipVox) > 1;
        NewVox(SkipVox(2:end),:) = NaN; % First, label as NaN; we will delete these later
    end
    nIdent(UniqueCt) = sum(IdentIdx);
    UniqueCt = UniqueCt+1;
end

IdxLogical = all(~isnan(NewVox(:,1)),2);
Idx = find(IdxLogical);
NewVox = NewVox(Idx,:);




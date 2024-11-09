function [Vox,varargout] = mlBV_VOIVoxels(VTCfile,VOIfile,VOIname,reduce)

% Usage: [Vox [,Sz] [,Idx]] = mlBV_VOIVoxels(VTCfile,VOIfile,VOIname [,reduce])
% 
% Returns the timecourses of individual voxels in a given ROI (defined by
% VOIfile [BV .voi file name], VOIname [string VOI name, e.g. 'LO
% Bilateral')). "reduce" flag, if set to true (false by default), will
% remove redundant time courses (Time courses are otherwise returned for
% 1x1x1 (Talairach resolution) voxels. 
% 
% Created by ML 2007.??.??
% Modified by ML 2009.08.20

BVvtc = BVQXfile(VTCfile);
Sz = size(BVvtc.VTCData);
Res = BVvtc.Resolution;
if ~exist('reduce','var')
    reduce = false;
end
BrainThresh = 200;

% Specify which VOI by finding VOIname within VOI File:
BVvoi = BVQXfile(VOIfile);
BVvoiNames = mlStructExtract(BVvoi.VOI,'Name');
WhichVOI = find(strcmpi(BVvoiNames,VOIname));

OldWayNewWay = 'OldWay';
switch OldWayNewWay
    case 'OldWay' % slower by a little. Matters if iterated. This has been problematic with code...
        [AllROIVox, Idx] = BVvtc.VOITimeCourse(BVvoi, Inf);
        Vox = AllROIVox{WhichVOI};
    case 'NewWay'
        VOInew = BVQXfile('VOI');
        VOInew.VOI(1) = BVvoi.VOI(WhichVOI);
        [AllROIVox, Idx] = BVvtc.VOITimeCourse(VOInew, Inf);
        Vox = AllROIVox{1};
end


if reduce
    % NOTE: This is essentially the text of the function
    % mlBV_UniqueVOIIndices, re-written here to save time loading BV files.
    % This will 
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
    
    Keepers = find(nIdent>=round(.66*Res^3));
    
    % Cut out redundant voxels:
    Vox = Vox(:,Idx(Keepers));

    % Cut out low-signal voxels:
    VTCmask = find(mean(Vox)>BrainThresh);
    Vox = Vox(:,VTCmask);
    
    %Vox = unique(Vox','rows')';
    fprintf('You have %.0f voxels.\n',size(Vox,2));
else
    fprintf('You have %.0f voxels.\n',size(Vox,2));
end

varargout{1} = Sz;
varargout{2} = Idx;

BVQXfile(0, 'clearallobjects')


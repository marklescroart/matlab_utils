function mlBV_MakeVMPMaskFromVOI(SubID,ExpDir,VOIf,VOIn,VTCf,sName,VoxRes)

% Usage: mlBV_MakeVMPMaskFromVOI(SubID,ExpDir,VOIf,VOIn,VTCf [,sName] [,VoxRes])
% 
% Creates a VTC-sized mask from a particular VOIn (VOI name) in a
% particular VOIf (Brain Voyager VOI file). VOI files store coordinates for
% a volume of interest in Talairach space (i.e., 1x1x1 mm coordinates);
% this will return a binary (1/0) mask of the same size and in the same
% coordinate frame as VTCf
% 
% Notes: 
% - Masks for a given subject will all be stored in the "Anatomical" folder
%   within their MRI sub-folder (according to ML conventions)
% - VOI files should be in the same folder
% - VTCf file should be specified FROM the subject's experiment directory
%   (e.g., Localizer_VTCs/Filename.vtc)
% 
% Created by ML 2009.08.13

% TO DO: Create OTHER masks - in native-space / ACPC resolution??

% Useless?
% VMPn = sprintf('VOImask_%s.vmp',strrep(VOIn,' ','_'));
% VoxResolution = 2;

fprintf('Running %s on %s\n\n',mfilename,datestr(now));

% Inputs: 
if ~nargin
    % For first analysis only - all arguments should be specified.
    SubID = 'ML';
    ExpDir = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/MVPA_3D/MRI/ML_2009_08_05/';
    VOIf = 'ML_LOLoc_t=4_FromFlat_2x2x2mmVox.voi';
    VOIn = 'PF Bilateral t=4'; % 'LOC Bilateral Large'; % 'LOC Bilateral'; % 'LO Bilateral t=4'; % 
    VTCf = 'Localizer_VTCs/ML_WOR_LOLoc_Run1_SCSAI_3DMCTS_LTR_THP3c_TAL.vtc';
end
if ~exist('sName','var')||isempty(sName)
    sName = sprintf('Sub%s_BV_VOImask_for_%s',SubID,strrep(VOIn,' ','_'));
end
if ~exist('VoxRes','var')
    % 2x2x2 mm voxels
    VoxRes = 2; 
end

% Option flags:
Flag.ShowMask = true;
Flag.KeepFullVoxelsOnly = true;
Flag.SaveVMP = false;
Flag.SaveMatFile = true;

BrainThresh = 200;

%%% --- Down to business --- %%%

try
% modify save name with full path: 
sName = [ExpDir 'Anatomical/' sName];

% Get Size of VTC 
BigVTC = BVQXfile([ExpDir,VTCf]);
Brain = BigVTC.VTCData;
Brain = squeeze(mean(Brain));

%Brain = mlNormalize(Brain,'WholeMatrix')*255;
[SzX,SzY,SzZ] = size(Brain);
% Clean up
BigVTC.ClearObject; clear BigVTC;

% Get Matlab voxels
fprintf('Reading in VOI file, getting Matlab coordinates...\n');
[MatVox,nIdent,Idx] = mlBV_UniqueVOIIndices([ExpDir 'Anatomical/' VOIf],VOIn,VoxRes);
if Flag.KeepFullVoxelsOnly
    % Keep only "full" voxels - i.e., those that have more than 2/3 of
    % their 1x1x1 subsampled voxels specified at 1x1x1 mm (.voi) resolution 
    Keepers = find(nIdent>=round(.66*VoxRes^3));
    MatVox = MatVox(Keepers,:);
% else
%     Keepers = 1:length(MatVox);
end

% Fill in mask
Mask = zeros(SzX,SzY,SzZ);
%Mask(Keepers) = 1;
%Mask = reshape(Mask,[SzX,SzY,SzZ]);
for iVOIvox = 1:length(MatVox);
   Mask(MatVox(iVOIvox,1),MatVox(iVOIvox,2),MatVox(iVOIvox,3)) = 1;
end
if any(size(Mask)>[SzX,SzY,SzZ])
    fprintf('Cropping mask... (might want to check on why we had to do this!\n');
    Mask = Mask(1:SzX,1:SzY,1:SzZ);
end

% Secondary mask - on the off chance that we have something in here NOT
% covered by the slice prescription of the current VTCs:
VTCmask = Brain>BrainThresh;
Mask = Mask.*VTCmask;


if Flag.SaveMatFile
    save([sName '.mat'],'Mask');
end

if Flag.SaveVMP
    VMPnew = BVQXfile('new:vmp');
    VMPnew.Resolution = VoxRes;
    VMPnew.Map.VMPData = single(Mask);
    VMPnew.SaveAs([sName '.vmp'])
end

% Display should have ROI in some other color - currently black. Buggy.
if Flag.ShowMask
    TitStr = {[VOIn 'for Sub. ' SubID];['Overlaid on ' strrep(VTCf,'_','')]};
    h = figure;
    mlBV_ShowFMRDataWROI(Brain,Mask,TitStr,h,[255 206 0]/255)
    drawnow;
    fprintf('Saving fig. %d...\n',h);
    set(h,'inverthardcopy','off')
    print(sprintf('-f%d',h),'-dpng','-r300',sName)
%     mlFigure(1,[8,9]);
%     [x,y] = mlFindSquareishDimensions(SzY); % SzY is the second dimension...
%     Pos = mlTileAxes(x,y,[0 0 1 .9]);
%     mlFigTitle(1,sprintf('ROI = %s',VOIn),[0 .9 1 .1]);
%     for i = 1:SzY;
%         axes('Position',Pos(i,:));
%         ImTmp = double(squeeze(Brain(:,i,:)));
%         %ImTmp = repmat(ImTmp,[1 1 3]);
%         MaskTmp = double(squeeze(Mask(:,i,:)));
%         %R = ImTmp .* ones(size(MaskTmp));
%         %G = ImTmp .* ~MaskTmp;
%         %B = ImTmp .* ~MaskTmp;
%         %ImTmp = cat(3,R,G,B);
%         %ImTmp(:,:,3) = ImTmp(:,:,3) .* ~MaskTmp;
%         %ImTmp(:,:,2) = ImTmp(:,:,2) .* ~MaskTmp;
%         %ImTmp(1,1) = 1;
%         ImTmp = ImTmp .* ~MaskTmp;
%         if any(MaskTmp(:));
%             0;
%         end
%         imshow(ImTmp,[0,max(Brain(:))],'initialmagnification','fit');
%     end
end
catch 
    mlErrorCleanup
    rethrow(lasterror)
end
%{
% Crucial part of Tal2Matlab coordinate transform function: 
%% BrainVoyager QX Initialisations
X_Start = 57;
Y_Start = 52;
Z_Start = 59;
if ~exist('Resolution_VTC','var')
    Resolution_VTC = 3;
end

%% Convert TAL to BV_INT
%  The same can be achieved by:
%    [BV_INT_X, BV_INT_Y, BV_INT_Z] = Tal2BVint(TAL_X, TAL_Y, TAL_Z);
BV_SYS_X = 128 - TAL_X;
BV_SYS_Y = 128 - TAL_Y;
BV_SYS_Z = 128 - TAL_Z;

BV_INT_X = BV_SYS_Y;
BV_INT_Y = BV_SYS_Z;
BV_INT_Z = BV_SYS_X;

%% Calculate the coordinates
ML_X = ceil((BV_INT_X - X_Start + 2)/Resolution_VTC);
ML_Y = ceil((BV_INT_Y - Y_Start + 2)/Resolution_VTC);
ML_Z = ceil((BV_INT_Z - Z_Start + 2)/Resolution_VTC);
%}
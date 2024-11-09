function FMRvox = mlBV_TalVOItoFMRMask(VOIf,VOIn,TALf,ACPCvtcf,ACPCtrfF,IAtrfF,FAtrfF,VTCres)

% usage: mlBV_TalVOItoFMRMask(VOIf,VOIn,TALf,ACPCvtcf,ACPCtrf,IAtrf,FAtrf,VTCres)
% 
% Converts a Talairach-space VOI (for example, a retinotopic VOI for V1) to
% a mask in native FMR space. 

%{
NOTES: 

- Coordinates come out to be too high - 96x96x96, roughly. 

%}

try 
    
if ~nargin
    %RelMVPAv2dir = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/MVPA_Relations_v2/MRI/ML_2009_06_08/';
    MVPA_3Ddir = '/Users/Work/Documents/Neuro_Docs/Projects-IUL/MVPA_3D/MRI/ML_2009_08_05/';
    VOIf = [MVPA_3Ddir 'Anatomical/ML_LOLoc_t=4_FromFlat_2x2x2mmVox.voi'];
    VOIn = 'PF Bilateral t=4';
    TALf = [MVPA_3Ddir 'Anatomical/ML_avg_ACPC.tal'];
    ACPCvtcf = [MVPA_3Ddir 'Main_VTCs/ML_WOR_Run1_SCSAI_3DMCTS_LTR_THP3c_ACPC.vtc'];
    ACPCtrfF = [MVPA_3Ddir 'Anatomical/ML_WOR-TO-ML_avg_ACPC.trf'];
    IAtrfF = [MVPA_3Ddir 'Main_FMRs_STCs/ML_WOR_Run1_SCSAI_3DMCTS_LTR_THP3c-TO-ML_WOR_IA.trf'];
    FAtrfF = [MVPA_3Ddir 'Main_FMRs_STCs/ML_WOR_Run1_SCSAI_3DMCTS_LTR_THP3c-TO-ML_WOR_FA.trf'];
    VTCres = 2;
end

% Get VOI coordinates: 
fprintf('Getting Talairach VOI coordinates...\n');
BVvoi = BVQXfile(VOIf);
Cel = regexp(mlStructExtract(BVvoi.VOI,'Name'),VOIn);
for iC = 1:length(Cel); 
    Xx(iC) = ~isempty(Cel{iC});
end
VOInum = find(Xx);
TalVox = BVvoi.VOI(VOInum).Voxels;
nTalVox = BVvoi.VOI(VOInum).NrOfVoxels;
% Clean up BV Object: 
BVvoi.ClearObject; clear BVvoi;

% Get Tal file, convert tal coordinates to ACPC coordinates: 
BVtal = BVQXfile(TALf);
ACPCvox = acpc2tal(TalVox,BVtal,true);
% Clean up BV Object: 
BVtal.ClearObject; clear BVtal;

% Get transformation Matrices:
Tmp = BVQXfile(ACPCtrfF);
ACPCtrf = Tmp.TFMatrix;
Tmp.ClearObject;
Tmp = BVQXfile(IAtrfF);
IAtrf = Tmp.TFMatrix;
Tmp.ClearObject;
Tmp = BVQXfile(FAtrfF);
FAtrf = Tmp.TFMatrix;
Tmp.ClearObject; clear Tmp;



% Getting ACPC start / end data:
fprintf('Getting ACPC size data...\n');
ACPCvtc = BVQXfile(ACPCvtcf);
FN = {'XStart','XEnd','YStart','YEnd','ZStart','ZEnd'}; % Field names to extract
for iFN = 1:length(FN)
    ACPCdat.(FN{iFN})= ACPCvtc.(FN{iFN});
end
ACPCsize = size(ACPCvtc.VTCData);
ACPCsize = ACPCsize(2:4);
% Clean up BV Object: 
ACPCvtc.ClearObject; clear ACPCvtc;

% Convert ACPC coordinates to matlab coordinates: 

% TAKEN FROM TAL2MATLAB.M FUNCTION
% Convert TAL to BV_INT
%  The same can be achieved by:
%    [BV_INT_X, BV_INT_Y, BV_INT_Z] = Tal2BVint(TAL_X, TAL_Y, TAL_Z);
BV_SYS_X = 128 - ACPCvox(:,1);
BV_SYS_Y = 128 - ACPCvox(:,2);
BV_SYS_Z = 128 - ACPCvox(:,3);

BV_INT_X = BV_SYS_Y;
BV_INT_Y = BV_SYS_Z;
BV_INT_Z = BV_SYS_X;

% Calculate the coordinates
ACPCvoxMat(:,1) = ceil((BV_INT_X - ACPCdat.XStart + 2)/VTCres); % X
ACPCvoxMat(:,2) = ceil((BV_INT_Y - ACPCdat.YStart + 2)/VTCres); % Y
ACPCvoxMat(:,3) = ceil((BV_INT_Z - ACPCdat.ZStart + 2)/VTCres); % Z

% Add ones to go back through transformations: 
ACPCvoxMat(:,4) = ones(size(ACPCvoxMat,1),1);

NatCoRegVox = (pinv(ACPCtrf) * ACPCvoxMat')';

FMRvox = (pinv(FAtrf) * NatCoRegVox')';
FMRvox = (pinv(IAtrf) * FMRvox')';

save DebugVars

catch 
    mlErrorCleanup;
    rethrow(lasterr)
end
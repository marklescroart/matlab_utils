function mlBV_MDMCreator(OutputFileName, VTCSDMfolder,VTCPrefix,SDMPrefix)

% Usage: mlBVMDMCreator(OutputFileName [,VTCSDMfolder] [,VTCPrefix] [,SDMPrefix])
% 
% Inputs:   OutputFileName - resulting MDM file title
%           VTCSDMfolder - absolute path to folder containing VTCs and SDMs
%           VTC/SDMPrefix - cues for which files to use
% 
% NOTE:     If VTCSDMfolder is not supplied, it will assume that you wish 
%           to use the current directory.
%           THIS RELIES ON HAVING ALL VTCs and SDMs IN THE SAME DIRECTORY.
% 
% Please modify this code to suit your particular naming conventions below.
% You can specify a common beginning for each SDM and VTC in the folder. 
% 
% Created by ML 4.23.07
% Modified by ML on 5.27.09 to operate on .sdm files instead of .rtc files
%

%%% Modify this part of the code to suit your naming conventions/preferences:
if ~exist('VTCPrefix','var')
    VTCPrefix = 'Run';
end
if ~exist('SDMPrefix','var')
    SDMPrefix = 'Run'; 
end

if ~exist('OutputFileName','var')
    NewFileNm = 'Multi.mdm';
else
    NewFileNm = OutputFileName;
end

% BV Defaults for creation of MDM - modify as you like:
TypeOfFunctionalData = 'VTC';
zTransformation = 0;
RFX_GLM = 0;
PSCTransformation = 0;
SeparatePredictors = 0;

%%% Not recommended to modify the below code:
% See below for what this does
mlConventions = 0;

if ~exist('VTCSDMfolder','var') || isempty(VTCSDMfolder);
    GoYN = questdlg('Use current directory?');
    if strcmpi(GoYN,'Yes')
        VTCSDMfolder = [pwd filesep];
    else
        error('Well what the hell do you think I SHOULD do then?');
    end
end

NewMDM = BVQXfile('mdm');
NewMDM.zTransformation = zTransformation;
NewMDM.TypeOfFunctionalData = TypeOfFunctionalData;
NewMDM.RFX_GLM = RFX_GLM;
NewMDM.PSCTransformation = PSCTransformation;
NewMDM.SeparatePredictors = SeparatePredictors;

VTCs = dir('*.vtc'); VTCl = length(VTCs);
SDMs = dir('*.sdm'); SDMl = length(SDMs);
if ~SDMl
    SDMs = dir('*.rtc'); SDMl = length(SDMs);
end

% Setting order of VTC files
VTCcell = cell(VTCl,1);
for iFix = 1:VTCl
    VTCIdx = strfind(VTCs(iFix).name,VTCPrefix);
    if isempty(VTCIdx)
        continue
    else
        VTCIdx = VTCIdx+length(VTCPrefix);
    end
    VTCcell{str2num(VTCs(iFix).name(VTCIdx)),1} = VTCs(iFix).name;
end

% Setting order of SDM files
SDMcell = cell(SDMl,1);
for iFix = 1:SDMl
    SDMIdx = strfind(SDMs(iFix).name,SDMPrefix);
    if isempty(SDMIdx)
        continue
    else
        SDMIdx = SDMIdx+length(SDMPrefix);
    end
    SDMcell{str2num(SDMs(iFix).name(SDMIdx)),1} = SDMs(iFix).name;
end

clear VTCs SDMs;

% Creating new cell array of only 
for iNew = 1:length(VTCcell); 
    if ischar(VTCcell{iNew}); 
        VTCs{iNew} = VTCcell{iNew};
    else
        continue
    end 
end

for iNew = 1:length(SDMcell); 
    if ischar(SDMcell{iNew}); 
        SDMs{iNew} = SDMcell{iNew};
    else
        continue
    end 
end

VTCl = length(VTCs);
SDMl = length(SDMs);

% Generate an error if there are different numbers of VTCs and SDMs
if VTCl ~= SDMl;
    error('Your VTCs and SDMs are mismatched...');
end

NewMDM.NrOfStudies = VTCl;
NewMDM.XTC_RTC = cell(VTCl,2);

for iRuns = 1:VTCl
    NewMDM.XTC_RTC{iRuns,1} = [VTCSDMfolder VTCs{iRuns}];
    NewMDM.XTC_RTC{iRuns,2} = [VTCSDMfolder SDMs{iRuns}];
end

% Saving new .mdm file:
if mlConventions
    Idx = findstr('Subject_',VTCSDMfolder);
    Subj = VTCSDMfolder(Idx+8:Idx+9);
    NewMDM.SaveAs([Subj '_' NewFileNm]);
else
    NewMDM.SaveAs(NewFileNm);
end



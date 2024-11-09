% Analysis workflow:

ExpName = 'LOScTr_HugeIm';
SubNm = 'AG';
CodeDir = '~/Documents/Neuro_Docs/Projects-IUL/LOScaleTrans/Code/LOST_6Cond_HugeImOnly/';
SubDir = '~/Documents/Neuro_Docs/Projects-IUL/LOScaleTrans/MRI/AG_05_06_08/';
pDir = '~/Documents/Neuro_Docs/Projects-IUL/LOScaleTrans/MRI/';
% move in mat files: 
movefile([CodeDir SubNm '_*_*.mat'], [SubDir 'PRTs_RTCs/']); % from code directory

% move in PRTs & RTCs:
copyfile([pDir 'PRTs_RTCs_HugeImOnly/' ExpName '_Run*.prt'],[SubDir 'PRTs_RTCs/']); % from PRTs_RTCs directory
copyfile([pDir 'PRTs_RTCs_HugeImOnly/' ExpName '_Run*.rtc'],[SubDir 'PRTs_RTCs/']); % from PRTs_RTCs directory
mlBV_PRTListMaker(SubNm)

% Create error-free PRTs & RTCs:
mlBV_CreateErrorFreePRT_Loop
mlBV_RTCwriteLoop([SubNm '_' ExpName '_Run'],[SubNm '_' ExpName '_NoErr_Run'],'Deconv',10)
mlBV_PRTListMaker(SubNm,SubNm,'_NoErr')

cd ../Main_VTCs/
mlBV_VTCListMaker(SubNm)

% Link Error Free PRTs to VTCs:
mlLinkPRT2VTC([SubNm '_VTCs.txt'],['../PRTs_RTCs/' SubNm '_NoErr_PRTs.txt'])

% Create VOIf from localizer (manual)

% Create MDM:
copyfile('../PRTs_RTCs/*NoErr*rtc');
mlBV_MDMCreator([SubNm '_' ExpName '_NoErr_Runs1to' num2str(length(dir('*.vtc'))) '_10preds.mdm'])

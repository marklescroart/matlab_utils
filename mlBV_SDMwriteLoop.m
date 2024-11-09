function mlBV_SDMwriteLoop(PRTprefix,SDMprefix,Type,nPreds,TRlength)

% Wrapper for mlBV_SDMfromPRT.m
%
% Usage: mlBV_SDMwriteLoop(PRTprefix,SDMprefix,Type,nPreds,TRlength)
%
% Will take PRT file [PRTprefix(ii).prt] and convert it to:
%                    [SDMprefix(ii)_(nPreds)_Preds.sdm];
% 
% Written by ML on 5.27.09; modified from mlBV_RTCwriteLoop

YN = questdlg('Use current directory?');
if ~strcmp(YN,'Yes')
    error('OK, then I don''t know what to do with you for now.');
end

PRTs = dir(['*' PRTprefix '*.prt']);
disp('This is a temp fix: please make sure these PRT files are in order (i.e., go from 1 to N scans)');
PRTs = mlStructExtract(PRTs,'name')

for ii = 1:length(PRTs)
    mlBV_SDMfromPRT([SDMprefix num2str(ii) '_' num2str(nPreds) '_Preds.sdm'], PRTs{ii} ,Type ,nPreds,TRlength);
end

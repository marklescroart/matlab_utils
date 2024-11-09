function mlBV_RTCwriteLoop(PRTprefix,RTCprefix,Type,nPreds)

% Wrapper for mlBV_RTCfromPRT.m
%
% Usage: mlBV_RTCwriteLoop(PRTprefix,RTCprefix,Type,nPreds)
%
% Will take PRT file [PRTprefix(ii).prt] and convert it to:
%                    [RTCprefix(ii)_(nPreds)_Preds.rtc];
% 
% Written by ML on 9.20.07; modified 11.15.07

YN = questdlg('Use current directory?');
if ~strcmp(YN,'Yes')
    error('OK, then I don''t know what to do with you for now.');
end

PRTs = dir(['*' PRTprefix '*.prt']);
disp('This is a temp fix: please make sure these PRT files are in order (i.e., go from 1 to N scans)');
PRTs = mlStructExtract(PRTs,'name')

for ii = 1:length(PRTs)
    mlBV_RTCfromPRT([RTCprefix num2str(ii) '_' num2str(nPreds) '_Preds.rtc'], PRTs{ii} ,Type ,nPreds);
end

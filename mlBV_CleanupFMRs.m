function mlBV_CleanupFMRs

% Deletes extra intermediate BV pre-processing files. Currently kills
% SCSAI2, SCCAI2, 3DMCTS, 3DMCT, SD3DSS4.00mm (this is assuming that
% temporal high-pass filtering comes last, and so you don't want to delete
% that one...
RecycleState = recycle;
recycle on;

L = length(dir); 

FMRs = mlStructExtract(dir('*.fmr'),'name');
STCs = mlStructExtract(dir('*.stc'),'name');

if length(FMRs) == 0
    error('Excuse me: there are no FMR files here, jackass.')
end

Steps = {'SCSAI','SCSAI2','SCCAI2','3DMCTS','3DMCT'}; % intermediate steps in BV Preprocessing
0;
%{
A = regexp(FMRs,'(?<=_)[A-Za-z0-9]*(?=[_.])','match');
for i = 1:length(A); L(i) = length(A{i}); end
A(L==max(L))
%}


try
    for iS = 1:length(Steps)
        ToKillFMR = grep(FMRs,[Steps{iS} '.fmr']);
        ToKillSTC = grep(STCs,[Steps{iS} '-.stc']);
        if ~isempty(ToKillFMR)
            delete(ToKillFMR{:});
        end
        if ~isempty(ToKillSTC)
            delete(ToKillSTC{:});
        end
    end
catch
    % Warning if file naming scheme is different:
    error([mfilename ':UnknownPreprocessing'],['You seem to have a different pre-processing scheme than ML.' ...
        '\n Deleting your FMRs with this function is NOT RECOMMENDED.' ... 
        '\n To continue anyway, comment out this error message and call the function again.']);
end
recycle(RecycleState);

LL = length(dir); 
fprintf('\n%s moved %d files to the recycle bin.\n\n',mfilename,L-LL)
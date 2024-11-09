function mlFilePartReplace(ToComeOut,ToGoIn,F)

% Usage: mlFilePartReplace(ToComeOut,ToGoIn [,fNameCell])
% 
% Replaces string "ToComeOut" with string "ToComeIn" in every file in
% fNameCell (or every file in current directory matching criteria).
% 
% Created by ML 2009.08.18

if ~exist('F','var')
    F = mlStructExtract(dir(['*' ToComeOut '*']),'name');
end
nFiles = length(F);

for iF = 1:length(F)
    movefile(F{iF},strrep(F{iF},ToComeOut,ToGoIn));
end

fprintf('%d file names modified.\n\n',nFiles)
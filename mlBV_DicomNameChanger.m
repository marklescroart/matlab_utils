% BV Dicom Filename modifier
%
% Gets rid of spaces in dicom file names (I hope).
%%

% FileDir = '/Users/Work/Desktop/LO_LatII.2/SubjectKH_03_22_07/Raw/';

%%
error('old outdated garbage. comment this out if you want to work with it.')

CurrentDir = pwd;
cd(FileDir);

Files = Dir;

%%% This will only work for ONE blank!

for ii = 1:length(Files)
    if length(Files(ii).name) > 10
        blank = findstr(' ',FileNm);
        movefile(FileNms(ii).name,[FileNms(ii).name(1:blank-1) FileNms(ii).name(blank+1:end)]);
    end
end

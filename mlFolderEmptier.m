function mlFolderEmptier

% Moves all files within the FOLDERS in the current directory into the
% CURRENT DIRECTORY. 
% 
% Created for the extremely annoying tendency of USC's MRI magnet to group
% dicom files into folders of 1000 files each, without regard to which scan
% they belong to.
%
% Written by ML 6.13.06

Dirs = dir;

Count = 1; 
for ii = 1:length(Dirs); 
    if Dirs(ii).isdir && Dirs(ii).name(1) ~= '.';
        movefile([Dirs(ii).name filesep '*'])
        rmdir(Dirs(ii).name);
        Count = Count+1; 
    end 
end

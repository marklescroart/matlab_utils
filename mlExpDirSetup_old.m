function mlExpDirSetup(Subject,ExpName,Date)

% Usage: mlExpDirSetup(SubjectInitials, ExpName [,Date])
%
% Creates ML's usual directory structure for a BV MRI subject
% 
% 
% Assumes that first two letters of CD name are subject's
% initials. Also assumes usual setup for CDs from USC's Dornsife
% Neuroimaging Center.
% 
% If Date is not provided, today's date is used. 
%
% Created by ML 6.28.07

here = pwd;

if ~exist('Date','var')
    Date = mlTitleDate;
end
    
% ML Root directory for all projects:
Root = ['/Users/Work/Documents/Neuro_Docs/Projects-IUL/'];
Experiment = [Root ExpName];

try
    cd(Root)
catch
    error(['Please fix the root directory in ' mfilename]);
end
try
    cd(Experiment)
catch
    mkdir(Experiment)
    cd(Experiment)
end

try 
cd([Subject '_' Date]);
catch 
    mkdir([Subject '_' Date]);
    cd([Subject '_' Date]);
end

Folders{1} = 'Raw';
Folders{2} = 'Anatomical';
Folders{3} = 'Main_FMRs_STCs';
Folders{4} = 'Main_VTCs';
Folders{5} = 'Localizer_FMRs_STCs';
Folders{6} = 'Localizer_VTCs';
Folders{7} = 'EyeData';
Folders{8} = 'PRTs_RTCs';

for ii = 1:length(Folders)
    try
        cd(Folders{ii})
    catch
        mkdir(Folders{ii});
        cd(Folders{ii});
    end
    cd ..
end

cd(here)

%% The following won't work on windows machines. 

COMP = computer; % (thus this, to keep it from trying)

if strfind(COMP,'MAC')
    [CDorNot] = questdlg('Import data from CD?');
    if strcmp(CDorNot,'Yes');
        
        cd('/Volumes/');
        
        % Assumes that first two letters of CD name are subject's
        % initials. Also assumes usual setup for CDs from USC's Dornsife
        % Neuroimaging Center.
        
        CDfolder = dir([Subject '*']);
        cd(CDfolder.name);

        cd DICOM;
        FLDR = dir;
        for ii = 1:length(FLDR)
            if strcmp(FLDR(ii).name(1),'.')
                continue
            else
                copyfile(FLDR(ii).name,[Experiment '/' Subject '_' Date '/Raw/']);
            end
        end
    end

    cd([Experiment '/' Subject '_' Date '/Raw']);
    
    test = dir;
    test2 = mlStructExtract(test,'isdir');
    nDirs = length(find(test2));
    
    while nDirs>2
        mlFolderEmptier;
        test = dir;
        test2 = mlStructExtract(test,'isdir');
        nDirs = length(find(test2));
        % Just in case this goes on forever...
        disp('Repeating mlFolderEmptier...');
        WaitSecs(.01);
    end
    
end

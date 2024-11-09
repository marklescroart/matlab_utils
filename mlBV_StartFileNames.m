function mlBV_StartFileNames(Runs,fName,RawDir)

% Usage: mlBV_StartFileNames(Runs [,fName][,RawDir])
% 
% Inputs: Runs =  a vector of run numbers (see example)
%        fName = name of file to be created (default = 'dicomfiles.txt')
%       RawDir = string; directory for raw dicom files. Defaults to 'Raw/'
% 
% Example:
%   mlBV_StartFileNames([2 4 6 8 10 12 14]);
% 
% Writes <fName> (defaults to dicomfiles.txt) file for use with BV Scripting.
% 
% please call from main subject directory (according to ML conventions)

if ~exist('RawDir','var')
    RawDir = 'Raw/'; % ML conventions
end
if ~exist('fName','var')
    fName = 'dicomfiles.txt';
end

nRuns = length(Runs);

fAll = mlStructExtract(dir([RawDir '*dcm']),'name');
fStartAll = grep(fAll,'00001.dcm');

TitStr = ['~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ file names ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n'...
          '                  Created ' sprintf('%.0f.%02.0f.%02.0f - %02.0f:%02.0f:%02.0f',clock) 'by ' mfilename '\n'...
          '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n'];
if exist(fName,'file')
    YN = input('File already exists. Proceed anyway? (this will overwrite file) (y/n)   ','s');
    if strcmpi(YN,'y')
        0;
    else
        error('Stopped instead of overwriting file. Please move file and try again.')
    end
        
end
fid = fopen(fName,'w');
fprintf(fid,TitStr);
fprintf(fid,'Number of files:\n%.0f\n',nRuns);

for i = 1:nRuns
    R = grep(fStartAll,sprintf('%04.0f',Runs(i))); 
    fprintf(fid,'%s%s%s%s <br>\n',pwd,filesep,RawDir,R{1}); 
end

fclose(fid);
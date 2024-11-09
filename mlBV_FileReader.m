function Data = mlBV_FileReader(InptFile,OutptFile)

% OBSOLETE - DO NOT USE.

% usage: Data = mlBV_FileReader(InptFile [,FileType])
%
% Designed to read data from BV saved data (.dat files only, not data
% tables) 
%
% Inputs: InptFile - string that specifies the relative or absolute path of
%                    the file to be read
%         FileType - So far, 'Deconv' (=Deconvolution plot data) or '3DMC'
%                    (3D motion correction data for a given subject). This
%                    is only needed if you want to see a plot of the data;
%                    If you want to save the data (without plotting), enter
%                    'Save' or leave it blank. (Saves
%                    "(InptFile)_MatVars.mat") To skip saving AND plotting,
%                    enter 'dnr'
%                    
% Outputs:  Data   - a struct array with the fields: 
%                    .Subject - Subject's initials (from first two
%                        letters of filename)
%                    .nGroups - number of groups (curves) of data
%                    .Colors - Colormap to graph the curves
%                    .Length - number of time points (x points) of data
%                    .Data - nGroups x 1 cell array of Length x 2
%                        matrices of data. (the actual data, separated 
%                        into curves)
% 
% Written by ML on 3.30.07

% for Deconvolution data, files should be saved in the form: 
% 
% "<Subject Initials>_<Region of Interest>_Deconv.dat"

error('This is an outdated file as of 3.11.08. Try mlBV_DatFileReader');

%%% Input check:
if ~exist('InptFile','var') || ~strcmp(InptFile(end-3:end),'.dat')
    error('Please input a .dat file exported from BV to this function, if you want it to do anything.');
end

if ~exist('FileType','var')
    FileType = 'Save';
end


%%% The following rely on the structure of the .dat files written by BV -
%%% they always have "TimeCourseDataR: " and then the R value 8 lines above
%%% where the data begins.
backto.R = 8;
backto.G = 7;
backto.B = 6; 

%%% COULD BE PROBLEMATIC:
%[Data.Subject, Data.ROI, Data.Type] = mlTitleReader(InptFile);

%%% Quick fix: ???
[Data.Subject, Data.ROI, Data.Type] = mlTitleReader(InptFile);
%[Data.ROI, Data.Subject, Junk, Data.Type] = mlTitleReader(InptFile);
Data.Type = 'Deconv';

try
    load ConditionNames.mat
    Data.ConditionNames = ConditionNames;
catch
    disp('No Condition Names found... no legend will be added');
end

stDC = strfind(InptFile,'DC');
Data.DC = str2num(InptFile(stDC+2:stDC+4));
fid = fopen(InptFile);
count = 1;
while(1)
    AllDat{count} = fgetl(fid);
    if ~ischar(AllDat{count}), break, end
    count = count+1;
end
fclose(fid); clear fid;

%%% Indices of where the data are in the big cell array:
Data.nGroups = str2num(AllDat{2}(12:end));

Ind.data = find(strcmp(AllDat,'<data>')==1);
Ind.start = Ind.data(1:2:end);
Ind.fin = Ind.data(2:2:end);

%%% Color of the lines in the resultant plots: 
Data.Colors = zeros(length(Ind.start),3);
%%% Length of each data set should be equal to "NrOfCurveDataPoints" field
%%% from header of each set; this checks with the first set only (though
%%% all should be the same)
Data.Length = str2num(AllDat{5}(20:end)); 


for ii = 1:length(Ind.start)
    Data.Colors(ii,1) = str2double(AllDat{Ind.start(ii)-backto.R}(19:end));
    Data.Colors(ii,2) = str2double(AllDat{Ind.start(ii)-backto.G}(19:end));
    Data.Colors(ii,3) = str2double(AllDat{Ind.start(ii)-backto.B}(19:end));
    %%% Checking on length of data set:
    if (Ind.fin(ii)-Ind.start(ii)-1) ~= Data.Length
        save DebugVars
        error('The data sets in this file are not equal in size.');
    end
    %%% Assigning data to variable dd:
    for jj = 1:Data.Length
        dd{ii}(jj,:) = str2num(AllDat{Ind.start(ii)+jj});
    end
end

Data.Data = dd;

save([InptFile(1:end-4) '_MatVars.mat'],'Data')

% Writing to subject average file:
fid = fopen(OutptFile,'a');
fprintf(fid,'\n<Subject>\n%s\n<Subject>\n',Data.Subject);


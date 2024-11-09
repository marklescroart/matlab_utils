function Data = mlBV_DatFileReader(InptFile,OutptFile)

% usage: Data = mlBV_DatFileReader(InptFile,OutptFile)
%
% Designed to read data from BV saved data (.dat files only, not data
% tables) 
%
% Inputs: InptFile - String filename for a Brain Voyager .dat file.
%                    Currently, this program must be run from the same 
%                    directory as the .dat file to work. Sorry. 
%         ** NOTE: There must be a file called ConditionNames.txt in the
%                    same directory as the .dat files that lists the names
%                    of the experimental conditions in order on subsequent
%                    lines
%                    
% Outputs:  OutptFile - a text file written according to ML's conventions.
%         Run it and see what it creates for an example. 
% 
% Written by ML on 3.30.07
% Modified by ML on 1.30.08


%%% Input check:
if ~exist('InptFile','var') || ~strcmp(InptFile(end-3:end),'.dat')
    error('Please input a .dat file exported from BV to this function, if you want it to do anything.');
end

if ~exist('OutptFile','var')
    OutptFile = 'Test.txt';
end

%%% The following rely on the structure of the .dat files written by BV -
%%% they always have "TimeCourseDataR: " and then the R value 8 lines above
%%% where the data begins.
backto.R = 8;
backto.G = 7;
backto.B = 6; 

% Should define Data.ROI,Data.DC,and Data.SUB
Data = mlParseTitle(InptFile);

try
    ConditionNames = importdata('ConditionNames.txt');
    Data.ConditionNames = ConditionNames;
catch
    error(sprintf('No Condition Names found...\n\nPlease create a ConditionNames.txt file in the same directory as your .dat files.'));
end

if ~isempty(findstr(InptFile,'NoErr'));
    for iEr = 1:length(ConditionNames)
        Data.ConditionNames{end+1} = [Data.ConditionNames{iEr} ' Errors'];
    end
end

AllDat = mlFileToCell(InptFile);

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
% Data.Length = str2num(AllDat{5}(20:end)); 

R = grep(AllDat,'TimeCourseColorR');
G = grep(AllDat,'TimeCourseColorG');
B = grep(AllDat,'TimeCourseColorB');

for ii = 1:length(Ind.start)
    Data.Colors(ii,1) = str2double(R{ii}(end-4:end));
    Data.Colors(ii,2) = str2double(G{ii}(end-4:end));
    Data.Colors(ii,3) = str2double(B{ii}(end-4:end));
    %%% Checking on length of data set:
    if (Ind.fin(ii)-Ind.start(ii)-1) ~= Data.NPOINTS
        save DebugVars
        error('The data sets in this file are not equal in size.');
    end
    %%% Assigning data to variable dd:
    for jj = 1:Data.NPOINTS
        dd{ii}(jj,:) = str2num(AllDat{Ind.start(ii)+jj});
    end
end

Data.Betas = dd;
for iPct = 1:length(Data.Betas)
    Data.Data{iPct} = Data.Betas{iPct}/Data.DC*100;
end


%save([InptFile(1:end-4) '_MatVars.mat'],'Data')

% Writing to subject average file:
fid = fopen(OutptFile);
if fid<0
    % Writing header (for group average, only needs to be done once)
    fid = fopen(OutptFile,'w');
    fprintf(fid,'Notes on Experiment:\n\n\n<ConditionNamesStart>\n');
    fprintf(fid,'%s\n',Data.ConditionNames{:},'<ConditionNamesEnd>');
    fprintf(fid,'\n<ColorsStart>\n');
    for ii = 1:length(Data.Colors)
        fprintf(fid,'%s\n',num2str(Data.Colors(ii,:)));
    end
    fprintf(fid,'<ColorsEnd>\n\n');
    fprintf(fid,'<ROIStart>\n%s\n<ROIEnd>\n',Data.ROI);
else
    % ROI check: (to make sure we're not mixing Regions of Interest)
    count = 1;
    while(1)
        FCheck{count} = fgetl(fid);
        if ~ischar(FCheck{count}), break, end
        count = count+1;
    end
    ROIidx = find(strcmp('<ROIStart>',FCheck));
    if ~strcmp(Data.ROI,FCheck{ROIidx+1})
        error(sprintf('You may have the wrong ROI in the file you''re attempting to add.\n\n Please check it out before proceeding.'));
    end
end
fclose(fid);

fid = fopen(OutptFile,'a');
fprintf(fid,'\n<SubjectStart>\n%s\n<SubjectEnd>\n',Data.SUB);
for iWr = 1:length(Data.Data); 
    fprintf(fid,'<DataStart>\n'); 
    fprintf(fid,'%.4f\t',Data.Data{iWr}(:,1));
    fprintf(fid,'\n'); % there has to be a better way to do this ???
    fprintf(fid,'%.4f\t',Data.Data{iWr}(:,2)); 
    fprintf(fid,'\n<DataEnd>\n\n');
end

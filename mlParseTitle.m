function SS = mlParseTitle(fName)

% Usage: SS = mlParseTitle(fName)
% 
% Parses file name into fields in a struct array. For example, the file
% 
% "SUB=ML_ROI=PF_SEX=M_AGE=27.dat" 
% 
% will be parsed to: 
% 
% SS = 
%     SUB: 'ML'
%     ROI: 'PF'
%     SEX: 'M'
%     AGE: 27
% 
% All pairs should be separated by a non-capital-letter, non-numeric
% character (stick with "_", it works). 
% 
% Created by ML 1.30.08




[Vars] = regexp(fName,'[A-Z]*(?==)','match');
[Values] = regexp(fName,'(?<==)([A-Z]*|[0-9]*)','match');

if length(Vars)~=length(Values)
    error('Your conventions don''t match Mark''s. You suck. See the help for this function and fix your file name.')
end

for ii = 1:length(Vars)
    if isletter(Values{ii})
        SS.(Vars{ii}) = Values{ii};
    else
        SS.(Vars{ii}) = str2num(Values{ii});
    end
end
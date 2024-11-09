function mlBV_HTMLtableReader(fname)

% Reads BV GLM graphs.
% 
% Currently unused: Values(:,3) = T values
%                   Values(:,4) = P values associated with T
%                   Values(17:20,:) and Labels(17:20) contain ANOVA output
%                   
% Created by ML 

Data = mlParseTitle(fname);
FF = mlFileToCell(fname);

% Beta values will be in Values(26:end,1) and se (standard error) will be Values(26:end,2)
for ii = 1:length(FF);
    Labels{ii} = regexp(FF{ii},'(?<=<b>)[^<]*(?=</b>)','match');
    Values{ii} = regexp(FF{ii},'(?<=<td>)[^<]*(?=</td>)','match');
end

datfname = [fname(1:end-4) 'dat'];
fid = fopen(datfname,'w');
% fid = 1; % For test runs
Count = 26; % First line of actual data in BV html files
nCurves = (length(Labels)-25-5)/Data.NPOINTS; % 25 blank at beginning, 5 blank at end, 6 3DMC conditions

try
    Color = importdata('ConditionColors.txt');
catch
    warning([mfilename ':NoColors'],'Couldn''t find ConditionColors.txt file. Using all white curves.')
    Color = 255*ones(10,3);
end

fprintf(fid,'FileVersion: 1.0\n');
fprintf(fid,'NrOfCurves:  %.0f\n\n',nCurves);
fprintf(fid,'StdDevErrs:  1\n');

for ii = 1:nCurves
    fprintf(fid,'NrOfCurveDataPoints %.0f\n',Data.NPOINTS);
    fprintf(fid,'TimeCourseThick:  3\n');
    fprintf(fid,'TimeCourseColorR: %.0f\n',Color(ii,1));
    fprintf(fid,'TimeCourseColorG: %.0f\n',Color(ii,2));
    fprintf(fid,'TimeCourseColorB: %.0f\n',Color(ii,3));
    fprintf(fid,'StdDevErrThick:   2\n');
    fprintf(fid,'StdDevErrColorR:  %.0f\n',Color(ii,1));
    fprintf(fid,'StdDevErrColorG:  %.0f\n',Color(ii,2));
    fprintf(fid,'StdDevErrColorB:  %.0f\n',Color(ii,3));
    fprintf(fid,'NrOfSegIntervals: 0\n');
    fprintf(fid,'<data>\n');
    for jj = 1:Data.NPOINTS
        fprintf(fid,'%s %s\n',Values{Count}{1:2});
        Count = Count + 1;
    end
    fprintf(fid,'<data>\n\n');
end


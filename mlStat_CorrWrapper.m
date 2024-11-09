function Rho = mlStat_CorrWrapper(X,Names)

if nargin<1
    error([mfilename ':NoXorY'],['What the hell do you think you''re doing running a regression with no variables?' ...
        '\nGo take a stats class. Or see the help for this function for usage.']);
elseif nargin<2
    for iCol = 1:size(X,2)
        Names{iCol} = sprintf('Col_%.0f',iCol);
    end
end

% Defaults: 
PrintSimpleStats = 1;
DisplayOn = 1;
PrintToFile = 0;

if PrintToFile
    fid = fopen(['RegressionResult_' mlTitleTime '.txt'],'w');
else
    fid = 1; % Prints to screen
end

Rho = corr(X);

if DisplayOn
    fprintf(fid,'\nCorrelations between variables:\n\n');
    fprintf(fid,'%10s',' ',Names{:});
    for iCor = 1:size(Rho,1);
        fprintf(fid,'\n%10s',Names{iCor});
        fprintf(fid,'%10.4f',Rho(iCor,:));
    end
    fprintf(fid,'\n');
end
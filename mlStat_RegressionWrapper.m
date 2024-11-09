function mlStat_RegressionWrapper(X, Y, VarNames)

% Usage: mlStat_RegressionWrapper(X, Y [,VarNames])
% 
% Put X and Y into column form, please. VarNames should be a cell array
% that has the DV first, then each of the IVs in order. 
% 
% 

if nargin<2
    error([mfilename ':NoXorY'],['What the hell do you think you''re doing running a regression with no variables?' ...
        '\nGo take a stats class. Or see the help for this function for usage.']);
elseif nargin<3
    VarNames{1} = 'DV';
    for iv = 1:size(X,2)-1
        VarNames{iv+1} = sprintf('IV_%.0f',iv);
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

% Quick manipulation of data:
AllVars = VarNames;
DV_Name = VarNames{1};
IV_Names = VarNames(2:end);
clear VarNames;

DatMat = [Y X(:,2:end)];

% Printing out simple statistics: 
if PrintSimpleStats
    P = {'Variable' 'Length (N)' 'Mean' 'Std Dev' 'Sum' 'Minimum' 'Maximum'};
    fprintf(fid,'\nSimple Stats on Variables: \n');
    fprintf(fid,'%s\n',repmat('-',1,15*size(P,2)+15));
    fprintf(fid,'%15s%15s%15s%15s%15s%15s%15s\n',P{1,:});
    fprintf(fid,'%s\n',repmat('-',1,15*size(P,2)+15));
    for ii = 1:length(AllVars)
        fprintf(fid,'%15s%15.0f%15.5f%15.5f%15.5f%15.5f%15.5f\n',AllVars{ii},length(DatMat(:,ii)),mean(DatMat(:,ii)),std(DatMat(:,ii)),sum(DatMat(:,ii)),min(DatMat(:,ii)),max(DatMat(:,ii)));
    end
end

% Calculating and printing correlations between DV / IVs
Rho = mlStat_CorrWrapper(DatMat,AllVars);

% Regressions
[Betas,bint,resids,rint,RegStats] = regress(Y,X);
%     bint = beta val confidence intervals
%     rint = residual confidence intervals
% RegStats = R-square statistic, the F statistic and p value for the full
%            model, and an estimate of the error variance

Rsquared = RegStats(1);
RegF = RegStats(2);
RegP = RegStats(3);

MS_Err = RegStats(4);

SS_Err = sum(resids.^2);
SS_Tot = sum((Y-mean(Y)).^2);
SS_Mod = SS_Tot-SS_Err;

RegDF_Mod = size(X,2)-1;
RegDF_Err = size(X,1)-size(X,2)+1-1; % plus one for extra column of ones, minus one for (n-1) df
RegDF_Tot = RegDF_Mod+RegDF_Err;

MS_Mod = SS_Mod/RegDF_Mod;


% Plotting Residuals:
% figure('Position',Pos(1,:));
% plot(rint,'+');
% hold on; plot(resids,'r.'); hold off;
% title('Residuals with confidence intervals around them');


for jj = 1:length(Y); SeparateResids(jj,1) = Y(jj) - Betas(1); end
for jj = 1:length(Y); SeparateResids(jj,2) = Y(jj) - Betas(1) - (Betas(2)*X(jj,2)); end
for jj = 1:length(Y); SeparateResids(jj,3) = Y(jj) - Betas(1) - (Betas(3)*X(jj,3)); end
NewCorr = [DatMat SeparateResids];
NewRho = corr(NewCorr);

tt(1,1:6) = {'Source' 'df' 'SS' 'MS' 'F' 'Prob>F'};
tt(2,1:6) = {'Model',[RegDF_Mod],[SS_Mod],[MS_Mod],RegF,RegP};
tt(3,1:6) = {'Error',[RegDF_Err],[SS_Err],[MS_Err],0,0};
tt(4,1:6) = {'Total',[RegDF_Tot],[SS_Tot],0,0,0};

if DisplayOn
    fprintf(fid,'\nRegression Results: \n');
    fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
    fprintf(fid,'%15s%15s%15s%15s%15s%15s\n',tt{1,1:6});
    fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
    for ii = 2:size(tt,1)
        if SS_Err<100 % Use 4 decimal places for SS_Err < 100
            fprintf(fid,'%15s%15.0f%15.4f%15.4f%15.2f%15.4f\n',tt{ii,:});
        else 
            fprintf(fid,'%15s%15.0f%15.0f%15.4f%15.2f%15.4f\n',tt{ii,:});
        end
    end
    
    fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
    fprintf(fid,'Root MSE = \n');
    fprintf(fid,'DV Mean = %.4f\n',mean(Y));
    fprintf(2,'Rsquared = %.4f\n',Rsquared);
    
    fprintf(fid,'\nParameter Estimates:\n');
    fprintf(fid,'%15s:%15.5f\n','Intercept',Betas(1));
    for iB = 1:length(IV_Names);
        fprintf(fid,'%15s:%15.5f\n',IV_Names{iB},Betas(iB+1));
    end
end


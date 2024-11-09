function mlBV_ROI_Deconvolution(SubID,VTCs,RTCs,VOIfile,VOIname,CondNames,CondCols,OutPutFile,Extras)

% usage: mlBV_ROI_Deconvolution(SubID,VTCs,RTCs,VOIfile,VOIname [,CondNames] [,CondCols] [,OutPutFile] [,Extras])
%
% Inputs:
%        SubID = String for subject ID (e.g. 'ML')
%         VTCs = Cell array of VTC file names (with path name from
%                the directory from which you call it, or with absolute
%                path names)
%         RTCs = Cell array of RTC file names (in same order as VTCs, with
%                same path requirements)
%      VOIfile = String file name for Brain Voyager .voi file
%      VOIname = String name of actual ROI in which you want the analysis
%                done
%    CondNames = Cell array of Condition Names (Optional)
%     CondCols = (nConditions x 3) Matlab array of Condition Colors
%                (Optional - defaults to all white)
%   OutPutFile = String name for output file; if omitted, function will
%                print to screen
%       Extras = EITHER a Cell array of string filenames for output .mat 
%                files from mlBV_VTCOutliers, used to cut out outlying data
%                points if this argument is provided, OR a cell array of
%                string filenames for output .dat files from
%                mlMRI_3DMCinfo, which are used to create motion correction
%                regressors (code recognizes .dat or .mat extension)
%
%  Outputs:
%        Writes OutPutFile (w/ ML Conventions as to what's what - turn off 
%        ML Conventions to just write the raw data matrix)
% 
% Created by ML 2008/03/20; modified 2008/04/26

if nargin<5
    error([mfilename ':BadArgs'],['I need at least a Subject ID, a list of VTCs & RTCs, a VOI file, and a VOI name.' ...
        '\n\nUsage: mlBV_Regression(SubID,VTCs,RTCs,VOIfile,VOIname [,CondNames] [,F.PrintToFile])\n']);
end
if ~exist('OutPutFile','var')||isempty(OutPutFile); 
    F.PrintToFile = 0; 
else
    F.PrintToFile = 1;
end
if ~exist('Extras','var');
    F.CutOutliers = 0;
    F.MCRegressors = 0;
else
    if strcmp(Extras{1}(end-2:end),'dat') % meaning: these are Motion Correction parameter files
        F.MCRegressors = 1;
        F.CutOutliers = 0;
    elseif strcmp(Extras{1}(end-2:end),'mat') % meaning: these are outlying voxel definition files
        F.MCRegressors = 0;
        F.CutOutliers = 1;
    end
end
MLConventions = 1;
F.Factors = 1;
try
    %fname = ['Subject_' SubID '_' VOIname '_' ExpName '.txt'];
    nRuns = length(VTCs);
    RTC1 = BVQXfile(RTCs{1});
    nTimePoints = size(RTC1.RTCMatrix,1);
    nPredsTot = size(RTC1.RTCMatrix,2);
    nDeconvPtsCell = regexp(RTCs{1},'[0-9]*(?=_Preds)','match');
    nDeconvPts = str2double(nDeconvPtsCell{1}); % 10; % 20
    nConds = nPredsTot/nDeconvPts; 
    clear RTC1;
    
    if ~exist('CondNames','var')
        for iv = 1:nConds;
            CondNames{iv} = sprintf('Cond_%.0f',iv);
        end
    end
    if ~exist('CondCols','var')
        CondCols = zeros(nConds,3);
    end
    
    ReduceOrNo = 0; % Eliminates redundant voxels in interpolated BV VTCs

    Y = [];
    X = [];
    for iR = 1:nRuns
        if F.CutOutliers; 
            load(Extras{iR});
            ToCut = ToCut(ToCut<=length(PctBad));
        end
        [Vox] = mlBV_VOIVoxels(VTCs{iR},VOIfile,VOIname,ReduceOrNo);
        TempY = mean(Vox,2);
        if F.CutOutliers; TempY(ToCut) = []; end                  % Clipping Y
        Y = [Y;TempY];
        RTC = BVQXfile(RTCs{iR});
        TempX = RTC.RTCMatrix;
        if F.CutOutliers; TempX(ToCut,:) = []; end                % Clipping X
        if F.MCRegressors; 
            MC = importdata(Extras{iR});                          % Getting MC Data
            if F.Factors
                warning('off','all');
                nFactors = 3;
                [Lambda, Psi, T, FAStats, Factors] = factoran(abs(MC(end-size(TempX,1)+1:end,:)), nFactors,'Rotate','promax');
                warning('on','all');
                TempX = [TempX, Factors];                          % Adding Regressors
            else
                TempX = [TempX, MC(end-size(TempX,1)+1:end,1:3)];  % Adding Regressors
            end
            0;
        end
        
        AddMeanIV = zeros(size(TempX,1),nRuns);
        AddMeanIV(:,iR) = ones(size(TempX,1),1);
        TempX = [TempX,AddMeanIV];
        X = [X;TempX];
        clear TempX TempY
    end

    % Regression
    [Betas,bint,resids,rint,RegStats] = regress(Y,X);
    %     bint = beta val confidence intervals
    %     rint = residual confidence intervals
    % RegStats = R-square statistic, the F statistic and p value for the full
    %            model, and an estimate of the error variance

    % Setting up regression statistics:
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

    tt(1,1:6) = {'Source' 'df' 'SS' 'MS' 'F' 'Prob>F'};
    tt(2,1:6) = {'Model',[RegDF_Mod],[SS_Mod],[MS_Mod],RegF,RegP};
    tt(3,1:6) = {'Error',[RegDF_Err],[SS_Err],[MS_Err],0,0};
    tt(4,1:6) = {'Total',[RegDF_Tot],[SS_Tot],0,0,0};

    DatMat = reshape(Betas(1:nPredsTot),nDeconvPts,nConds);
    DC = mean(Betas(end-nRuns+1:end));
    if F.MCRegressors;
        MCBetas = Betas(nPredsTot+1:end-nRuns);
    end
    DatMatPct = DatMat/DC*100;
    
    ErrMat = std(resids)/sqrt(nPredsTot+nConds)*ones(size(DatMat));
    ErrMatPct = ErrMat/DC*100;

    %%% Here we go w/ display:

    if MLConventions
        if F.PrintToFile
            fid = fopen(OutPutFile);
        else
            fid = 1;
        end
        if fid<=1
            if F.PrintToFile; fid = fopen(OutPutFile,'w'); end
            fprintf(fid,'Notes on Experiment:\n\n');
            fprintf(fid,'Values already converted to Pct. Signal Change.\n\n');
            fprintf(fid,'There are %.0f Voxels in this ROI.\n\n',size(Vox,2));

            % Statistics:
            fprintf(fid,'Regression Statistical Results:\n');
            fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
            fprintf(fid,'%15s%15s%15s%15s%15s%15s\n',tt{1,1:6});
            fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
            for iSt = 2:size(tt,1)
                if SS_Err<100 % Use 4 decimal places for SS_Err < 100
                    fprintf(fid,'%15s%15.0f%15.4f%15.4f%15.2f%15.4f\n',tt{iSt,:});
                else
                    fprintf(fid,'%15s%15.0f%15.0f%15.4f%15.2f%15.4f\n',tt{iSt,:});
                end
            end
            fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
            fprintf(fid,'Root MSE = %.4f\n',sqrt(tt{3,4}));
            fprintf(fid,'DV Mean = %.4f\n',mean(Y));
            fprintf(fid,'Rsquared = %.4f\n',Rsquared);
            fprintf(fid,'\n\n');

            % Condition Names:
            fprintf(fid,'%s\n','<ConditionNamesStart>', CondNames{:},'<ConditionNamesEnd>');
            fprintf(fid,'\n');

            % Colors:
            fprintf(fid,'<ColorsStart>\n');
            for iCol = 1:length(CondCols)
                fprintf(fid,'%s\n',num2str(CondCols(iCol,:)));
            end
            fprintf(fid,'<ColorsEnd>\n\n');

            % ROI:
            fprintf(fid,'<ROIStart>\n%s\n<ROIEnd>\n',VOIname);
            if F.PrintToFile; fclose(fid); end
        else
            if F.PrintToFile
                
                % ROI check: (to make sure we're not mixing Regions of Interest)
                count = 1;
                while(1)
                    FCheck{count} = fgetl(fid);
                    if ~ischar(FCheck{count}), break, end
                    count = count+1;
                end
                ROIidx = find(strcmp('<ROIStart>',FCheck));
                if ~strcmp(VOIname,FCheck{ROIidx+1})
                    error(sprintf('You may have the wrong ROI in the file you''re attempting to add.\n\n Please check it out before proceeding.'));
                end
                fclose(fid);
            end
        end
        
        
        if F.PrintToFile
            fid = fopen(OutPutFile,'a');
        end
        fprintf(fid,'\n<SubjectStart>\n%s\n<SubjectEnd>\n\n',SubID);
        % Regression Statistics:
        fprintf(fid,'Regression Statistical Results:\n');
        fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
        fprintf(fid,'%15s%15s%15s%15s%15s%15s\n',tt{1,1:6});
        fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
        for iSt = 2:size(tt,1)
            if SS_Err<100 % Use 4 decimal places for SS_Err < 100
                fprintf(fid,'%15s%15.0f%15.4f%15.4f%15.2f%15.4f\n',tt{iSt,:});
            else
                fprintf(fid,'%15s%15.0f%15.0f%15.4f%15.2f%15.4f\n',tt{iSt,:});
            end
        end
        fprintf(fid,'%s\n',repmat('-',1,15*size(tt,2)+15));
        fprintf(fid,'Root MSE = %.4f\n',sqrt(tt{3,4}));
        fprintf(fid,'DV Mean = %.4f\n',mean(Y));
        fprintf(fid,'Rsquared = %.4f\n',Rsquared);
        fprintf(fid,'\n\n');

        % Data:
        fprintf(fid,'\n<SubFValueStart>\n%.2f\n<SubFValueEnd>\n\n',tt{2,5});
        if F.MCRegressors
            fprintf(fid,['\n<SubMCBetaValuesStart>\n' repmat('%.4f\t',1,length(MCBetas)) '\n<SubMCBetaValuesEnd>\n\n'],MCBetas);
        end
        for iWr = 1:size(DatMatPct,2);
            fprintf(fid,'<DataStart>\n');
            fprintf(fid,'%.4f\t',DatMatPct(:,iWr));
            fprintf(fid,'\n');
            fprintf(fid,'%.4f\t',ErrMatPct(:,iWr));
            fprintf(fid,'\n<DataEnd>\n\n');
        end
    else
        dlmwrite(fname,DatMatPct,'\t');
    end

catch
    mlErrorCleanup;
    rethrow(lasterror);
end
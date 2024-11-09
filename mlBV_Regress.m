function mlBV_Regress(sName,VTCs,SDMs,VOIfile,VOIname,ExtraRegressors,OutlierDatFile,CondNames,CondCols)

% usage: mlBV_Regress(sName,VTCs,SDMs,VOIfile,VOIname [,ExtraRegressors] [,OutlierDatFile] [,CondNames] [,CondCols])
%
% Inputs:
%        sName = (string) Save file name. Should incorporate subject name
%                and any other identifying information you wish to include
%                (there is no other input for subject name / other info)
%         VTCs = (Cell array of strings) VTC file names (with path name 
%                from the directory from which you call it, or with 
%                absolute path names)
%         SDMs = (Cell array of strings) SDM file names (in same order as 
%                VTCs, with same path requirements) Also accepts .rtc files
%                for backward compatibility with earlier Brain Voyager data
%      VOIfile = (string) file name for Brain Voyager .voi file
%      VOIname = (string) name of ROI in which you want the analysis done
% ExtraRegressors = (cell array of strings) File names of (1) .rtc files
%                from BV's motion correction, or (2) .dat files from 
%                mlMRI_3DMCinfo (which reads out header-file info on motion
%                correction done by Siemens scanners in some scan
%                protocols), or (3) other regressors (heart rate, eye
%                position, more 3DMC info, etc) saved as .mat files. There
%                should be one file per run. The code will recognize .rtc, 
%                .dat, and .mat file extensions. All variables in .mat
%                files should be nTimepoints x rRegressors in size. 
%    CondNames = (cell array) Condition Names (Optional - does NOTHING as
%                of 2009.06.09)
%     CondCols = (nConditions x 3) Matlab array of Condition Colors
%                (Optional - Does NOTHING as of 2009.06.09)
%
%  Outputs:
%        Writes sName (.mat file) with the following variables: 
%        Betas (pBetas x nVoxels matrix)
%        Tvals (pTvals x nVoxels matrix) %!% Consider cutting this! Maybe not generally useful, easily calculated from other values... %!%  
%        MSe   (1 x nVoxel vector of Mean Squared Errors for each voxel 
%               regression)
%        Rsquared (1 x nVoxel vector of Rsquared for each voxel regression)
%        iXX (pBetas x pBetas matrix - pseudo-inverse of X'X (X is the
%               design matrix)
%        
% Created by ML 2008/03/20; modified 2009/06/09

% NOTE: http://luna.cas.usf.edu/~mbrannic/files/regression/matalg.html for
% explanation of multiple regression / singular matrices and the problems
% they cause. 

if nargin<5
    error([mfilename ':BadArgs'],['I need at least a save file name, a list of VTCs & SDMs, a VOI file, and a VOI name.' ...
        '\n\nUsage: mlBV_Regression(SubID,VTCs,SDMs,VOIfile,VOIname [,CondNames] [,Flag.PrintToFile])\n']);
end
if ~exist('ExtraRegressors','var')||isempty(ExtraRegressors)
    Flag.MoreRegressors = 0;
else
    WhichTypeRegressor = ExtraRegressors{1}(end-2:end); % end of first string better be indicative
    switch WhichTypeRegressor
        case {'rtc','dat','mat'}
            Flag.MoreRegressors = 1;
        otherwise 
            error('Unknown file type in variable "ExtraRegressors." Please try again.')
    end
end
if ~exist('OutlierDatFile','var')||isempty(OutlierDatFile)
    Flag.CutOutliers = false;
else
    Flag.CutOutliers = true;
end
    
VoxRes = 2
warning([mfilename ':DumbVoxCode'],'YOU MIGHT VERY WELL WANT TO CHANGE THE VOXEL RESOLUTION IN THE CODE... CURRENTLY SET TO 2X2X2 VOXELS');

% Option flags. See code for details. 
Flag.DisplayProgress = true;    % Displays regression progress (through many voxels). Updates every 100 voxels.
Flag.Factors = true;            % Substitute factors for raw 3DMC read-out; see below for notes
Flag.ROIAvg = false;            % Whether to compute ONE regression on the whole ROI or all voxel regressions
Flag.ReduceOrNo = false;        % Eliminates redundant voxels in interpolated BV VTCs %!% Needs work! Also re-sorts voxels ( =no good!) %!%
Flag.KeepOnly3x3 = true;        % New as of 2009.06.15: Selects only full 3x3x3 voxels from BV VOI

try

    nRuns = length(VTCs);
    
    %SDM1 = BVQXfile(SDMs{1});
    %if strfind('.sdm',SDMs{1});
    %    nTimePoints = size(SDM1.SDMMatrix,1);
    %    nPredsTot = size(SDM1.SDMMatrix,2);
    %else
    %    nTimePoints = size(SDM1.RTCMatrix,1);
    %    nPredsTot = size(SDM1.RTCMatrix,2);
    %end

    %nDeconvPtsCell = regexp(SDMs{1},'[0-9]*(?=_Preds)','match');
    %nDeconvPts = str2double(nDeconvPtsCell{1}); % 10; % 20
    %nConds = nPredsTot/nDeconvPts; 
    %clear SDM1 nDeconvPtsCell
    
    %if ~exist('CondNames','var')
    %    for iv = 1:nConds;
    %        CondNames{iv} = sprintf('Cond_%.0f',iv);
    %    end
    %end
    %if ~exist('CondCols','var')
    %    CondCols = zeros(nConds,3);
    %end
    
    % New as of 2009.06.15: Selects only full 3x3x3 voxels
    if Flag.KeepOnly3x3
        [MatVox,nIdent,Idx] = mlBV_UniqueVOIIndices(VOIfile,VOIname,VoxRes);
        % Following line changed 2009.06.17: for ACPC space (presumably
        % because of the transformation / interpolation), even VOI files
        % created with interpolation turned off still do not contain a
        % majority of full 3x3x3 voxels (i.e., voxels that contain 27 1x1x1
        % indices). 
        Keepers = Idx(nIdent>=round(.66*VoxRes^3));
        %Keepers = Idx(nIdent>=18); 
    else
        Keepers = Idx;
    end

    % initialize Y and X for regression
    Y = [];
    X = [];
    
    % For loop will concatenate multiple runs
    for iR = 1:nRuns
        if Flag.CutOutliers; 
            % See mlBV_VTCOutliers.m for details of these variables...
            load(OutlierDatFile{iR});
            ToCut = ToCut(ToCut<=length(PctBad));
        end
        
        % First: create Y variable from Voxel timecourses
        % NOTE: This calls BVQXtools VTCfile method "voitimecourse" (e.g.,
        % VTC = BVQXfile('SomeFile.vtc');
        % VTC.voitimecourse(
        [Vox] = mlBV_VOIVoxels(VTCs{iR},VOIfile,VOIname,Flag.ReduceOrNo);
        if Flag.ROIAvg
            TempY = mean(Vox,2);
        else
            TempY = Vox;
        end
        
        if Flag.KeepOnly3x3; TempY = TempY(:,Keepers); end
        if Flag.CutOutliers; TempY(ToCut,:) = []; end                  % Clipping Y
        
        Y = [Y;TempY];
        
        
        SDM = BVQXfile(SDMs{iR});
        
        % Regardless of SDM or RTC, there will be a .RTCmatrix field - and
        % THAT is the one you want to use, because it does NOT contain a
        % constant (we're adding our own constants for separate runs later)
        TempX = SDM.RTCMatrix;
        
        %TempX = mlNormalize(TempX,'WholeMatrix');                    % Set range of X to [0,1];
        
        if Flag.CutOutliers; TempX(ToCut,:) = []; end                % Clipping X
        if Flag.MoreRegressors; 
            % Allow for .rtc files, .dat files, or .mat files
            switch WhichTypeRegressor
                case 'rtc'
                        RR = BVQXfile(ExtraRegressors{iR});
                        AddReg = RR.RTCMatrix;
                        % Get rid of initial offset for runs 2+ corrected
                        % based on run 1:
                        AddReg = AddReg-repmat(AddReg(1,:),size(AddReg,1),1); 
                case 'dat'
                    warning('Not sure if this works yet. Pleez to debug.');
                    for iAddReg = 1:length(ExtraRegressors)
                        AddReg = importdata(ExtraRegressors{iR});   % Getting MC Data
                    end
                    % Cleaning up size - these .dat files will not reflect
                    % any time points cut from the beginning of a run at
                    % the .fmr creation stage. 
                    %!% This is worth debugging further! %!%
                    AddReg = AddReg(end-size(TempX,1)+1:end,:);
                case 'mat'
                    error('Not yet implemented (No .mat file types for extra regressors yet)');
            end
            
            if Flag.Factors
                % This creates three factors from the 6 motion correction
                % parameters (much like principal components). It should
                % yield regressors that capture the variance in the motion 
                % parameters, while saving 3 degrees of freedom. Also, it
                % avoids having redundant predictors (usually there is a
                % lot of mutual information in the 6 different motion
                % correction parameters). A cute trick, inspired by a stats 
                % class in the spring of 2008.
                % On by default.  ML 06/09/2009
                warning('off','all');
                nFactors = 3;
                [Lambda, Psi, T, FAStats, Factors] = factoran(abs(AddReg), nFactors,'Rotate','promax');
                warning('on','all');
                Factors = mlNormalize(Factors,'WholeMatrix');      % Set range to [0,1]
                TempX = [TempX, Factors];                          % Adding Regressors
            else
                TempX = [TempX, AddReg];  % Adding Regressors
            end
        end
        
        % Add a constant per run at the end
        AddMeanIV = zeros(size(TempX,1),nRuns);
        AddMeanIV(:,iR) = ones(size(TempX,1),1);
        TempX = [TempX,AddMeanIV];
        
        % Concatenate with previous runs
        X = [X;TempX];
        
        % Reset for next run
        clear TempX TempY
    end
    

    iXX = pinv(X'*X); % Pseudo-inverse of X'X (Design matrix)
    
    % Pre-allocating regression variables
    nVoxels = size(Y,2);
    pBetas = size(X,2);
    
    MSe = zeros(1,nVoxels);
    Rsquared = zeros(1,nVoxels);
    Tvals = zeros(pBetas,nVoxels);
    Betas = zeros(pBetas,nVoxels);
    
    % Regression
    for iY = 1:nVoxels;
        % Regstats adds a constant predictor by default - the
        % eye(size(x,2)) line gets rid of that constant (we've already
        % added spearate constants here for each run). The argument from
        % this position in "regstats" is actually fed along with X to the
        % function x2fx, so putting an idenity matrix there simply keeps X
        % as it is. see help x2fx for details. The last cell array argument
        % to "regstats" specifies what fields to output in the rStat struct
        rStat = regstats(Y(:,iY),X,eye(size(X,2)),{'tstat','mse','rsquare'});
        Tvals(:,iY) = rStat.tstat.t;
        Betas(:,iY) = rStat.tstat.beta;        
        MSe(iY) = rStat.mse;
        Rsquared(iY) = rStat.rsquare;
        clear rStat
        
        % Display regression progress.
        if nVoxels > 300 && Flag.DisplayProgress
            if iY == 100;
                h = waitbar(iY/size(Y,2),'% voxel regressions completed...');
            elseif any(iY == 200:100:size(Y,2));
                waitbar(iY/size(Y,2),h,'% voxel regressions completed...')
            end
        end
    end
    
    if nVoxels > 300 && Flag.DisplayProgress
        close(h);
    end

    save(sName,'Tvals','Betas','iXX','MSe','Rsquared');
        
    %{
    
    %%%%%
    
    NOTE: The below was intended to put matlab regression output into a 
    format similar to Brain Voyager's ROI GLM output. ML no longer uses 
    this format. This is preserved in case anyone ever wants to go back / 
    pick apart the output of "regstats" in the same way the below picks
    apart the output of "regress". 
    
    %%%%%
    
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
    if Flag.MoreRegressors;
        MCBetas = Betas(nPredsTot+1:end-nRuns);
    end
    DatMatPct = DatMat/DC*100;
    
    ErrMat = std(resids)/sqrt(nPredsTot+nConds)*ones(size(DatMat));
    ErrMatPct = ErrMat/DC*100;

    %%% Here we go w/ display:

    if Flag.MLConventions
        if Flag.PrintToFile
            fid = fopen(OutPutFile);
        else
            fid = 1;
        end
        if fid<=1
            if Flag.PrintToFile; fid = fopen(OutPutFile,'w'); end
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
            if Flag.PrintToFile; fclose(fid); end
        else
            if Flag.PrintToFile
                
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
        
        
        if Flag.PrintToFile
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
        if Flag.MoreRegressors
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
    %}
catch
    ErrorVarName = 'DebugVars_mlBV_Regress.mat';
    mlErrorCleanup;
    rethrow(lasterror);
end
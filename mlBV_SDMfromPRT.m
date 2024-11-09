 function varargout = mlBV_SDMfromPRT(NewFileName,PRT,Type,nPreds,TRlength)

% Usage: [SDMout=] mlBV_SDMfromPRT(NewFileName,PRT [,Type] [,nPreds] [,TRlength])
% 
% NewFileName = output of function (should be full file name - e.g. 
%       'SubXX_RunYY_20preds.sdm')
% 
% PRT   = the PRT file from which you want the SDM created
% 
% Type  =  the type of SDM you want ('Conv' or 'Deconv'). 'Conv' will
%       convolve the response with a two-gamma HRF; 'Deconv' will leave it 
%       alone. 
% 
% nPreds = number of predictors per condtion. defaults to 1.


% Inputs: 
if ~exist('Type','var')
    Type = 'Conv';
end
if ~exist('nPreds','var')
    nPreds = 1;
end
if ~exist('TRlength','var')
    TRlength = 1;
end

% Business:

% Other options (for debugging)
Flag.Save = true;       % Toggles saving of SDM. Generally on. Off for debugging.
Flag.Fixation = false;  % Toggles inclusion of fixation condition in SDM on (1) and off (0). 
                        % The only reason I can think of you'd want it on is
                        % for KH's data check, in which he compares fixation to
                        % the other conditions to check the goodness of the
                        % data.

Count.PredNm = 1;   % Separate index for predictors - see below.
                    
PP = BVQXfile(PRT);    % Creating struct array of PRT, using BVQXtools function "BVQXfile"
BVsdm = BVQXfile('sdm');  % Creating blank struct array of SDM, again with "BVQXfile"

% Pre-allocating parts of SDM struct:
BVsdm.NrOfPredictors = (PP.NrOfConditions-1)*nPreds + 1; % add one for constant
BVsdm.PredictorNames = cell(1,BVsdm.NrOfPredictors);

% The following line assume fixation will be either the first or last
% listed condition, and that it will occur last in your design (i.e., that
% there will be several fixation trials at the end)
FixFirstOrLast = [PP.Cond(1).OnOffsets(end),PP.Cond(end).OnOffsets(end)];
FixFirst = FixFirstOrLast(1)>FixFirstOrLast(2); % Will be 1 (true) if fixation is the first condition
BVsdm.NrOfDataPoints = max(FixFirstOrLast);

% Just in case fixation ISN'T your last condition, these lines might help:
% TimeOff = zeros(PP.NrOfConditions,1);
% for ii = 1:PP.NrOfConditions
%     TimeOff(ii) = PP.Cond(ii).OnOffsets(end);
% end
% BVsdm.NrOfDataPoints = max(TimeOff); % This will find the max time point of the experiment - the time the last condition switches off.
      
BVsdm.SDMMatrix = zeros(BVsdm.NrOfDataPoints,BVsdm.NrOfPredictors);

% ??? !!!
% Temp code to see if time is measured in seconds or volumes (i.e., TRs).
% Something below may need to be changed if we move away from TR = 1000 ms
% ??? !!!
disp(['Time measured in ' PP.ResolutionOfTime])

if FixFirst
    iii = 2:PP.NrOfConditions;
else
    iii = 1:PP.NrOfConditions-~Flag.Fixation; % Either gets rid of fixation condition in SDM or doesn't, depending on Flag.Fixation (See above)
end

for iCd = iii; 
    for iPred = 1:nPreds;
        if nPreds > 1
            BVsdm.PredictorNames{Count.PredNm} = [PP.Cond(iCd).ConditionName{1} '_D' num2str(iPred-1) ];
        else
            BVsdm.PredictorNames{Count.PredNm} = [PP.Cond(iCd).ConditionName{1}];
        end

        On = PP.Cond(iCd).OnOffsets(:,1);  % First column of this field in the PRT struct is ONSET of each condition
        BVsdm.SDMMatrix(On+iPred-1,Count.PredNm) = 1;  % Set all onsets of condition to 1 for unconvolved predictor / EV
        if strcmp(Type,'Conv')
            HH = hrf('twogamma',TRlength);
            CC = conv(BVsdm.SDMMatrix(:,Count.PredNm),HH);             % Convolution with HRF
            BVsdm.SDMMatrix(:,Count.PredNm) = CC(1:end-length(HH)+1);  % Clipping tail (extended by convolution)
        end
        Count.PredNm = Count.PredNm+1;
    end
end

% Add constant as final predictor:
BVsdm.SDMMatrix(:,Count.PredNm) = ones(size(BVsdm.SDMMatrix,1),1);
BVsdm.PredictorNames{Count.PredNm} = 'Constant';
BVsdm.IncludesConstant = 1;
BVsdm.FirstConfoundPredictor = Count.PredNm;


BVsdm.SDMMatrix = BVsdm.SDMMatrix(1:BVsdm.NrOfDataPoints,:); % Deconvolution designs / anything without adequate
                                                    % fixation at the end will add time points
                                                    % to the end - this clips those (and loses you 
                                                    % some of your later
                                                    % predictors - but so it goes)
% Add Colors:
BVsdm.PredictorColors = mlStructExtract(PP.Cond,'Color');

if nargout
    varargout{1} = BVsdm;
end

if Flag.Save
    BVsdm.SaveAs(NewFileName)
end

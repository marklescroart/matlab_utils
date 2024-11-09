 function varargout = mlBV_RTCfromPRT(NewFileName,PRT,Type,nPreds,TRlength)

% Usage: [RTCout=] mlBV_RTCfromPRT(NewFileName,PRT [,Type] [,nPreds] [,TRlength])
% 
% NewFileName = output of function (should be full file name - e.g. 
%       'SubXX_RunYY_20preds.rtc')
% 
% PRT   = the PRT file from which you want the RTC created
% 
% Type  =  the type of RTC you want ('Conv' or 'Deconv'). 'Conv' will
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
Flag.Save = 1;      % Toggles saving of RTC. Generally on. Off for debugging.
Flag.Fixation = 0;  % Toggles inclusion of fixation condition in RTC on (1) and off (0). 
                    % The only reason I can think of you'd want it on is
                    % for KH's data check, in which he compares fixation to
                    % the other conditions to check the goodness of the
                    % data.

Count.PredNm = 1;   % Separate index for predictors - see below.
                    
PP = BVQXfile(PRT);    % Creating struct array of PRT, using BVQXtools function "BVQXfile"
RR = BVQXfile('rtc');  % Creating blank struct array of RTC, again with "BVQXfile"

% Pre-allocating parts of RTC struct:
RR.NrOfPredictors = (PP.NrOfConditions-1)*nPreds;
RR.PredictorNames = cell(1,RR.NrOfPredictors);

% The following line assume fixation will be either the first or last
% listed condition, and that it will occur last in your design (i.e., that
% there will be several fixation trials at the end)
FixFirstOrLast = [PP.Cond(1).OnOffsets(end),PP.Cond(end).OnOffsets(end)];
FixFirst = FixFirstOrLast(1)>FixFirstOrLast(2); % Will be 1 (true) if fixation is the first condition
RR.NrOfDataPoints = max(FixFirstOrLast);

% Just in case fixation ISN'T your last condition, these lines might help:
% TimeOff = zeros(PP.NrOfConditions,1);
% for ii = 1:PP.NrOfConditions
%     TimeOff(ii) = PP.Cond(ii).OnOffsets(end);
% end
% RR.NrOfDataPoints = max(TimeOff); % This will find the max time point of the experiment - the time the last condition switches off.
      
RR.RTCMatrix = zeros(RR.NrOfDataPoints,RR.NrOfPredictors);

% ??? !!!
% Temp code to see if time is measured in seconds or volumes (i.e., TRs).
% Something below may need to be changed if we move away from TR = 1000 ms
% ??? !!!
disp(['Time measured in ' PP.ResolutionOfTime])

if FixFirst
    iii = 2:PP.NrOfConditions;
else
    iii = 1:PP.NrOfConditions-~Flag.Fixation; % Either gets rid of fixation condition in RTC or doesn't, depending on Flag.Fixation (See above)
end

for iCd = iii; 
    for iPred = 1:nPreds;
        if nPreds > 1
            RR.PredictorNames{Count.PredNm} = [PP.Cond(iCd).ConditionName{1} '_D' num2str(iPred-1) ];
        else
            RR.PredictorNames{Count.PredNm} = [PP.Cond(iCd).ConditionName{1}];
        end

        On = PP.Cond(iCd).OnOffsets(:,1);  % First column of this field in the PRT struct is ONSET of each condition
        RR.RTCMatrix(On+iPred-1,Count.PredNm) = 1;  % Set all onsets of condition to 1 for unconvolved predictor / EV
        if strcmp(Type,'Conv')
            HH = hrf('twogamma',TRlength);
            CC = conv(RR.RTCMatrix(:,Count.PredNm),HH);             % Convolution with HRF
            RR.RTCMatrix(:,Count.PredNm) = CC(1:end-length(HH)+1);  % Clipping tail (extended by convolution)
        end
        Count.PredNm = Count.PredNm+1;
    end
end

RR.RTCMatrix = RR.RTCMatrix(1:RR.NrOfDataPoints,:); % Deconvolution designs / anything without adequate
                                                    % fixation at the end will add time points
                                                    % to the end - this clips those (and loses you 
                                                    % some of your later
                                                    % predictors - but so it goes)
if nargout
    varargout{1} = RR;
end

if Flag.Save
    RR.SaveAs(NewFileName)
end


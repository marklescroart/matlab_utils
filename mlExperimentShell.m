function [varargout] = mlExperimentShell(SubID,Inpt1)

% Usage: [[ED] [,Clock] [,ScrVars] = mlExperimentShell(Inpt1, ...) 
% 
% Description:  
% 
% Inputs:       
% 
% Outputs:      
% 
% Created by 

% Note: ??? = likely / possible edit points

% Notes on ML Conventions: 
% ED = Experiment Data. This is a struct array for saving all relevant info
%      on the subject / behavior / stim presentation / etc.
% Ck = struct array for Clock data. Stim timing, debugging, etc.

% Inputs: 
if ~exist('SubID','var')
    SubID = input('Please input subject initials:   ','s');
end
if ~exist('Inpt1','var')
    Inpt1 = 0;
end

% First timing variables:
T.AbsStart = GetSecs;
ED.TimeOfScan = mlTitleTime;
ED.SubID = SubID; clear SubID;

% And re-randomizing "rand":
rand('twister',sum(100*clock));

% Modifiable Defaults
ED.ExpName = 'ExpShell';
ED.ImgType = 'png';
ED.ImgDir = [pwd filesep];
ED.tLength = 2; % in seconds
ED.ImTime = .300; % in seconds
ED.OpeningLag = 8; % in seconds

% Pre-allocating struct array:
ED.TA(1:ED.nTrials) = struct('RT',[NaN],...
    'RawResp',[NaN],...
    'CorrResp',[0],...
    'RespRec',[0],...
    'TrialStart',[NaN]); %{struct('TA',Trial)};
% Clock (timing) data:
Ck.TrStart = zeros(ED.nTrials,1);
Ck.ImTime = zeros(ED.nTrials,1);

% Getting images:
fDir = dir([ED.ImgDir filesep '*.' ED.ImgType]);
fNames = mlStructExtract(fDir,'name');

SaveFileName = ['Sub' ED.SubID '_' ED.ExpName '_' ED.TimeOfScan '.mat'];
SaveFileRoot = [pwd filesep];

try
    % These must be done before opening screen if they are to be done:
    %InitializeMatlabOpenGL; % for direct OpenGL rendering
    %InitializePsychSound;   % for sound
    [win,ScrVars] = mlScreenSetup;
    % Enable Alpha-blending
    Screen(win,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    HideCursor;
    Priority(MaxPriority(win));
    
    % Matching timing to flip interval:
    ED.ImTimeifi = round(ED.ImTime/ScrVars.ifi)*ScrVars.ifi; % Actual trial length (as an even multiple of refresh interval)
    
    % Loading Images into Texture memory:
    mlCenterText('Loading Images...',win);
    Screen('Flip',win);
    ImSize = zeros(length(fNames),2);
    for ii = 1:length(fNames)
        TempImg = imread([ED.ImgDir filesep fNames{ii}]);
        if size(size((TempImg)))>2; TempImg = rgb2gray(TempImg); end
        ImSize(ii,:) = size(TempImg);
        ImgTex(ii) = Screen('MakeTexture',win,TempImg);
    end
    
    % Any further set-up should go here: 
    
    % Setting response keys:
    [Key1, Key2] = mlSetResponseKeys(win, 'Response Key 1', 'Response Key 2');

    % Scan Start:
    mlCenterText('Waiting for sync with scanner.',win)
    Screen('Flip',win);
    T.ScanStart = mlTRSync(1,'5'); 
    T.FF11 = Screen('Flip',win);
    Ck.FirstFlipLag = T.FF11-T.ScanStart;
    T.Go = round((T.FF11+ED.OpeningLag)/ScrVars.ifi)*ScrVars.ifi; % in terms of refresh interval
    
    % Presentation loop:
    for iTrial = 1:length(ImgTex);
        Priority(MaxPriority(win));
        
        % ???
        % Any manipulation of image goes here - you may need to move
        % reading in of image up here, or set different ImgTex variables)
        % ???
        
        Screen('DrawTexture',win,ImgTex(iTrial));
        
        T.F1 = Screen('Flip', win, T.Go+ScrVars.ifi); % Wait one extra flip to put up image
        
        % In-between response search:
        RespDL = T.F1+ED.ImTimeifi-ScrVars.ifi; % Response Deadline
        [ED.TA(iTrial).RawResp, ED.TA(iTrial).RT, ED.TA(iTrial).RespRec] = mlGetResponse(RespDL, T.F1, Key1, Key2);
        
        T.F2 = Screen('Flip', win, T.F1+ED.ImTimeifi);
        
        Ck.ImTime(iTrial) = T.F2-T.F1;
        
        % Response Collection:
        RespDL = T.FF11 + round((ED.OpeningLag+tLength*iTrial)/ScrVars.ifi)*ScrVars.ifi; % Response Deadline
        if ~ED.TA(iTrial).RespRec
            [ED.TA(iTrial).RawResp, ED.TA(iTrial).RT, ED.TA(iTrial).RespRec] = mlGetResponse(RespDL, T.F1, Key1, Key2);
        end
        T.Go = RespDL;

    end
    
    Screen('CloseAll');

catch
    mlErrorCleanup;
    rethrow(lasterror)
end

save([SaveFileRoot SaveFileName], 'ED','Ck','ScrVars');

if nargout>0; varargout{1} = ED; end
if nargout>1; varargout{2} = Ck; end
if nargout>2; varargout{3} = ScrVars; end
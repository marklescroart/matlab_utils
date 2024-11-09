function [Response, ReactionTime, RespRec] = mlGetResponse(RespDL, RTStartTime, varargin)

% Usage: [Response, ReactionTime, RespRecorded] = mlGetResponse(ResponseDeadline, RTStartTime, Key1 [,Key2][...])
% 
% Looks only for a response from the pre-set response keys "Key1", "Key2",
%       etc. Returns the key number of the key pressed (which will be
%       equivalent to Key1 OR Key2 etc.)
% 
% Inputs: Keys are key numbers (in the form set by mlSetResponseKeys)
%         ResponseDeadline = time in (GetSecs) format
% 
% Outputs: Response = keycode for response pressed (ALWAYS one of the keys
%                     you set via Key1, Key2, etc.); 0 if no response
%      ReactionTime = time of response keypress MINUS RTStartTime
%                     NOTE: if you want absolute response times, set
%                     timestamp from the beginning of your experiment (or
%                     0) as RTStartTime. 
%           RespRec = Whether or not a response was recorded. Useful for
%                     debugging.
% 
% Note: Assumes the response is to be take from the highest-numbered
% keyboard (default of KBCheck). Might need modification on some systems.
% 
% Modified 4.13.07 ML

Start = GetSecs;
RespRec = 0;
Response = 0;
ReactionTime = 0;
QuitKey = KbName('escape');

%%% Modifiable: 
Tolerance = .005; % 5 ms before Response deadline, give control back to calling program.
RTPrecision = .0001;

if RespDL-GetSecs <= Tolerance; 
    % save DebugVarsGetResp
    % error([mfilename ':BadDeadline'],'The response deadline you entered in mlGetResponse passed before the function was called!');
    warning([mfilename ':BadDeadline'],'The response deadline you entered in mlGetResponse passed before the function was called!');
    Response = 0;
    ReactionTime = NaN;
    RespRec = 0;
    return
    % uncomment the error message for stronger control...
end

while RespDL-GetSecs > Tolerance
    [KeyDown RT KeyCode] = KbCheck; %(KB);
    if KeyDown==1
        for iKeys = 1:length(varargin);
            if KeyCode(varargin{iKeys})
                Response = varargin{iKeys};
                ReactionTime = RT - RTStartTime;
                RespRec = 1;
                break
            elseif KeyCode(QuitKey)
                error([mfilename ':ManQuit'],[mfilename ' has been manually quit.'])
            end
        end
    else
        Response = 0;
        ReactionTime = 0; %RT-Start;
    end
    if RespRec; break; end;
    WaitSecs(RTPrecision);
end


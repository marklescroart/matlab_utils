function [Response, ReactionTime, RespRec, TR] = mlGetResponseTR(RespDL, RTStartTime, varargin)

% Usage: [Response, ReactionTime, RespRecorded] = mlGetResponse(ResponseDeadline, RTStartTime, Key1 [,Key2][...])
% 
% Looks only for a response from the pre-set response keys "Key1", "Key2",
%       etc. Returns the key number of the key pressed (which will be
%       equivalent to Key1 OR Key2 etc.)
% 
% Inputs: Keys are key numbers (in the form set by mlSetResponseKeys)
%         ResponseDeadline = time in (GetSecs) format
%         TR = time of TR(s) during function call - could be a problem if
%         multiple...
% 
% Note: Assumes the response is to be take from the highest-numbered
% keyboard (default of KBCheck). Might need modification on some systems.
% 
% Modified 4.13.07 ML

Start = GetSecs;
RespRec = 0;
TR = 0;
QuitKey = KbName('escape');
TRkey = KbName('5%'); %For USC MRI Scanner (only?) 

%%% Modifiable: 
Tolerance = .010; % 10 ms before Response deadline, give control back to calling program.
RTPrecision = .001;

if RespDL-GetSecs <= Tolerance; 
    save DebugVarsGetResp
    error('The response deadline you entered in mlGetResponse passed before the function was called.');
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
            elseif KeyCode(TRkey)
                TR = RT;
            end
        end
    else
        Response = 0;
        ReactionTime = RT-Start;
    end
    if RespRec; break; end;
    WaitSecs(RTPrecision);
end

function [varargout] = ResponseKeys(DeviceNumber, win, varargin)


% Usage: [KeyVarName1, [KeyVarName2,] ...] = ResponseKeys(DeviceNumber, KeyTitle1, [KeyTitle2,] ... )
%
% Sets keys for subject response. Displays "Please press the (KeyTitle1) 
% Key" and then stores keyCode of that key as KeyVarName1 (output 1). 
% (& etc. for up to 4 keys)
% 
% Inputs: DeviceNumber - which device will be collecting the responses
%         win - Screen pointer
%         [names for response keys ('Up', 'Yes', whatever) - MUST BE STRINGS]
% Outputs: [Variable names for response keys (UpKey, YesKey, etc)]
% 
% Starts with setting the text size (to 20), ends with a Screen('Flip') 
% that puts "One moment more" onto the screen. Calls CenterFixation (very
% useful function from XL)
% 
% Created by ML 7.13.06
% Modified by ML on 7.16.06

winPtrs = Screen('Windows');

if isempty(winPtrs)
    OnPTBScreen = 0;
else
    OnPTBScreen = 1;
end

%%% Checking inputs / outputs: 
if nargin < 1 | isstr(DeviceNumber);
    error([mfilename ':DeviceNumberAbsent'], [mfilename ' says: Listen, meathead, I need to know which device I have to listen to.'...
        '\n                   Please specify a DeviceNumber as the first input.']);
    return
elseif nargin < 2 | isstr(win);
    error([mfilename ':WindowPointerAbsent'], [mfilename ' says: Specify a valid window pointer, please.']);
elseif nargin > 6
    error([mfilename ':TooManyInputs'], [mfilename 'says: What the bloody hell do you need more than 4 response keys for?']);
end

if nargin ~= nargout + 2
    error([mfilename ':UnbalancedInputs'],[mfilename ' says: I need you to focus, please. Equal numbers of inputs and outputs.']);
end

for xx = 1:nargin-2
    if ~isstr(varargin{xx})
        error([mfilename ':NamesNotStrings'],[mfilename ' says: What am I supposed to call the keys, ace?']);
    end
end


%%% Display of cue code:
if OnPTBScreen
    %oldTextSize = Screen('TextSize', win, 20);
    centerFixation(win,['Please press the "' varargin{1} '" key'],20);
    %Screen('DrawText', win, ['Please press the "' varargin{1} '" key'], 360, 384, [255 255 255]);
    Screen('Flip', win);
else
    disp(['Please press the "' varargin{1} '" key']);
end
WaitSecs(.3);
for iKey = 1:nargin-2
    CheckUp = 0;
    while CheckUp == 0
        [KeyDown Secs KeyCode] = KbCheck(DeviceNumber);
        if KeyDown == 1
            varargout{iKey} = find(KeyCode==1);
            CheckUp = 1;
        end
        WaitSecs(.001);
    end

    if iKey < nargin-2
        if OnPTBScreen
            centerFixation(win,['Thank you. Now please press the "' varargin{iKey+1} '" key.']);
            %Screen('DrawText', win, ['Thank you. Now please press the "' varargin{iKey+1} '" key.'], 270, 384, [255 255 255]);
            Screen('Flip', win);
        else
            disp(['Thank you. Now please press the "' varargin{iKey+1} '" key.']);
        end
        WaitSecs(.6);
    else
        if OnPTBScreen
            centerFixation(win,'Thank you very much. One moment more.');
            %Screen('DrawText', win, 'Thank you very much. One moment more.', 320, 384, [255 255 255]);
            OneMomentMore = Screen('Flip', win);
        else
            disp('Thank you very much. One moment more.');
        end
    end
end

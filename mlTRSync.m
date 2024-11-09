function Time = mlTRSync(TRWait, WhichKey, WhichMethod)

% Usage: Time = mlTRSync(TRWait, WhichKey, WhichMethod)
% 
% Waits for a TR cue from an MRI scanner. For USC, the cue is a 5, which
% can be specified with Which Key. 
% 
% Inputs: TRWait: Whether to wait or not. Makes it easy to turn this
%                 function off if you're not running the code in the
%                 scanner.
%         WhichKey: Which key to look for. If left out or empty, any
%                 (character) keypress will do
%         WhichMethod: Possibly temporary, but as of now can use EITHER
%                 GetChar (which has a nasty history of bugs) or KbWait 
%                 (which has had problems catching too-fast keypresses from
%                 scanners in the past). Input 'GetChar' (default) or
%                 'KbCheck', or 'CharAvail';
% 
% Created by ML on 10.17.07

% Input Defaults:
if ~exist('WhichMethod','var')
    WhichMethod = 'GetChar';
end
if ~exist('WhichKey','var')
    WhichKey = [];
end

if TRWait
    switch WhichMethod
        case 'GetChar'
            %%% Use of GetChar to Sync:
            FlushEvents('keyDown')
            [CC,TT] = GetChar;
            if ~isempty(WhichKey)
                while ~strcmp(CC,WhichKey)
                    [CC,TT] = GetChar;
                end
            end
            Time = TT.secs;
        case 'KbCheck'
            [KeyDown,Time,KeyCode] = KbCheck;
            while ~KeyDown
                [KeyDown,Time,KeyCode] = KbCheck;
                if KeyDown
                    if ~isempty(WhichKey)
                        if strcmp(WhichKey,'5');WhichKey='5%';end
                        if ~strcmp(KbName(KeyCode),WhichKey)
                            KeyDown = 0;
                        end
                    end
                end
                WaitSecs(.0001);
            end
            FlushEvents('KeyDown');

        case 'CharAvail' % Probably don't use this one... just for decoration.
            if TRWait
                gotChar=0;
                FlushEvents('keyDown')
                while ~gotChar
                    gotChar=CharAvail;
                end
                Time = GetSecs;
            else
                Time = GetSecs;
            end
    end % Switch
else
    Time = GetSecs;
end % if TRWait

% FlushEvents('KeyDown'); % Doesn't seem to serve any purpose... I'd really
% love it if it would clear the command line, though.

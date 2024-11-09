function String = GetOnscreenText(win,sX,sY,TxtCol)

% Usage: String = GetOnscreenText(win [,sX] [,sY] [,TxtCol]);
%
% Only absolutely necessary input is win (for the onscreen window)
% Designed to circumvent use of the extremely buggy "GetChar"
% The double flip is designed to draw the characters onto whatever screen
% was present before this function was called. There's probably a better
% way to do that.
% 
% Rough draft form on 1.08.07 by ML


%%% Inputs:
if ~exist('win','var')
    error([mfilename ':WindowPtr'],'Window Pointer is missing. Please include it in function inputs.');
end
if ~exist('sX','var')
    sX = 40;
end
if ~exist('sY','var')
    sY = 80;
end
if ~exist('TxtCol','var')
    TxtCol = [255 255 255];
end

%%% Startup:
charString = '';
QuitFlag = 0;
charCount = 1;

%%% Saving the current screen to draw on later: 
% GLr = mlglOFF;

OldScreen = Screen('GetImage', win);
OldScrTex = Screen('MakeTexture',win,OldScreen);

while ~QuitFlag
    %while KbCheck; end;  %For some reason this isn't working so well for
    %me...
    [KeyDown,Secs,KeyCode] = KbCheck;
    while ~KeyDown
        [KeyDown,Secs,KeyCode] = KbCheck;
        if KeyDown
            NextChar = KbName(KeyCode);
            %if (length(NextChar) > 1) && (~strcmp(upper(NextChar),'TAB')) && (~strcmp(upper(NextChar),'DELETE'));
            %    disp('I detected a non-letter keypress.')
            %    continue;
            %end
            if strcmp(upper(NextChar),'TAB')
                QuitFlag = 1;
            elseif strcmp(upper(NextChar),'DELETE') && (charCount > 1)
                charCount = charCount-1;
                charString = [charString(1:charCount-1)];
                %Screen('Flip',win,[],1);
                if length(charString)>0;
                    Screen('DrawTexture',win,OldScrTex);
                    Screen('DrawText',win,charString,sX,sY,TxtCol);
                    %[nx,ny,TextRect] = DrawFormattedText(win,[charString],sX,sY,TxtCol);
                end
                Screen('Flip',win);
            elseif strcmpi(NextChar,'space')
                Screen('DrawTexture',win,OldScrTex);
                charString = [charString ' '];
                charCount = charCount+1;
                Screen('DrawText',win,charString,sX,sY,TxtCol);
                %[nx,ny,TextRect] = DrawFormattedText(win,[charString],sX,sY,TxtCol);
                Screen('Flip',win);
            else
                Screen('DrawTexture',win,OldScrTex);
                charString = [charString(1:charCount-1) NextChar(1)];
                charCount = charCount + 1;
                %Screen('Flip',win,[],1);
                Screen('DrawText',win,charString,sX,sY,TxtCol);
                %[nx,ny,TextRect] = DrawFormattedText(win,[charString],sX,sY,TxtCol);
                Screen('Flip',win);
            end %if (strcmp with NextChar)
        end %if KeyDown
        WaitSecs(.001)
    end %while ~KeyDown
    WaitSecs(.001)
end %while ~QuitFlag

String = charString;

%save DebugVarsGetOnscreenText
% mlglON(GLr);
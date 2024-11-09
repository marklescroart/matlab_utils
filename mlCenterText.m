function mlCenterText(Text, win, sz, color, LineLimit, CenterOn)

% Usage: mlCenterText(Text, Window, TextSize, TextColor, LineLimit, CenterOn)
% 
% Draws a fixation point or text in the center of the screen.
% 
% Inputs: Text - string variable with text to be centered.
%       Window - window pointer from Screen('OpenWindow')
%     TextSize - font size for text
%    TextColor - color of text - if empty or absent, defaults to white (on
%                dark screens) or black) on light screens)
%    LineLimit - number of character (including spaces) per line
%     CenterOn - [x,y] matrix for point on screen on which to center text
% 
% Created by XRL, 09/01/2005
% Modified by ML, 04/13/2009

if (nargin<1)
    windowPtrs=Screen('Windows');
    if isempty(windowPtrs) || (Screen('WindowKind',windowPtrs(1)) ~=1); % is not onscreen
        win =Screen('OpenWindow',1,0);
    else
        error('On screen window not found');
    end
end



rect =Screen('Rect',win);

% input defaults:
if ~ischar(Text)
    error('What the hell do you think you''re doing putting something besides text into mlCenterText.');
end
if ~exist('sz','var')||isempty(sz); sz=Screen('TextSize',win); end
if ~exist('color','var')||isempty(color); 
    ScrColor = Screen('GetImage', win,[0 0 1 1]);
    if mean(ScrColor) < 100
        color = 255; % White for dark screens
    else
        color = 0;   % Black for light screens
    end
end
if ~exist('LineLimit','var')||isempty(LineLimit); LineLimit = rect(3); end
if ~exist('CenterOn','var')||isempty(CenterOn); CenterOn = [rect(3)/2,rect(4)/2]; end

oldSize=Screen('TextSize',win,sz);
ChopText = mlTextChopper(Text,LineLimit);
TxSize = size(ChopText);
nLines = TxSize(1);
for ii = 1:nLines
    xx = round(CenterOn(1)-RectWidth(Screen('TextBounds',win,ChopText(1,:)))/2);
    yy = round(CenterOn(2)-sz*0.71+sz*(ii-1));
    Screen('DrawText',win,ChopText(ii,:),xx,yy, color);
end

Screen('TextSize',win,oldSize);

function [win,ScrVars] = mlScreenSetup(BG)

% Usage: [win,ScrVars] = mlScreenSetup(BG)
% 
% Function to set up all the usual screen values that Mark Lescroart uses:
% Inputs: 
%   BackGround - default [128 128 128]
%   
%       Text size = 18
%       Text font = Arial
%       Background = [128 128 128] (gray)
% 
% Created 10.10.06 by ML

% Inputs: 
if ~exist('BG','var')
    ScrVars.BG = [128 128 128];
else
    ScrVars.BG = BG;
end

% Assert OpenGL Version, quit out with error if computer isn't compatible:
AssertOpenGL;

WarnStr = '\n\n\nmlScreenSetup currently has anti-aliasing turned on. This may decrease performance! \nPlease check code timing before proceeding with experiments!\n\n\n';
warning([mfilename ':Anti-Alias Warning'],WarnStr)

%%% Actually opening the screen (highest-numbered screen present):
ScrVars.ScreenNumber = max(Screen('Screens'));
% Usage: [Window,Rect] = Screen('OpenWindow',windowPtrOrScreenNumber [,color] [,rect][,pixelSize][,numberOfBuffers][,stereomode][,multisample][,imagingmode]);
[win, ScrVars.winRect] = Screen('OpenWindow',ScrVars.ScreenNumber, ScrVars.BG,[],32,2,[],6);

%%% Getting inter-flip interval (ifi):
Priority(MaxPriority(win));
ScrVars.ifi = Screen('GetFlipInterval', win, 20);
Priority(0);

Screen('TextFont', win, 'Arial');
Screen('TextSize', win, 18);

%%% Establishing generally useful screen value variables in a struct array:
ScrVars.x_min = ScrVars.winRect(1);
ScrVars.x_max = ScrVars.winRect(3);
ScrVars.y_min = ScrVars.winRect(2);
ScrVars.y_max = ScrVars.winRect(4);

ScrVars.AspectRatio = ScrVars.x_max/ScrVars.y_max;
ScrVars.winWidth = ScrVars.x_max-ScrVars.x_min;
ScrVars.winHeight = ScrVars.y_max-ScrVars.y_min;
ScrVars.x_center = ScrVars.winWidth/2;
ScrVars.y_center = ScrVars.winHeight/2;

ScrVars.FixRect = [0 0 10 10];
ScrVars.FixRectBig = [0 0 12 12];
ScrVars.Fixation = CenterRectOnPoint (ScrVars.FixRect, ScrVars.x_center, ScrVars.y_center);
ScrVars.FixationBig = CenterRectOnPoint (ScrVars.FixRectBig, ScrVars.x_center, ScrVars.y_center);

ScrVars.PixPerDeg = 42.8; % per 1024x768 screen, for USC MRI ONLY; see ScreenGeometry for calculation
% Usage: mlEyeTrackerDots (This is a *SCRIPT*)
%
% Puts up the nine eye tracker calibration points on the screen.
%
% Relies on struct variable "ScrVars", created by MLScreenSetup, to be
% present, and the onscreen window to be labeled "win"
%
% Created by ML 7.5.06
% Modified by ML 11.10.07

ETAdjust = 304/1024*ScrVars.winWidth; % should be 304 on 1024x768 screen

ETPos = [-1 0 1 -1 0 1 -1 0 1;...
         -1 -1 -1 0 0 0 1 1 1]';
% ETPos = [-1 -1 -1 0 0 0 1 1 1;...
%        -1 0 1 -1 0 1 -1 0 1]';
ETPos = ETPos.*ETAdjust;
ETPos(:,1) = ETPos(:,1)+ScrVars.x_center;
ETPos(:,2) = ETPos(:,2)+ScrVars.y_center;

Screen('FillRect', win, [128]);
oldTextSize=Screen('TextSize', win, 14);

for iET = 1:9
    BigRect = CenterRectOnPoint(ScrVars.FixRectBig,ETPos(iET,1),ETPos(iET,2));
    SmRect  = CenterRectOnPoint(ScrVars.FixRect,ETPos(iET,1),ETPos(iET,2));
    Screen('FillOval',win,[255], BigRect)
    Screen('FillOval',win,[0], SmRect);
    Screen('DrawText',win,num2str(iET),ETPos(iET,1),ETPos(iET,2)+15);
end

Screen('TextSize',win,oldTextSize);

Screen('Flip', win);

function mlDrawFixation(win,ScrVars,WhichFix,FixColor,Rings)

% Usage: mlDrawFixation(win,ScrVars,WhichFix,FixColor)
% 
% Draws a fixation dot, cross, or whatever (see input options).
% 
% Inputs:      win - window handle
%          ScrVars - struct array of relevant screen variables (created in
%                    mlScreenSetup)
%         WhichFix - option for fixation. either: 
%               'dot' - 12 pixel dot
%            'bigdot' - 14 pixel dot
%                'oh' - 16 fontsize "o"
%        'crosshairs' - whole-screen rings at 2,4,8 deg, with
%                       vertical/horizontal/diagonal croshairs
%             'cross' - 16 fontsize "x"
%              'plus' - 16 fontsize "+" [default]
%            FixColor - color of fixation
%         
% 
% Created by ML 2009.08.04

% Inputs
if ~exist('WhichFix','var')
    WhichFix = 'plus';
end
if ~exist('FixColor','var')||isempty(FixColor)
    FixColor = [245   239     128];
end
if ~exist('Rings','var')
    Rings = [2 4 8];
end
% Draw Fixation
switch lower(WhichFix)
    case 'dot' % Takes ~3 ms - maybe ~9 the first time
        FixRect = CenterRectOnPoint([0 0 12 12],ScrVars.x_center,ScrVars.y_center);
        Screen('FillOval',win,FixColor,FixRect);
    case 'bigdot' % Takes ~3 ms - maybe 9 the first time
        FixRect = CenterRectOnPoint([0 0 14 14],ScrVars.x_center,ScrVars.y_center);
        Screen('FillOval',win,FixColor,FixRect);
    case 'crosshairs'
        nCircles = 3; 
        nDegrees = Rings;
        PPD = 42.8;
        CenterOn(1) = ScrVars.x_center;
        CenterOn(2) = ScrVars.y_center;
        for i =1:nCircles
            % Screen('FrameOval', windowPtr [,color] [,rect] [,penWidth] [,penHeight] [,penMode]);
            Rr = CenterRectOnPoint([0,0,2*PPD*nDegrees(i),2*PPD*nDegrees(i)],CenterOn(1),CenterOn(2));
            Screen('FrameOval',win, FixColor, Rr, 1, 1);
        end
        xy = [-700, 700,   0,   0,-500, 500, 500,-500; ...
                 0,   0,-500, 500,-500, 500,-500, 500];
        Screen('DrawLines',win,xy,3,FixColor,[ScrVars.x_center,ScrVars.y_center]);
    case 'plus'
        mlCenterText('+',win,30,FixColor);
        
        %Screen('DrawText',win,'+',ScrVars.x_center,ScrVars.y_center,FixColor);
end


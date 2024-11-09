% Usage: ML_EyeTrackerDots (This is a *SCRIPT*)
%
% Puts up the nine eye tracker calibration points on the screen.
%
% NOTE: OLD NAME MAINTAINED 'CAUSE I DON'T WANT TO RE-CODE OLD FUNCTIONS.
% 
% Relies on struct variable "ScrVars", created by MLScreenSetup, to be
% present, and the onscreen window to be labeled "win"
%
% Created by ML 7.5.06
% Modified by ML 11.16.06

ETAdjust = 304;

ET.LFar = ScrVars.x_center-ETAdjust;
ET.RFar = ScrVars.x_center+ETAdjust;
ET.TopFar = ScrVars.y_center-ETAdjust;
ET.BotFar = ScrVars.y_center+ETAdjust;
ET.One = CenterRectOnPoint(ScrVars.FixRect, ET.LFar, ET.TopFar);
ET.OneB = CenterRectOnPoint(ScrVars.FixRectBig, ET.LFar, ET.TopFar);
ET.Two = CenterRectOnPoint(ScrVars.FixRect, ScrVars.x_center, ET.TopFar);
ET.TwoB = CenterRectOnPoint(ScrVars.FixRectBig, ScrVars.x_center, ET.TopFar);
ET.Three = CenterRectOnPoint(ScrVars.FixRect, ET.RFar, ET.TopFar);
ET.ThreeB = CenterRectOnPoint(ScrVars.FixRectBig, ET.RFar, ET.TopFar);
ET.Four = CenterRectOnPoint(ScrVars.FixRect, ET.LFar, ScrVars.y_center);
ET.FourB = CenterRectOnPoint(ScrVars.FixRectBig, ET.LFar, ScrVars.y_center);
ET.Five = CenterRectOnPoint (ScrVars.FixRect, ScrVars.x_center, ScrVars.y_center);
ET.FiveB = CenterRectOnPoint (ScrVars.FixRectBig, ScrVars.x_center, ScrVars.y_center);
ET.Six = CenterRectOnPoint(ScrVars.FixRect, ET.RFar, ScrVars.y_center);
ET.SixB = CenterRectOnPoint(ScrVars.FixRectBig, ET.RFar, ScrVars.y_center);
ET.Seven = CenterRectOnPoint(ScrVars.FixRect, ET.LFar, ET.BotFar);
ET.SevenB = CenterRectOnPoint(ScrVars.FixRectBig, ET.LFar, ET.BotFar);
ET.Eight = CenterRectOnPoint(ScrVars.FixRect, ScrVars.x_center, ET.BotFar);
ET.EightB = CenterRectOnPoint(ScrVars.FixRectBig, ScrVars.x_center, ET.BotFar);
ET.Nine = CenterRectOnPoint(ScrVars.FixRect, ET.RFar, ET.BotFar);
ET.NineB = CenterRectOnPoint(ScrVars.FixRectBig, ET.RFar, ET.BotFar);

Screen('FillRect', win, [128]);
oldTextSize=Screen('TextSize', win, 14);
Screen('FillOval', win, [255], [ET.OneB]);
Screen('FillOval', win, [0], [ET.One]);
Screen('DrawText', win, '1', ET.LFar, ET.TopFar+15, 255);
Screen('FillOval', win, [255], [ET.TwoB]);
Screen('FillOval', win, [0], [ET.Two]);
Screen('DrawText', win, '2', ScrVars.x_center, ET.TopFar+15, 255);
Screen('FillOval', win, [255], [ET.ThreeB]);
Screen('FillOval', win, [0], [ET.Three]);
Screen('DrawText', win, '3', ET.RFar, ET.TopFar+15, 255);
Screen('FillOval', win, [255], [ET.FourB]);
Screen('FillOval', win, [0], [ET.Four]);
Screen('DrawText', win, '4', ET.LFar, ScrVars.y_center+15, 255);
Screen('FillOval', win, [255], [ET.FiveB]);
Screen('FillOval', win, [0], [ET.Five]);
Screen('DrawText', win, '5', ScrVars.x_center, ScrVars.y_center+15, 255);
Screen('FillOval', win, [255], [ET.SixB]);
Screen('FillOval', win, [0], [ET.Six]);
Screen('DrawText', win, '6', ET.RFar, ScrVars.y_center+15, 255);
Screen('FillOval', win, [255], [ET.SevenB]);
Screen('FillOval', win, [0], [ET.Seven]);
Screen('DrawText', win, '7', ET.LFar, ET.BotFar+15, 255);
Screen('FillOval', win, [255], [ET.EightB]);
Screen('FillOval', win, [0], [ET.Eight]);
Screen('DrawText', win, '8', ScrVars.x_center, ET.BotFar+15, 255);
Screen('FillOval', win, [255], [ET.NineB]);
Screen('FillOval', win, [0], [ET.Nine]);
Screen('DrawText', win, '9', ET.RFar, ET.BotFar+15, 255);

Screen('Flip', win);

% mlETDotFollow

if ~exist('ETPos','var')
    error('Please run mlEyeTrackerDots before mlETDotFollow.');
end

mlCenterText('Follow the dots!',win)
Screen('Flip',win);

Screen('DrawDots',  win,   ETPos(5,:), 12, [255], [0,0], 1); %ScrVars.x_center,ScrVars.y_center
%BigRect = CenterRectOnPoint(ScrVars.FixRectBig,ETPos(5,1),ETPos(5,2));
%Screen('FillOval',win,[255 255 0],BigRect);
Screen('Flip',win,T.FF11+2);

for iETf = 1:9;
    %BigRect = CenterRectOnPoint(ScrVars.FixRectBig,ETPos(iETf,1),ETPos(iETf,2));
    %Screen('FillOval',win,[255 255 0], BigRect);
    Screen('DrawDots',  win,   ETPos(iETf,:), 12, [255], [0,0], 1); %ScrVars.x_center,ScrVars.y_center
    ETf(iETf) = Screen('Flip',win,round((T.FF11+2+2*iETf)/ScrVars.ifi)*ScrVars.ifi-.002);
end

Screen('DrawDots',  win,   [ScrVars.x_center, ScrVars.y_center], 15, [255], [0,0], 1); %ScrVars.x_center,ScrVars.y_center
Ck.ETfin = Screen('Flip',win,round((T.FF11+22)/ScrVars.ifi)*ScrVars.ifi);
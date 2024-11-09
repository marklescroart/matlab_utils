function mlPTB_VisAngle(win,nCircles,nDegrees,CenterOn,PPD)

% Usage: mlPTB_VisAngle(win,nCircles,nDegrees,CenterOn,PPD)
% 
% Draws nCircles circles of nDegrees (visual angle) around fixation (or 
% whatever other point), based on PPD (Pixels Per Degree) of display. 
% Designed to help scale stimuli to appropriate size. 
% 
% Inputs: win = window pointer from Screen('OpenWindow')
%         PPD = Pixels Per Degree (e.g. 42.8)
% 
% Created by ML 2008.11.22


if ~exist('win','var');
    win=Screen('Windows');
    %if isempty(win) || (Screen('WindowKind',win(1)) ~=1); % is not onscreen
    %    win =Screen('OpenWindow',1,0);
    %else
    if isempty(win) || (Screen('WindowKind',win(1)) ~=1); % is not onscreen
        error('On screen window not found');
    end
    %end
end
ScrSize = get(0,'ScreenSize');
x = ScrSize(3)/2; y = ScrSize(4)/2;

Inputs       = {'nCircles','nDegrees','CenterOn','PPD'};
InptValues = { 20,        1,        [x,y],    42.8};
mlDefaultInputs;

for i =1:nCircles
    % Screen('FrameOval', windowPtr [,color] [,rect] [,penWidth] [,penHeight] [,penMode]);
    Rr = CenterRectOnPoint([0,0,2*PPD*nDegrees*i,2*PPD*nDegrees*i],CenterOn(1),CenterOn(2));
    Screen('FrameOval',win, 255, Rr, 1, 1);
    Screen('DrawText', win, num2str(i*nDegrees),Rr(3),y,255,[],1);
    Screen('DrawText', win, num2str(i*nDegrees),x,Rr(2),255,[],0);
end
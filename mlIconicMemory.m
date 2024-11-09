function mlIconicMemory


[win,ScrVars] = mlScreenSetup

CueDelay = .100;  % seconds
ImageTime = .500; % seconds


ImUpTime = round(ImageTime/ScrVars.ifi)*ScrVars.ifi;
CueDelay = round(CueDelay/ScrVars.ifi)*ScrVars.ifi;

PPD = 42.8;

ABC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

nAcross = 3;
nUpDown = 4;
[x1,y1] = meshgrid(linspace(-1.5,1.5,nAcross),linspace(-2,2,nUpDown));

nRows = size(x1,1);

x = round(x1(:) * PPD + ScrVars.x_center);
y = round(y1(:) * PPD + ScrVars.y_center); 

n = ceil(26*rand(size(x)));
n = n(:);
Screen('FillRect',win,255);
centerFixation(win,1);
Screen('Flip',win);
WaitSecs(.5)

for iNum = 1:length(x); 
    Screen('DrawText',win,ABC(n(iNum)),x(iNum),y(iNum),[],[],1);
end

Flip = Screen('Flip',win);

Flip = Screen('Flip',win,Flip+ImUpTime-.005);

Margin = 10;
Row = y(round(rand*length(y)));
TempR = abs([0, 0, 3*PPD+Margin, PPD]);
Rr = CenterRectOnPoint(TempR,ScrVars.x_center+PPD/4,Row);
Screen('FrameRect',win,[255 0 0],Rr);

Screen('Flip',win, Flip+CueDelay-.005);

KbWait;

% To check answer:
for iNum = 1:length(x); 
    Screen('DrawText',win,ABC(n(iNum)),x(iNum),y(iNum),[],[],1);
end
Screen('Flip',win);
WaitSecs(.5);
KbWait;


c;


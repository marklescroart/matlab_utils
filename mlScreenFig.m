function mlScreenFig(Sz,BG,labels,Degrees)

% Usage: mlScreenFig([Size] [,BackGround] [,labels],Degrees)
% 
% Sets figure axes to current screen's size (or to Sz = [1024 768], e.g.),
% w/ "Background" (graylevel) color, w/ axes labeled if "labels" is set to 1
% 
% Created on ?? by ML
% Modified on 10.24.07 by ML

if ~exist('labels','var')
    labels = true;
end
if ~exist('BG','var')
    BG = 128;
end
if ~exist('Sz','var');
    Sz = get(0,'ScreenSize');
    Sz = Sz(3:4);
end
if ~exist('Degrees','var')
    Degrees = false;
end

set(gca,'xtick',[],'ytick',[],'xlim',[0 Sz(1)],'ylim',[0 Sz(2)]);
whitebg([BG BG BG]/255); 
if labels
    xlabel(['(' num2str(Sz(1)) ')']); 
    ylabel(['(' num2str(Sz(2)) ')']);
else
    xlabel([]);
    ylabel([]);
end

if Degrees
    cPos = mlCirclePos(42.8*Degrees,50); % 42.8 is pixels to 1 visual degree in USC's eye tracking system.
    hold on; 
    plot(cPos(:,1),cPos(:,2),'y');
    hold off;
end
    
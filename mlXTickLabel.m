function mlXTickLabel(h,Labels,fontsz)

% Usage: mlXTickLabel(h,Labels,fontsz)
% 
% 

if ~exist('fontsz','var');
    fontsz = 16;
end

Xtk = get(h,'xtick');
set(h,'xticklabel',[]);

YL = ylim;

DownFactor = .07; % change w/ 1 vs 2 layer cell arrays?

ylevel = YL(1)-range(ylim) * DownFactor; 

while length(Labels)<length(Xtk)
    Labels = [Labels,Labels];
end

for iTxt = 1:length(Xtk);
    tH(iTxt) = text(Xtk(iTxt),ylevel,Labels{iTxt});
end

set(tH,'horizontalalignment','center','fontname','arial','fontsize',fontsz);
% attempt to make Xlabel behave properly:
set(h,'xtick',Xtk(end)+10,'xticklabel',{'you will never see me.'});
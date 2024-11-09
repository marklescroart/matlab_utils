function mlStackAxes(nAxes,AxSize)

h = my_Figure_A4('landscape');
Spot = 'M_2';
bor = .05; % distance from border
sz = .5; % size

FullFig = axes('position',[0,0,1,1]);
axis off;
% set(FullFig,'xtick',[],'ytick',[]);
ha1 = axes('position',[bor bor sz sz]);
ha2 = axes('position',[.5-sz/2 .5-sz/2 sz sz]);
ha3 = axes('position',[1-bor-sz 1-bor-sz sz sz]);

set(h,'CurrentAxes',FullFig)
% axis off;
text(.05,.9,{['Spot ' Spot]})
function varargout = mlShowConditionOrderList(OL)

% Usage: ImH = mlShowConditionOrderList(OL)
% 
% Created by ML 2009.07.09



load MLColors_FigureColors1
fn = fieldnames(Col);
for i = 1:max(OL); 
    cMap(i,:) = Col.(fn{i})/255; 
end

% x tick label:
xTL(1:65) = {''};
for iTick = 1:floor(length(xTL)/10);
    xTL{10*iTick} = num2str(10*iTick);
end

h = figure;
mlFigure(h,[10,3]);
Im = imagesc(OL');
colormap(cMap);
set(gca,'ytick',[],'xtick',1:length(OL),'xticklabel',xTL);
mlGraphSetup('Condition Order List','trial');
for i = 1:max(OL)
    hold on;
    L(i) = plot(.5,.5,'s','color',cMap(i,:),'markerfacecolor',cMap(i,:));
    set(L(i),'visible','off')
    hold off;
    CondNames{i} = sprintf('Condition %d',i);
end

LH = legend(L,CondNames,'location','eastoutside');
legend(LH,'boxoff');
if nargout
    varargout{1} = Im;
end
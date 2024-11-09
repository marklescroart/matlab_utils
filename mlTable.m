function mlTable(TableCell,HorizSpacing,VertSpacing)

% usage: mlTable(TableCell)
% 
% Generates a table from the values stored in TableCell

FontSize = 14;

Sz = size(TableCell);

if ~exist('VertSpacing','var')
    % Default to evenly-spaced
    VertSpacing = linspace(0,1,Sz(1)+2);
    VertSpacing = VertSpacing(2:end-1);
end
if ~exist('HorizSpacing','var')
    % Default to evenly-spaced
    HorizSpacing = linspace(0,1,Sz(2)+2); 
    HorizSpacing = HorizSpacing(2:end-1);
end



[x,y] = meshgrid(HorizSpacing,VertSpacing);

TableCell = TableCell(:);
x = x(:);
y = y(:); 

for iCell = 1:length(TableCell);
    if ischar(TableCell{iCell})||iscellstr(TableCell{iCell})
        Txt = TableCell{iCell};
    elseif isnumeric(TableCell{iCell})
        Txt = num2str(TableCell{iCell});
    else
        error([mfilename ':BadInput'],'WTF did you feed me? Please fix "TableCell" input and try again.')
    end
    T(iCell) = text(x(iCell),y(iCell),Txt);
end

set(T,'horizontalalignment','center','verticalalignment','baseline','FontName','Arial','FontSize',FontSize)
set(gca,'xticklabel',[],'yticklabel',[],'xtick',[],'ytick',[],'box','on')
% axis off;
axis ij;
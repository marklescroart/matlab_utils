function varargout = mlYlims(AxisHandle,Pcts)

% Usage: [yLimits] = mlLineYlims(AxisHandle,Pcts)
% 
% Gives back ylimits that scale the data to a particular proportion of the
% vertical space available (specified by "Pcts")
%
% example: 
% yLimits = mlLineYLims(gca,[.1 .1]) 
%    This will set ylimits 10% of the range of the data above the maximum 
%    and 10% of the range of the data below the minimum, such that the data 
%    fills the center 80% of the axes

if ~exist('AxisHandle','var')
    AxisHandle = gca;
end
if ~exist('Pcts','var')
    Pcts = [.1 .1];
end

L = findobj(AxisHandle,'type','line');
B = findobj(AxisHandle,'type','hggroup');

DatCell = get(L,'ydata');
DatCell = [DatCell; get(B,'ydata')];
Dat = [];

if iscell(DatCell);
    for iCat = 1:length(DatCell);
        try
            Dat = [Dat;DatCell{iCat}(:)];
        catch
            0;
        end
    end
else
    Dat = DatCell;
end

Mn = min(Dat(:));
Mx = max(Dat(:));
R = range(Dat(:));

yLimits = [Mn-Pcts(1)*R, Mx + Pcts(2)*R];

if nargout > 0
    varargout{1} = yLimits;
else
    set(AxisHandle,'ylim',[yLimits]);
end
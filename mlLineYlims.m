function [yLimits] = mlLineYlims(AxisHandle,Pcts)

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

L = findobj(AxisHandle,'type','line');
DatCell = get(L,'ydata');
Dat = [];
for iCat = 1:length(DatCell); 
    Dat = [Dat,DatCell{iCat}];
end

Mn = min(Dat);
Mx = max(Dat);
R = range(Dat);

yLimits = [Mn-Pcts(1)*R, Mx + Pcts(2)*R];
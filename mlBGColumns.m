function mlBGColumns(nCols,Cols,ColColors,x_lim,y_lim)

% Usage: mlBGColumns(nCols [,Cols,ColColors,x_lim,y_lim])
% 
% Draws shaded background rectangles on a graph (good for setting up events
% at particular times, or markers for particular x values)
% 
% Inputs: nCols = number of columns
%         Cols = polygons defining X locations of column borders - so this
%                will be nCols+1 long. Defaults to evenly spaced columns
%                between x_lim(1) and x_lim(2); for narrower columns (which
%                would most likely be for point events), define columns
%                yourself...
%         ColColors = nCols x 3 matrix of RGB triples for colors; OR, color
%                of thin columns (odd, non-white ones)
%         only use x_lim and y_lim if you don't want the background shading
%                spanning the whole graph.
% Created by ML 2009.01.05

%%% Inputs: 
if exist('ColColors','var') && size(ColColors,1)==1; 
    if size(ColColors,2) == 3;
        ColColors = repmat([1 1 1; ColColors],nCols/2,1); % face colors for patches
    else
        ColColors = repmat([1 1 1; ColColors*[1 1 1]],nCols/2,1); % face colors for patches
    end
    if mod(nCols,2)
        ColColors(end+1,:) = [1 1 1];
    end

elseif ~exist('ColColors','var')||isempty(ColColors)
    ColColors = repmat([1 1 1; .92 .92 .92],nCols/2,1); % face colors for patches
    if mod(nCols,2)
        ColColors(end+1,:) = [1 1 1];
    end
end

Limits = get(gca,{'xLim','yLim'});
AlreadyPlotted = get(gca,'Children');

if ~exist('x_lim','var')||isempty(x_lim)
    x_lim = Limits{1};
end
if ~exist('y_lim','var')||isempty(y_lim)
    y_lim = Limits{2};
end

if ~exist('Cols','var')||isempty(Cols)
    Cols = linspace(x_lim(1),x_lim(2),nCols+1);
end

for i = 1:nCols;
    % defining polygons for patch function
    X = [Cols(i),Cols(i),Cols(i+1),Cols(i+1)]';
    Y = [y_lim(1),y_lim(2),y_lim(2),y_lim(1)]';
    p = patch(X,Y,ColColors(i,:));
    %set(p,'EdgeAlpha',0)
    set(gca,'Layer','top');
end

for j = 1:length(AlreadyPlotted)
    uistack(AlreadyPlotted(j),'top');
end

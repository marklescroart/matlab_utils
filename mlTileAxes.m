function [varargout] = mlTileAxes(nRows,nColumns,SpaceToTile,OrderFlag,Gap)

% usage: [AxPos [,AxH]] = mlTileAxes(nRows,nColumns,SpaceToTile,OrderFlag,Gap)
%
% Rows & Columns are self-explanatory (unless you're a Bruin)
% 
% SpaceToTile is the rectangle within the figure you'd like to tile with
%       axes, e.g. [.5,.5,.5,.5] for the top right corner
%       That is: [xBotLeft yBotLeft Width Height]
% 
% OrderFlag determines order of axes. 
%
% OrderFlag = 1  |   OrderFlag = 2
%                |
% 1 2 3 4 5      |   1 4 7 10 e
% 6 7 8 9 10     |   2 5 8 11 t
% 11... etc      |   3 6 9 12 c...
% 
% Gap is a proportion gap between the axes (in normalized figure units)
% 
% This function will return position rectangles ("AxPos") for the number of 
% axes specified if called with one or zero outputs; it will return
% position rectangles AND axis handles ("AxH") AND actually plot the axes 
% if called with two outputs. 
%
% Created by ML 2009.03.25

if ~exist('OrderFlag','var')||isempty(OrderFlag)
    OrderFlag = 1;
end
if ~exist('SpaceToTile','var')||isempty(SpaceToTile)
    SpaceToTile = [0 0 1 1];
end
if ~exist('Gap','var')
    Gap = 0.0;
end


AxWidth = SpaceToTile(3)/nColumns;
AxHeight = SpaceToTile(4)/nRows;

HorizSpacing = linspace(SpaceToTile(1),SpaceToTile(1)+SpaceToTile(3)-AxWidth,nColumns);
VertSpacing  = linspace(SpaceToTile(2),SpaceToTile(2)+SpaceToTile(4)-AxHeight,nRows);
[Horiz,Vert] = meshgrid(HorizSpacing,VertSpacing);

switch OrderFlag
    case 1
        Horiz = Horiz'; Horiz = Horiz(:);
        Vert = Vert'; Vert = flipud(Vert(:));
    case 2
        Horiz = Horiz(:);
        Vert = flipud(Vert(:));
end

TmpAxPos = [Horiz,Vert,repmat(AxWidth,nRows*nColumns,1),repmat(AxHeight,nRows*nColumns,1)];


OffSetX = AxWidth*Gap;
OffSetY = AxHeight*Gap;
TmpAxPos(:,1) = TmpAxPos(:,1) + OffSetX;
TmpAxPos(:,3) = TmpAxPos(:,3) - 2 .* OffSetX;
TmpAxPos(:,2) = TmpAxPos(:,2) + OffSetY;
TmpAxPos(:,4) = TmpAxPos(:,4) - 2 .* OffSetY;


AxPos = TmpAxPos;

if nargout>1
    for iRC = 1:nRows*nColumns
        Axh(iRC) = axes('Position',AxPos(iRC,:));
    end
    varargout{1} = AxPos;
    varargout{2} = Axh;
else
    varargout{1} = AxPos;
end
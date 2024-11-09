function [varargout] = TileFigs(varargin)

% Usage: [Pos] = TileFigs(nFigs) OR [Pos] = TileFigs(nCols,nRows) OR 
%        [Pos] = TileFigs(nCols,nRows,OffSet)
% 
% Tiles the screen with a specified number of figures (1 input) OR with
% nCols by nRows of figures. If "Pos" is specified, it returns a variable
% with all the figure positions and sizes rather than actually displaying
% them.
% 
% Calls SetFigProps. 
% 
% Created by ML 11.16.06
% Modified by ML 4.9.07

SetFigProps;

ScrSize = get(0,'ScreenSize');

if length(varargin) < 1
    hTest = figure;
    nFigs = hTest-1;
    close;
    SqSize = nFigs;
    
    [nCols,nRows] = mlFindSquareishDimensions(SqSize);
%     nCols = floor(sqrt(SqSize));
%     if sqrt(nFigs) ~= nCols
%         while sqrt(SqSize)~=floor(sqrt(SqSize))
%             SqSize = SqSize+1;
%         end
%     end
% 
%     if nFigs >= sqrt(SqSize) * sqrt(SqSize)-1;
%         nCols = sqrt(SqSize); nRows = sqrt(SqSize);
%     else
%         nCols = sqrt(SqSize); nRows = sqrt(SqSize)-1;
%     end

elseif length(varargin) == 1
    nFigs = varargin{1}; clear varargin
    SqSize = nFigs;
    [nCols,nRows] = mlFindSquareishDimensions(SqSize);
%     nCols = floor(sqrt(SqSize));
%     if sqrt(nFigs) ~= nCols
%         while sqrt(SqSize)~=floor(sqrt(SqSize))
%             SqSize = SqSize+1;
%         end
%     end
% 
%     if nFigs >= sqrt(SqSize) * sqrt(SqSize)-1;
%         nCols = sqrt(SqSize); nRows = sqrt(SqSize);
%     else
%         nCols = sqrt(SqSize); nRows = sqrt(SqSize)-1;
%     end
elseif length(varargin) == 2
    nCols = varargin{1};
    nRows = varargin{2};
    nFigs = nCols*nRows;
elseif length(varargin) > 2
    error([mfilename ':TooManyInput'], 'Too many inputs.')
end

FigWidth  = floor(ScrSize(3)/nCols);
FigHeight = (floor(ScrSize(4))-40)/nRows;

for ii = 1:nFigs
    FigPosX = 1+FigWidth*(mod(ii-1,nCols));
    FigPosY = ScrSize(4)-FigHeight-40-(FigHeight*(floor((ii-1)/nCols)));
    Pos(ii,:) = [FigPosX FigPosY FigWidth FigHeight];
    if ~nargout
        hh(ii) = figure(ii);
        set(hh(ii),'Position',Pos(ii,:));
    end
end

if nargout
    varargout{1} = Pos;
end


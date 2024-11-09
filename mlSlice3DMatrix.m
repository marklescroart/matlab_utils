function mlSlice3DMatrix(Mat,dim,h,MatRange)

% Usage: mlSlice3DMatrix(Mat,dim,h,MatRange)
% 
% 

PosType = 'Position'; % 'OuterPosition'; % 

if ~exist('h','var');
    h = figure;
end
if ~exist('MatRange','var')
    MatRange = [];
end

Sz = size(Mat);
XY = Sz(Sz~=Sz(dim));
MaxImDim = find(XY==max(XY));
if length(MaxImDim)==2
    MaxImDim = MaxImDim(1);
end
D = Sz(dim);
Dd = mlFindSquareishDimensions(D);

Pos = mlTileAxes(Dd,Dd,[],[],.01); 
switch MaxImDim
    case 1
        mlFigure(h,[Dd*min(XY)/max(XY),Dd]);
    case 2
        mlFigure(h,[Dd,Dd*min(XY)/max(XY)]);
end

for iSlice = 1:D; 
    axes(PosType,Pos(iSlice,:));
    switch dim
        case 1
            ToShow = squeeze(Mat(iSlice,:,:));
        case 2
            ToShow = squeeze(Mat(:,iSlice,:));
        case 3
            ToShow = squeeze(Mat(:,:,iSlice));
    end
    imshow(ToShow,MatRange,'initialmagnification','fit')
end

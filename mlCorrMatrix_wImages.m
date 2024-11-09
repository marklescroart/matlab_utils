function mlCorrMatrix_wImages(R,Im,TitleStr,Range,h,Xlab,Ylab)

% Usage: mlCorrMatrix_wImages(R,Im,TitleStr,Range,h,Xlab,Ylab)
% 
% Creates an image of a correlation matrix (black-and-white, for now)
% 
% Recommended figure size is 8x8
% 
% sample call: 
% 
%
% ImDir = '~/Documents/Neuro_Docs/Projects-IUL/MVPA_Relations_v2/Images/ScreenShotsLetters/';
% ImNm = mlStructExtract(dir([ImDir '*.png']),'name');
% a = imread([ImDir ImNm{1}]);
% Im = zeros(size(a,1),size(a,2),length(ImNm));
% clear a;
% for iIm = 1:length(ImNm);
%    Im(:,:,iIm) = rgb2gray(imread([ImDir ImNm{iIm}]));
% end
% One = rand(100,16);
% Two = mlNormalize(One + .75*rand(100,16));
% R = corr(One,Two);
% TitleStr = 'Correlation matrix example';
% h = mlFigure(1,[8 8]);
% mlCorrMatrix_wImages(R,Im,TitleStr,[],h);


% Default Inputs: 

if ~exist('h','var')
    h = figure;
end
if ~exist('Range','var')
    Range = [];
end
if ~exist('Im','var')||isempty(Im);
    % TO DO: create an option for text labels instead of images, and create
    % a default set of text labels. 
    error('Please specify a matrix of images to label the correlation matrix. ("Im" variable - see usage)');
end
if ~exist('TitleStr','var')||isempty(TitleStr)
    TitleStr = {['Correlations of voxel patterns']}; % - Run ' num2str(WhichRuns) ', ALL vox w/ discontinuity'],'Even Presentations of Images'};
end
if ~exist('Xlab','var')||isempty(Xlab)
    Xlab = ['']; %'Other 1/2 Presentations of Images';
end
if ~exist('Ylab','var')||isempty(Ylab)
    Ylab = ['']; %'1/2 Presentations of Images';
end

Flag.DrawCorrValues = true;

%%% Correlation graph
CorrValTextColor = [1 0 0];

figure(h);

%%% Create text labels on background axis first: 
BG = axes('Position',[0 0 1 1]);

text(.5,.95,TitleStr,'fontname','Arial','fontsize',14,...
    'VerticalAlignment','middle','HorizontalAlignment','center','units','normalized','Rotation',0)

text(.05,.5,Ylab,'fontname','Arial','fontsize',14,...
    'VerticalAlignment','middle','HorizontalAlignment','center','units','normalized','Rotation',90)

text(.5,.025,Xlab,'fontname','Arial','fontsize',14,...
    'VerticalAlignment','middle','HorizontalAlignment','center','units','normalized','Rotation',0)

set(BG,'Visible','off');

%%% Set up correlation matrix as central axis: 
xdim = size(R,2); % And R better be square if it's a correlation matrix
Extent = .85/((xdim+1)/xdim);
MainAx = axes('Position',[1-Extent-.05 .05  Extent Extent]);
% MainAx = axes('Position',[.2 .05 .75 .75]);
imshow(R,Range,'InitialMagnification','fit');
axis on;
mlGraphSetup;
set(MainAx,'xtick',[],'ytick',[])

%%% Draw border lines between 
hold on;
plot(repmat([.5 xdim+.5],[xdim-1,1])',[[1.5:1:xdim-.5]',[1.5:1:xdim-.5]']','linewidth',1.5,'Color','k'); 
plot([[1.5:1:xdim-.5]',[1.5:1:xdim-.5]']',repmat([.5 xdim+.5],[xdim-1,1])','linewidth',1.5,'Color','k'); 
hold off

%%% Fill in Correlation values in boxes, if flag is set: 
if Flag.DrawCorrValues
    TxtX = linspace(1/(xdim*2),((xdim*2)-1)/(xdim*2),xdim);
    TxtY = fliplr(TxtX);
    for i = 1:xdim;
        for j = 1:xdim;
            text(TxtX(i),TxtY(j),sprintf('%-3.2f',mlRound(R(j,i),.01)),'Units','normalized','horizontalalignment','center','color',CorrValTextColor);
        end
    end
end


% Put images up around edges (top and left - create options to change location ??) 
AxPos = get(MainAx,'Position');
AxX = linspace(AxPos(1),AxPos(1)+AxPos(3),xdim+1);
AxY = linspace(AxPos(2)+AxPos(4),AxPos(2),xdim+1);
AxSzX = AxPos(3)/xdim;
AxSzY = AxPos(4)/xdim;

for iVert = 1:xdim
    ImAx(iVert) = axes('Position',[AxX(1)-AxSzX,AxY(iVert+1),AxSzX,AxSzY]);
    imshow(Im(:,:,iVert),[]);
    set(ImAx(iVert),'visible','on','xtick',[],'ytick',[],'linewidth',1.5)
    ImAx(iVert+xdim) = axes('Position',[AxX(iVert),AxY(2)+AxSzY,AxSzX,AxSzY]);
    imshow(Im(:,:,iVert),[])
    set(ImAx(iVert+xdim),'visible','on','xtick',[],'ytick',[],'linewidth',1.5)
end


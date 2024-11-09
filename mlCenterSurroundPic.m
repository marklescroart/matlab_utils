function mlCenterSurroundPic(Sz)

% Usage: mlCenterSurroundPic(Sz)
% 
% Sz = Size
% 
% Created by ML, 11.14.07

Plot = 1;
Save = 0;

if ~exist('Sz','var')
    Sz = 100;
end

% Define an impulse response function (i.e. a spatial kernel)
[x y] = meshgrid([-Sz:Sz],[-Sz:Sz]);
sigma = Sz /2 ; %50

Gauss1 = 1/pi/sigma^2*exp(-(x.^2+y.^2)/sigma^2);

Gauss2 = 1/pi/sigma^2*exp(-(x.^2+y.^2)/(.5*sigma)^2);

Hat = Gauss2-Gauss1;


if Plot;
    hh = figure;
    imshow(Hat,[]);
end

if Save
    SavePath = './'; %'/Users/Work/Documents/Neuro_Docs/Presentations/Vision-RetToLO/';
    saveas(hh,[SavePath 'MexicanHat.png'],'png');
    imwrite(Hat,'MexcanHatPic.png');
end
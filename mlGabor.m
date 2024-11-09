function Gabor = mlGabor(Ori,Sz,phi)

% Usage: Gabor = mlGabor([Ori] [,Sz] [,phi])
% 
% Ori = Orientation (up to 180 - more than that is meaningless)
% Sz = Size
% phi = phase
% 
% Created by BT, annotated by ML 9.18.07

Plot = 1;
Save = 0;

if ~exist('Ori','var')
    Ori = 45;
end
if ~exist('Sz','var')
    Sz = 100;
end
if ~exist('phi','var')
    phi = 0; % pi/2; %
end

% Define an impulse response function (i.e. a spatial kernel)
[x y] = meshgrid([-Sz:Sz],[-Sz:Sz]);
% Make it a Gabor
f = 1/Sz; %0.01; (at 100) - % normalized frequency (1=Nyquest)
theta = Ori/180*pi; % Thus, [Ori] degrees
sigma = Sz /2 ; %50
a = cos(theta);	
b = sin(theta);	

Gauss1 = 1/pi/sigma^2*exp(-(x.^2+y.^2)/sigma^2);
Sine1 = cos(2*pi*f*(b*x+a*y)+phi);
Gabor = Gauss1.*Sine1;

if Plot;
    % show the kernel
    %H1 = figure;
    %subplot(311);
    %imshow(Gauss1,[]);
    %subplot(312);
    %H2 = figure;
    %imshow(Sine1,[]);
    %subplot(313);
    H3 = figure;
    imshow(Gabor,[]);
end

if Save
    SavePath = './'; %'/Users/Work/Documents/Neuro_Docs/Presentations/Vision-RetToLO/';
    %saveas(H1,[SavePath 'Gaussian.png'],'png');
    %saveas(H2,[SavePath 'SineGrating.png'],'png');
    saveas(H3,[SavePath 'Gabor' num2str(Ori) '.png'],'png');
end
function Gauss1 = ml2DGauss(Sz,Sig)

error('Recommended that you use mlGauss2D instead...')

if ~exist('Sz','var')
    Sz = 100;
end
if ~exist('phi','var')
    phi = 0; % pi/2; %
end

% Define an impulse response function (i.e. a spatial kernel)
[x y] = meshgrid([-Sz:Sz],[-Sz:Sz]);
sigma = Sz /2 ; %50
Gauss1 = 1/pi/sigma^2*exp(-(x.^2+y.^2)/sigma^2);
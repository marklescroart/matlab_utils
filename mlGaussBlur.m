function g = mlGaussBlur(Sz)


[x y] = meshgrid([-Sz:Sz],[-Sz:Sz]);

% Make it a Gabor
sigma = Sz /2 ; %50

g = 1/pi/sigma^2*exp(-(x.^2+y.^2)/sigma^2);
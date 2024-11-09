function Y = mlGauss2D(x,y,muY,muX,sigma)

% Usage: Y = mlGauss2D(x,y,muY,muX,sigma)
% 
% NOTE: max amplitude of function is set to 1
% 
% Example calls: 
% 
% [x,y] = meshgrid(linspace(-4,4,100),linspace(-4,4,100));
% Gg = mlGauss2D(x,y,-1,2,1.5);
% imshow(Gg,[])

% Y = 1/pi/sigma^2*exp(-((x-muX).^2+(y-muY).^2)/sigma^2);
% As far as I can tell - (4/12/09) - the 1/pi/sigma^2 at the beginning
% makes the area under the curve sum to 1 (i.e., makes it a PROBABILITY 
% DENSITY FUNCTION). IF we don't care about that, and are more interested 
% in a response from 0 to 1, we can use the second function: 

Amplitude = 1;
Y = Amplitude * exp(-((x-muX).^2+(y-muY).^2)/sigma^2);
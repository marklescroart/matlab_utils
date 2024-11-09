function Y = mlNormPDF2D(x,y,muY,muX,sigma)

% Usage: Y = mlNormPDF2D(x,y,muY,muX,sigma)

%[xx yy] = meshgrid([-Sz:Sz],[-Sz:Sz]);

% As far as I can tell - (4/12/09) - the 1/pi/sigma^2 at the beginning
% makes the area under the curve sum to 1. IF we don't care about that, we
% can use the second function: 
% Y = 1/pi/sigma^2*exp(-((x-muX).^2+(y-muY).^2)/sigma^2);

Amplitude = 1;
Y = Amplitude * exp(-((x-muX).^2+(y-muY).^2)/sigma^2);
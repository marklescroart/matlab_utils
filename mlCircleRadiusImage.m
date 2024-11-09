function CircleIm = mlCircleRadiusImage(MaxValue,Sz)

% Usage: CircleIm = mlCircleRadiusImage(MaxValue,Sz)
% 
% Cute trick picked up from Xiangrui Li's retinotopy code: creates an image
% with a value of zero at the center and increasing values (i.e., linearly
% increasing values up to MaxValue) extending radially out from the center
% of the image. Good for drawing circles.  
% 
% Example use: 
% 
% ScreenSizePix = 764;
% ScreenPPD = 42.8;
% ScreenVisDegrees = ScreenSizePix/ScreenPPD;
% Im = mlCircleRadiusImage(ScreenVisDegrees,ScreenSizePix);
% imshow(Im<7,[])
% % (Creates a circle that's 7 visual deg. in radius if displayed over the
% % entire screen)

% Create a meshgrid of the appropriate size:
[x,y]=meshgrid(linspace(-MaxValue,MaxValue,Sz), linspace(MaxValue,-MaxValue,Sz));

% Get r and theta coordinates for each point: (very cute trick)
CircleIm = sqrt (x.^2  + y.^2);

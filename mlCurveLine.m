function LinePts = mlCurveLine(Length,nPoints,RadiansCurv)

% Usage: LinePts = mlCurveLine(Length,nPoints,RadiansCurv)
% 
% NOTE: the length of the curve is set by the absolute length along
% the curve. If you need to specify a particular radius, you can calculate 
% the values of Length and RadiansCurv that you will need.

% Because x and y will range from -1 to 1, the range is twice what you'd
% think...



if ~exist('Length','var')
    Length = 4;
end
if ~exist('nPoints','var');
    nPoints = 40;
end
if ~exist('RadiansCurv','var')
    RadiansCurv = pi/3;
end
if RadiansCurv<0
    F.NegCurv = 1;
    RadiansCurv = abs(RadiansCurv);
else
    F.NegCurv = 0;
end

% Radius of curvature is a function of (absolute) length of the curve and
% number of radians 
% (RadiansCurv/(2*pi) = Fraction of the circle)
% So:        Circumfrence * CircleFract = Length
%            2*pi*cRadius * CircleFract = Length  %% cRadius = CircleRadius
%     2*pi*cRadius * RadiansCurv/(2*pi) = Length
%                 cRadius * RadiansCurv = Length
%                               cRadius = Length/RadiansCurv

cRadius = Length/(RadiansCurv);

% Define x points - linear spread of nPoints from left extreme of curve to
% right
x = linspace(cRadius*(-sin(RadiansCurv/2)),cRadius*sin(RadiansCurv/2),nPoints);

% x^2+y^2 = 1;
y = sqrt(cRadius^2-x.^2); 

%plot(x,y); 

%axis equal

if F.NegCurv
    %LinePts = 1-(y-min(y)); % for start and end point at 1
    LinePts = (y-min(y)); % for start and end point at 0
else
    %LinePts = y-min(y)+1;
    LinePts = y-min(y);
end
%save DebugVars;

% plot(LinePts);
% axis equal
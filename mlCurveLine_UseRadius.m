function LinePts = mlCurveLine_UseRadius(cRadius,nPoints,RadiansCurv)

% Usage: LinePts = mlCurveLine_UseRadius(cRadius,nPoints,RadiansCurv)
% 
% NOTE: the length of the curve is set by the absolute length along
% the curve. If you need to specify a particular radius, you can calculate 
% the values of Length and RadiansCurv that you will need.

% Because x and y will range from -1 to 1, the range is twice what you'd
% think...



if ~exist('cRadius','var')
    cRadius = 3;
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


% Define x points - linear spread of nPoints from left extreme of curve to
% right
x = linspace(cRadius*(-sin(RadiansCurv/2)),cRadius*sin(RadiansCurv/2),nPoints);

% x^2+y^2 = 1;
y = sqrt(cRadius^2-x.^2); 

%plot(x,y); 

%axis equal

if F.NegCurv
    LinePts = -(y-min(y));
else
    LinePts = y-min(y);
end
%save DebugVars;

% plot(LinePts);
% axis equal
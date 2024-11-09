function Pos = mlCirclePos(radius,nPos,x_center,y_center,Direction)

% Usage: Pos = mlCirclePos(radius,nPos [,x_center,y_center,Direction])
% 
% Returns coordinates for [nPos] points around a circle of radius [radius], 
% centered on [x_center,y_center]. Coordinates returned in [Pos], an nPos 
% by 2 matrix of [x,y] values. 
% 
% Inputs: radius = Radius of the circle
%           nPos = number of positions around the circle
%       x_center = duh (defaults to 512)
%       y_center = duh (defaults to 384)
%      Direction = String specifying direction of points around circle - 
%                  either 'BotCCW' (botom Counter-Clockwise), 'BotCW'
%                  (bottom Clockwise), 'TopCCW', or 'TopCW' (Defaults to
%                  'BotCCW')
% 
% See function text at the bottom for example usage.
% 
% Created by ML on ??/??/2007

if nargin < 2
    error([mfilename ':Arguments'],'Usage: Pos = mlCirclePos(radius, nPos [, x_center,y_center,Direction])')
end

if nargin < 3
    x_center = 512;
    y_center = 384;
end

if ~exist('Direction','var')
    Direction = 'BotCCW';
end

iPos = 1;
for tt = 0:360/nPos:360-360/nPos;
    Pos(iPos,1) = radius*sind(tt) + x_center;
    Pos(iPos,2) = -radius*cosd(tt) + y_center;
    iPos = iPos+1;
end; clear tt; clear iPos;

switch upper(Direction)
    case 'BOTCCW'
        0; % Do nothing - it's set this way anyway.
    case 'BOTCW'
        Pos = [Pos(1,:); Pos(end:-1:2,:)];
    case 'TOPCCW'
        Pos = [Pos(1,:); Pos(end:-1:2,:)];
        Pos(:,2) = -(Pos(:,2)-y_center) + y_center;
    case 'TOPCW'
        Pos(:,2) = -(Pos(:,2)-y_center) + y_center;
        %Pos(:,2) = -Pos(:,2);
end


%{

% NOTE: To reverse (from CCW starting at bottom to CW starting at bottom):
figure(1);
subplot(121);
Pos = mlCirclePos(10,12,0,0);
ylim([-12 12]); xlim([-12 12]);
hold on; for i =1:12; text(Pos(i,1),Pos(i,2),num2str(i)); end; hold off
title('Created from: "Pos = mlCirclePos(10,12,0,0)"')
subplot(122);
Pos = mlCirclePos(10,12,12,12,'TopCCW');
ylim([0 24]); xlim([0 24]);
hold on; for i =1:12; text(Pos(i,1),Pos(i,2),num2str(i)); end; hold off
title('Created from: "Pos = mlCirclePos(10,12,12,12,''TopCCW'')"')


figure(2);
Pos = mlCirclePos(10,12,0,0,'TopCW');
ylim([-12 12]); xlim([-12 12]);
hold on; for i =1:12; text(Pos(i,1),Pos(i,2),num2str(i)); end; hold off
title('Created from: "Pos = mlCirclePos(10,12,0,0,''TopCW'')"')

figure(3);
Pos = mlCirclePos(10,12,0,0,'BotCW');

ylim([-12 12]); xlim([-12 12]);
hold on; for i =1:12; text(Pos(i,1),Pos(i,2),num2str(i)); end; hold off
title('Created from: "Pos = mlCirclePos(10,12,0,0,''BotCW'');"')

%}
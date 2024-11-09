function AngleDist = mlAngleDistance(A1,A2)

% Usage: AngleDist = mlAngleDistance(AngleOne,AngleTwo)
% 
% Lazy man's function to find distance (in degrees) between two angles.
% Four lines long (one subtraction with an if clause). 
% 
% 

AngleDist = abs(diff([A1,A2]));

if AngleDist > 180
    AngleDist = 360-AngleDist;
end
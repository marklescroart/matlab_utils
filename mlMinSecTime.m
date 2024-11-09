function [tt] = mlMinSecTime(Start, Fin, Exact)

% Usage: [XXminsYYsecsString] = MLMinSecTime(StartTime,FinishTime [,ExactTime])
%
% Inputs: 'StartTime' & 'FinishTime' must be timestamps taken with GetSecs
%            or equivalent functions.
%         'ExactTime' - set to 1 for exact (three decimal place) time. 
%            default is 0 (for rounding - i.e. whole integers)
%
% Created by ML 12.11.06

if nargin < 2
    error('You must input a valid Start and Finish Time');
elseif nargin < 3
    Exact = 0;
end
    
TotalTimeMin = floor((Fin - Start) / 60);
if Exact
    TotalTimeSec = Fin - Start - (TotalTimeMin*60);
else
    TotalTimeSec = round(Fin - Start - (TotalTimeMin*60));
end
tt = [num2str(TotalTimeMin) ' minutes ' num2str(TotalTimeSec) ' seconds'];

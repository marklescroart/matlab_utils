function TimeStamp = mlMouseWait(StartTime,Deadline)

% Usage: TimeStamp = mlMouseWait([StartTime] [,Deadline])
% 
% simple function to wait for a mouse button press; returns the time of the
% button press (minus StartTime)
% 
% Inputs: StartTime - Starting time point for the returned timestamp
%                     (default = moment the function is called)
%         Deadline  - When to quit the function (default = StartTime+120 s)
% 
% Created by ML 02.22.08

if ~exist('StartTime','var')
    StartTime = GetSecs;
end
if ~exist('Deadline','var')
    Deadline = StartTime+120;
end

Tolerance = .0001;
[x,y,buttons] = GetMouse;

while ~any(buttons) && GetSecs < Deadline;
    [x,y,buttons] = GetMouse;
    Stop = GetSecs;
    WaitSecs(Tolerance);
end

if ~exist('Stop','var')
    Stop = GetSecs;
end

TimeStamp = Stop-StartTime;

% fprintf('%.5f\n',TimeStamp); 
% takes about .0003-4 seconds to return if mouse is down when it's called.
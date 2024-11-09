function QuitNow = QuitKeyTimer(WaitFor, QuitCheck)

% Usage: QuitNow = QuitKeyTimer(WaitFor [, QuitCheck])
%
% Called as a utility in other functions. KEEP IT ON THE PATH.
% 
% Defines a QuitKey (as ESCAPE) and looks for it (waits for an input of 
% that key) for the time specified, counting either from the time it is 
% called (default) or from the input argument QuitCheck
%
% QuitNow (returned by the function) is a 1 (true) if the QuitKey is
% pressed, and a zero otherwise.
%
% Created 04/06 by ML

if ~exist('QuitCheck', 'var')
    QuitCheck = clock;
end

if ~exist('WaitFor', 'var')
    error([mfilename ':NoWaitFor'], 'Please add a time to wait to your use of the "QuitKeyTimer" function.');
end

QuitKey = KbName('ESCAPE');
QuitNow = 0;
while etime(clock,QuitCheck) < WaitFor
    [a,b,KeyCode] = KbCheck;
    WaitSecs(.005);
    if KeyCode(QuitKey)
        Screen('CloseAll');
        ShowCursor
        QuitNow = 1;
        return
    end
end

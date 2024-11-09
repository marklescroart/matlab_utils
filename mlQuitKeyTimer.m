function mlQuitKeyTimer(DL)

% Usage: mlQuitKeyTimer(WaitTill)
%
% Returns a Manual Quit error if 'Escape' is pressed between call and
%           "WaitTill" (on the GetSecs timeline)
% 
% Should return control to program < 1 ms after WaitTill.
%
% Created 10/07 by ML

if ~exist('DL', 'var')
    error([mfilename ':NoDeadLine'], 'EEEDIOT. Do you want me to run forever? Please set a deadline.');
end

QuitKey = KbName('ESCAPE');
Tolerance = .005; % Returns control to 

if DL-GetSecs <= Tolerance %DL <= GetSecs
    warning([mfilename ':BadDeadline'],['BEWARE: your deadline for ' mfilename 'passed before the function was called. \nThis could be a bad timing bug.'])
    return
end

while DL-GetSecs > Tolerance %DL > GetSecs
    [a,b,KeyCode] = KbCheck;
    WaitSecs(.001);
    if KeyCode(QuitKey)
        error([mfilename ':ManQuit'],'You manually quit the program.')
    end
end

% mlErrorCleanup
%
% Script designed to go after "catch" in a try/catch loop. displays the
% line number of the last error generated and what it was. 
% 
% Must call "rethrow(lasterror)" after this script!
% 
% Lifted & slightly adapted from Don Kalar's code by M.L. 12.08.07

%fprintf('Starting mlErrorCleanup\n'); % This is to clarify what this program has done, as some PTB debugging code prints in the middle of it...

disp(sprintf('Error: %s', lasterr))
Priority(0);
ShowCursor          % No matter if cursor isn't hidden
Screen('CloseAll'); % no matter if no screen is open
%fprintf('mlErrorCleanup just closed Screen.\n');

if ~exist('ErrorVarName','var')
    ErrorVarName = 'DebugVars.mat';
end
save(ErrorVarName);

error_struct = lasterror;
error_output = [];
for i = 1:length(error_struct.stack)
    error_lines = error_struct.stack(i);
    error_output = [error_output, sprintf('file: %s\t\t\tline: %d\n',error_lines.name, error_lines.line)];
end
disp(error_output)

%fprintf('Finished mlErrorCleanup\n');
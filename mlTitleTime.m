function Time = mlTitleTime(C)

% Usage: Time = mlTitleTime([ClockTime])
%
% Creates a string in the form "YYYY_MM_DD_HHMM"
%
% In the absense of input, the function uses the time from "clock" at the
%       moment the function is called.
%
% Created by ML 4/13/07

if ~exist('ClockTime','var')
    C = clock;
end


Time = sprintf('%04d_%02d_%02d_%02d%02d',C(1),C(2),C(3),C(4),C(5));

% for ii = 1:length(ClockTime)
%     if ClockTime(ii) < 10
%         Part{ii} = ['0' int2str(ClockTime(ii))];
%     else
%         Part{ii} = [int2str(ClockTime(ii))];
%     end
% end
% 
% Time = [Part{2} '_' Part{3} '_' Part{4} Part{5}];


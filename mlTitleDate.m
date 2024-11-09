function Time = mlTitleDate(Format)

% Usage: Time = mlTitleDate([Format])
%
% Creates a string in the form:
%      Format = 1 -> "YYYY_MM_DD"
%      Format = 2 _> "MM_DD_YY"
%
% Created by ML 4/13/07


if ~nargin
    Format = 1;
end

ClockTime = clock;

for ii = 1:length(ClockTime)
    if ClockTime(ii) < 10
        Part{ii} = ['0' int2str(ClockTime(ii))];
    else
        Part{ii} = [int2str(ClockTime(ii))];
    end
end

switch Format
    case 1
        Time = [Part{1}(1:4) '_' Part{2} '_' Part{3}];
    case 2
        Time = [Part{2} '_' Part{3} '_' Part{1}(3:4)];
end


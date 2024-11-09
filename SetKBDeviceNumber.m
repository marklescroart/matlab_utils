function [RespKB, MainKB] = SetKBDeviceNumber

% usage: [RespKB, MainKB] = SetKBDeviceNumber
% 
% Sets DeviceNumber for KbCheck / KbWait later in the main function.
% 
% Created by ML on 7.12.06
% Modified by ML on 11.16.06

try
    AssertOSX
catch
    error([mfilename ':OSX'], ['Sorry, the function SetKBDeviceNumber doesn''t work on Windows, \n because it calls "PsychHID", which is platform-specific']);
end

Devices = PsychHID('Devices');
KBCount = 0;
for ii = 1:length(Devices)
    if strcmpi(Devices(ii).usageName,'Keyboard')
        KBCount = KBCount+1;
    end
end

if KBCount == 1
    RespKB = 0;
    for WhosThere = 1:length(Devices)
        if strcmp(Devices(WhosThere).usageName, 'Keyboard') & RespKB == 0
            RespKB = WhosThere;
            MainKB = WhosThere;
        else
            continue
        end
    end
elseif KBCount == 2
    RespKB = 0;
    for WhosThere = 1:length(Devices)
        if strcmp(Devices(WhosThere).usageName, 'Keyboard') & RespKB == 0
            RespKB = WhosThere;
        elseif strcmp(Devices(WhosThere).usageName, 'Keyboard') & RespKB ~= 0
            MainKB = WhosThere;
        else
            continue
        end
    end
elseif KBCount > 2
    error('What the hell are you doing with all those keyboards? I can''t deal with this.')
end

function ConnectedDevices

% uses PsychHID function to give back the device names and numbers that are
% currently attached to the computer. 

Devices = PsychHID('Devices');

disp(['There are ' int2str(Devices(end).index) ' devices attached to the computer: '])
disp(' ')

for i = 1:length(Devices)
    disp(['Device ' int2str(i) ' is a ' Devices(i).usageName ' (' Devices(i).manufacturer ...
        ' ' Devices(i).product ').'])
end

disp(' ')

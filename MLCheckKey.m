function MLCheckKey(KB)

% Usage: MLCheckKey([WhichKeyboard])
% 
% Inputs: WhichKeyBoard - string - either "Main" or "Resp"
% 
% Created by ML on 12.12.06

if ~nargin
    KB = 'Main';
end
[RespKB, MainKB] = SetKBDeviceNumber;
if strcmpi('main',KB)
    KB = MainKB;
elseif strcmpi('Resp',KB)
    KB = RespKB;
end

while KbCheck; end
[KeyYN, Secs, KeyCode] = KbCheck(KB);
while ~KeyYN
    [KeyYN, Secs, KeyCode] = KbCheck(KB);
end
while KbCheck; end

KeyName = KbName(KeyCode);

disp(['Key Name is ''' KeyName ''' ']);

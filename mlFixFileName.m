function NewFileName = mlFixFileName(FileName)

% Changes "/" to "\" for windows
% Changes "\" to "/" for Mac / Unix

WhatOS = OSName;

switch WhatOS
    case 'OS X'
        NewFileName = strrep(FileName,'\','/');
    case 'Windows'
        NewFileName = strrep(FileName,'/','\');
end
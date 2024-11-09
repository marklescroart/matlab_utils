function StringOut = mlTextChopper(String,MaxLineLength)

% Usage: StringOut = mlTextChopper(String,MaxLineLength)
% 
% Takes a single-line string "String" and chops it into multiple lines less
% than "MaxLineLength" characters each. The result is a multi-line 
% character array "StringOut".
% 
% Created by ML 07.26.07
% Modified by ML 10.07.07

Spaces = findstr(' ',String);
Spaces(end+1) = length(String);
StrStart = 1;

% BlankLine = char(1,MaxLineLength);
nLines = ceil(length(String) / MaxLineLength);

for iCut = 1:nLines
    SpaceIdx = find(Spaces < MaxLineLength * iCut);
    NewLine = String(StrStart:Spaces(SpaceIdx(end)));    
    StringOut(iCut,1:length(NewLine)) = NewLine;
    if iCut < nLines
        StrStart = Spaces(SpaceIdx(end))+1;
    end
end
function varargout = mlTitleReader(fName)

% Usage: [part1 part2 ...] = mlTitleReader(FileName)
% 
% Designed to pull separate strings out of a title in the form
% "part1_part2_part3.fileextension"
% 
% Inputs: FileName - a string in the format above
% 
% Outputs: as many "parts" as there are sections of the file name
% 
% Created by ML 4.7.07

%% Checking input

if ~ischar(fName) || ~exist('fName','var')
    error([mfilename ':NoInput'],'I don''t know what to do with that kind of input');
end

%%

Blanks = findstr('_',fName);
EndStr = findstr('.',fName);
Flags.Dir = 0;
if isempty(EndStr)
    if isdir(fName)
        EndStr = length(fName)+1;
    else
        error('WTF. This isn''t a file or a directory.');
    end
end

if ~~isempty(Blanks) % replaced ~length(Blanks)
    varargout{1} = fName(1:EndStr-1);
    return    
end

if length(EndStr) > 1
    error([mfilename ':PointPres'],'This function can''t handle more than one "." in a file name');
end

Starts = [1 Blanks+1];
Fins   = [Blanks-1 EndStr-1];

for iParts = 1:length(Starts);
    varargout{iParts} = fName(Starts(iParts):Fins(iParts));
end
%nargout;
%varargout{:};
if nargout ~= length(varargout)
    error([mfilename ':Outputs'],'Outputs not matched to file name')
end
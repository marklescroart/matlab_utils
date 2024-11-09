function CC = mlFileToCell(InptFile)

% Usage: CC = mlFileToCell(InptFile)
% 
% Gives back a cell array with one cell for each line of the file read.
% 
% Inputs: InptFile
% 

fid = fopen(InptFile);
count = 1;
while(1)
    CC{count} = fgetl(fid);
    if ~ischar(CC{count}), CC=CC(1:end-1); break, end
    count = count+1;
end
fclose(fid); clear fid;
function CellOut = mlAddToCell(CellArray,ToAdd,AddInFront)

% Usage: mlAddToCell(CellArray,ToAdd [,AddInFront])
% 
% Adds a string to each element of a cell array. Probably something already
% exists to do this. Try regexprep, to start, for better, more complex ways
% to modify cell arrays.
% 
% optional input AddInFront sets whether string ToAdd is added to the front
% (default) or end of each string in the cell array. Default behavior is
% designed to facilitate adding directories to cell arrays of file names,
% for example. 
% 
% Created by ML 2009.06.09

if ~exist('AddInFront','var')
    AddInFront = true;
end
CellOut = CellArray;

for i = 1:length(CellArray)
    if AddInFront
        CellOut{i} = [ToAdd CellArray{i}];
    else
        CellOut{i} = [CellArray{i} ToAdd];
    end
end
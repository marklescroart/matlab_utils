function Idx = mlFindCellIndex(Str,Cel)

% Usage: Idx = mlFindCellIndex(Str,Cel)
% 
% Finds index (indices) at which string "str" occurs in cell "Cel"

Cc = regexp(Str,Cel);

for i = 1:length(Cc)
    TF(i) = ~isempty(Cc{i});
end

Idx = find(TF);
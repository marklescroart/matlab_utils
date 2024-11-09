function [varargout] = mlColorOpponencyBar(ptValues,nValues,Width)

% Usage: [cMap,ColBar] = mlColorOpponencyBar(ptValues,nValues,Width)

% Assuming even spacing for now btw all ptValues
% Leaving output in 0-1 range

if ~nargin
    ptValues = [0,0,1;1,1,0;1,0,0];
    nValues = [10,10]; % Must be one shorter than length of ptValues (3-1 = 2, here)
    Width = 8;
end

ColBar = [];
cMap = [];
for i = 1:size(ptValues,1)-1
    if i>1
        nValues(i) = nValues(i)+1;
    end
    Tmp = [linspace(ptValues(i,1),ptValues(i+1,1),nValues(i));...
           linspace(ptValues(i,2),ptValues(i+1,2),nValues(i));...
           linspace(ptValues(i,3),ptValues(i+1,3),nValues(i))]';
    if i>1
        cMap = [cMap;Tmp(2:end,:,:)];
    else
        cMap = [cMap;Tmp];
    end
    
    Tmp = reshape(Tmp,[nValues(i),1,3]);
    Tmp = repmat(Tmp,[1,Width,1]);
    
    if i>1
        ColBar = [ColBar;Tmp(2:end,:,:)];
    else
        ColBar = [ColBar;Tmp];
    end
end

if nargout == 1
    varargout{1} = cMap;
elseif nargout == 2
    varargout{1} = cMap;
    varargout{2} = ColBar;
end
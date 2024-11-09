function Output = mlNormalize(VM,Mode)

% usage: Output = mlNormalize(VectorOrMatrix,Mode)
% 
% Normalizes (rescales) a vector or matrix such that the values span the
% range from 0 to 1. 
% 
% Mode can be: 
% 
% 'Column' - [default] treats columns separately
% 'WholeMatrix' - treats whole matrix together. 
% 
% Created by ML ??/??/2008




if nargin<2
    Mode = 'Column';
end

if isvector(VM);
    Output = (VM-min(VM))/max(VM-min(VM));
else
    switch Mode
        case 'Column'
            % This will normalize by columns
            MinMatrix = repmat(min(VM),[size(VM,1),1]);
            Output = (VM-MinMatrix)./repmat(max(VM-MinMatrix),[size(VM,1),1]);
        case 'WholeMatrix'
            Output = (VM-min(VM(:)))/(max(VM(:)-min(VM(:))));
    end
end

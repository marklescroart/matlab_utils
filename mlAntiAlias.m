function ImOut = mlAntiAlias(ImIn,nPix)

% Usage: ImOut = mlAntiAlias(ImIn,nPix)
%
% Anti-aliases images by averaging images shifted "nPix" (default = 1)
% pixels in each of 8 directions.

% Notes: Making assumptions that edges of pictures are all the same...

if ~exist('nPix','var')
    nPix = 1;
end

Layers = size(ImIn,3);

for i = 1:Layers
    img = ImIn(:,:,i);
    alias(:,:,1) = img(:,[nPix+1:end,1:nPix]);                     % Left
    alias(:,:,2) = img(:,[1:nPix,1:end-nPix]);                     % Right
    alias(:,:,3) = img([nPix+1:end,1:nPix],:);                     % Up
    alias(:,:,4) = img([1:nPix,1:end-nPix],:);                     % Down
    alias(:,:,5) = img([nPix+1:end,1:nPix],[nPix+1:end,1:nPix]);   % Up-Left
    alias(:,:,6) = img([nPix+1:end,1:nPix],[1:nPix,1:end-nPix]);   % Up-Right
    alias(:,:,7) = img([1:nPix,1:end-nPix],[nPix+1:end,1:nPix]);   % Down-Left
    alias(:,:,8) = img([1:nPix,1:end-nPix],[1:nPix,1:end-nPix]);   % Down-Right

    ImOut(:,:,i) = mean(alias,3);
end
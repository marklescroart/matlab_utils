function mlColorShow(Col)

% Show colors saved in a struct array. Colors should be 1-255 RGB or 0-1
% RGB.
% 
% Created by ML


nColorsPerRow = 6;
FN = fieldnames(Col); 

for i = 1:length(FN); 
    cMap(i,:) = Col.(FN{i}); 
end

nColors = size(cMap,1);
nRows = ceil(nColors/nColorsPerRow);
cMapSize = mod(nColors,nColorsPerRow);

if max(cMap(:)) > 1
    cMap = cMap/255;
end

for iR = 1:nRows
    subplot(nRows,1,iR);
    if iR*nColorsPerRow > nColors
        %
        Idx = nColors-cMapSize+1:nColors;
        %image(Idx)
        %colormap(cMap);
        %set(gca,'ytick',[],'xtick',1:cMapSize,'xticklabel',FN(end-cMapSize+1:end));
    else
        Idx = [1:nColorsPerRow]+((iR-1)*nColorsPerRow);
    end
    image(Idx)
    colormap(cMap);
    set(gca,'ytick',[],'xtick',1:nColorsPerRow,'xticklabel',FN(Idx));
    mlGraphSetup_sm
end




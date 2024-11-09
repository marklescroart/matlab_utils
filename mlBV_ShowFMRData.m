function mlBV_ShowFMRData(FMRmatrix,fig_h)

if ndims(FMRmatrix) ~=3;
    error('Please use a 3-dimensional matrix for now.')
end

nSlices = size(FMRmatrix,3);
nSlicesOrig = nSlices;

nCols = floor(sqrt(nSlices));

if sqrt(nSlices) ~= nCols
    while sqrt(nSlices)~=floor(sqrt(nSlices))
        nSlices = nSlices+1;
    end
end

if nSlices >= sqrt(nSlices) * sqrt(nSlices)-1;
    nCols = sqrt(nSlices); nRows = sqrt(nSlices);
else
    nCols = sqrt(nSlices); nRows = sqrt(nSlices)-1;
end

if exist('fig_h','var')
    mlFigure(fig_h,[8,8]);
else
    fig_h = mlFigure(1,[8,8]);
end

for i = 1:nSlicesOrig;
    subplot(nRows,nCols,i);
    imshow(FMRmatrix(:,:,i),[]);
    set(gca,'Position',get(gca,'OuterPosition'))
end
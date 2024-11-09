function mlBV_ShowFMRData_Overlay(FMRmatrix,FMRmatrix2, fig_h)

% FMRmatrix2 has to be binary for now



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
    figure(fig_h);
else
    figure;
end

for i = 1:nSlicesOrig;
    subplot(nRows,nCols,i)
    
    R = FMRmatrix(:,:,i);
    G = FMRmatrix(:,:,i);
    B = FMRmatrix(:,:,i);
    imshow(FMRmatrix(:,:,i),[]);
end
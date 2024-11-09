function AllData = mlBV_GetFMRData(fName,numSlices)

% Usage: AllData = mlBV_GetFMRData(fName,numSlices)
% 
% Returns a 64 x 64 x nSlices x tTimePoints matrix of fmr data
% 
% Created by ML 2008.11.19

FMR = BVQXfile(fName);

if ~exist('numSlices','var');
    numSlices = FMR.NrOfSlices;
end

% For sub-plots:
x = 4;
y = 4;

F.plot = 0; % Do not turn this on for now - not working (as of 2008.11.17)


for SliceNum = 1:numSlices
    %Vox(:,:,:,SliceNum) = FMR.Slice(SliceNum).STCData(:,:,:);
    %AllData.STC(SliceNum).data = FMR.Slice(SliceNum).STCData;
    %fprintf('Loading Slice #%d\n', SliceNum);
    if SliceNum == 1
        h = waitbar(SliceNum/numSlices,sprintf('Loading FMR file %s',strrep(fName,'_','-')));
    else
        h = waitbar(SliceNum/numSlices,h,['Loading FMR file ' strrep(fName,'_','-')]);
    end
    if exist('mlTmp','var'); clear mlTmp; end
    try
        mlTmp(:,:,:) = FMR.Slice.STCData(:,:,:,SliceNum);
    catch
        mlTmp(:,:,:) = FMR.Slice(SliceNum).STCData(:,:,:); % TO account for earlier versions of BV
    end
    mlTmp = reshape(mlTmp,[size(mlTmp,1),size(mlTmp,2),1,size(mlTmp,3)]);
    AllData(:,:,SliceNum,:) =  mlTmp; %MySTC.STCData;

end


clear FMR;
close(h)
if F.plot
    ToShow = squeeze(mean(AllData.STC,3));

    for iPl = 1:size(ToShow,3)
        figure(1);
        subplot(x,y,iPl)
        imshow(ToShow(:,:,iPl),[]);
        axis off
        axis image
        xlabel(sprintf('Slice %.0f',iPl));

    end
end

return

%{

% Call this:
IULProj
cd LOScaleTrans/MRI/AM_01_25_08/
VTCs = mlStructExtract(dir('Main_VTCs/*.vtc'),'name');
FMRs = mlStructExtract(dir('Main_FMRs_STCs/*SC*.fmr'),'name');


VoxF = mlBV_GetFMRData(['Main_FMRs_STCs/' FMRs{1}]);


% Not equal:
length(VoxF(:)~=0)
length(VTC.VTCData(:)~=0)

%}
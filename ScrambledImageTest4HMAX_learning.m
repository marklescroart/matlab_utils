function [C2_resp_AllImage] = ScrambledImageTest4HMAX_learning(FileList, ImgSizeIndex) % in output: , Corr_C2_resp

%
% This function is used to test HMAX with scrambled images
% 
% Inputs: file list    -- the list of images you want to test
%         ImgSizeIndex -- if you want to resize the first image of the image, the number should be 1, otherwise is 0 (default) 
%              
% Ouputs: C2_resp_AllImage: a matrix with 256 rows from C2 responses
%                           and a number of columns of all of images.
%         Corr_C2_resp: a correlation coefficient matrix with #images rows
%                       and #images columns
%
% created by Xiaomin Yue at 8/1/2005
%

if nargin < 1
    disp('Please input the image file list you want to do gabor wavelet transform.');
    return;
end

if nargin < 2
    ImgSizeIndex = 0;
end


fid = fopen(FileList,'r');
NumberOfImages = 0;

while (~feof(fid))
    tmp = fgetl(fid);
    if ~isempty(tmp)
        NumberOfImages = NumberOfImages+1;
        ImageFileNames{NumberOfImages} = tmp;
    end    
end
fclose(fid);

%%----Settings for Testing --------%
patchSizes = [4 8 12 16]; 
numPatchSizes = length(patchSizes);

rot = [90 -45 0 45];
c1ScaleSS = [1:2:18];
RF_siz    = [7:2:39];
c1SpaceSS = [8:2:22];
minFS     = 7;
maxFS     = 39;
div = [4:-.05:3.2];
Div       = div;
%%--- END Settings for Testing --------%

%%creates the gabor filters use to extract the S1 layer
[fSiz,filters,c1OL,numSimpleFilters] = init_gabor(rot, RF_siz, Div);

%%reading trained patches from nature images
cPatches = load('PatchesFromNaturalImages250per4sizes','cPatches');
cPatches = cPatches.cPatches;
LengthPatches = numPatchSizes*500;


%% main body
C2_resp_AllImage = zeros(LengthPatches,NumberOfImages);
for tt=1:NumberOfImages
    tmp = double(imread(ImageFileNames{tt}));
    if ndims(tmp) > 2
        tmp = rgb2gray(tmp);
    end    
    if (ImgSizeIndex ~= 0) & (tt==1) 
        tmp = imresize(tmp,0.5);
    end    
    disp([mfilename ' >> creating C2 output of HMAX of ' ImageFileNames{tt}]);
    tmp_All_C2 = [];
    for pp = 1: numPatchSizes
         [tmpC2, tmpS2,tmpC1,tmpS1] = C2(tmp,filters,fSiz,c1SpaceSS,c1ScaleSS,c1OL,cPatches{pp});
        tmp_All_C2 = [tmp_All_C2; tmpC2]; 
    end    
    C2_resp_AllImage(:,tt) = tmp_All_C2(:); 
end

% Corr_C2_resp = corr(C2_resp_AllImage);



% [xx,yy]=meshgrid(1:NumberOfImages,1:NumberOfImages);
% Pairs = xx+yy*i;
% Pairs = triu(Pairs,1);
% Pairs = Pairs(find(real(Pairs(:))>0));
% 
% for tt=1:length(Pairs)
%    tmp = corrcoef(C2_resp_AllImage(:,real(Pairs(tt))),C2_resp_AllImage(:,imag(Pairs(tt))));
%    CorrOutput{tt} = [ImageFileNames{real(Pairs(tt))} ' <--> ' ImageFileNames{imag(Pairs(tt))} ' : ' num2str(tmp(1,2))];
%    NumCorr(tt) = tmp(1,2); 
% %    disp([mfilename ' >> correlation between ' ImageFileNames{real(Pairs(tt))}...
% %        ' and ' ImageFileNames{imag(Pairs(tt))} ' is ' num2str(tmp(1,2))]);
% end    
% 
% [tmp,RankIndex] = sort(NumCorr,2,'descend');
% for tt=1:length(Pairs)
%    disp([CorrOutput{RankIndex(tt)}]);
% end

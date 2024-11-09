% just a loop command to execute any old function

ReadFolder = 'Clothing/';

Directory = dir([ReadFolder '*.png']);

%Image = uint8(ones(256,256,length(Directory)));
for ii = 1:length(Directory)
    Image(:,:,ii) = imread([ReadFolder Directory(ii).name]);
    
    % Insert looped function here:
    
    [ImSizeXX(ii) ImSizeYY(ii) MaxDimension(ii)] = ImSize(Image(:,:,ii)); 
  
end

AvgImSizeXX = mean(ImSizeXX)
AvgImSizeYY = mean(ImSizeYY)

AvgMaxDimension = mean(MaxDimension)

MaxImSizeXX = max(ImSizeXX)
MaxImSizeYY = max(ImSizeYY)


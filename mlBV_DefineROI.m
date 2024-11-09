function ROIMask = mlBV_DefineROI(MAPFileName,nSlices,Box,T_Threshold)

% Usage: ROIMask = mlBV_DefineROI(MAPFileName,Box,T_Threshold)
% 
% 
% 
% 

% Load map file of ttest values from LOC localizer for this same subject
fprintf('Loading MAP file: %s\n', MAPFileName);

MyMAP = BVQXfile(MAPFileName);

% Default inputs: 

% Assumption of where pfs will be: (good all the time?)
if ~exist('Box','var')
    Box.Size = [64,64];
    %Define binary mask with rectangular boxes where pFs may be defined
    Box.LeftBox.MinSlice = 4;
    Box.LeftBox.MaxSlice = 11;
    Box.LeftBox.MinX = 10;
    Box.LeftBox.MaxX = 30;
    Box.LeftBox.MinY = 35;
    Box.LeftBox.MaxY = 50;

    Box.RightBox.MinSlice = Box.LeftBox.MinSlice;
    Box.RightBox.MaxSlice = Box.LeftBox.MaxSlice;
    Box.RightBox.MinX = 32 + (32 - Box.LeftBox.MaxX); %Mirror project
    Box.RightBox.MaxX = 32 + (32 - Box.LeftBox.MinX);
    Box.RightBox.MinY = Box.LeftBox.MinY;
    Box.RightBox.MaxY = Box.LeftBox.MaxY;
end

if ~exist('T_Threshold','var')
    T_Threshold = 4;
end

if ~exist('nSlices','var')
    nSlices = MyMAP.NrOfSlices;
end


%Load ttest data into MapSlice structure
MyMapMax = 0;
for SliceNum = 1:nSlices 
    MapSlice(SliceNum).data = MyMAP.Map(SliceNum).Data;

    temp = max(max(MapSlice(SliceNum).data));
    if temp > MyMapMax
        MyMapMax = temp;
    end
end

% Note: need max and min from AllData
% 
% %Display Map ttest data
% figure(1);
% set(gcf,'name','MAP ttest data');
% subplot(4,4,1); %assumes 16 slices
% for SliceNum = 1:NumOfSlicesToLoad
%     subplot(4,4,SliceNum);
%     imshow(MapSlice(SliceNum).data, [0 MyMapMax]);
% 
%     MyStr = sprintf('Slice %d', SliceNum);
%     title(MyStr);
% 
% end


%Create binary Mask from t map data
MyStr = sprintf('Creating binary mask from MAP file. T_Threshold = %0.5g', T_Threshold);
disp(MyStr);
for SliceNum = 1:nSlices
    MyTThresholdMask(SliceNum).BinaryData = (MyMAP.Map(SliceNum).Data >= T_Threshold);
end


%Display this ROI on volume #1 of the FMR data and create final ROIMask
%figure(2);
%set(gcf,'name','ROI display');
%subplot(4,4,1); %assumes 16 slices
%for VolumeNum = 1:1 %MyFMR.NrOfVolumes
% VolumeNum = 1;
for SliceNum = 1:nSlices
    %subplot(4,4,SliceNum);

    %CurrentData = double(AllData.STC(SliceNum).data(:,:,VolumeNum))/double(MyMax);

    for i = 1:Box.Size(1) %MyFMR.ResolutionX
        for j=1:Box.Size(2) %MyFMR.ResolutionY
            ROIMask(SliceNum).BinaryData(i,j) = 0;

            if (IsInABox(Box,i,j,SliceNum) > 0.5) && (MyTThresholdMask(SliceNum).BinaryData(i,j) > 0.5)
                %MyPicture(i,j,1) = CurrentData(i,j);
                %MyPicture(i,j,2) = 0;
                %MyPicture(i,j,3) = 0;
                ROIMask(SliceNum).BinaryData(i,j) = 1; %Only those voxels that are above the T threshold and in the boxes
            elseif (IsInABox(Box,i,j,SliceNum) > 0.5)
                %MyPicture(i,j,1) = 0;
                %MyPicture(i,j,2) = 0;
                %MyPicture(i,j,3) = CurrentData(i,j);
            elseif (MyTThresholdMask(SliceNum).BinaryData(i,j) > 0.5)
                %MyPicture(i,j,1) = 0;
                %MyPicture(i,j,2) = CurrentData(i,j);
                %MyPicture(i,j,3) = 0;
            else
                %MyPicture(i,j,1) = CurrentData(i,j);
                %MyPicture(i,j,2) = CurrentData(i,j);
                %MyPicture(i,j,3) = CurrentData(i,j);
            end
        end
    end

    %imshow(MyPicture);


    %imshow(AllData.STC(SliceNum).data(:,:,VolumeNum), [MyMin MyMax]);

    %if SliceNum == 1
    %    MyStr = sprintf('Vol %d, Slice %d',VolumeNum, SliceNum);
    %    title(MyStr);
    %else
    %    MyStr = sprintf('Slice %d', SliceNum);
    %    title(MyStr);
    %end
end

% if you want to plot ROI: 
nSlices = 20; X = []; Y = []; Z = []; for iSl = 1:nSlices; [x,y] = find(ROIMask(iSl).BinaryData); X = [X;x]; Y = [Y;y]; Z = [Z;iSl*ones(length(x),1)]; end


function IsInside = IsInABox(Box,x,y,SliceNum)


% global LeftBox;
% global RightBox;


IsInside = 0;
if (SliceNum >= Box.LeftBox.MinSlice) && (SliceNum <= Box.LeftBox.MaxSlice) && (x >= Box.LeftBox.MinX) && (x <= Box.LeftBox.MaxX) ...
        && (y >= Box.LeftBox.MinY) && (y <= Box.LeftBox.MaxY)
    IsInside = 1;
end

if (SliceNum >= Box.RightBox.MinSlice) && (SliceNum <= Box.RightBox.MaxSlice) && (x >= Box.RightBox.MinX) && (x <= Box.RightBox.MaxX) ...
        && (y >= Box.RightBox.MinY) && (y <= Box.RightBox.MaxY)
    IsInside = 1;
end


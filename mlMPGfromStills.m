function mlMPGfromStills(mpgName,FPIm,fDir,mSize,fType)

% Usage: mlMPGfromStills(mpgName,FPIm [,fDir,mSize,fType])
%
% Creates an mpg file with mpgwrite (downloaded from matlab file central)
%
% Inputs:
%
% mpgName = name of output file (with or without ".mpg" at end)
%    fDir = file directory - by default, reads from "ImageDirectory/" in this
%           folder. Alternately, you can use a cell array of image file
%           names. This is useful if you have images that repeat. 
%    FPIm = frames per IMAGE (note: currently mpeg frame rate is fixed at 
%           30 frames per second). Can be a scalar (all images shown for
%           the same number of frames) or a vector, with one value per
%           image incorporated into the movie. 
%   mSize = size of movie (defaults to first image size) - in the form
%           [height width]
%   fType = image type for raw images (reads image type if not specified -
%           please use all same type of image (all jpeg, all black and white, etc)
%
% Examples:
% 
% For an RSVP sequence of 100 images appearing for 100 ms each:
%   mlMPGfromStills('RSVPmovie.mpg',3,'~/Documents/Images/RSVPdirectory/')
% 
% For a replay of an experiment with 200 ms image presentations followed by
% 800 ms fixation intervals: 
%   fNm = mlStructExtract(dir('Frame*.png'),'name'); % gets all image names in this directory in the form "Frame<xxx>.png"   
%   fDir = cell(length(fNm)*2,1);
%   fDir(1:2:end) = fNm;
%   fDir(2:2:end) = {'Fixation.png'}; % Relies on an image in this directory called "Fixation.png"   
%   FPIm = repmat([6,24]',length(fNm),1);
%   mlMPGfromStills('ExpReplay.mpg',FPIm,fDir)
% 
% Created by ML 4.1.09


% NOTE: mpeg frames per second seems fixed at 30. Might be a way to change
% this with some more effort (at least to 25, if need be).


% Dealing with inputs:
if ~exist('fDir','var')||isempty(fDir)
    fDir = 'ImageDirectory';
end

if ~exist('mSize','var')
    mSize = [];
end


% Movie making:
if iscell(fDir) && length(fDir)>1
    ImNm = fDir;
else
    if ~strcmp(fDir(end),filesep)
        fDir = [fDir filesep];
    end
    ImNm = mlStructExtract(dir([fDir '*' fType]),'name');
end

if ~exist('fType','var')||isempty(fType)
    fType = 'png';
%     % clumsy...
%     Cc = regexp(ImNm,'(?<=.)[a-z,A-Z]*','match');
%     for i = 1:length(Cc)
%         if ~isempty(Cc{i})
%             fType = Cc{i}{2};
%         end
%     end
end


Ct = 1;

if length(FPIm)==1;
    CtTot = FPIm*length(ImNm);
else
    CtTot = sum(FPIm);
end


for iIm = 1:length(ImNm)
    % Read alpha layer of png images separately, if it exists:
    if iscell(fDir)
        ToRead = fDir{iIm};
    else
        ToRead = [fDir ImNm{iIm}];
    end
    
    if strcmp(fType,'png')
        [TmpIm,map,alph] = imread(ToRead);
    else
        TmpIm = imread(ToRead);
    end
    
    Ss = size(TmpIm);
    % make into RGB image if it's not:
    if Ss(3) == 1
        TmpIm = repmat(TmpIm,[1,1,3]);
    end
    if isempty(mSize) && iIm == 1
        mSize = size(TmpIm);
        mSize = mSize(1:2);
    end
    if any(Ss(1:2) ~= mSize)
        warning([mfilename],'Resizing image %3d - different from specified size or other images',iIm);
        TmpIm = imresize(TmpIm,mSize);
    end

    % convert image to movie frame
    if length(FPIm) == 1;
        nFrames = FPIm;
    else
        nFrames = FPIm(iIm);
    end
    
    for iFPIm = 1:nFrames
        F(Ct) = im2frame(TmpIm);
        Ct = Ct+1;
    end
    
    PctDone = Ct/CtTot;
    if mod(round(PctDone*100),10)<2 % That is: every 10% 
        if ~exist('hWB','var')
            hWB = waitbar(PctDone,'Setting up Frames...');
        else
            hWB = waitbar(PctDone,hWB,'Setting up Frames...');
        end
    end
end

hWB = waitbar(PctDone,hWB,'Calling "mpgwrite"...');

mpgwrite(F,[],mpgName,[1, 1, 1, 1, 10, 8, 10, 25]);


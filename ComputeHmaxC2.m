function C2res = ComputeHmaxC2(Im)

% Usage: C2res = ComputeHmaxC2(Im)
%
% Compute C2 layer - i.e., final output of Hmax by T. Serre's 
% 
% Modified from T. Serre's (old) code by ML on 2009.08.19



% This is an old implementation - think about doing a new one!
HmaxPath = '/Users/Work/Code/StandardModelSerre/';
Porig = addpath(HmaxPath);
addpath('/Applications/MATLAB74/MarkCode/ImageManipulation/');

try

    %F = F(2);
    %
    %for j = 1: length(F)

        %Im = imread([Root F{j}]);

        if size(Im,3) >1
            Im = rgb2gray(Im);
        end

        ImHmax = double(MakeImageSquare(Im,128,128))/255;

        cImages{1} = ImHmax;
    %end
    
    % use Pre-computed patches computed from natural images
    READPATCHESFROMFILE = 1; 

    % other sizes might be better, maybe not; all sizes are required
    patchSizes = [4 8 12 16]; 

    numPatchSizes = length(patchSizes);

    % below the c1 prototypes are extracted from the images/ read from file
    if ~READPATCHESFROMFILE
        T.C1Go = GetSecs;
        % more will give better results, but will take more time to compute
        numPatchesPerSize = 250; 
        
        % fix: extracting from positive only
        cPatches = extractRandC1Patches(cI{1}, numPatchSizes, ...
            numPatchesPerSize, patchSizes); 

        T.C1Fin = GetSecs;
        fprintf(1,'%.2f seconds spent calculating C1 layer\n',T.C1Fin-T.C1Go);
    else
        fprintf('reading patches\n');
        cPatches = load('PatchesFromNaturalImages250per4sizes','cPatches');
        cPatches = cPatches.cPatches;
    end


    %----Settings for Testing --------%
    rot = [90 -45 0 45];        % different orientations we're using
    c1ScaleSS = [1:2:18];       % Frequency Bands (9 - we're counting by 2s)
    RF_siz    = [7:2:39];       % Particular scales we're using - this will determine overlap of RFs
    c1SpaceSS = [8:2:22];       % Pooling?
    minFS     = 7;              % Frequency Band?
    maxFS     = 39;             % Frequency Band?
    div = [4:-.05:3.2];         % weight (for soft max operation?)
    Div       = div;
    %--- END Settings for Testing --------%

    fprintf(1,'Initializing gabor filters -- full set...');
    %creates the gabor filters use to extract the S1 layer
    [fSiz,filters,c1OL,numSimpleFilters] = init_gabor(rot, RF_siz, Div);
    fprintf(1,'done\n');

    %The actual C2 features are computed below for each one of the training/testing directories
    T.C2Go = GetSecs;

    C2res = extractC2forcell(filters,fSiz,c1SpaceSS,c1ScaleSS,c1OL,cPatches,cImages,numPatchSizes);
    %C2res = extractC2forcell(filters,fSiz,c1SpaceSS,c1ScaleSS,c1OL,cPatches,cImages,numPatchSizes);

    T.C2Fin = GetSecs;
    fprintf(1,'%.2f seconds spent calculating C2 layers\n',T.C2Fin-T.C2Go);


catch
    mlErrorCleanup;
    fprintf('Resetting path...\n\n')
    path(Porig);
    rethrow(lasterror);
end
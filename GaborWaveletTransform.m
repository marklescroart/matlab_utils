function [JetsMagnitude, JetsPhase, GridPosition] = GaborWaveletTransform(Im,GridSize,Sigma)

% Usage: [JetsMagnitude, JetsPhase, GridPosition] = GaborWaveletTransform(Im,GridSize,Sigma)
%
% The goal of this function is to transform a image with gabor wavelet
% method, and then convultion values at limited positions of the image
% will be choosen as output
%
% Inputs to the function:
%   Im                  -- The image you want to process with this
%                          function. Must be square, 128x128 or 256x256
%   GridSize            -- If input is 0, grid size is 10*10 (default);
%                          If input is 1, grid size would be the image size
%                          itself (128*128 or 256*256)
%   Sigma               -- control the size of Gaussion envelope
%
% Outputs of the functions:
%   JetsMagnitude       -- Gabor wavelet transform magnitude
%   JetsPhase           -- Gabor wavelet transform phase
%   GridPosition        -- postions sampled
%
% Created by Xiaomin Yue 7/25/2004
%
% Modified by ML 2009.08.06
%

if nargin < 1
    error('Please input the image you want to do gabor wavelet transform.');
end

if ~exist('GridSize','var')
    GridSize = 0;
end

if ~exist('Sigma','var')
    Sigma = 2*pi;
end

% Double-check for square image (must be square)
[SizeX,SizeY] = size(Im);
if (SizeX~=SizeY)
    error('The image has to be squared. Please try again');
end


% FFT of the image
Im = double(Im);
ImFreq = fft2(Im);

% Generate the grid
if SizeX==256
    if GridSize == 0
        RangeXY = 40:20:220;
    else
        RangeXY = 1:256;
    end
    [xx,yy] = meshgrid(RangeXY,RangeXY);
    Grid = xx + yy*i;
    Grid = Grid(:);
elseif SizeX==128
    if GridSize == 0
        RangeXY = 20:10:110;
    else
        RangeXY = 1:128;
    end
    [xx,yy] = meshgrid(RangeXY,RangeXY);
    Grid = xx + yy*i;
    Grid = Grid(:);
else
    error('The image has to be 256*256 or 128*128. Please try again');
end
GridPosition = [imag(Grid) real(Grid)];

% setup the paramers
nScale = 1; nOrientation = 8;
xyResL = SizeX; xHalfResL = SizeX/2; yHalfResL = SizeY/2;
kxFactor = 2*pi/xyResL;
kyFactor = 2*pi/xyResL;

% setup space coordinate
[tx,ty] = meshgrid(-xHalfResL:xHalfResL-1,-yHalfResL:yHalfResL-1);
tx = kxFactor*tx;
ty = kyFactor*(-ty);

% initiallize useful variables
JetsMagnitude  = zeros(length(Grid),nScale*nOrientation);
JetsPhase      = zeros(length(Grid),nScale*nOrientation);

for LevelL = 0:nScale-1
    k0 = (pi/2)*(1/sqrt(2))^LevelL;
    for DirecL = 0:nOrientation-1
        kA = pi*DirecL/nOrientation;
        k0X = k0*cos(kA);
        k0Y = k0*sin(kA);
        %% generate a kernel specified scale and orientation, which has DC on the center
        FreqKernel = 2*pi*(exp(-(Sigma/k0)^2/2*((k0X-tx).^2+(k0Y-ty).^2))-exp(-(Sigma/k0)^2/2*(k0^2+tx.^2+ty.^2)));
        
        %figure; imshow(FreqKernel);
        %drawnow;
        %% use fftshift to change DC to the corners
        FreqKernel = fftshift(FreqKernel);

        %% convolute the image with a kernel specified scale and orientation
        TmpFilterImage = ImFreq.*FreqKernel;
        %% calculate magnitude and phase
        TmpGWTMag   = abs(ifft2(TmpFilterImage)) ;
        TmpGWTPhase = angle(ifft2(TmpFilterImage));
        %% get magnitude and phase at specific positions
        tmpMag = TmpGWTMag(RangeXY,RangeXY);
        tmpMag = (tmpMag');
        JetsMagnitude(:,LevelL*nOrientation+DirecL+1)=tmpMag(:);
        tmpPhase = TmpGWTPhase(RangeXY,RangeXY);
        tmpPhase = (tmpPhase')+ pi;
        JetsPhase(:,LevelL*nOrientation+DirecL+1)=tmpPhase(:);
    end
end

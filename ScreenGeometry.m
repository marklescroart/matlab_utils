% Trying to figure out screen geometry of USC's MRI screen

% General screen considerations: 

% Scanner Projection System Measurements:
DistToScrCm = 85; % Previously 78;
ScrWdCm = 35.5;
HalfScrWdCm = ScrWdCm/2;

% Screen Size (Scanner Projector) in Pixels:
ScrWdPix = 1024;
HalfScrWdPix = ScrWdPix/2;
ScrHtPix = 768;

CmPerPix = ScrWdCm/ScrWdPix; % = .035
DistToScrPix = ceil(DistToScrCm/CmPerPix); % = 2229


% For the Pixs nearest to the Fov: 
PixFromFov = 1;

FovDegPerPix = atand(PixFromFov/DistToScrPix)
FovPixPerDeg = FovDegPerPix^(-1)

% For the Pixs nearest to the Scr's edge:
PixNearPeriph1 = HalfScrWdPix-1;
PixNearPeriph2 = HalfScrWdPix;

PeriphDegPerPix = atand(PixNearPeriph2/DistToScrPix) - atand(PixNearPeriph1/DistToScrPix)
PeriphPixPerDeg = PeriphDegPerPix^(-1)

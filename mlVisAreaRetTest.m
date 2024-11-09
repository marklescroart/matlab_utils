% First shot at plotting visual field position for each voxel in an ROI

aa = importdata('DJB_LH_V2Vent_Test.txt'); % 'V2_Test_Wedge.txt'); %
VoxW = aa.data;
bb = importdata('DJB_LH_V2Vent_Test_RING.txt');
VoxR = bb.data;
PeakPhaseW = zeros(length(VoxW),1); 
PeakPhaseR = zeros(length(VoxR),1); 

if length(VoxW) ~= length(VoxR)
    error('Mismatched pair of ROI data')
end


nBlksWedge = 12; % Blocks (i.e., periods of rotation) per run
nBlksRing = 14;
PerWedge = 32;   % Period of rotation
PerRing = 24;
lagg = 8;   % seconds lag at beginning and end

degPerTR = 360/PerWedge;

% Attempt to align polar graph so it matches wedge position:
Conv = 180-degPerTR:degPerTR:360+180-2*degPerTR;
Conv = mod(Conv,360);
ConvRad = deg2rad(Conv);

%%% ??? APPROXIMATION! ??? %%%
RingConv = 12/24:12/24:12;

for iVox = 1:length(VoxW);
    ThisVoxW = VoxW(:,iVox);
    ThisVoxR = VoxR(:,iVox);
    ThisVoxW = ThisVoxW(1+lagg:end-lagg);
    ThisVoxR = ThisVoxR(1+lagg:end-lagg);
    
    %%% Wedge:
    SepBlksW = zeros(nBlksWedge,PerWedge);
    for iBlk = 1:nBlksWedge
        index = 1+(iBlk-1)*PerWedge:PerWedge*iBlk;
        SepBlksW(iBlk,:) = ThisVoxW(index);
    end
    
    BlkAvg = mean(SepBlksW);
    %figure(iVox); plot(BlkAvg); %%%???%%% Kill this line!
    
    PeakWedge = (find(BlkAvg == max(BlkAvg)));
    if length(PeakWedge) > 1;
        PeakWedge = min(PeakWedge);
    end
    
    PeakPhaseW(iVox) = ConvRad(PeakWedge);
    
    %%% Ring:
    SepBlksR = zeros(nBlksRing,PerRing);
    for iBlk = 1:nBlksRing
        index = 1+(iBlk-1)*PerRing:PerRing*iBlk;
        SepBlksR(iBlk,:) = ThisVoxR(index);
    end
    
    BlkAvg = mean(SepBlksR);
    %figure(iVox); plot(BlkAvg); %%%???%%% Kill this line!
    
    PeakRing = (find(BlkAvg == max(BlkAvg)));
    if length(PeakRing) > 1;
        PeakRing = min(PeakRing);
    end
    
    PeakPhaseR(iVox) = RingConv(PeakRing);
    
end

%polar(PeakPhaseW,rand(length(PeakPhaseW),1),'r*');
polar(PeakPhaseW,PeakPhaseR/12,'r*');
set(gca,'View',[270,90])

% This is going to be off, because the starting angle isn't exact, but it's
% good enough for now.

% Tmp = WedgeNo*360/32;
% Phase = mod(Tmp+190,360);
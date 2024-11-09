function NewET = mlFilterETData(sh,fName,sf,filterdef)

% Usage: mlFilterETData(fName,sf,filterdef)
% 
% 
% 
% 
% 
% Created by ML 10.22.07
% Modified by ML 10.22.07

% "convolution theorem" if you plug the convolution formula into the 
% freqz
% difference equation 
% I want a " linear phase filter "
% firls (fir filter, least-square fit)

% Filter in matlab runs the whole difference equation (for IIR filters,
% e.g.)

% 1 = half the length of my sampling frequency... (??) 

% B is causal, A is feedback
%
% dd = zeros(2000,1);
% dd(1000) = 1;
% xyz = filter(b,a,dd);
% to plot in freq space: plot(log(abs(fft(xyz))+1))
% 
% faster than 50-60 (63) hertz is garbage (no saccade will be faster than that)
% slower than (.2) is garbage (too slow for anything I'm interested in)
% 



%% Inputs:
if ~exist('fName','var')||isempty(fName)
    fName = 'VV_EyeData_Run3real.ceyeS';
end
if ~exist('sf','var')
    sf = 240;
end
if ~exist('filterdef','var')
    ff = 1/960; % = .25/sf?
    filterdef = {[0 ff-.0001 ff+.0001 1],[0 0 1 1]};
    %filterdef = {[0 .05/sf .5/sf 1],[0 0 1 1]};
end
if ~exist('sh','var')
    sh = 128; % i.e., number of taps, and also phase SHift - try also 256? started with 5 only
end

ET = importdata(fName);
Pos = TileFigs(3,2);

Idx = sf*24+1:length(ET)-sf*12; % Data without first 24 or last 12 seconds
XX = ET(Idx,1);
YY = ET(Idx,2);
%DB = ET(Idx,4); % i.e., what each time point was labeled, according to Dave Berg's "markEye.m" program.

% Creating timecourse variable - this will be in normalized time units (1.0 = max signal length)
t = (1:length(YY))/length(YY);
hh(1) = figure('Position',Pos(1,:));
plot(XX,YY,'.'); mlScreenFig([1024 768]); title('Original Signal');


hh(2) = figure('Position',Pos(2,:));
whitebg([1 1 1]);

subplot(211); plot(t,YY); title('Orginal Y signal:'); ylim([0 768])
subplot(212); plot(t,YY); title('Original Y signal overlaid with filtered signal:'); ylim([0 768])

hh(3) = figure('Position',Pos(3,:));
plot(t,log(abs(fft(YY))))
title('Original Fourier Spectrum (blue) and filtered spectrum (red)')

% creating filter:
[b a] = firls(sh,filterdef{:});

% filtering:
ny = filter(b,a,YY);%+mean(YY);
nx = filter(b,a,XX);%+mean(XX);

% accounting for phase delay:
nny = zeros(1,length(ny))*mean(ny);%ones(1,length(ny))*mean(ny);
nny(1:end-sh/2+1) = ny(sh/2:end); %
%nny(sh:end) = ny(1:end-(sh-1)); 

nnx = zeros(1,length(nx))*mean(nx);%ones(1,length(nx))*mean(nx);
nnx(1:end-sh/2+1) = nx(sh/2:end); %nnx(sh:end) = nx(1:end-(sh-1));

% llim = 100;
% figure(2); subplot(212); xlim([1 llim]); subplot(211); xlim([1 llim]);

%% Plotting filter results:
cPos = mlCirclePos(100,8);
%Elabel = 0; % 0 = Fixation, 1 = Saccade, 2 = Blink, 3 = Blink/Saccade, 4 = Smooth Pursuit, 5 = Mislabel
figure(hh(1));
hold on; 
%plot(XX(DB==Elabel),nn(DB==Elabel),'r.'); % not taking multiple classifications into consideration
plot(nnx,nny,'r.'); 
plot(cPos(:,1),cPos(:,2),'g*');
hold off;

figure(hh(2)); subplot(212);
hold on; plot(t,nny,'r'); hold off;

figure(hh(3)); 
hold on; plot(t,log(abs(fft(nny))),'r'); hold off;


% figure; plot(t,s2+s3); hold on; plot(t,nn,'y');
fvtool(b); 
ylim([-2 1]);



% n = filter(b,a,YY);%+mean(YY);
% 
% % accounting for phase delay:
% nn = zeros(1,length(n)); 
% nn(sh:end) = n(1:end-(sh-1)); 
% 
% 
% 
% 
% %% Plotting filter results:
% cPos = mlCirclePos(100,8);
% Elabel = 0; % 0 = Fixation, 1 = Saccade, 2 = Blink, 3 = Blink/Saccade, 4 = Smooth Pursuit, 5 = Mislabel
% figure(hh(1));
% hold on; 
% %plot(XX(DB==Elabel),nn(DB==Elabel),'r.'); 
% plot(XX,nn,'r.'); 
% plot(cPos(:,1),cPos(:,2),'g*');
% hold off;
% 
% figure(hh(2)); subplot(212);
% hold on; plot(t,nn,'r'); hold off;
% 
% figure(hh(3)); 
% hold on; plot(t,log(abs(fft(n))),'r'); hold off;
% 
% 
% % figure; plot(t,s2+s3); hold on; plot(t,nn,'y');
% fvtool(b);
% 
% NewET = zeros(length(XX),4);
% NewET(:,1) = XX;
% NewET(:,2) = nn;
% %NewET(:,4) = DB;
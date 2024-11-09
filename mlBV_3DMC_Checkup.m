function mlBV_3DMC_Checkup(ByRun,FixTo)

% Usage: mlBV3DMC_Checkup(fix)
%
% Displays Brain Voyager Motion Correction plot (must be called from within
%       a directory that contains 3DMC .rtc files)
% If optional input "fix" is set to 1, then the y axes of the 3DMC plots
% will be fixed to 3mm up and down.
%
% NOTE: Requires bvqxtools (http://wiki.brainvoyager.com/BVQXtools) to run
%
% Created by ML 4.23.07

if ~exist('FixTo','var')
    fix = false;
else
    fix = true;
end
if ~exist('ByRun','var');
    ByRun = true;
end
WhatData = 'RTCMatrix';

RTCdir = dir('*3DMC.rtc');
if isempty(RTCdir)
    % Second attempt - try 'sdm' files instead of 'rtc' files
    RTCdir = dir('*3DMC*sdm');
    WhatData = 'SDMMatrix';
end

if isempty(RTCdir)
    error([mfilename ':noRTCs'],['Please add this function to the path (if you haven''t already) and run it \n' ...
        'from a directory that contains the 3DMC files you wish to inspect.'])
end

nRTCs = length(RTCdir);
% TileFigs(nRTCs);
[X,Y] = mlFindSquareishDimensions(nRTCs);
Pos = mlTileAxes(X,Y,[0,0,1,.85]);
mlFigTitle(1,sprintf('Subject %s 3DMC Results',RTCdir(1).name(1:2)),[0,.85,1,.15]);

for ii = 1:nRTCs
    %hh(ii) = figure(ii);
    hh = mlFigure(1,[9,9]); 
    axes('OuterPosition',Pos(ii,:));
    motparam = BVQXfile(RTCdir(ii).name);
    YLim = max([abs(floor(min(motparam.(WhatData)))),abs(ceil(max(motparam.(WhatData))))]);

    % Adding a background gaussian for a reasonable range of motion:
    Height = 200;
    Width = 300;
    BG = .5*mlNormalize(normpdf(linspace(-YLim,YLim,Height),0,.75));
    Im = repmat(BG',[1,Width]);
    Im = gray2ind(Im,255);
    cMap = repmat(linspace(0,1,255),3,1)';
    colormap(cMap);
    image(1:motparam.NrOfDataPoints,-YLim:.01:YLim,Im);
    hold on;
    
    if ByRun
        ToPlot = motparam.(WhatData)-repmat(motparam.(WhatData)(1,:),size(motparam.(WhatData),1),1);
    else
        ToPlot = motparam.(WhatData);
    end

    plot(1:motparam.NrOfDataPoints,ToPlot);

    hold off;

    % Accounting for head movements greater than 1.5 mm: (bad news!)
    if YLim > 1.5 && ~fix
        set(gca,'ylim',[-YLim YLim],'linewidth',1);
    elseif YLim < 1.5 && ~fix
        set(gca,'ylim',[-1.5 1.5],'linewidth',1);
    else
        set(gca,'ylim',[-FixTo FixTo],'linewidth',1);
    end
    %set(hh(ii),'Name',RTCdir(ii).name);
    %title('Brain Voyager 3D Motion Correction Plot');
    title(strrep(RTCdir(ii).name,'_',' '));
    xlabel('Time Points');
    ylabel('Head motion (mm)');
    mlGraphSetup_sm;
    %legend(motparam.PredictorNames(:));

end
whitebg(hh,[0 0 0]);
set(hh,'inverthardcopy','off');
print('-f1','-dpng','MotionCorrectionResult')
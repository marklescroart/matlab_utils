function varargout = mlBV_PRTPlot(PRTfile,Plot)

% Usage: TimeCourse = mlBVPlotPRT(PRTfile)
% 
% Plots Timecourse of PRT file as Brain Voyager does - or, alternately,
% returns a [timepoint x condition] timecourse matrix for when each 
% condition was on
% 
% Inputs: PRTfile - string for which protocol file you want to read
%         Plot - Flag (1 or 0) for whether to plot the PRT or just return
%               the timecourse
% 
% Created by ML 10.20.07

if ischar(PRTfile)
    if strcmp(PRTfile(end-2:end),'prt')
        PRT = BVQXfile(PRTfile);
    else
        load(PRTfile)
    end
else
    PRT = PRTfile;
end
if ~exist('Plot','var')
    Plot = true;
end

for iMax = 1:PRT.NrOfConditions;
    try 
        MM(iMax,:) = max(PRT.Cond(iMax).OnOffsets);
    catch
        MM(iMax,:) = 0;
    end
end

TC = zeros(max(max(MM)),PRT.NrOfConditions);
PRTIm = 127*ones(100,max(max(MM)),3); %2*max...

for iCond = 1:PRT.NrOfConditions
    OnOff = PRT.Cond(iCond).OnOffsets;
    for iOnOff = 1:PRT.Cond(iCond).NrOfOnOffsets
        TC(OnOff(iOnOff,1):OnOff(iOnOff,2),iCond) = 1; 
    end
    if PRT.Cond(1).NrOfOnOffsets > 1
        for iCol = 1:3
            PRTIm(:,find(TC(:,iCond)),iCol) = PRT.Cond(iCond).Color(iCol);
        end
    else
        hold on; plot(TC(:,iCond),'color',PRT.Cond(iCond).Color/255); hold off;
    end
end

if PRT.Cond(1).NrOfOnOffsets > 1 && Plot
    Sz = get(0,'ScreenSize');
    Xx = round(.8*Sz(3));
    Yy = round(.4*Sz(4));
    hh = figure('Position',[round(.1*Sz(3)) round(.9*Sz(4)) Xx Yy]);
    image(PRTIm/255);
    Ticks = [0:20:length(PRTIm)];

    set(gca,'ytick',[],'xtick',Ticks);
end

if nargout
    varargout{1} = TC;
end

% legend(PRT.ConditionNames)
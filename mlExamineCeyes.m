function mlExamineCeyes(fName,ToShow,sf)

% Usage: mlExamineCeyes(fName,ToShow,sf)
%
%
%
%

%fixation:                   0 blue
%saccade:                    1 green
%blink/Artifact:             2 red
%Saccade during Blink:       3 green .-
%smooth pursuit:             4 magenta
%drift/misclassification:    5 black

if ~exist('ToShow','var')
    ToShow = {'Fixation','Saccade','Blink/Artifact','Sac during blink','Smooth Pursuit','Drift/Misclassification'};
end
if ~exist('ScrSize','var')
    ScrSize = [1920 1080];
end
if ~exist('sf','var');
    sf = 240;
end

Flag.Clip = 0;

ET = importdata(fName);
if Flag.Clip
    ETL = ET;
    ET = ET(24*sf:end-240*12,:);
end

XX = ET(:,1);
YY = ET(:,2);
LL = ET(:,4);

mlFigure(1,[ScrSize]/100)
% plot(XX,YY,'y.')
% mlScreenFig([1024 768]);
title('Eye Trace');

DBLabels = {'Fixation','Saccade','Blink/Artifact','Sac during blink','Smooth Pursuit','Drift/Misclassification'};
LineStyles = {'b.','r.','k.','y.','c.','m.'};
mlScreenFig([ScrSize],255);

for iLab = 1:length(ToShow)

    ThisLabel = mlFindCellIndex(DBLabels,ToShow{iLab});
    P = ThisLabel-1;
    hold on;
    if any(LL==P)
        h(iLab) = plot(XX(LL==P),YY(LL==P),LineStyles{ThisLabel});
    end
    hold off;
    %title(['Without first 24 seconds, all points labeled ' DBLabels{iLab}]);
    %legend(DBLabels)

end
hold on; 
plot(ScrSize(1)/2,ScrSize(2)/2,'k+'); 
hold off;
legend(h(h>0),DBLabels(h>0));

figure(2);
for iTag = 1:5;
    ThisTag = iTag-1; 
    TagCol = LineStyles{iTag};
    subplot(211);
    hold on;
    plot(find(LL==ThisTag)/sf,XX(LL==ThisTag),TagCol);
    hold off;
    subplot(212);
    hold on;
    plot(find(LL==ThisTag)/sf,YY(LL==ThisTag),TagCol);
    hold off; 
end
subplot(211); title('Eye Position: X'); ylim([1,ScrSize(1)])
hold on; 
plot(xlim,[ScrSize(1)/2 ScrSize(1)/2],'k--');
hold off;
mlGraphSetup_sm;
subplot(212); 
title('Eye Position: Y'); 
ylim([1,ScrSize(2)])
hold on;
plot(xlim,[ScrSize(2)/2 ScrSize(2)/2],'k--'); 
hold off
mlGraphSetup_sm;
%legend(h(h>0),DBLabels(h>0));
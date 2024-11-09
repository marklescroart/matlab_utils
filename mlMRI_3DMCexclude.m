% function mlMRI_3DMCexclude(Threshold,HistogramPlot,PrintName)% Temp 3DMC exclusion criterion

if ~exist('Threshold','var')
    Threshold = .5;
end
if ~exist('PrintName','var')
    fid = 1;
else
    fid = fopen(PrintName,'w');
end
if ~exist('HistogramPlot','var')
    HistogramPlot = 1;
end

aa = mlStructExtract(dir('*.dat'),'name');
LOLoc = grep(aa,'LOLoc');
Main = grep(aa,'-v','LOLoc');

Pos = TileFigs(length(Main));

for iMain = 1:length(Main);
    MC = importdata(Main{iMain});
    
    [X,Y] = find(abs(MC)>Threshold);
    FF = find(abs(MC))>Threshold;

    X = [1; X]; %YY = Y(idx);
    [XX,idx] = sort(X); %YY = Y(idx);
    diffs = XX(2:end)-XX(1:end-1);
    
    DIdx = find(diffs>1);
    if ~isempty(DIdx)||~isempty(Y)
        if HistogramPlot
            figure('Position',Pos(iMain,:));
            hist(XX,20); title(sprintf('Run %.0f',iMain)); xlim([0 length(MC)+30]);
        end
        fprintf(fid,'Run %.0f has %.0f head movements over %.1f mm\n',iMain,length(DIdx),Threshold);
    end
end

% hold on; plot(XX,MC(FF),'g*'); hold off

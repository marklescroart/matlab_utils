
ThresholdPct = 10;
nTimePointsOut = 10;
matf = mlStructExtract(dir('Run*_PctOutliers.mat'),'name');

for ii = 1:length(matf)
    load(['Run' num2str(ii) '_PctOutliers.mat'])
    ToCutPre = find(PctBad>ThresholdPct);

    Temp = zeros(length(ToCutPre),nTimePointsOut);

    for iCut = 1:length(ToCutPre);
        Temp(iCut,:) = ToCutPre(iCut):ToCutPre(iCut)+9;
    end

    ToCut = unique(Temp(:));
    figure;
    plot(PctBad);
    whitebg([0 0 0]);
    hold on; plot(ToCut,20*ones(length(ToCut),1),'r.'); hold off
    save(sprintf('Run%.0f_%.0fPctOutliers_Thresh%.0fPct.mat',ii,100*length(ToCut)/length(PctBad),ThresholdPct),'PctBad','ToCut')
end
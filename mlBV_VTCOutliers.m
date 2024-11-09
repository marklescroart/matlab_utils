function mlBV_VTCOutliers(vtcfile,voifile,voiname,PctThresh,STDThresh,CutNPoints)

% Usage: mlBV_VTCOutliers(vtcfile,voifile,voiname [,PctThresh] [,STDThresh] [,CutNPoints])
% 
% Creates an index as long as the VTC file for how many 


try
    RunNum = regexp(vtcfile,'(?<=Run)[0-9]*','match');
    RunNum = RunNum{1};
catch % for idiot old ML code
    RunNum = regexp(vtcfile,'(?<=Seq)[0-9]*','match');
    RunNum = RunNum{1};
end
Inputs = {'PctThresh','STDThresh','CutNPoints'};
InptValues = {10,3,10};
mlDefaultInputs;

% The voxels extracted by this method are redundant - they are in 1x1x1
% resolution instead of native resolution. The following loops get rid of
% exactly equivalent timecourses to pare down the data.
VV = mlBV_VOIVoxels(vtcfile,voifile,voiname,1);

% BadOnes here is an index for which trials are outliers.
BadOnes = zeros(size(VV));
for ii = 1:size(VV,2);
    BadOnes(:,ii) = (VV(:,ii)>mean(VV(:,ii))+STDThresh*std(VV(:,ii)))|(VV(:,ii)<mean(VV(:,ii))-STDThresh*std(VV(:,ii)));
end
hh = figure;
PctBad = 100*sum(BadOnes,2)/size(BadOnes,2);
plot(PctBad,'LineWidth',1.5);
set(gca,'LineWidth',2,'FontSize',16)
ylabel({'% outlying voxels' sprintf('(>%.1f Std. Dev. from mean)',STDThresh)})
ylim([0 100])
xlabel('Time (seconds)')
whitebg([1 1 1]);
title(sprintf('Run %s',RunNum));

ToCutPre = find(PctBad>PctThresh); 
Temp = zeros(length(ToCutPre),CutNPoints); 

for iCut = 1:length(ToCutPre);                 % \/ Below here was 9 (replaced by CutNPoints-1)
    Temp(iCut,:) = ToCutPre(iCut):ToCutPre(iCut)+CutNPoints-1; 
end

ToCut = unique(Temp(:));
ToCut = ToCut(ToCut<=length(PctBad));
hold on; plot(ToCut,PctThresh*ones(length(ToCut),1),'r.'); hold off

%saveas(hh,sprintf('Run%s_%.0fPctOutlierPlot_Thresh%.0fPctOver%.1fSTDs.png',RunNum,100*length(ToCut)/length(PctBad),PctThresh,STDThresh))
save(sprintf('Run%s_VOI_%s_%.0fPctOutliers_Thresh%.0fPctOver%.1fSTDs_Cut%.0f.mat',RunNum,voiname(1:2),100*length(ToCut)/length(PctBad),PctThresh,STDThresh,CutNPoints),'PctBad','ToCut')

clear all; 

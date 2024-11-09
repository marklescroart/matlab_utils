function stats = xy_Oneway_Repeated_ANOVA(data)

% this function is used to calculate statistics of repeated measure
% analysis of variance
%
% usage: stats = Oneway_Repeated_ANOVA(data)
%
% data should be organized in the following way: the rows are subjects,
% the columons are the measured data.
%
% Written by Xiaomin Yue at 7/30/2007
% 


[totalSubjects, conditions] = size(data);
GrandMean = mean(data(:));
ConditionMean = mean(data);
SubjectMean = mean(data,2);

SStotal = sum((data(:)-GrandMean).^2);
Dftotal = totalSubjects*conditions - 1;

SScondition = totalSubjects*sum((ConditionMean - GrandMean).^2);
Dfcondition = conditions - 1;
MScondition = SScondition/Dfcondition;

SSsubject = conditions*sum((SubjectMean-GrandMean).^2);

SSerror = SStotal - SScondition - SSsubject;
Dferror = (totalSubjects-1)*(conditions-1);
MSerror = SSerror/Dferror;

Fvalue = MScondition/MSerror;
Pvalue = 1 - fcdf(Fvalue, Dfcondition, Dferror);
eta2 = SScondition/(SScondition+SSerror);

q05 = 4.04; % for alpha = .05
q01 = 5.64; % for alpha = .01
% table of q values from p. 604, appendix G, Statistics for the Behavioral 
% Sciences 4 (Xiaomin's copy)

CD05 = q05*sqrt(MSerror/totalSubjects);
CD01 = q01*sqrt(MSerror/totalSubjects);
stats.SSfactor = SScondition;
stats.DFfactor = Dfcondition;
stats.SSerror = SSerror;
stats.DFerror = Dferror;
stats.F = Fvalue;
stats.P = Pvalue;
stats.eta2 = eta2;
stats.HSD_sig05 = [(ConditionMean(3)-ConditionMean(1)>CD05) (ConditionMean(3)-ConditionMean(2)>CD05) (ConditionMean(2)-ConditionMean(1)>CD05)];
stats.HSD_sig01 = [(ConditionMean(3)-ConditionMean(1)>CD01) (ConditionMean(3)-ConditionMean(2)>CD01) (ConditionMean(2)-ConditionMean(1)>CD01)];
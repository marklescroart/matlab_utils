function varargout = mlMRI_PlotDeconvDat(fName,Conds,Type,ExpTitle,RunStats)

% Usage: mlMRI_PlotDeconvDat(fName,Conds,Type,ExpTitle,RunStats)
%
% Inputs: fName - String filename for ML's (data).txt files, created
%                 according to ML's conventions (should be output of 
%                 mlBVDatFileReader.m)
%         Conds - which Conds to plot (e.g., conditions [1 2 4] only)
%         Type  - either: 'Deconv', 'Bar' (bar graph of all conditions'
%                 peaks, from time point 4 to 7), 'Bar2' (bar graph of 
%                 condition rise over condition 1 
%         ExpTitle - 2nd line of title of graph
%
% Created by ML on 1.15.08


% Input Check:
if ~exist('fName','var')
    error('I need some data to work with, bonehead.')
end
%Inputs = {'Type','ExpTitle','RunStats'};
%InptValues = {'Deconv','',0};
%mlDefaultInputs;
if ~exist('RunStats','var')
    RunStats = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PeakAvgStart = 5;                   %%% *** !!!IMPORTANT!!! *** %%%
PeakAvgEnd = 8;             %%% (These values determine % release graph) %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(findstr(fName,'NoErr'))
    ExpTitle = [ExpTitle ' - No Error Trials']; %(For Plot Title)
    NoErr = 'NoErr';
else
    NoErr = '';
end

SaveOrNo = 0;
AltOrNo = ''; % find this below - this is particular to LOScTrans Experiment

% Reading in data according to ML's conventions:
WholeFile = mlFileToCell(fName);

% Checking to be sure each subject has the same number of predictors:
for i = 1:length(WholeFile); SubIdx(i) = strcmp(WholeFile{i},'<SubjectStart>'); end
SubIdx = [find(SubIdx) length(WholeFile)];
for j = 1:length(SubIdx)-1;
    Tmp = WholeFile(SubIdx(j):SubIdx(j+1));
    for k = 1:length(Tmp); 
        DatIdx(k) = strcmp(Tmp{k},'<DataStart>');
    end
    DatCount(j) = length(find(DatIdx));
end
if ~all(DatCount==mean((DatCount))); % That is: if not all subjects have the same "DatCount"
    error('Something is wrong with your data file. Subjects do not have the same number of data points.')
end



Dfield = {[AltOrNo 'ConditionNames'],'Colors','Subject','ROI'};
for iF = 1:length(Dfield);
    idx1 = find(strcmp(['<' Dfield{iF} 'Start>'],WholeFile));
    idx2 = find(strcmp(['<' Dfield{iF} 'End>']  ,WholeFile));
    if length(idx1)>1
        for iRpt = 1:length(idx1)
            Data.(Dfield{iF}){iRpt} = WholeFile{idx1(iRpt)+1:idx2(iRpt)-1};
        end
    else
        Data.(Dfield{iF}) = WholeFile(idx1+1:idx2-1);
    end
end
Data.nConds = length(Data.([AltOrNo 'ConditionNames']));
idx1 = find(strcmp(['<DataStart>'],WholeFile));
idx2 = find(strcmp(['<DataEnd>']  ,WholeFile));

try % Trying to extract F value - May give bugs with older files. Sorry.
    Fidx = find(strcmp(['<SubFValueStart>'],WholeFile))+1;
    Fstr = WholeFile(Fidx);
    for cc = 1:length(Fstr); Data.IndFVals(cc) = str2num(Fstr{cc}); end
catch
    Data.IndFVals = 0;
end

try % Trying to extract Beta values for 3D Motion Correction Parameters
    MCidx = find(strcmp(['<SubMCBetaValuesStart>'],WholeFile))+1;
    if isempty(MCidx); error('No MC Files.'); end
    MCstr = WholeFile(MCidx);
    for cc = 1:length(MCstr); Data.MCBetas(cc,:) = str2num(MCstr{cc}); end
catch
    Data.MCBetas = 0;
end


if isempty(Fstr)
    Data.IndFVals = 0;
end

for iData = 1:length(idx1)
    iSub = ceil(iData/Data.nConds);
    DatCell = WholeFile(idx1(iData)+1:idx2(iData)-1);
    Data.RawData(mlRptN(iData,Data.nConds),:,iSub) = str2num(DatCell{1});
    ee(mlRptN(iData,Data.nConds),:,iSub) = str2num(DatCell{2});
end

% Data Manipulations: 


if size(Data.RawData,3)>1 % For multi subject runs
    F.MultiSub = 1;
    %%% For straightforward BOLD curves: 
    Data.SubjMeanData = mean(Data.RawData,3);
    Data.Error = std(Data.RawData,0,3)/length(Data.Subject)^.5; % Standard error of the mean
    %%% For bar graph of AVERAGE peaks: 
    Data.PeakValuesOnly_avg5to8 = Data.RawData(:,PeakAvgStart:PeakAvgEnd,:);
    Data.nSub_x_aCondMatrix_avg5to8(:,:) = mean(Data.PeakValuesOnly_avg5to8,2); % Technically this will be aCond x nSubs -
    Data.nSub_x_aCondMatrix_avg5to8 = Data.nSub_x_aCondMatrix_avg5to8';         % So we transpose it here.
    Data.Bar_avg5to8 = mean(Data.nSub_x_aCondMatrix_avg5to8); 
    Data.BarStdErr_avg5to8 = std(Data.nSub_x_aCondMatrix_avg5to8)/length(Data.Subject)^.5;

    %%% For bar graph of AVERAGE peaks:
    Data.PeakValuesOnly(:,:) = max(Data.RawData,[],2);
    Data.nSub_x_aCondMatrix = Data.PeakValuesOnly'; % Again, transposition (see above)
    Data.Bar = mean(Data.nSub_x_aCondMatrix); 
    Data.BarStdErr = std(Data.nSub_x_aCondMatrix)/length(Data.Subject)^.5;

    %%% For percent release bar graph:  (PR = Percent Release) %% ASSUMES
    %%% FIRST CONDITION IS IDENTICAL CONDITION - GUARANTEED TO CAUSE BUGS%%
    nPlotConds = size(Data.nSub_x_aCondMatrix,2); % for when the number of subjects exceeds the number of conditions.
    for iPR = 2:nPlotConds
        PR(iPR,:) = (Data.nSub_x_aCondMatrix(:,iPR)-Data.nSub_x_aCondMatrix(:,1))./Data.nSub_x_aCondMatrix(:,1);
    end
    Data.PRraw = 100*PR';
    Data.PctRel = 100*mean(PR,2);
    Data.PctRelErr = 100*std(PR,0,2)/size(Data.RawData,3)^.5;
    
    %%% For release bar graph:  %% ASSUMES FIRST CONDITION IS IDENTICAL CONDITION - GUARANTEED TO CAUSE BUGS%%
    for iRel = 2:nPlotConds
        Rel(iRel,:) = (Data.nSub_x_aCondMatrix(:,iRel)-Data.nSub_x_aCondMatrix(:,1));
    end
    Data.Relraw = Rel';
    Data.Rel = mean(Rel,2);
    Data.RelErr = std(Rel,0,2)/size(Data.RawData,3)^.5;
    
else                      % Single subject
    F.MultiSub = 0;
    %%% For straightforward BOLD curves: 
    Data.SubjMeanData = mean(Data.RawData,3);
    Data.Error = ee;
    %%% For bar graph of peaks: 
    Data.PeakValuesOnly = Data.RawData(:,PeakAvgStart:PeakAvgEnd);
    Data.nSub_x_aCondMatrix = mean(Data.PeakValuesOnly,2); % Technically this will be aCond x nSubs -
    Data.nSub_x_aCondMatrix = Data.nSub_x_aCondMatrix';    % So we transpose it here.
    Data.Bar = Data.nSub_x_aCondMatrix; 
    Data.BarStdErr = mean(ee(:,PeakAvgStart:PeakAvgEnd),2); % a little dodgy - averaging standard error of (however many points). How should this be calculated?
    
    %%% For percent release bar graph:  (PR = Percent Release) %% ASSUMES
    %%% FIRST CONDITION IS IDENTICAL CONDITION - GUARANTEED TO CAUSE BUGS%%
    nPlotConds = size(Data.nSub_x_aCondMatrix,2); % for when the number of subjects exceeds the number of conditions.
    for iPR = 2:nPlotConds
        PR(iPR,:) = (Data.nSub_x_aCondMatrix(iPR)-Data.nSub_x_aCondMatrix(1))./Data.nSub_x_aCondMatrix(1);
    end
    Data.PctRel = 100*PR;
    Data.PctRelErr = Data.BarStdErr; % Cheap cop-out for now...    
end


% Statistics: 
if RunStats 
    if ~F.MultiSub; disp('Sorry, currently can''t run stats on a single subject.'); end
    ToTest = Data.nSub_x_aCondMatrix(:,Conds);
    % F Test on Bar Graphs (for 4 peak time points)
    Data.StatCell = rm_anova1(ToTest,1,1);
end

% Plot Setup:
Data.Length = size(Data.RawData,2);
for iCol = 1:length(Data.Colors)
    Cc(iCol,:) = str2num(Data.Colors{iCol});
end
Data.Colors = Cc;

if F.MultiSub
    PlotTitle = {['Average (N=' num2str(length(Data.Subject)) ')']}; 
else
    PlotTitle = Data.Subject;
end

if ~exist('Conds','var')
    Conds = 1:Data.nConds;
end

% Plotting:

switch Type
    case 'Deconv'
        Hh = mlFigure(1);

        Low = -.2;

        Peak = max(max(Data.SubjMeanData(Conds,:)))+.1;
        Peak = ceil(max(Peak*10))/10;
        FinTitle = {['Subject ' PlotTitle{:} ' ' Data.ROI{:} ' Deconv Plot'],ExpTitle};
        mlGraphSetup(FinTitle,'Time from Stim Onset','% Signal Change',[0 Data.Length+1],[Low Peak])
        hold all;
        for iDeconv = Conds
            errorbar(Data.SubjMeanData(iDeconv,:)',Data.Error(iDeconv,:)','linewidth',1.5,'Color',Data.Colors(iDeconv,:)/255);
        end
        hold off;

        whitebg(Hh,[1 1 1]);
        set(gca,'linewidth',.5);
        hold on;
        plot(0:Data.Length+1,zeros(1,Data.Length+2),'w')
        plot(0:Data.Length+1,ones(1,Data.Length+2),'w')
        hold off;

        legend(Data.([AltOrNo 'ConditionNames'])(Conds));
    case 'BarPeakAvg'
        Hh = figure;
        % To plot maxes in bar graph:
        for iB = Conds; %1:length(Data.Bar);
            hold on; 
            BarPlot = zeros(length(Conds),1);
            BarPlot(iB) = Data.Bar_avg5to8(iB);
            bar(BarPlot,'FaceColor',Data.Colors(iB,:)/255);
            hold off;
        end
        hold on; 
        errorbar(Data.Bar_avg5to8(Conds),Data.BarStdErr_avg5to8(Conds),'k+')
        hold off;
        % Temp fix!!!???
        %CNames = {{'Ident'},{'2.3';'Trans'},{'4.5';'Trans'},{'9';'Trans'},{'New';'Obj'},};
        % Should be something more like this:
        % for ii = 1:length(Data.ConditionNames); Data.ConditionNames{ii} = regexprep(Data.ConditionNames{ii},' ','\n'); end
        set(gca,'xtick',1:length(Conds), 'XTickLabel',Data.([AltOrNo 'ConditionNames'])(Conds),'FontSize',18) % OR: CNames(Conds)
        FinTitle = {['Subject ' PlotTitle{:} ' ' Data.ROI{:} ' Activation Peaks'],ExpTitle};
        title(FinTitle,'FontSize',20);
        ylabel('% Signal change','FontSize',18);
        xlabel('Degrees Translated','FontSize',18);
                
    case 'Bar'
        Hh = mlPPTfigure;
        % To plot maxes in bar graph:
        for iB = Conds; %1:length(Data.Bar);
            hold on; 
            BarPlot = zeros(length(Conds),1);
            BarPlot(iB) = Data.Bar(iB);
            bar(BarPlot,'FaceColor',Data.Colors(iB,:)/255);
            hold off;
        end
        hold on; 
        errorbar(Data.Bar(Conds),Data.BarStdErr(Conds),'k+')
        hold off;
        % Temp fix!!!???
        %CNames = {{'Ident'},{'2.3';'Trans'},{'4.5';'Trans'},{'9';'Trans'},{'New';'Obj'},};
        % Should be something more like this:
        % for ii = 1:length(Data.ConditionNames); Data.ConditionNames{ii} = regexprep(Data.ConditionNames{ii},' ','\n'); end
        set(gca,'xtick',1:length(Conds), 'XTickLabel',Data.([AltOrNo 'ConditionNames'])(Conds),'FontSize',18) % OR: CNames(Conds)
        FinTitle = {['Subject ' PlotTitle{:} ' ' Data.ROI{:} ' Activation Peaks'],ExpTitle};
        title(FinTitle,'FontSize',20);
        ylabel('% Signal change','FontSize',18);
        xlabel('Degrees Translated','FontSize',18);
        
    case 'BarPctRel'
        Hh = mlPPTfigure;
        % To plot maxes in bar graph:
        bCount = 1;
        for iB = Conds; %1:length(Data.PctRel);
            hold on; 
            BarPlot = zeros(length(Conds),1);
            BarPlot(bCount) = Data.PctRel(iB);
            bar(BarPlot,'FaceColor',Data.Colors(iB,:)/255);
            hold off;
            bCount = bCount+1;
        end
        hold on; 
        errorbar(Data.PctRel(Conds),Data.PctRelErr(Conds),'k+');
        hold off;
        set(gca,'xtick',1:length(Conds), 'XTickLabel',Data.([AltOrNo 'ConditionNames'])(Conds),'FontSize',18); %,'ylim',[0 50]);
        title({['Subject ' PlotTitle{:} ' ' Data.ROI{:} ' Activation Peaks'],ExpTitle},'FontSize',20);
        ylabel('% Release','FontSize',18);
        xlabel('Degrees Translated','FontSize',18);
        ylim([0 80]);
        
    case 'BarRel'
        Hh = mlPPTfigure;
        % To plot maxes in bar graph:
        bCount = 1;
        for iB = Conds; %1:length(Data.PctRel);
            hold on; 
            BarPlot = zeros(length(Conds),1);
            BarPlot(bCount) = Data.Rel(iB);
            bar(BarPlot,'FaceColor',Data.Colors(iB,:)/255);
            hold off;
            bCount = bCount+1;
        end
        hold on; 
        errorbar(Data.Rel(Conds),Data.RelErr(Conds),'k+');
        hold off;
        set(gca,'xtick',1:length(Conds), 'XTickLabel',Data.([AltOrNo 'ConditionNames'])(Conds),'FontSize',18); %,'ylim',[0 50]);
        title({['Subject ' PlotTitle{:} ' ' Data.ROI{:} ' Activation Peaks'],ExpTitle},'FontSize',20);
        ylabel('Release (% Bold)','FontSize',18);
        xlabel('Degrees Translated','FontSize',18);
        ylim([0 .1]);

        
end

if F.MultiSub 
%     if all(Data.IndFVals>1);
%         Hf = mlPPTfigure; bar(Data.IndFVals);
%         title({['Individual Subject F Values - ' Data.ROI{:}],ExpTitle},'FontSize',20);
%         set(gca,'xtickLabel',Data.Subject,'FontSize',18,'ylim',[-20 180]);
%         ylabel('F value','FontSize',18);
%         xlabel('Subject','FontSize',18);
%     end
%     if all(Data.MCBetas~=0);
%         Hmc = mlPPTfigure; bar(Data.MCBetas);
%         title({['Individual Subject F Values - ' Data.ROI{:}],ExpTitle},'FontSize',20);
%         set(gca,'xtickLabel',Data.Subject,'FontSize',18);%,'ylim',[-20 180]);
%         ylabel('MC regressor Beta value','FontSize',18);
%         xlabel('Subject','FontSize',18);
%     end
    set(0,'Defaultaxescolororder',Data.Colors(Conds,:)/255)
    Hi = mlPPTfigure; bar(Data.nSub_x_aCondMatrix(:,Conds));
    title({['Individual Subject Patterns - ' Data.ROI{:}],ExpTitle},'FontSize',20);
    set(gca,'xtickLabel',Data.Subject,'FontSize',18);%,'ylim',[-20 180]);
    ylabel('% Release','FontSize',18);
    xlabel('Subject','FontSize',18);
    colormap(Data.Colors(Conds,:)/255);
end

if SaveOrNo
    SaveRoot = ''; %'/Users/Work/Documents/Neuro_Docs/Projects-IUL/LOScaleTrans/Images/Graphs/';
    if ~isempty(strfind(ExpTitle,'Sm'))
        BigSm = 'SmIms';
    else
        BigSm = 'BigIms';
    end
    SaveName1 = ['Subject_' PlotTitle{:} '_' Data.ROI{:} '_' Type NoErr '_' BigSm '.png'];
    saveas(Hh,[SaveRoot SaveName1]);
    if F.MultiSub
        SaveNameInd = ['Subject_' PlotTitle{:} '_' Data.ROI{:} '_' Type NoErr '_IndSubjPlots_' BigSm '.png'];
        %SaveNameMC = ['Subject_' PlotTitle{:} '_' Data.ROI{:} '_' Type NoErr '_IndSubjMCvalues_' BigSm '.png'];
        saveas(Hi,[SaveRoot SaveNameInd]);
        %saveas(Hmc,[SaveRoot SaveNameMC]);
    end
end

if nargout
    varargout{1} = Data;
end
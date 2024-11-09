function mlETPreprocess(fname,path,RealOffSet)

% Usage: mlETPreprocess([fname,path] [,RealOffSet])
%
% EyeTracker data preprocessing function. Designed to prepare a file for
% input to another program.
%
% Inputs: fname - file name
%         path  - absolute path to that file
%              If fname and path are not provided, the program will prompt
%              the user to choose an input file
%              NOTE: the input file can either be a .eyd file OR a .mat
%              file that is a past output of this program (to save time)
% 
%         RealOffSet - distance from center to ET calibration dots.
%              Defaults to 304 (ML's value) if not provided.
% 
%         
%         NOTE: The program will assume that the first two letters of the 
%             input file are the subject's initials.
%
% Outputs: The program saves separate .eyeS files for each run, which are
% simpy two columns of data - x eye position, y eye position - with NaNs in
% place of blinks.
%
% Created by ML 11.28.06
% Modified by ML 10.23.07

% NOTES:
% 
% This reads asl files using the "readasl" function from (???). This
% converts .eyd data into a struct array. Most fields are pretty obvious;
% the "Data" field has ten columns:
% 
% 1 - Measurement Number
% 2 - ??Overtime (no real data during overtime frame)
% 3 - Total Time So far (secs)
% 4 - ??Scene
% 5 - ??ES-Dist
% 6 - X data
% 7 - Y data
% 8 - Pupil Diameter
% 9 - fMRI Trigger cues
% 10- Mark


%% Inputs: 
% choose either .eyd or .mat file
if ~nargin;
    [fname, path] = uigetfile({'*.eyd';'*.mat'}, 'Pick an Eye Tracker (.eyd) or Matlab (.mat) file','*.eyd');
end
if ~exist('RealOffSet','var')
    RealOffSet = 304; %250 for KH's code; 304 For ML's code
end
if ~exist('UseCalrun','var')
    Flags.UseCalRun = 0;
else
    Flags.UseCalRun = UseCalRun;
end
TRtime = 2;

% dealing with choice (eyd or mat)
try
    if strcmp(fname(end-3:end),'.eyd')
        ET = readasl([path fname],6);
        save([path fname(1:end-4) '.mat'],'ET')
    elseif strcmp(fname(end-3:end),'.mat')
        load([path fname]);
    else
        error('Please get your act together. Make some command decisions in life.');
    end
catch
    error('Either you''ve cancelled the function or something is wrong with your files.')
end

%% Set-up of other variables:
SubjInits = fname(1:2);
nScans = length(ET.data);
sf = ET.acqRate;

Pos = TileFigs(3,2);

ScanNo = 1;
% try
for iScan = 1:nScans
    
    % Pulling data from weird struct that readasl gets you, and saving a
    % more intelligible matlab struct array as a starting point to ET
    % analysis (this is good for checking if any of the pre-processing has
    % gone wrong)
    ET.(['Scan' num2str(iScan)]).TRData   = ET.data{iScan}(:,9);
    ET.(['Scan' num2str(iScan)]).TimeData = ET.data{iScan}(:,3);
    TimeTemp = ET.data{iScan}(:,3);
    ET.(['Scan' num2str(iScan)]).XData    = ET.data{iScan}(:,6);
    XXTemp = ET.data{iScan}(:,6);
    ET.(['Scan' num2str(iScan)]).YData    = ET.data{iScan}(:,7);
    YYTemp = ET.data{iScan}(:,7);
    ET.(['Scan' num2str(iScan)]).PupData  = ET.data{iScan}(:,8);
    PupTemp = ET.data{iScan}(:,8);
    ET.(['Scan' num2str(iScan)]).AbsNum   = ET.data{iScan}(:,1);
    NumTemp = ET.data{iScan}(:,1);
    
    % 
    SkipPres = 0;
    Flags.GoCalRuns = 0;
    

    % Check for scanner activity in a given run (assumes that this is for MRI Eyetracking...):
    TRTemp = ET.(['Scan' num2str(iScan)]).TRData;
    % Lately (02/08), there has been a problem with the TR signal in the
    % eye tracker - it isn't a binary signal coming out of it, either TR or
    % no - it's got some weird periodic component underneath it. The
    % following lines aim to get rid of that baseline shift (that was
    % messing up the data).
    
    TRTemp(1) = 0;
    TRTemp(2:end) = TRTemp(2:end)-TRTemp(1:end-1);

    %%% ???
    %TRTemp(5793+60) = 255;
    
    TRIdx = find(TRTemp>100); %TRIdx = find(TRTemp);

    fprintf('Initial pass found %.0f TRs in Scan number %.0f\n',length(TRIdx),iScan);

    % Dealing with possibility of no TRs present:
    Flags.TRpres  = length(TRIdx)>0;
    if ~Flags.TRpres
        Flags.YNCalRuns = questdlg(['Is run number ' num2str(iScan) ' a calibration run?']);
        if strcmp(Flags.YNCalRuns,'Yes')
            disp(['Calibration run ' num2str(iScan) ' included.']);
            Flags.GoCalRuns = 1;
        elseif strcmp(Flags.YNCalRuns,'No')
            disp(['Skipping run ' num2str(iScan) ' - no TRs detected for that run.']);
            rmfield(ET,['Scan' num2str(iScan)])
            Flags.GoCalRuns = 0;
            continue
        else
            error('Please figure out what to do with your blank runs, and try again.');
        end
    end

    %%% Check for TRs outside the  given run:
    TrNs = NumTemp(TRIdx);
    for iSkip = 1:length(TrNs)
        try
            SkipCheck = TrNs(iSkip+1) - TrNs(iSkip);
        catch
            continue
        end
        if SkipCheck > TRtime*sf+1 && SkipPres == 0 % > sf+1?
            Part1End = iSkip;
            Part2Start = iSkip+1;
            SkipPres = 1;
            disp(['Detected another TR trigger after main run of experiment in scan ' num2str(iScan)]);
            disp(iSkip);
        elseif SkipCheck > TRtime*sf+1 && SkipPres == 1 % > sf+1?
            disp(['Detected more than one outlying TR trigger in scan ' num2str(iScan) ' - and that''s messed up. I don''t know what to do with that.'])
            disp(iSkip);
        end
    end
    
%     clear iSkip SkipCheck Part1End Part2Start SkipPres
    


    if ~Flags.GoCalRuns
        TRIdx2 = zeros(length(TRIdx),1);
        TRIdx2(1) = TRIdx(1);
        TRIdx2(2:end) = TRIdx(1:end-1);
        TRIdxCheck = abs(TRIdx2-TRIdx+1);
        TRStartIndices = find(TRIdxCheck);
        Skips = find(TRIdxCheck > TRtime*sf+1);
        if ~isempty(Skips)
            disp(['Skip Double-Check for ' num2str(iScan) ' confirms skip.'])
        end
        nTRs = length(find(TRIdxCheck))-length(Skips);
        
        fprintf('Calculated %.0f TRs in Run %.0f\n',nTRs,iScan);
        
        for iTrCt = 1:length(TRIdx)-1;
            if TRIdx(iTrCt)~=TRIdx(iTrCt+1)-1;
                TRstart(iTrCt) = 1;
            end;
        end
        
        %NumTRs = 472; %%% ??? Flagrant hack - fix later
        NumTRs = nTRs;
        RunData(:,1) = XXTemp(TRIdx(1):TRIdx(1)+(sf*NumTRs)-1);
        RunData(:,2) = YYTemp(TRIdx(1):TRIdx(1)+(sf*NumTRs)-1);
        PupSize(:,1) = PupTemp(TRIdx(1):TRIdx(1)+(sf*NumTRs)-1);
%     if ~Flags.GoCalRuns && SkipPres
%         %%% NOTE: Cannot deal with multiple skips - i.e., if the scanner
%         %%% comes on more than twice during a given eye tracker recording
%         %%% session
%         ScanTime(iScan) = TimeTemp(TRIdx(Part1End)) - TimeTemp(TRIdx(1));
%         RunData(:,1) = XXTemp(TRIdx(1):TRIdx(Part1End)+sf);
%         RunData(:,2) = YYTemp(TRIdx(1):TRIdx(Part1End)+sf);
%         PupSize(:,1) = PupTemp(TRIdx(1):TRIdx(Part1End)+sf);
%     elseif ~Flags.GoCalRuns && ~SkipPres
%         ScanTime(iScan) = TimeTemp(TRIdx(end))-TimeTemp(TRIdx(1));
%         %%% Variable RunData's columns will be: (x,y)
%         RunData(:,1) = XXTemp(TRIdx(1):TRIdx(end)+sf);
%         RunData(:,2) = YYTemp(TRIdx(1):TRIdx(end)+sf);
%         PupSize(:,1) = PupTemp(TRIdx(1):TRIdx(end)+sf);
    elseif Flags.GoCalRuns
        RunData(:,1) = XXTemp;
        RunData(:,2) = YYTemp;
        PupSize(:,1) = PupTemp;
        
        figure('Position',Pos(3,:));
        plot(RunData(:,1),RunData(:,2),'g*');
        set(gca,'ylim',[0 400],'xlim',[0 400]);
        hold on;
        plot(ET.calpts(:,1),ET.calpts(:,2), 'r.');
        hold off;
    end

    % Use Calibration run:
    if Flags.UseCalRun %currently useless - do not attempt %%%???%%%
        error('Sorry, this isn''t ready yet.');
    else
        XLeft   = ET.calpts(1,1);
        XRight  = ET.calpts(3,1);
        XCenter = ET.calpts(5,1);
        YTop    = ET.calpts(1,2);
        YBot    = ET.calpts(9,2);
        YCenter = ET.calpts(5,2);
        ETOffSetX = ET.calpts(2,1)-ET.calpts(1,1);
        ETOffSetY = ET.calpts(7,2) - ET.calpts(6,2);
        % To show fit of calibration points to data -
        % for X:
        figure(1);
        plot(RunData(:,1));
        set(gca,'ylim',[0 300]);
        hold on;
        plot(ET.calpts(1,1)*ones(length(RunData(:,1)),1),'g-');
        plot(ET.calpts(2,1)*ones(length(RunData(:,1)),1),'g-');
        plot(ET.calpts(3,1)*ones(length(RunData(:,1)),1),'g-');
        hold off;
        title('X calibration point fit');
        % and for Y:
        figure(2);
        plot(RunData(:,2));
        set(gca,'ylim',[0 300]);
        hold on;
        plot(ET.calpts(1,2)*ones(length(RunData(:,1)),1),'g-');
        plot(ET.calpts(4,2)*ones(length(RunData(:,1)),1),'g-');
        plot(ET.calpts(7,2)*ones(length(RunData(:,1)),1),'g-');
        hold off;
        title('Y calibration point fit');
    end

    % Actual transformation of values in code:

    RunData(:,1) = RunData(:,1)-XCenter;
    RunData(:,1) = RunData(:,1)/ETOffSetX * RealOffSet;
    RunData(:,1) = RunData(:,1)+512;
    %RunData(:,1) = RunData(:,1)-mean(RunData(:,1))+512; % We don't want to force the mean of the data to be (512, 384), do we?
    RunData(:,2) = RunData(:,2)-YCenter;
    RunData(:,2) = RunData(:,2)/ETOffSetY * -1 * RealOffSet; % that -1 is there because the MRI Eyetracker records y position negative as UP for some idiotic reason
    RunData(:,2) = RunData(:,2)+384;
    %RunData(:,2) = RunData(:,2)-mean(RunData(:,2))+384;
    mean(RunData)

%     figure(3);
%     plot(RunData(:,1),RunData(:,2));
%     mlScreenFig;
    
    % Removing Blinks:
    BlinkThresh = 2*std(PupSize); % Considers blinks to be 2 standard deviations of pupil size smaller than mean...
    BlinkIdx = find(PupSize < BlinkThresh);
    ET.(['Scan' num2str(iScan)]).CutBlinkTime = length(BlinkIdx)/sf;
    RunData(BlinkIdx,:) = NaN;
    
    if Flags.GoCalRuns
        RunStr = [num2str(ScanNo) 'cal'];
    else
        RunStr = [num2str(ScanNo) 'real'];
        ScanNo = ScanNo+1;
    end
    
    
    
    dlmwrite([path SubjInits '_EyeData_Run' RunStr '.eyeS'],RunData,'delimiter','\t');

    clear RunData PupSize BlinkIdx;
    
end; clear iScan;
% catch 
%     save DebugVars
%     rethrow(lasterror);
% end
%% Saving modified ET Data in a Matlab Struct array:
ET = rmfield(ET,'data');
save([path fname(1:end-4) '_mod.mat'],'ET')

% Checking progress so far: 
% First 24 seconds are a pre-set pattern of eye movements, going over
% allthe calibration dots. If these plots don't look like that, then worry.
% ff = mlStructExtract(dir('*.eyeS'),'name');
% kk = 1:60*26;
% tc = 1/60:1/60:26;
% for ii = 1:6; 
%     aa = importdata(ff{ii}); 
%     figure; plot(tc,aa(kk,1)); 
%     hold on; plot([4 6 8 10 12 14 16 18 20 22],500*ones(1,10),'y.'); hold off; 
%     title(['Run ' num2str(ii)]); 
% end
% 

%% Resampling data:

%%% USC's MRI ASL eye tracker samples at 60 Hz, and Dave Berg's markEye
%%% program has a minimum sampling frequency of 240 Hz
here = pwd;
dbergEye;

if sf < 240
    NewFileDir = dir([path SubjInits '*.eyeS']);
    for iResamp = 1:length(NewFileDir)
         mlResampleEyeS([path NewFileDir(iResamp).name],60,240);
    end; clear iResamp;
end

%% Invoking markEye to prepare final markup:

MarkupDir = dir([path SubjInits '*.reyeS']);

for iMkUp = 1:length(MarkupDir)
    markEye([path MarkupDir(iMkUp).name],'sf',240,'autosave',1,'ppd',[43 43]);
end; clear iMkUp;

cd(here);
return
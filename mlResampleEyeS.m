function mlResampleEyeS(InputFile,startHz,finHz)

% Usage: mlResampleEyeS(InputFile,startHz,finHz)
% 

% for mlNaNFill:
% Usage: [NoNaNs WereNaNs] = mlNaNFill(EyeSFile [,startHz] [,finHz])

if ~strcmp(InputFile(end-3:end),'eyeS');
    error('Please input a .eyeS file');
end
if nargin<2
    startHz = 60;
    finHz = 240;
end

Orig = importdata(InputFile);
NoNaNs = Orig;
NanLogical = isnan(NoNaNs(:,1));

NanIdx = find(NanLogical);
RealIdx = find(~NanLogical);
AllIdx = 1:length(NoNaNs);


for iFill = 1:length(NanIdx)
    Before = find(AllIdx(RealIdx)<NanIdx(iFill));
    % In case the first value is NaN:
    if isempty(Before)
        Before = 1;
        Orig(1,:) = mode(Orig);
    end
    
    PreX = Orig(RealIdx(Before(end)),1);
    PreY = Orig(RealIdx(Before(end)),2);
    if isnan(PreX)
        disp(['What the fuck... ' num2str(Before(end)) 'is skanky']);
    end
    
    %%% A little too fancy-pants...
    %if length(Before) > 10
    %   Pre = Before(end-9:end);
    %   PreMeanX = mean(NoNaNs(Pre,1));
    %   PreMeanY = mean(NoNaNs(Pre,2));
    %end
    %After = find(AllIdx(RealIdx)<NanIdx(iFill));
    %if length(After) > 10
    %    Post = After(1:10);
    %    PostMeanX = mean(NoNaNs(Post,1));
    %    PostMeanY = mean(NoNaNs(Post,2));
    %end
    
    NoNaNs(NanIdx(iFill),1) = PreX; %mean([PreMeanX PostMeanX]);
    NoNaNs(NanIdx(iFill),2) = PreY; %mean([PreMeanY PostMeanY]);    
    
end

NewFile = resample(NoNaNs,finHz,startHz);
MM = finHz/startHz;

for iNN = 1:length(NanLogical)
    NewNanLogical((iNN-1)*MM+1:iNN*MM) = NanLogical(iNN);
end

NewFile(find(NewNanLogical),:) = NaN;


%% Quick look plot:
% Start = 1;
% Fin   = 300;
% OldPlotIdx = Start:Fin;
% NewPlotIdx = MM*Start:MM*Fin;

% figure(4); 
% plot(Orig(OldPlotIdx,:))
% hold on;
% plot(500*NanLogical(OldPlotIdx),'r.')
% hold off;
% 
% figure(5); 
% plot(NewFile(NewPlotIdx,:));
% set(gca,'xtick',[0:40:240]); 
% hold on;
% plot(500*NewNanLogical(NewPlotIdx),'r.');

%% Closing up, writing file:
FileName = [InputFile(1:end-4) 'reyeS'];
dlmwrite(FileName,NewFile,'delimiter','\t');



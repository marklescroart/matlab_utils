function tt = rm_anova1(TestDat,displayOn,multCompOn)

% Usage: tt = rm_anova1(TestDat [,displayOn] [,multCompOn])
% 
% Repeated-measures one-way ANOVA.
% 
% Inputs:   TestDat = nSubjects x aConditions matrix of data
%         displayOn = whether or not to print out results of statistical
%                     tests
%        multCompOn = whether to proceed with multiple comparisons tests
%                     (currently, only Tukey's HSD available)
% Outputs:       tt = cell array table of statistics outputs. 
% 
% Created by ML 02.23.08


%% Inputs:
if ~exist('displayOn','var')
    displayOn = 1;
end
if ~exist('multCompOn','var');
    multCompOn = 1;
end

%% Other modifiable Defaults:
alpha = .05; % For Tukey HSD, below


%% Calculations:
Xg = mean(TestDat(:));  % Grand Mean
a = size(TestDat,2);    % number of conditions / levels of independent variable
n = size(TestDat,1);    % number of subjects

% Creating Original Data-sized matrices of means (for easier subtraction):  
SubMeans = repmat(mean(TestDat,2),1,a); % repeats a times, because it's already n long...
CondMeans = repmat(mean(TestDat),n,1);  % repeats n times, because it's already a long...

% Partitioning the variance into SStotal = SSa + SSs + SSaxs:
%                Or:             SStotal = SSa + SSs + (Everything Else)

% SStot - everything:
SStot = sum((TestDat(:)-Xg).^2);
% SSa - variance due to manipulated independent variable (and variable x
% subject interactions)
CondMeansMinusGrandMean = CondMeans-Xg;
SSa = sum(CondMeansMinusGrandMean(:).^2);
% SSs - variance due to individual differences - i.e., noise, in a
% repeated-measures design
SubMeansMinusGrandMean = SubMeans-Xg;
SSs = sum(SubMeansMinusGrandMean(:).^2);
% SSaxs - variance due to interaction of subject differences and condition
% differences - this will end up in the denominator
Leftovers = TestDat-Xg-(SubMeans-Xg)-(CondMeans-Xg); % i.e., interactions / Noise
SSaxs = sum(Leftovers(:).^2);

% Double Checking: (should be unnecessary)
if mlRound(SStot,.01) ~= mlRound(SSa+SSs+SSaxs,.01)
    error('You''ve incorrectly partitioned your variance, poop face.')
end

% And now Mean Squares (dividing out degrees of freedom)
df_tot = a*n-1;
df_a = a-1;
df_s = n-1;
df_axs = (a-1)*(n-1);
% df_tot == df_a + df_s + df_axs

MSa = SSa/df_a;
MSs = SSs/df_s;
MSaxs = SSaxs/df_axs;

F = MSa/MSaxs;
% F = MSa/MSs;
p = 1- fcdf(F,df_a,df_axs);

tt = cell(5,6);

tt(1,1:6) = {'Source' 'SS' 'df' 'MS' 'F' 'Prob>F'};
tt(2,1:6) = {'Factor A' SSa df_a MSa F p};
tt(3,1:4) = {'Factor S' SSs df_s MSs};
tt(4,1:4) = {'A x S'  SSaxs df_axs MSaxs};
tt(5,1:3) = {'Total'  SStot df_tot};

if displayOn
    fprintf('\nRepeated Measures ANOVA Results: \n')
    fprintf('%s\n',repmat('-',1,15*size(tt,2)+15))
    fprintf('%15s%15s%15s%15s%15s%15s\n',tt{1,1:6})
    fprintf('%s\n',repmat('-',1,15*6))
    fprintf('%15s%15.4f%15.0f%15.4f%15.2f%15.4f\n',tt{2,1:6})
    fprintf('%15s%15.4f%15.0f%15.4f\n',tt{3,1:4})
    fprintf('%15s%15.4f%15.0f%15.4f\n',tt{4,1:4})
    fprintf('%15s%15.4f%15.0f\n',tt{5,1:3})
end

% Moving on immediately to Tukey's HSD
% (Making sure we want to go here)
if multCompOn && p < .05; 
    
    % Do nothing...
    
    %resp = questdlg('Continue with Tukey HSD or stop here?','Continue?','Continue','Abort','Continue');
    %if strcmp(resp,'Abort'); return; end
else
    return
end

load qValues.mat
if alpha == .05
    Qalpha = qMatrix(:,[1,2:2:end]);
elseif alpha ==.01
    Qalpha = qMatrix(:,[1,3:2:end]);
else
    error('No other alphas besides .01 and .05 currently accepted.');
end

if a > 10
    error('Sorry, can''t account for that many comparisons');
end
if df_axs < 5
    error('Sorry, can''t deal with less than 5 df for interaction')
end

% accounting for incomplete nature of table: (all elided values are well
% approximated by other values)

%{
Q matrix is:
    ncomparisons ncomparisons ncomparisons ncomparisons ...
df  q            q            q            q
df  q            q            q            q
df  q            q            q            q
df  q            q            q            q
.
.                       ...
.

%}

if df_axs>20 && df_axs < 24
    df_axs = 20; disp('Using df_axs = 20'); % These are the more conservative measures (fewer df)
elseif df_axs>24 && df_axs<30
    df_axs = 24; disp('Using df_axs = 24');
elseif df_axs>30 && df_axs<40
    df_axs = 30; disp('Using df_axs = 30');
elseif df_axs>40 && df_axs<60
    df_axs = 40; disp('Using df_axs = 40');
elseif df_axs>60 && df_axs<120
    df_axs = 60; disp('Using df_axs = 60');
elseif df_axs>120
    df_axs = Inf;
end

q = Qalpha(find(Qalpha(:,1)==df_axs),find(Qalpha(1,:)==a));

CD = q*sqrt(MSaxs/n);% CD = Critical Difference

diffs = zeros(a,a);
for ii = 1:a; 
    diffs(ii,:) = abs(CondMeans(1,:)-CondMeans(1,ii)); 
end

SigDif = diffs>CD;
load MLColorsOpenGL;
Pos = TileFigs(a);
for iCond = 1:a;
    BoxCol = repmat(GLCol.Gray128,a,1);
    BoxCol(iCond,:) = GLCol.Gold;
    ColIdx = find(SigDif(iCond,:));
    BoxCol(ColIdx,:) = repmat(GLCol.Cherry,length(ColIdx),1);
    figure('Position',Pos(iCond,:));
    boxplot(TestDat,'notch','on','color',BoxCol);
end

%{
gmeans = condition means (in vertical vector)
crit = either CD or q, not sure which; 2.9006 for LOScTr group
mname = 'means'
gnames = condition names, as vertical string vector
%}
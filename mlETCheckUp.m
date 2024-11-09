function mlETCheckUp(CkName,root,sf)

if ~nargin
    [CkName, root] = uigetfile('*.ceyeS', 'Pick a file to check on.');
end
if ~exist('sf','var');
    sf = 240;
end

VarName = CkName(1:end-6);
load([root CkName]); 
TestDat = eval(VarName);

saccades = find(TestDat(:,4)==1);

Count = 1;

for ii = 2:length(saccades); 
    if saccades(ii)-saccades(ii-1)>1; 
        sacStart(Count,1) = saccades(ii,1);
        Count = Count+1;
    end; 
end

NumSaccades = length(sacStart)                                              %#ok<NOPRT>
markers = 150*ones(NumSaccades);

TT(:,1) = 1/sf:1/sf:length(TestDat)/(4*sf);
TT(:,2) = 1/sf:1/sf:length(TestDat)/(4*sf);
TTall(:,1) = 1/sf:1/sf:length(TestDat)/(sf);
TTall(:,2) = 1/sf:1/sf:length(TestDat)/(sf);

plot(TT,TestDat(1:length(TestDat)/4,1:2));

hold on;
plot(sacStart/sf,markers,'r*');
hold off;
set(gca,'xlim',[1,length(TestDat)/(4*sf)],'ylim',[0 1024]);

figure;
plot(TTall,TestDat(:,1:2))
hold on;
plot(sacStart/sf,markers,'r*');
hold off;
set(gca,'ylim',[0 1024]);
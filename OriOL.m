nBlocks = 12;
SecPerSegment = 2;
TotTRs = 210;
load MLColors;

OL = [3 2 1 2 1 1 1 2 2 3 3 3];
OLFin = 4*ones(210,1);


% (6*13)+(11*12)

for i = 1:nBlocks; 
    Idx = ((6*i)+(11*(i-1))+1:(6*i)+(11*i));
    
    OLFin(Idx) = OL(i);
end


% for i = 1:4; 
    ExpNm = 'Flip_NAP_MP';
    Conds = {'MP','NAP','Rotation','Fixation'}';
    Cols = {Blue,Orange,Cyan,Gray128}';
    mlBV_CreatePRT(ExpNm,OLFin, Conds, Cols,0,0,1);
% end
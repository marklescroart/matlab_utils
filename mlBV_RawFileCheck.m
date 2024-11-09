function mlBV_RawFileCheck

% Lists how many TRs are in each raw file (relies on BV naming scheme)

% The following should extract "<subjectnumber>^<SubjectInitials> -00"
% (for example: "2234IB^ML -00")

AllFiles = dir('*.dcm');
PP = findstr('00',AllFiles(1).name);
% if PP(1) < 10
if PP(1) < 8
    Idx = PP(2)+1;
else
    Idx = PP(1)+1;
end

FileSt = AllFiles(1).name(1:Idx);

for iRaw = 1:30
    if iRaw < 10
        ScanNum = ['0' num2str(iRaw)];
    else
        ScanNum = num2str(iRaw);
    end
    
    TT = length(dir([FileSt ScanNum '*']));
    if TT>0
        disp(['Scan ' ScanNum ' has ' num2str(TT) ' TRs in it.']);
    end
end

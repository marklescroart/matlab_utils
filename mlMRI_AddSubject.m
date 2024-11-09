function mlMRI_AddSubject(SubID,ExpName)

% usage: mlMRI_AddSubject(SubID,ExpName)
% 
% 
% 
% Created by ML 1.30.08

here = pwd;
try
    sDir = mlStructExtract(dir,'name');
    cd([sDir{grep(sDir,'-l',SubID)} '/Stats']);

    fDir = mlStructExtract(dir('*.dat'),'name');

    ToGrep = {{'-lv','PF','NoErr'},{'-lv','LO','NoErr'},{'-l','LO','NoErr'},{'-l','PF','NoErr'}};
    %ToGrep = {{'-lv','PFS','NoErr'},{'-lv','LO','NoErr'},{'-l','LO','NoErr'},{'-l','PFS','NoErr'}};
    WW = {'LO','PF','LO_NoErr','PF_NoErr'};
    %WW = {'LO','PFS','LO_NoErr','PFS_NoErr'};
    
    % Accounting for the possibility that all ROIs / Error conditions might
    % not have been run yet:
    for iT = 1:length(WW)
        try
            FF.(WW{iT})=fDir{grep(fDir,ToGrep{iT}{:})};
        catch
            fprintf('No %s file in directory for Subject %s\n\n',WW{iT},SubID);
        end
    end

    if length(SubID)>3
        %SubNm = regexp(SubID,'[A-Z]*(?=_)','match');
        uScoreIdx = regexp(SubID,'_');
        SubNm = SubID(1:uScoreIdx(1)-1);
    else
        SubNm = SubID;
    end

    for iF = 1:length(WW);
        if ~isempty(FF.(WW{iF}));
            NewFile = ['Subject_' SubNm '_' WW{iF} '_' ExpName '.txt'];
            fid = fopen(NewFile);
            if fid<0
                mlBV_DatFileReader(FF.(WW{iF}),NewFile);
                mlBV_DatFileReader(FF.(WW{iF}),['../../GroupStat/' ExpName '_SubjectAverage_' WW{iF} '.txt']);
            else
                fclose(fid);
                fprintf('Already found %s in Subject %s''s directory\n',WW{iF},SubNm)
            end
        end
    end
    cd(here)

catch
    cd(here)
    mlErrorCleanup
    rethrow(lasterror)
end
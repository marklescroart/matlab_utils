% Approximating polar angle of eye movements after first data point per
% trial



StimPosData = RunPosData(3:end,[2 4 6 8]);


try
    for iTrial = 1:nTrials;
        for iStim = 1:2
            % Trial index (choosing the time points to bin together for this particular trial):
            if iStim == 1
                start  = (iTrial-1)*nSecPerCond*sf+1;
                finish = (iTrial-1)*nSecPerCond*sf+ImTime*sf; % Change ISI to some other variable for shorter window after image to average over
            elseif iStim == 2
                start  = start(1)+ImTime*sf+ISI*sf;
                finish = finish(1)+ImTime*sf+ISI*sf;
            end
            TrIndex = start:finish;
            Xp1(iTrial,iStim) = ET(TrIndex(1),1);
            Yp1(iTrial,iStim) = ET(TrIndex(1),2);
            Xpos = ET(TrIndex,1)-Xp1(iTrial,iStim);
            Ypos = ET(TrIndex,2)-Yp1(iTrial,iStim);
            Xx(iTrial,iStim) = max(Xpos)/42.8; %42.8 = degrees per vis. angle for USC's magnet
            Yy(iTrial,iStim) = max(Ypos)/42.8; 
            Xstd(iTrial,iStim) = std(ET(TrIndex,1))/42.8;
            Ystd(iTrial,iStim) = std(ET(TrIndex,2))/42.8;
            
            pctTrOverHalfDegSTD(iRun)  = length(find(Xstd>.5))/length(Xstd);
            pctTrOverHalfDegMove(iRun) = max([length(find(Xx>.5))/length(Xx),length(find(Yy>.5))/length(Yy)]);
            pctOverOneDegMove(iRun) = max([length(find(Xx>1))/length(Xx),length(find(Yy>1))/length(Yy)]);
            
        end
    end
catch
    mlErrorCleanup
    rethrow(lasterror)
end
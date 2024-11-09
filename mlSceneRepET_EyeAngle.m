% Approximating polar angle of eye movements after first data point per
% trial



StimPosData = RunPosData(:,[2 4 6 8]); % First two trials are already chopped off
SASin = [mean(sind(StimPosData(:,1:2)),2),mean(sind(StimPosData(:,3:4)),2)];
SACos = [mean(cosd(StimPosData(:,1:2)),2),mean(cosd(StimPosData(:,3:4)),2)];
for iSA = 1:length(SASin)
    for iS12 = 1:2
        if SASin(iSA,iS12)>0 && SACos(iSA,iS12)>0
            SA(iSA,iS12) = atand(SASin(iSA,iS12)/SACos(iSA,iS12));
        elseif SACos(iSA,iS12) < 0
            SA(iSA,iS12) = atand(SASin(iSA,iS12)/SACos(iSA,iS12))+180;
        elseif SASin(iSA,iS12)<0 && SACos(iSA,iS12)>0
            SA(iSA,iS12) = atand(SASin(iSA,iS12)/SACos(iSA,iS12))+360;
        end
    end
end
StimAngle = round(SA);

disp(sprintf('For run %.0f, there are %.0f trials',iRun,nTrials));
try
    for iTrial = 1:nTrials;
        for iStim = 1:2
            % Trial index (choosing the time points to bin together for this particular trial):
            if iStim == 1%(iTr-1)*sf*nSecPerTr+1
                start  = (iTrial-1)*nSecPerCond*sf+1;
                finish = (iTrial-1)*nSecPerCond*sf+ImTime*sf+AddTime*sf; % Changed ISI to AddTime for shorter window after image to average over
                ii = 1; jj = 2; % These are indices for the column of StimPosDat from which we'll pull the stim angle information.
            elseif iStim == 2
                start  = start(1)+ImTime*sf+ISI*sf;
                finish = finish(1)+ImTime*sf+ISI*sf;
                ii = 3; jj = 4; 
            end
            TrIndex = start:finish;
            Xp1(iStim) = ET(TrIndex(1),1);
            Yp1(iStim) = ET(TrIndex(1),2);
            Xmean(iStim) = mean(ET(TrIndex,1));
            Ymean(iStim) = mean(ET(TrIndex,2));
            DD = sqrt((Xp1(iStim)-Xmean(iStim))^2+(Yp1(iStim)-Ymean(iStim))^2);
            MeanEyeMovement(iTrial,iStim) = DD;
            
            EASin = (Yp1(iStim)-Ymean(iStim));
            EACos = (Xmean(iStim)-Xp1(iStim));
            if EASin>0 && EACos>0
                EyeAngle(iTrial,iStim) = atand(EASin/EACos);
            elseif EACos < 0
                EyeAngle(iTrial,iStim) = atand(EASin/EACos)+180;
            elseif EASin<0 && EACos>0
                EyeAngle(iTrial,iStim) = atand(EASin/EACos)+360;
            end

        end
        fid = fopen([pPath 'Sub' SubjInits 'EyeAngle.txt'],'a');
        fprintf(fid,'%.2f\t%.2f\t%.2f\t%.2f\n',EyeAngle(iTrial,1),EyeAngle(iTrial,2),StimAngle(iTrial,1),StimAngle(iTrial,2));
        fclose(fid);
        fid = fopen([pPath 'Sub' SubjInits 'EyePos1.txt'],'a');
        fprintf(fid,'%.2f\t%.2f\t%.2f\t%.2f\n',Xp1(1),Yp1(1),Xp1(2),Yp1(2));
        fclose(fid);
        fid = fopen([pPath 'Sub' SubjInits 'EyeMean1.txt'],'a');
        fprintf(fid,'%.2f\t%.2f\t%.2f\t%.2f\n',Xmean(1),Ymean(1),Xmean(2),Ymean(2));
        fclose(fid);

    end

    
catch
    mlErrorCleanup
    rethrow(lasterror)
end
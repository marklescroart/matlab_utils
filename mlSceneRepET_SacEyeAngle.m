% Approximating polar angle of eye movements after first data point per
% trial


if strcmp(Sub_Exp,'MRI_GlobFeat/');
    AddTime = .15; %.50; %
else
    AddTime = 0; % -.100; % 
end

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
    SacAngle = zeros(nTrials,2);
    SacAngle(:,:) = NaN;
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
            
            DB(iStim,:) = ET(TrIndex,4);
            
            if any(DB(iStim,:)==1)
                Sidx = find(DB(iStim,:)==1);
                XSp1(iStim) = ET(Sidx(1),1);
                YSp1(iStim) = ET(Sidx(1),2);
                XSpEnd(iStim) = ET(Sidx(end),1);
                YSpEnd(iStim) = ET(Sidx(end),2);

                DDs = sqrt((XSp1(iStim)-XSpEnd(iStim))^2+(YSp1(iStim)-YSpEnd(iStim))^2);
                SacDist(iTrial,iStim) = DDs;
                SacDist(iTrial,iStim) = DDs;
                EASinSac = (YSp1(iStim)-YSpEnd(iStim));
                EACosSac = (XSpEnd(iStim)-XSp1(iStim));
                if EASinSac>0 && EACosSac>0
                    SacAngle(iTrial,iStim) = atand(EASinSac/EACosSac);
                elseif EACosSac < 0
                    SacAngle(iTrial,iStim) = atand(EASinSac/EACosSac)+180;
                elseif EASinSac<0 && EACosSac>0
                    SacAngle(iTrial,iStim) = atand(EASinSac/EACosSac)+360;
                end
            else
                SacDist(iTrial,iStim) = 0;
                SacAngle(iTrial,iStim) = NaN;
            end
            
            

        end
        fid = fopen([pPath 'Sub' SubjInits 'SacEyeAngle.txt'],'a');
        fprintf(fid,'%.2f\t%.2f\t%.2f\t%.2f\n',SacAngle(iTrial,1),SacAngle(iTrial,2),StimAngle(iTrial,1),StimAngle(iTrial,2));
        fclose(fid);
%         fid = fopen([pPath 'Sub' SubjInits 'SacEyePos1.txt'],'a');
%         fprintf(fid,'%.2f\t%.2f\t%.2f\t%.2f\n',Xp1(1),Yp1(1),Xp1(2),Yp1(2));
%         fclose(fid);
%         fid = fopen([pPath 'Sub' SubjInits 'EyeMean1.txt'],'a');
%         fprintf(fid,'%.2f\t%.2f\t%.2f\t%.2f\n',Xmean(1),Ymean(1),Xmean(2),Ymean(2));
%         fclose(fid);

    end

    
catch
    mlErrorCleanup
    rethrow(lasterror)
end
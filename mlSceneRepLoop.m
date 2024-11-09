% mlSceneRepLoop


SubjInits = {'AG' 'DR' 'LC'; 'KH' 'SJ' 'VV'};
Sub_Exp = {'MRI_T1wSwap/','MRI_GlobFeat/'};
ImUpTime = [.7,.5];
RunNum = {[1 2 3 4],[1 2 3 4],[1 2 3];
          [1 2 3 4 5 6],[2 3 4 5 6],[1 3 4 5 6]};

%fid = fopen('~/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/SceneRepETAnalysisDB.txt','a');
fid = fopen('~/Documents/Neuro_Docs/Projects-IUL/SceneRepresentation/SceneRepETAnalysisEyePos.txt','a');
labels = {'Ident' 'Trans' 'Rel' 'Trans+Rel' 'New' 'Blank'};
fprintf(fid,'Analysis run on %s\n\n',date);
%fprintf(fid,'Percent Saccades by condition:\n');
%fprintf(fid,'%10s',labels{:});
%fprintf(fid,'%3s%15s%15s','Sub','Pct Std>.5deg','Pcd Move>.5deg\n')
fclose(fid);
for iExp = 1:2
    for iSub = 1:3
        mlSceneRepEyeTrack(SubjInits{iExp,iSub},RunNum{iExp,iSub},Sub_Exp{iExp},ImUpTime(iExp),1)
    end
end

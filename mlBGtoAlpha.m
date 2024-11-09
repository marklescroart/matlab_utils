function mlBGtoAlpha(Ims,BG,Overwrite)

% Usage: mlBGtoAlpha(Im,BG,Overwrite)
% 
% 

if ~iscell(Ims)
    Ims{1} = Ims;
end
if ~exist('BG','var')
    BG = 128;
end
if ~exist('Overwrite','var')
    Overwrite = 0;
end

for iIm = 1:length(Ims); 
    Tmp = imread(Ims{iIm}); 
    Tmp = imresize(Tmp,[400 400]);
    TmpAlph = 255*ones(size(Tmp));
    BGIdx1 = find(Tmp==BG);
    BGIdx2 = find(Tmp==BG+1);
    if length(BGIdx1)>length(BGIdx2)
        BGIdx = BGIdx1;
    else
        BGIdx = BGIdx2;
    end
    clear BGIdx1 BGIdx2;
    TmpAlph(BGIdx) = 0;
    if Overwrite
        ImName = Ims{iIm};
    else
        ImName = [Ims{iIm}(1:end-4) '_Alpha.png'];
    end
    
    imwrite(Tmp,ImName,'png','Alpha',TmpAlph);
end
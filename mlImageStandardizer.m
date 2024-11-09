function mlImageStandardizer(DesiredSize,BG,imtype)

% Gives images on blank backgrounds a constant background (128 gray by
% default) and a constant size (256x256) 

if ~exist('DesiredSize','var')
    DesiredSize = input('What dimension should the images be?');
end
if ~exist('BG','var')
    BG = [];
end
if ~exist('imtype','var')
    imtype = 'png';
end

Flag.ShowFullScreen = false;


F = mlStructExtract(dir(['*.' imtype]),'name');

for i = 1:length(F); 
    Tmp = imread(F{i}); 
    if any(size(Tmp) ~= DesiredSize)
        if size(Tmp,1)~=size(Tmp,2);
            Ans = questdlg(['Image ' num2str(i) ' is not square. Crop & resize?']);
            if strcmpi(Ans,'no')||strcmpi(Ans,'cancel')
                error('Aborting.')
            end
            Mn = min([size(Tmp,1),size(Tmp,2)]); % don't take 3rd dimension into account.
            MnDim = find(size(Tmp)==Mn);
            Mx = max([size(Tmp,1),size(Tmp,2)]); % don't take 3rd dimension into account.
            St = round((Mx-Mn)/2); % where to start crop. Cut evenly from both sides. 
            if MnDim==1
                Idx1 = 1:Mn;
                Idx2 = St:St+Mn-1;
            elseif MnDim==2
                Idx1 = St:St+Mn-1;
                Idx2 = 1:Mn;
            end
            fprintf('Cropping image %s\n', F{i});
            Tmp = Tmp(Idx1,Idx2,:);
        end
        fprintf('Resizing image %s\n', F{i});
        Tmp = imresize(Tmp,DesiredSize(1:2));
    end
    
    if ~isempty(BG)
        if median(Tmp(:)) ~= BG;
            disp(['changing background for image ' num2str(i) '. Was: ' num2str(median(Tmp(:))) ]);
            Tmp(Tmp==median(Tmp(:))) = BG;
            disp(['... and is now: ' num2str(median(Tmp(:)))]);
        end
    end
    F{i} = strrep(F{i},' ','');
    fprintf('Finished with image %s\n\n',F{i});
    imwrite(Tmp,[lower(F{i}(1:end-4)) '.' imtype],imtype);
end

% Checking up: 

if Flag.ShowFullScreen
    F = mlStructExtract(dir(['*.' imtype]),'name');

    mlScreenSetup;
    Go = GetSecs;
    for j = 1:length(F)
        I = imread(F{j});
        Tx = Screen('MakeTexture',win,I);
        Screen('DrawTexture',win,Tx);
        Go = Screen('Flip',win,Go+.2);
        %Go = Screen('Flip',win,Go+.2);
    end
    WaitSecs(.5);
    c;
end
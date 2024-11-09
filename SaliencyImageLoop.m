% This is going to be a loop to move around the images I've created for Dr.
% Itti to run through his saliency map.
% 
% 09/27/06 ML

% ActiveFolder = '/Applications/MATLAB704/MarkCode/Namibia/ScreenShots_ForItti/RegularMac/';
ActiveFolder = '/Applications/MATLAB704/MarkCode/Namibia/ScreenShots_ForItti/NoisyMac/';

cd(ActiveFolder);
Folders = dir;
for ii = 1:length(Folders)
    if ~strcmp('.', Folders(ii).name(1))
        ImageInfo{ii} = dir([Folders(ii).name '/*.png']);
        for jj = 1:10
            if jj < 10
                NewFolder{jj} = [Folders(ii).name(1:end-1) '0' int2str(jj)];
                NumStr = ['0' int2str(jj)];
            else
                NewFolder{jj} = [Folders(ii).name(1:end-1) int2str(jj)];
                NumStr = [int2str(jj)];
            end
            mkdir(ActiveFolder,NewFolder{jj});
            Source{jj} = [ActiveFolder Folders(ii).name '/' ImageInfo{ii}(jj).name];
            Destination{jj} = [ActiveFolder NewFolder{jj} '/Input.png'];
            movefile(Source{jj}, Destination{jj});
        end
    end
end



% Note: the files need to be specified exactly if you want to change the
% names with "movefile". Not specifying a 

% Hechsler Pirenne
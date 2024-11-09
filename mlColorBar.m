function h = mlColorBar(BarDat,Cols,h,Groups)

% Usage: h = mlColorBar(BarDat,Cols [,h])
% 
% Inputs: BarDat = a vector (for matrices, setting colors works
%                  differently)
%         Cols = <length(BarDat)>x3 color matrix with RGB values [0:255]
%         h = figure handle (optional)

if exist('Groups','var')
    G = zeros(length(Groups),length(BarDat));
    L(1,:) = BarDat;
    for iG = 1:length(Groups)
        if iG~=length(Groups)
            G(iG,Groups{iG}) = BarDat(Groups{iG});
            L(Groups{iG}) = 0;
        else
            G(iG,:) = L;
        end
    end
    
    for iB = 1:size(G,1)
        hold on;
        bar(G(iB,:)','stack','FaceColor',Cols(iB,:)/255);
        hold off;
    end
else
    bCount = 1;
    for iB = 1:length(BarDat); %1:length(Data.PctRel);
        %if exist('h','var')
        %    figure(h);
        %else
        %    h = figure;
        %end
        hold on;
        BarPlot = zeros(length(BarDat),1);
        BarPlot(bCount) = BarDat(iB);
        bar(BarPlot,'FaceColor',Cols(iB,:)/255);
        hold off;
        bCount = bCount+1;
    end
end


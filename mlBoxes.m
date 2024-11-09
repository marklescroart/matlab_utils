function mlBoxes(PixGroup,ImSize)

BoxSize = 1;
Colors = [0 0 0;
        1 1 1];


%{
We're drawing Boxes: 

2   3

1   4

%}
for iGrp = 1:size(PixGroup,2);
    Im = zeros(ImSize(1),ImSize(2));
    Im(PixGroup(:,iGrp)) = 1;
    [VertIdx,HorzIdx] = find(Im);
    
    for i = 1:size(PixGroup,1)
        VertTmp = [VertIdx(i)-.5;
            VertIdx(i)-.5;
            VertIdx(i)-.5;
            VertIdx(i)+.5;
            VertIdx(i)+.5;
            VertIdx(i)+.5;
            VertIdx(i)+.5;
            VertIdx(i)-.5];
        HorzTmp = [HorzIdx(i)-.5;
            HorzIdx(i)+.5;
            HorzIdx(i)+.5;
            HorzIdx(i)+.5;
            HorzIdx(i)+.5;
            HorzIdx(i)-.5;
            HorzIdx(i)-.5;
            HorzIdx(i)-.5];
        hold on;
        plot(HorzTmp,VertTmp,'color',Colors(iGrp,:),'linewidth',1.2);
        hold off
    end
end

%{ 
Edges are overlapping. png print prints white lines as black. v.v. lame.
%% TRY set(fig_h,'inverthardcopy','off') to get rid of white-> black
call: (having called AttentionArguments)
image(ImG1)
axis square
axis off
colormap(cMap)
mlBoxes([G1',G2'],[10,10])
%}


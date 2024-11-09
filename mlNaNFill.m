function [NoNaNs WereNaNs] = mlNaNFill(InputVar)

NoNaNs = InputVar;
NanLogical = isnan(InputVar(:,1));

NanIdx = find(NanLogical);
RealIdx = find(~NanLogical);
AllIdx = 1:length(InputVar);

for iFill = 1:length(NanIdx)
    Before = find(AllIdx(RealIdx)<NanIdx(iFill));
    if length(Before) > 10
        Pre = Before(end-9:end);
        PreMeanX = mean(NoNaNs(Pre,1));
        PreMeanY = mean(NoNaNs(Pre,2));
    end

    After = find(AllIdx(RealIdx)<NanIdx(iFill));
    if length(After) > 10
        Post = After(1:10);
        PostMeanX = mean(InputVar(Post,1));
        PostMeanY = mean(InputVar(Post,2));
    end
    
    NoNaNs(NanIdx(iFill),1) = mean([PreMeanX PostMeanX]);
    NoNaNs(NanIdx(iFill),2) = mean([PreMeanY PostMeanY]);    
    
end

WereNaNs = NanIdx;
function mlTRTimer

AbsStart = GetSecs;
Gap = 1;
ii = 1;

TRTime(ii) = mlTRSync(1);
ii = ii+1;

while Gap < 2.1
    TRTime(ii) = mlTRSync(1);
    disp(['Got TR at ' num2str(mlRound(TRTime(ii)-AbsStart,.001)) ' seconds']);
    Gap = TRTime(ii)-TRTime(ii-1);
    ii = ii+1;
end

save TRTime TRTime
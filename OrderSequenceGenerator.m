% This stoopid loop is designed to be an order sequence generator. It calls
% Bosco's "repeatedhistory" function, so make sure that's on the path. It
% makes six different order sequences; change it in the code below if you
% want more / less.


for tt = 1:3
    Temp = repeatedhistory(2,4,4);
    Task(:,tt) = Temp(1:end-4)';
    csvwrite(['LO_Lat2_2f_Task' int2str(tt) '.txt'], Task(:,tt));
end
for uu = 1:3
    Task(:,uu+3) = flipud(Task(:,uu));
    csvwrite(['LO_Lat2_2f_Task' int2str(uu+3) '.txt'], Task(:,uu+3));
end

return


for kk = 1:3
    Order(:,kk) = repeatedhistory(5,1,2);  % Old LO_Lat2_2 = 7,3,1
    csvwrite(['LO_Lat2_2f_Order' int2str(kk) '.txt'], Order(:,kk));
end

for ll = 1:3
    Order(:,ll+3) = flipud(Order(:,ll));
    csvwrite(['LO_Lat2_2f_Order' int2str(ll+3) '.txt'], Order(:,ll+3));
end


return



for ii = 1:3
    Order(:,ii) = repeatedhistory(3,6,2);
end

for mm = 1:3
    csvwrite(['MacOrderList' int2str(mm) 'w2.txt'], Order(:,mm));
end

for jj = 1:3
    Task(:,jj+3) = flipud(Order(:,jj));
    csvwrite(['MacOrderList' int2str(jj+3) 'w2.txt'], Task(:,jj+3));
end



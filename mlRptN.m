function IdxOut = mlRptN(idxIn,rpt)

% Usage: IdxOut = mlRptN(idxIn,rpt)
%
% Given a straightforward index (e.g., an index variable in a for loop  
% that is counting up from 1 to 100), this function will return a repeating
% count of 1 to (rpt). 
% 
% Example:
% 
% for ii = 1:25
%     disp(mlRptN(ii,5))
% end
% 
% Created by ML 01/15/08

IdxOut = mod(idxIn,rpt);

IdxOut(IdxOut == 0) = rpt;

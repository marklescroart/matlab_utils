function varargout = mlFSLOrderList(OL, Prefix, TpT, Type, Pts)

% Usage: [OnsetCheck = ] mlFSLOrderList(OrderList [,Prefix] ,TimePerTrial
% [,Type] [,DeconvPoints])
% 
% Creates separate EVs (Expected Values = Predictors = Regressors) for FSL
% fMRI analysis, given a particular OrderList of conditions. 
% 
% This assumes that your order list will be numbered 1,2,3...n, with no
% skipping of condition numbers.
% 
% "Type" can be 'Deconv' or 'Block'. For 'Deconv', "DeconvPoints" 
% regressors will be created for each condition. 
% 
% Time per trial is time per trial (or Block). It should either be scalar
% (if all trials are the same length) or a vector (if each condition /
% block has a different length). The order of values in the vector should
% match the order of conditions).
% 
% A typical call would be: 
%
% OL = ones(30,1); 
% OL(11:20) = 2;
% OL(21:30) = 3;
% OL = Shuffle(OL);
% mlFSLOrderList(OL, 'Exp_Run1', 2, 'Block')
% 
% Created by ML 08.16.07

% Input Defaults: 

if ~exist('Type','var')
    Type = 'Block';
end
if ~exist('Pts','var')
    switch Type
        case 'Block'
            Pts = 1;
        case 'Deconv'
            Pts = 20;
    end
end
if ~exist('TpT','var')
    error('Please set time per trial / block.')
end

% Max should be highest-numbered condition - i.e., number of conditions
nConds = max(OL); 
nEvents = length(OL);
Count = ones(6,1);
Onset = cell(6,1);
TSF = 0; % Time So Far
for ii = 1:nEvents; 
    CC = OL(ii); % Current Condition
    Onset{CC}(Count(CC),1) = TSF;
    Onset{CC}(Count(CC),2) = TpT(CC);
    Onset{CC}(Count(CC),3) = 1;
    TSF = TSF+TpT(CC);
    Count(CC) = Count(CC)+1;
end

for jj = 1:nConds
    switch Type
        case 'Block'
            dlmwrite([Prefix '_C' num2str(jj) '.txt'],Onset{jj});
        case 'Deconv'
            error('Sorry, not working yet...');
            dlmwrite([Prefix '_C' num2str(jj) '_EV' num2str(jj) '.txt'],DD, 'delimiter','\t'); 
    end
end

if nargout
    varargout{1} = Onset;
end


%     switch Type
%         case 'Deconv'
%             for jj = 1:Pts
%                 DD = zeros(length(CC),3);
%                 DD(:,1) = TpT(ii)*(CC)-1+jj-1;
%                 DD(:,2) = TpT(ii);
%                 DD(:,3) = ones(length(CC),1);
%                 dlmwrite([Prefix '_C' num2str(ii) '_EV' num2str(jj) '.txt'],DD, 'delimiter','\t'); 
%             end
%         case 'Block'
%             EE = zeros(length(CC),3);
%             EE(:,1) = TpT(ii)*(CC-1);
%             EE(:,2) = TpT(ii);
%             EE(:,3) = ones(length(CC),1);
%             dlmwrite([Prefix '_C' num2str(ii) '.txt'],EE);
%         otherwise 
%             error([mfilename ':SecondArgument'],['What the hell do you think you''re doing. \n'...
%             'Fix your second input argument.'])
%     end           
%     
% end
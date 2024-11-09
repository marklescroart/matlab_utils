function Out = mlRound(In,RoundTo)
% Usage: Out = mlRound(In,RoundTo)
% 
% Rounds "In" to be an even multiple of "RoundTo"
%
% Created by ML (Stupid addition to Matlab's "round" function)

if ~exist('RoundTo','var')
    RoundTo = 1;
end

Out = round(In/RoundTo)*RoundTo;
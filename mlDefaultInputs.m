% mlDefaultInputs
% 
% Create the cell array variables "Inputs" and "InptValues", then call this
% script, and it will set the "Inputs" equal to the specified values in
% "InptValues"
% 
% Created by ML (??_??_??)

if ~exist('Inputs','var')||~exist('InptValues','var')
    error('mlDefaultInputs:UnknownVariables',['Please create the cell array variables "Inputs" and "InptValues"\n' ...
        'before calling the script "mlDefaultInputs".']);
end
nInputs = length(Inputs);
for iInpt = 1:nInputs
    if ~exist(Inputs{iInpt},'var')
        if ischar(InptValues{iInpt})
            eval([Inputs{iInpt} '=' '' InptValues{iInpt} '' ';']);
        else
            eval([Inputs{iInpt} '= [' num2str(InptValues{iInpt}) ' ];']);
        end
    end
end
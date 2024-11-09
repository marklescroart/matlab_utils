function mlPackageCodeForFunction(FunctionCall)

% Getting all necessary functions from mark's library for a particular call
StartPath = path;
try

    MarkCodePath = '/Applications/MATLAB74/MarkCode/ExperimentUtilities/';

    CalledVersion = which('mlPackageCodeForFunction');
    if regexp(CalledVersion,MarkCodePath)
        copyfile([MarkCodePath 'mlPackageCodeForFunction.m'],[pwd filesep]);
        error('I copied myself to this directory. Please call me again.')
    elseif regexp(CalledVersion,pwd)
        fprintf('Moving on using %s in this directory...\n\n',mfilename);
    end

    StartPath = rmpath(MarkCodePath);

    Success = 0;

    while ~Success
        try
            0;
            eval(FunctionCall)
            Success = 1;
            0;
        catch
            EE = lasterror
            MissingFn = regexp(EE.message,'(?<='')[a-z,A-Z,0-9,_]*(?='')','match');
            MissingFn = [MissingFn{1} '.m'];
            fprintf('Copying %s ...\n',MissingFn);
            copyfile([MarkCodePath MissingFn]);
        end
    end

catch
    path(StartPath);
    mlErrorCleanup;
end

path(StartPath);
function NewVar = mlStructExtract(InputStruct,Field)

% usage: NewVariable = mlStructExtract(InputStruct, Field)
%
% Extracts data from InputStruct(index).(Field) into a new variable.
% 
% Added 7.23.07: can now handle vectors as well as scalars
%
% Created (??) by ML

nFields = length(InputStruct);

switch(iscell(InputStruct))
    case 0
        if ischar(InputStruct(1).(Field)) %||isstruct(InputStruct(1).(Field))
            NewVar = cell(nFields,1); 
            for ii = 1:nFields;
                NewVar{ii} = InputStruct(ii).(Field);
            end
            
        else
            SizeTest = size(InputStruct(1).(Field));
            if all(SizeTest>1)
                NewVar = cell(nFields,1);
                for ii = 1:nFields;
                    NewVar{ii,:} = InputStruct(ii).(Field);
                end
            else
                if ~isstruct(InputStruct(1).(Field))
                    NewVar = zeros(nFields,SizeTest(2));
                end
                for ii = 1:nFields;
                    NewVar(ii,:) = InputStruct(ii).(Field);
                end
            end
        end
    case 1
        if ischar(InputStruct{1}.(Field))
            NewVar = cell(nFields,1);
            for ii = 1:nFields;
                NewVar{ii} = InputStruct{ii}.(Field);
            end
        else
            SizeTest = size(InputStruct{1}.(Field));
            NewVar = zeros(nFields,SizeTest(2));
            for ii = 1:nFields;
                NewVar(ii,:) = InputStruct{ii}.(Field);
            end
        end
end
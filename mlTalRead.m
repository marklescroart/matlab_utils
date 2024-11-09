function TalMatrix = mlTalRead(filename)

% Filename must be in the directory, or else specified as an absolute path


[TalPre{1:4}] = textread(filename, '%s%s%s%s');

XX(:,1) = TalPre{2}(2:end);
XX(:,2) = TalPre{3}(2:end);
XX(:,3) = TalPre{4}(2:end);

TalMatrix = zeros(8,3);

for ii = 1:8
    for jj = 1:3
        TalMatrix(ii,jj) = str2num(XX{ii,jj});
    end
end



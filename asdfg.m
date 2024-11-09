% asdfg

clc
clear all
clear global
close all

try
    BVQXfile(0, 'clearallobjects')
catch
    fprintf('You don''t seem to have BVQXtools installed... \nIf you''re going to use ML''s functions, you might want to install them. \n');
    fprintf('\nhttp://wiki.brainvoyager.com/BVQXtools\n\n');
end
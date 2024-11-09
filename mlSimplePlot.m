function varargout = mlSimplePlot(h)

% Usage: varargout = mlSimplePlot(h)

% Plots a quick graph with two lines; good for testing other functions (for
% play with "axes" function, for example) or quick demos.
% 
% Created by ML 2008.08.19

if nargin
    h = figure(h); 
else
    h = figure;
end


Y1 = 2*sin(0:pi/16:2*pi);
Y2 = 3*cos(0:pi/16:2*pi);
X = linspace(0,10,length(Y1));

plot(X,Y1,'r');
hold on;
plot(X,Y2,'b');
hold off;


if nargout
    varargout{1} = h;
end
function varargout = mlQuickPlot(h)

% Usage: varargout = mlQuickPlot([h])

% Plots a quick graph with two lines; good for testing other functions (for
% play with "axes" function, for example) or quick demos.
% 
% Created by ML 2008.08.19

if nargin
    h = figure(h); 
else
    h = figure;
end

x = linspace(0,2*pi,100);
xplot = linspace(0,1,100);

y1 = sin(4*x);
y2 = sin(3*x);

plot(xplot,y1,'b','linewidth',2)
hold on;
plot(xplot,y2,'r','linewidth',2);
hold off;

% title('Random Data');
% xlabel('Time');
% ylabel('Signal');
mlGraphSetup('Random Data','Time','Signal');


if nargout
    varargout{1} = h;
end
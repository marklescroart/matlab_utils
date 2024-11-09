function Im = mlGradientImage(x,y,Mn,Mx)

% Draws a gradient at a particular size

Im = repmat(linspace(Mx,Mn,x),y,1)';
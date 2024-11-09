figure; colormap(lbmap(60,'RedBlue')); colorbar
cmap = lbmap(60,'RedBlue')
tmp = rgb2hsv(cmap);
tmp(:,2) = 1
cmap2 = hsv2rgb(tmp);
colormap(cmap2)
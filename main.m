Yini = single(imread('Mars_dunes.jpg'));
ltot = size(Yini,1);
ctot = size(Yini,2);
trois = size(Yini,3);
image(uint8(Yini))
title('image initiale')
axis equal
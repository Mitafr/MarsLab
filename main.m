Yini = single(imread('Mars_dunes.jpg'));

ltot = size(Yini,1);
ctot = size(Yini,2);
trois = size(Yini,3);

nl = 5;
l = floor(ltot/nl);
%(test rgb%)
tr = Yini(l:l,l:l*2,1);
tg = Yini(l:l,l:l*2,2);
tb = Yini(l:l,l:l*2,3);

tt = reshape([tr, tb, tg], [], 3);


test = reshape(Yini, [], l);

image(uint8(Yini))
title('image initiale')
axis equal
%(codeur_APC(Yini,p);%)

function [P,E,Ip] = codeur_ACP(X,p)

end
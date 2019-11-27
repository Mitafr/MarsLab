Yini = single(imread('Mars_dunes.jpg'));

function show_image(image_input, title)
  image(uint8(image_input))
  title(title)
  axis equal
endfunction

function compare_images(I1, I2)
  figure,
  title('image initiale'),
  imshow(uint8(I1));
  figure,
  title('image finale'),
  imshow(uint8(I2));
endfunction

function imageFinale = build_image(P,w,h)  
  red = P(1:w*h, 1);
  green = P(1:w*h,2);
  blue = P(1:w*h,3);
  colors = cat(1,red,green,blue);
  imageFinale = reshape(colors, [w, h, 3]);
  return;
endfunction

#show_image(Yini, 'image initiale');
ltot = size(Yini,1);
ctot = size(Yini,2);
trois = size(Yini,3);
X = reshape(Yini, [ltot*ctot, 3]);

function [P,E,Ip] = codeur_ACP(X,p)  
  %{
  TEST de bloc
  nl = 50;
  l = floor(ltot/nl);
  tr = Yini(l:l,l:l*2,1);
  tg = Yini(l:l,l:l*2,2);
  tb = Yini(l:l,l:l*2,3);
  trmoyenne = mean(tr);

  blocknumber = 38456;
  line=floor((blocknumber*l)/ltot);
  b=mod(blocknumber*l, ltot);
  bloc1=Yini(b+1:b+l,line,1:3);
  X = reshape(squeeze(bloc1), [3, l]);
  X = Ynew;
  %}
  Xcentre = X - repmat(mean(X), size(X,1), 1);

  #Matrice centrée réduite
  Xstandard =Xcentre./(e*std(X,1))

  Vs = (Xcentre'*Xcentre)/size(Xcentre,2)-1;
  [E,D] = eig(cov(Xstandard));
  P=Xstandard*E;
  Ip=ones(1); #temporaire
  return;
endfunction

function X = decodeur_ACP(P,E)
  X = P*E';
  return;
endfunction

[Pmat, Vmat, Ipmat] = codeur_ACP(reshape(Yini, [ltot*ctot, 3]),3);
Xfinal = decodeur_ACP(Pmat, Vmat);
moyenneX = mean(X);
ecartTypeX = std(X);
n=size(X,1);
image = build_image(Xfinal .* repmat(ecartTypeX,[n 1]) + repmat(moyenneX,[n 1]),ltot,ctot);
imwrite(uint8(image), "output.jpg");
compare_images(Yini, image);
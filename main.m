clear;
clc;

Yini = single(imread('test2.jpg'));
#Yini = single(imread('Mars_dunes.jpg'));

function show_image(image_input, title)
  image(uint8(image_input))
  title(title)
  axis equal
endfunction

function compare_images(I1, I2)
  figure,
  set(gcf,'numbertitle','off','name','image initiale'),
  imshow(uint8(I1));
  figure,
  set(gcf,'numbertitle','off','name','image finale'),
  imshow(uint8(I2));
endfunction
function X = decodeur_ACP(P,E)
  X = P*transpose(E);
  return;
endfunction
ltot = size(Yini,1);
ctot = size(Yini,2);
trois = size(Yini,3);
X = reshape(Yini, [ltot*ctot,3]);

n=size(X,1);
nl = 50;
l = floor(ltot/nl);
nc = 50;
c = floor(ctot/nc);
excedingLine = mod(ltot,nl);
excedingCol = mod(ctot,nc);
tbloc=[];

function [P,E,Ip] = codeur_ACP(X,p)  
  moyenneBloc=mean(X);
  stdBloc=std(X);
  Xcentre = X - repmat(moyenneBloc, size(X,1), 1);
  Xreduite = (e*stdBloc);
  Xstandard = (X - repmat(moyenneBloc,[size(X,1) 1])) ./ repmat(stdBloc,[size(X,1) 1]);
  # Supression des NaN
  Xstandard(isnan(Xstandard))=0;

  Vs = (Xcentre'*Xcentre)/size(Xcentre,2)-1;
  [E,D] = eig(cov(Xstandard));
  
  # Vs = E*((D/size(X,1)).^(1/2));
  p=size(X,2)-p;
  for i = 1:p
    E(:,i) =[];
  end
  P=Xstandard*E;
  Ip=cumsum(E) / sum(E); #temporaire
  return;
endfunction

for i = 1:l*c
    xi=(i-1)*nl*nc;
    bloc=X(xi+1:(xi+1+nl*nc)-1,:);
    moyenneBloc=mean(bloc);
    stdBloc=std(bloc);
    
    [P,E,Ip] = codeur_ACP(bloc,1);
    Xfinal = decodeur_ACP(P, E);
    
    tbloc=cat(1,tbloc, Xfinal .* repmat(stdBloc,[size(bloc,1) 1]) + repmat(moyenneBloc,[size(bloc,1) 1]));
endfor
finalData = reshape(tbloc, [ltot,ctot,3]);
compare_images(Yini, finalData);
imwrite(uint8(Yini), "output_ini.jpg");
imwrite(uint8(finalData), "output_final.jpg");


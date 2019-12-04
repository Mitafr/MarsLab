clear;
clc;

Yini = single(imread('test2.jpg'));
%Yini = single(imread('Mars_dunes2.jpg'));

ltot = size(Yini,1);
ctot = size(Yini,2);
trois = size(Yini,3);
X = reshape(Yini, [ltot*ctot,3]);

n=size(X,1);
nl = 5;
l = floor(ltot/nl);
nc = 5;
c = floor(ctot/nc);
excedingLine = mod(ltot,nl);
excedingCol = mod(ctot,nc);
tbloc=[];
counter=0;
for i = 1:nl*nc:l*c
    xi=(i-1)*nl*nc;
    bloc=X(xi+1:(xi+1+nl*nc)-1,:);
    %{
    if ltot-xi < 0
        kk=xi+1-nl*nc;
        kkk=ltot;
        bloc=X(kk:kkk,:);
        oqz1=5;
    end
    %}
    moyenneBloc=mean(bloc);
    stdBloc=std(bloc);
    
    [P,E,Ip] = codeur_ACP(bloc,3);
    Xfinal = decodeur_ACP(P, E);
    
    tbloc=cat(1,tbloc, Xfinal .* repmat(stdBloc,[size(bloc,1) 1]) + repmat(moyenneBloc,[size(bloc,1) 1]));
    counter=counter+1;
end
finalData = reshape(tbloc, ltot,ctot,trois);
compare_images(Yini, finalData);
imwrite(uint8(Yini), "output_ini.jpg");
imwrite(uint8(finalData), "output_final.jpg");


function show_image(image_input, title)
  image(uint8(image_input))
  title(title)
  axis equal
end

function compare_images(I1, I2)
  figure,
  set(gcf,'numbertitle','off','name','image initiale'),
  imshow(uint8(I1));
  figure,
  set(gcf,'numbertitle','off','name','image finale'),
  imshow(uint8(I2));
end
function X = decodeur_ACP(P,E)
  X = P*transpose(E);
  return;
end

function [P,E,Ip] = codeur_ACP(X,p)  
  moyenneBloc=mean(X);
  stdBloc=std(X);
  Xcentre = X - repmat(moyenneBloc, size(X,1), 1);
  Xreduite = (eye()*stdBloc);
  Xstandard = (X - repmat(moyenneBloc,[size(X,1) 1])) ./ repmat(stdBloc,[size(X,1) 1]);
  % Supression des NaN
  Xstandard(isnan(Xstandard))=0;

  Vs = (Xcentre'*Xcentre)/size(Xcentre,2)-1;
  [E,D] = eig(cov(Xstandard));
  Ip=cumsum(E) / sum(E); %temporaire
  
  % Vs = E*((D/size(X,1)).^(1/2));
  p=size(X,2)-p;
  for i = 1:p
    E(:,i) =[];
  end
  P=Xstandard*E;
  return;
end


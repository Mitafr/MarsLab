clear;
clc;


Yini = single(imread('test2.jpg'));
%Yini = single(imread('Mars_Path_Finder.jpg'));

ltot = size(Yini,1);
ctot = size(Yini,2);
trois = size(Yini,3);
X = reshape(Yini, [ltot*ctot,3]);

n=size(X,1);
nl = 100;
l = floor(ltot/nl);
nc = 100;
c = floor(ltot/nc);

tblocc=[];
tblocl=[];
i=1;
j=1;
nl2=nl;
nc2=nc;
finl=false;
tIp=[];
finc=false;
while finl ~= true
    tblocc=[];
    if nl2 >= ltot
      nl2 = ltot;
      finl = true;
    end
    while finc ~= true
        if nc2 >= ctot
            nc2 = ctot;
            finc=true;
        end
        bloc1=Yini(i:nl2, j:nc2,:);
        bloc2d=reshape(bloc1,(nl2+1-i)*(nc2+1-j),3);

        moyenneBloc=mean(bloc2d);
        stdBloc=std(bloc2d);
        [P,E,Ip] = codeur_ACP(bloc2d,1);
        tIp=cat(1, tIp, Ip(1)); %temporaire
        nm = numel(P);
        
        Xfinal = decodeur_ACP(P, E);

        Xfinal = Xfinal .* repmat(stdBloc,[size(bloc2d,1) 1]) + repmat(moyenneBloc,[size(bloc2d,1) 1]);
        Xfinal=reshape(Xfinal,nl2-i+1,nc2-j+1,3);
        tblocc=cat(2, tblocc, Xfinal);
        j = nc2+1;
        nc2 = nc2 + nc;
    end
    tblocl=cat(1, tblocl, tblocc);
    i= nl2+1;
    nl2 = nl2+nl;
    j=1;
    nc2 = nc;
    finc=false;
end

compare_images(Yini, tblocl);
imwrite(uint8(Yini), "output_ini.jpg");
imwrite(uint8(tblocl), "output_final.jpg");

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
    E=fliplr(E);
    Ip=cumsum(var(Xstandard*E)) / sum(var(Xstandard*E)); %temporaire
    

    % Vs = E*((D/size(X,1)).^(1/2));
    p=size(X,2)-p;
    for i = 1:p
        E(:,i)=[];
    end
    P=Xstandard*E;
    return;
end

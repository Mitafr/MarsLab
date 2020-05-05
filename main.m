clear;
clc;

Yini = single(imread('test2.jpg'));
%Yini = single(imread('Mars_dunes.jpg'));

ltot = size(Yini,1);
ctot = size(Yini,2);
trois = size(Yini,3);
X = reshape(Yini, [ltot*ctot,3]);

n=size(X,1);
nl = 3;
nc = 3;
ncomp = 1;
l = floor(ltot/nl);
c = floor(ltot/nc);
numBitsSent = 0;

Yfinal=[];
Ybloc=[];

i=1;
j=1;
nl2=nl;
nc2=nc;
tIp=[];


% end of line
finl=false;
% end of col
finc=false;
while finl ~= true
    Ybloc=[];
    if nl2 >= ltot
      nl2 = ltot;
      finl = true;
    end
    while finc ~= true
        if nc2 >= ctot
            nc2 = ctot;
            finc=true;
        end
        bloc=Yini(i:nl2, j:nc2,:);
        bloc2d=reshape(bloc,(nl2+1-i)*(nc2+1-j),3);

        mu=mean(bloc2d);
        stdBloc=std(bloc2d);
        % Code current bloc
        [P,E,Ip] = codeur_ACP(bloc2d,ncomp);
        % Total informations portées pour chaque bloc
        tIp=cat(1, tIp, sum(Ip));
        
        numBitsSent = numBitsSent + numel(P);
        
        % Decode bloc
        Xfinal = decodeur_ACP(P, E);
        
        % reconstruction du bloc
        Xfinal = Xfinal + repmat(mu,[size(bloc2d,1) 1]);
        Xfinal=reshape(Xfinal,nl2-i+1,nc2-j+1,3);
        Ybloc=cat(2, Ybloc, Xfinal);
        j = nc2+1;
        nc2 = nc2 + nc;
    end
    Yfinal=cat(1, Yfinal, Ybloc);
    i= nl2+1;
    nl2 = nl2+nl;
    j=1;
    nc2 = nc;
    finc=false;
end

compare_images(Yini, Yfinal);
imwrite(uint8(Yini), "output_ini.jpg");
imwrite(uint8(Yfinal), "output_final.jpg");
msgbox(strcat("Quality : ", int2str(mean(tIp)), "%"));
msgbox(strcat("Nombre de Bits envoyés à la terre : ", int2str(numBitsSent), " bits"));


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
    X = P*E';
    return;
end

function [P,E,Ip] = codeur_ACP(X,p)  
    moyenneBloc=mean(X);
    stdBloc=std(X);
    
    Xcentre = X - repmat(moyenneBloc, size(X,1), 1);
    Xreduite = X / stdBloc;
    Xstandard = Xcentre ./ repmat(stdBloc,[size(X,1) 1]);
    % NaN Supression
    Xstandard(isnan(Xstandard))=0;

    [E,D] = eig(cov(Xstandard));
    latent=diag(D);
    Ip=latent/sum(latent)*100;
    
    E = E(:,1:p);
    Ip = Ip(1:p);
    P=Xcentre*E;
    return;
end

%load frey_rawface.mat  %20*28 images
%addpath("C:\\Users\\Florian\\Downloads\\PRD\\EmotionMatlab\\gplvm");
clear;
load learning3.mat;
img = imread('11.png');
imgtest = reshape(img,1,4050);%551
imgtest = double(imgtest);
N=size(obs,1); 

D=length(obs{1}.data);

data=zeros(N,D); 
for i=1:N
    size(obs{i}.data);
    data(i,:)=obs{i}.data(1:D,1);% recopie de chaque colonne de obs{i}.data dans chaque ligne de data
end
Y=data;% Y contient toutes les images de la base d'apprentissage sous forme de ligne pour chaque image
close all;
% figure(1)
% for i=1:N
%   im=Y(i,:);% r�cup�ration de la ligne i de Y dans im
%   im2=reshape(im,imgwidth,imglen);% redimmensionnement de im en 29*19 pour voir une vrai image et pas seulement un trait
% 
%   imshow(im2, [])
  %pause(0.01);
% end
%pause(1);

% Fix seeds
%randn('seed', 1e5);
%rand('seed', 1e5);

% Extract data dimensions and set IVM active set size
numData = size(Y, 1);%91
dataDim = size(Y, 2);%551
numActive = 21;
extIters = 15;
% Don't centre the data so that when there is no Brendan there is no Brendan.
meanData = zeros(1, dataDim); %mean(Y); matrice de 0 
Y = Y  - repmat(meanData, size(Y, 1), 1);% techniquement, repmap =0(60*551) donc Y=Y

% Initialise X with PCA
[v, u] = pca(Y); %v: coeff (551*1) ; u=principal components(551*551)

v(find(v<0))=0;% find(v<0) retourne la liste de toutes les positions o� v est <0; donc mise � 0 de tous les �l�ments de v <0
%size(Y) 60*551
%size(u) 551*551

X = Y*u(:, 1:2)*diag(1./sqrt(v(1:2))); %diag va cr�er une matrice diagonale(2*2) avec l'inverse des racine carr�e des 2 premiers �l�ments de v sur la diagonale
%u(:, 1:2) renvoie les 2 premiers �l�ments de chaque ligne de u(551*2)
%donc multiplication (60*551)*(551*2)*(2*2) => X de taille 60*2
%X = u(:, 1:2)*diag(1./sqrt(v(1:2)));
%ddddd = (X >0)
disp('X');
Xtest=imgtest*u(:, 1:2)*diag(1./sqrt(v(1:2)));

% Initialise theta
theta(1) = 1;
theta(2) = 1;
theta(3) = 1;

if 1
% Options for optimisation in latent space
options = foptions;
options(1) = 0;
options(9) = 0;
options(14) = 100;

% options for kernel optimisation
optionsKernel = foptions;
optionsKernel(1) = 0;
optionsKernel(9) = 0;
optionsKernel(14) = 100;

else

options = optimset('GradObj','on','MaxIter',100,'Display','iter');
optionsKernel = options;

end

% Fit the GP latent variable model
[X, theta, activeSet] = gplvmfit(X, Y, theta, numActive, optionsKernel, ...
		      options, extIters)

% compute the kernel from results
[K, invK] = computeKernel(X(activeSet, :), theta);

% Visualise the results
gplvmvisualise(X, Y, invK, theta, [], meanData, activeSet, 'imageVisualise', ...
	       'imageModify',Xtest, [imgwidth, imglen]);

if 1
%my_visualize(X, Y, invK, theta, [], meanData, activeSet, 'imageVisualise', 'imageModify', [imgwidth, imglen]);
end

feel= feelings(getFeeling(Xtest,X))

save onesubject.mat X theta activeSet
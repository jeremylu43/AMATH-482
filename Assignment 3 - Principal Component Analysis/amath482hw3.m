clear; close all; clc;

%% Noisy Case
load('cam1_1.mat')
load('cam2_1.mat')
load('cam3_1.mat')

%% Collect position data
ideal_1 = size(vidFrames1_1, 4);
ideal_x1 = zeros(1,ideal_1);
ideal_y1 = zeros(1,ideal_1);

for j = 1:ideal_1
    V = vidFrames1_1(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,ideal_x1(j)] = max(mean(max(V,[],1),3));
    [~,ideal_y1(j)] = max(mean(max(V,[],2),3));
end

ideal_2 = size(vidFrames2_1, 4);
ideal_x2 = zeros(1,ideal_2);
ideal_y2 = zeros(1,ideal_2);

for j = 1:ideal_2
    V = vidFrames2_1(:,:,:,j);
    V(1:80,:,:) = 0;
    V(400:480,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,380:640,:) = 0;
    
    [~,ideal_x2(j)] = max(sum(max(V,[],1),3));
    [~,ideal_y2(j)] = max(sum(max(V,[],2),3));
end

ideal_3 = size(vidFrames3_1, 4);
ideal_x3 = zeros(1,ideal_3);
ideal_y3 = zeros(1,ideal_3);

for j = 1:ideal_3
    V = vidFrames3_1(:,:,:,j);
    V(1:200,:,:) = 0;
    V(400:480,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,540:640,:) = 0;
    
    [~,ideal_x3(j)] = max(sum(max(V,[],1),3));
    [~,ideal_y3(j)] = max(sum(max(V,[],2),3));
end

%% Adjust video lengths
ideal_x2 = ideal_x2(10:235);
ideal_y2 = ideal_y2(10:235);
ideal_x3 = ideal_x3(1:226);
ideal_y3 = ideal_y3(1:226);

%% Perform PCA
X = [ideal_x1;ideal_y1;ideal_x2;ideal_y2;ideal_x3;ideal_y3];
[m,n] = size(X);
mn = mean(X,2);
X = X - repmat(mn,1,n);

[U,S,V] = svd(X, 'econ');
sig = diag(S);
lambda = diag(S).^2;
Y = U'*X;

figure()
plot(1:6, lambda/sum(lambda), 'ko', 'Linewidth', 2, 'MarkerFaceColor',[0.5,0.5,0.5]);
title("Ideal Case: PCA Energies")
xlabel("Dimension"); ylabel("Energy");
saveas(gcf,'Ideal_pca.png')

figure()
subplot(2,1,1)
plot(1:226, X(2,:),1:226, X(1,:), 'Linewidth', 2)
ylabel("Displacement (pixels)"); xlabel("Frames"); 
title("Ideal Case: Displacement in Z and XY Directions");
legend("Z", "XY")
subplot(2,1,2)
plot(1:226, Y(1,:),'r','Linewidth', 2)
ylabel("Displacement"); xlabel("Frames"); 
title("Ideal Case: Displacement in Principal Component(s) Directions");
legend("PC1")
saveas(gcf,'Ideal_displacement.png')

%% Noisy Case

load('cam1_2.mat')
load('cam2_2.mat')
load('cam3_2.mat')

%% Collect position data
noisy_1 = size(vidFrames1_2, 4);
noisy_x1 = zeros(1,noisy_1);
noisy_y1 = zeros(1,noisy_1);

for j = 1:noisy_1
    V = vidFrames1_2(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,noisy_x1(j)] = max(mean(max(V,[],1),3));
    [~,noisy_y1(j)] = max(mean(max(V,[],2),3));
end

noisy_2 = size(vidFrames2_2, 4);
noisy_x2 = zeros(1,noisy_2);
noisy_y2 = zeros(1,noisy_2);

for j = 1:noisy_2
    V = vidFrames2_2(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,noisy_x2(j)] = max(mean(max(V,[],1),3));
    [~,noisy_y2(j)] = max(mean(max(V,[],2),3));
end

noisy_3 = size(vidFrames3_2, 4);
noisy_x3 = zeros(1,noisy_3);
noisy_y3 = zeros(1,noisy_3);

for j = 1:noisy_3
    V = vidFrames3_2(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,noisy_x3(j)] = max(mean(max(V,[],1),3));
    [~,noisy_y3(j)] = max(mean(max(V,[],2),3));
end

%% Adjust video lengths
noisy_x2 = noisy_x2(20:333);
noisy_y2 = noisy_y2(20:333);
noisy_x3 = noisy_x3(1:314);
noisy_y3 = noisy_y3(1:314);

%% Perform PCA
X = [noisy_x1;noisy_y1;noisy_x2;noisy_y2;noisy_x3;noisy_y3];
[m,n] = size(X);
mn = mean(X,2);
X = X - repmat(mn,1,n);

[U,S,V] = svd(X, 'econ');
sig = diag(S);
lambda = diag(S).^2;
Y = U'*X;

figure()
plot(1:6, lambda/sum(lambda), 'ko', 'Linewidth', 2, 'MarkerFaceColor',[0.5,0.5,0.5]);
title("Noisy Case: PCA Energies")
xlabel("Dimension"); ylabel("Energy");
saveas(gcf,'Noisy_pca.png')

figure()
subplot(2,1,1)
plot(1:314, X(2,:),1:314, X(1,:), 'Linewidth', 2)
ylabel("Displacement"); xlabel("Frames"); 
title("Noisy Case: Displacement in Z and XY Directions");
legend("Z", "XY")
subplot(2,1,2)
plot(1:314, Y(1,:),1:314, Y(2,:),1:314, Y(3,:),'r','Linewidth', 2)
ylabel("Displacement"); xlabel("Frames"); 
title("Noisy Case: Displacement in Principal Component(s) Directions");
legend("PC1", "PC2", "PC3")
saveas(gcf,'Noisy_displacement.png')

%% Horizontal Displacement
load('cam1_3.mat')
load('cam2_3.mat')
load('cam3_3.mat')

%% Collect position data
hdisp_1 = size(vidFrames1_3, 4);
hdisp_x1 = zeros(1,hdisp_1);
hdisp_y1 = zeros(1,hdisp_1);

for j = 1:hdisp_1
    V = vidFrames1_3(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,hdisp_x1(j)] = max(mean(max(V,[],1),3));
    [~,hdisp_y1(j)] = max(mean(max(V,[],2),3));
end

hdisp_2 = size(vidFrames2_3, 4);
hdisp_x2 = zeros(1,hdisp_2);
hdisp_y2 = zeros(1,hdisp_2);

for j = 1:hdisp_2
    V = vidFrames2_3(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,hdisp_x2(j)] = max(mean(max(V,[],1),3));
    [~,hdisp_y2(j)] = max(mean(max(V,[],2),3));
end

hdisp_3 = size(vidFrames3_3, 4);
hdisp_x3 = zeros(1,hdisp_3);
hdisp_y3 = zeros(1,hdisp_3);

for j = 1:hdisp_3
    V = vidFrames3_3(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,hdisp_x3(j)] = max(mean(max(V,[],1),3));
    [~,hdisp_y3(j)] = max(mean(max(V,[],2),3));
end

%% Adjust video lengths
hdisp_x1 = hdisp_x1(3:239);
hdisp_y1 = hdisp_y1(3:239);
hdisp_x2 = hdisp_x2(35:271);
hdisp_y2 = hdisp_y2(35:271);

%% Perform PCA
X = [hdisp_x1;hdisp_y1;hdisp_x2;hdisp_y2;hdisp_x3;hdisp_y3];
[m,n] = size(X);
mn = mean(X,2);
X = X - repmat(mn,1,n);

[U,S,V] = svd(X, 'econ');
sig = diag(S);
lambda = diag(S).^2;
Y = U'*X;

figure()
plot(1:6, lambda/sum(lambda), 'ko', 'Linewidth', 2, 'MarkerFaceColor',[0.5,0.5,0.5]);
title("Horizontal Displacement: PCA Energies")
xlabel("Dimension"); ylabel("Energy");
saveas(gcf,'hd_pca.png')

figure()
subplot(2,1,1)
plot(1:237, X(2,:),1:237, X(1,:), 'Linewidth', 2)
ylabel("Displacement"); xlabel("Frames"); 
title("Horizontal Displacement: Displacement in Z and XY Directions");
legend("Z", "XY")
subplot(2,1,2)
plot(1:237, Y(1,:),1:237, Y(2,:),'r','Linewidth', 2)
ylabel("Displacement (pixels)"); xlabel("Frames)"); 
title("Horizontal Displacement: Displacement in Principal Component(s) Directions");
legend("PC1", "PC2", "PC3")
saveas(gcf,'hd_displacement.png')

%% Horizontal Displacement with Rotation
load('cam1_4.mat')
load('cam2_4.mat')
load('cam3_4.mat')

%% Collect position data
rotate_1 = size(vidFrames1_4, 4);
rotate_x1 = zeros(1,rotate_1);
rotate_y1 = zeros(1,rotate_1);

for j = 1:rotate_1
    V = vidFrames1_4(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,rotate_x1(j)] = max(mean(max(V,[],1),3));
    [~,rotate_y1(j)] = max(mean(max(V,[],2),3));
end

rotate_2 = size(vidFrames2_4, 4);
rotate_x2 = zeros(1,rotate_2);
rotate_y2 = zeros(1,rotate_2);

for j = 1:rotate_2
    V = vidFrames2_4(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,rotate_x2(j)] = max(mean(max(V,[],1),3));
    [~,rotate_y2(j)] = max(mean(max(V,[],2),3));
end

rotate_3 = size(vidFrames3_4, 4);
rotate_x3 = zeros(1,rotate_3);
rotate_y3 = zeros(1,rotate_3);

for j = 1:rotate_3
    V = vidFrames3_4(:,:,:,j);
    V(1:180,:,:) = 0;
    V(:,1:240,:) = 0;
    V(:,460:640,:) = 0;
    
    [~,rotate_x3(j)] = max(mean(max(V,[],1),3));
    [~,rotate_y3(j)] = max(mean(max(V,[],2),3));
end

%% Adjust video lengths
rotate_x2 = rotate_x2(14:405);
rotate_y2 = rotate_y2(14:405);
rotate_x3 = rotate_x3(1:392);
rotate_y3 = rotate_y3(1:392);

%% PCA
X = [rotate_x1;rotate_y1;rotate_x2;rotate_y2;rotate_x3;rotate_y3];
[m,n] = size(X);
mn = mean(X,2);
X = X - repmat(mn,1,n);

[U,S,V] = svd(X, 'econ');
sig = diag(S);
lambda = diag(S).^2;
Y = U'*X;

figure()
plot(1:6, lambda/sum(lambda), 'ko', 'Linewidth', 2, 'MarkerFaceColor',[0.5,0.5,0.5]);
title("Horizontal Displacement w/ Rotation: PCA Energies")
xlabel("Dimension"); ylabel("Energy");
saveas(gcf,'hdrotate_pca.png')

figure()
subplot(2,1,1)
plot(1:392, X(2,:),1:392, X(1,:), 'Linewidth', 2)
ylabel("Displacement"); xlabel("Frames"); 
title("Horizontal Displacement w/ Rotation: Displacement in Z and XY Directions");
legend("Z", "XY")
subplot(2,1,2)
plot(1:392, Y(1,:),1:392, Y(2,:), 1:392, Y(3,:),'r','Linewidth', 2)
ylabel("Displacement"); xlabel("Frames"); 
title("Horizontal Displacement w/ Rotation: Displacement in Principal Component(s) Directions");
legend("PC1", "PC2", "PC3", "PC4")
saveas(gcf,'hdrotate_displacement.png')
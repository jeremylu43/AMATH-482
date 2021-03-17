%% Read Image
%540x960x369

v = VideoReader('monte_carlo_low.mp4');
colorFrames = read(v);
    for f = 1:369
        J = rgb2gray(colorFrames(:,:,:,f));   % CONVERT COLOR TO GRAY
        X(:,f) = J(:);                     % GRAY FRAMES
    end
    
%% Perform DMD
X = im2double(X);
t = linspace(0,379/60,379);
dt = t(2)-t(1);
vid_length = size(X, 2);
X1 = X(:, 1:end-1);
X2 = X(:, 2:end);

[U, Sigma, V] = svd(X1,'econ');
S = U'*X2*V*diag(1./diag(Sigma));
[eV, D] = eig(S); % compute eigenvalues + eigenvectors
mu = diag(D); % extract eigenvalues
omega = log(mu)/dt;
Phi = U*eV;

%% Create DMD Solution

y0 = Phi\X1(:,1); % pseudoinverse to get initial conditions
umodes = zeros(length(y0),vid_length);
for iter = 1:vid_length
    umodes(:,iter) = y0.*exp(omega*t(iter));
end
udmd = Phi*umodes;
%% Background image
background = reshape(udmd(:,1), [540 960]);
imshow(background);
%% sparse dmd
sparse = X-abs(udmd(:,1));
%%
video = VideoWriter('monte_carlo_foreground.avi'); %create the video object
open(video); %open the file for writing
for ii=1:369 %where N is the number of images
  foreground = reshape(sparse(:,ii), [540 960]);
  I = mat2gray(foreground); %read the next image
  writeVideo(video,I); %write the image to file
end
close(video); %close the file

%%
figure();
t = tiledlayout(3,4,'TileSpacing','Compact','Padding','Compact');
for i=1:12
    nexttile
    imshow(mat2gray(reshape(sparse(:,30*i), [540 960])));
    title([num2str(i*30),'-th Frame']) 
end
saveas(gcf, 'monte_carlo_frames.png')
%% Read Image
%540x960x454

v = VideoReader('ski_drop_low.mp4');
colorFrames = read(v);
for f = 1:454
        J = rgb2gray(colorFrames(:,:,:,f));   % CONVERT COLOR TO GRAY
        X(:,f) = J(:);                     % GRAY FRAMES
    end
%% Perform DMD
X = im2double(X);
t = linspace(0,454/60,454);
dt = t(2)-t(1);
vid_length = size(X, 2);
X1 = X(:, 1:end-1);
X2 = X(:, 2:end);

[U, Sigma, V] = svd(X1,'econ');
S = U'*X2*V*diag(1./diag(Sigma));
[eV, D] = eig(S); % compute eigenvalues + eigenvectors
mu = diag(D); % extract eigenvalues
omega = log(mu)/dt;
Phi = U*eV;

%% Create DMD Solution

y0 = Phi\X1(:,1); % pseudoinverse to get initial conditions
umodes = zeros(length(y0),vid_length);
for iter = 1:vid_length
    umodes(:,iter) = y0.*exp(omega*t(iter));
end
udmd = Phi*umodes;
%%
background = mat2gray(abs(reshape(udmd(:,1), [540 960])));
imshow(background);
%% lowrank dmd
sparse = X-abs(udmd(:,1));
%%
video = VideoWriter('ski_drop_foreground.avi'); %create the video object
open(video); %open the file for writing
for ii=1:453 %where N is the number of images
  foreground = reshape(sparse(:,ii), [540 960]);
  I = mat2gray(foreground); %read the next image
  writeVideo(video,I); %write the image to file
end
close(video); %close the file
%%
figure();
t = tiledlayout(3,4,'TileSpacing','Compact','Padding','Compact');
for i=1:12
    nexttile
    imshow(mat2gray(reshape(sparse(:,37*i), [540 960])));
    title([num2str(i*37),'-th Frame']) 
end
saveas(gcf, 'ski_drop_frames.png')

%%
imshow(rgb2gray(colorFrames(:,:,:,1)));
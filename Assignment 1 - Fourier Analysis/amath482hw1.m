% Clean workspace
clear all; close all; clc

load subdata.mat % Imports the data as the 262144x49 (space by time) matrix called subdata

L = 10; % spatial domain
n = 64; % Fourier modes
x2 = linspace(-L,L,n+1); x = x2(1:n); y =x; z = x;
k = (2*pi/(2*L))*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k);

[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);

for j=1:49
Un(:,:,:)=reshape(subdata(:,j),n,n,n);
M = max(abs(Un),[],'all');
close all, isosurface(X,Y,Z,abs(Un)/M,0.7)
axis([-20 20 -20 20 -20 20]), grid on, drawnow
%pause(0.5)
end

%% Figure 1
figure
Un(:,:,:)=reshape(subdata(:,49),n,n,n);
isosurface(X,Y,Z,abs(Un),1)
title('Unfiltered Submarine Data (49th time step)')
xlabel('position (x)'); ylabel('position (y)'); zlabel('position (z)')
gca.FontSize = 14;
view(-45,15)
axis([-L L -L L -L L]), grid on, drawnow
pause(5)
print -depsc sub_unfiltered.eps

close all

%% Averaging Signal
Utn_ave=zeros(n,n,n);
for j=1:49
Un(:,:,:)=reshape(subdata(:,j),n,n,n);
Utn_ave=Utn_ave+fftn(Un);
end
ave = Utn_ave./49;
ave = abs(ave)/max(abs(ave(:)));
figure
isosurface(Kx,Ky,Kz,fftshift(ave),1)
title('Averaged Submarine Data (49th time step)')
xlabel('position (x)'); ylabel('position (y)'); zlabel('position (z)')
gca.FontSize = 14;
view(-45,15)
axis([-L L -L L -L L]), grid on, drawnow
pause(5)
print -depsc sub_averaged.eps
Utn_ave=abs(fftshift(Utn_ave))./49;

[m, index] = max(Utn_ave(:)); %
[ii,jj,ll] = ind2sub(size(Utn_ave),index);
x=ks(jj); y=ks(ii); z=ks(ll);



%% Filter Data

tau=0.01;
filter=exp(-tau*(((Kx-x).^2)+((Ky-y).^2)+((Kz-z).^2))); % Define the filter

x_coord = zeros(1,49); y_coord = zeros(1,49); z_coord = zeros(1,49);

for j=1:49
    Un(:,:,:)=reshape(subdata(:,j),n,n,n);
    Un_shift = fftshift(fftn(Un));
    Utn_filter= Un_shift.*filter;
    Unf = ifftn(Utn_filter);
    
    %% Figure 2
    isosurface(X,Y,Z,abs(Unf),0.9*max(abs(Unf(:))))
    gca.FontSize = 14;
    view(-45,15)
    axis([-L L -L L -L L]), grid on, drawnow
    xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis')
    title("Denoised Submarine Positions")
    pause(0.05)
    
    %% Storing Submarine Location
    [maxx, index] = max(Unf(:));
    [ii,jj,ll] = ind2sub(size(Unf),index);
    x_coord(j) = X(ii,jj,ll); y_coord(j) = Y(ii,jj,ll); z_coord(j) = Z(ii,jj,ll);
end
print -depsc sub_location.eps
pause(2)

%% Figure 3

close all
plot3(x_coord,y_coord,z_coord, '-o', 'MarkerSize', 3) 
hold on
plot3(x_coord(end),y_coord(end),z_coord(end), 'ro', 'MarkerSize', 3)
title('Submarine Trajectory')
legend('Submarine Movement','Submarine End Location')
xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis')
gca.FontSize = 14;
view(-45,15)
axis([-L L -L L -L L]), grid on, drawnow

print -depsc sub_final.eps
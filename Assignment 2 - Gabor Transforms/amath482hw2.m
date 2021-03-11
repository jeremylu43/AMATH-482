clear
%% Loading Songs

%Playing Guns n Roses
%figure(1)
%[y, Fs] = audioread('GNR.m4a'); %y=data, Fs = rate
%trgnr = length(y)/Fs; % record time in seconds
%plot((1:length(y))/Fs,y);
%xlabel('Time [sec]');
%ylabel('Amplitude');
%title('Sweet Child O'' Mine');
%p8 = audioplayer(y,Fs);
%playblocking(p8);
%close;

%Playing Comfortably Numb

figure(1)
[y, Fs] = audioread('Floyd.m4a');
fifth = (length(y)-1)/5;
y=y(4*fifth+1:5*fifth);
trfloyd = length(y)/Fs; % record time in seconds
plot((1:length(y))/Fs,y);
xlabel('Time [sec]');
ylabel('Amplitude');
title('Comfortably Numb');
%p8 = audioplayer(y,Fs);
%playblocking(p8);

n = length(y);
L = trfloyd;
k = (1/L)*[0:(n/2-1) -n/2:-1]; % use hertz instead of radians
ks = fftshift(k);
a=250;
ts=linspace(0,L,n+1);
t=ts(1:n);
tau=0:0.25:L;

%% Gabor Transform

for j = 1:length(tau)
    g=exp(-a*(t-tau(j)).^2);
    yg = g.*y';
    ygt = fft(yg);
    ygtspec(j,:) = abs(fftshift(ygt));
end

%% Plot Spectrogram

figure(2)
pcolor(tau,ks,log(ygtspec+1)') % plots with logarithm
%pcolor(tau,ks,ygtspec')  %plots without logarithm
shading interp
set(gca,'ylim',[200, 900],'Fontsize',16)
colormap(hot)
colorbar
xticks([0 2 4 6 8 10])
%xticklabels({'12','14','16','18','20','22'}) %Change accordingly
%xticklabels({'24','26','28','30','32','34'}) %Change accordingly
%xticklabels({'36','38','40','42','44','46'}) %Change accordingly
%xticklabels({'48','50','52','54','56','58'}) %Change accordingly
xlabel('time (t)'), ylabel('frequency (Hz)')
title(['a = ', num2str(a)],'FontSize', 16)
%saveas(gcf,'pinkfloyd_g5_nolog.png')

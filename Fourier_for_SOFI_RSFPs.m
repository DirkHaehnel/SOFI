% calculate the OTF of the microscope and Fourier-massage an SOFI image to
% get another factor 1.4 in resolution
% input is "im" output is "res"


clear res 
close all

%im = r(:,:,2);
%[nx,ny] = size(im);
nx = size(im,1);
ny = size(im,2);
mx = (nx-1)/2;
my = (ny-1)/2;
[x,y] = meshgrid(-my:my,-mx:mx);
x = x.^2+y.^2; clear y

NAv = 1.4;
for k=1:length(NAv)
    NA = NAv(k);
    n0 = 1.51;
    n = 1.51;
    n1 = 1.45;
    d0 = [];
    d = 0;
    d1 = [];
    lamem = 0.510;
    mag = 100;
    pixel = 16;
    pic = 1;
    be_res = [];
    al_res = [];
    focus = 1;
    zpos=focus;
    %if mod(nx,2)==0
    %    mx = 15.5;
    %else
    %    mx = 15;
    %end
    %if mod(ny,2)==0
    %    my = 15.5;
    %else
    %    my = 15;
    %end
    mdf = MDFWideFieldMicroscope(NA,n0,n,n1,d0,d,d1,lamem,2*mag,focus,pixel,zpos,mx);
    %mdf = [zeros((nx-2*mx-1)/2,size(mdf,2)); mdf; zeros((nx-2*mx-1)/2,size(mdf,2))];
    %mdf = [zeros(size(mdf,1),(ny-2*my-1)/2), mdf, zeros(size(mdf,1),(ny-2*my-1)/2)];
    %mx = (nx-1)/2;
    %my = (ny-1)/2;
    otm1 = abs(fftshift(fft2(mdf)));
    otm2 = mConv2(otm1,otm1);
    otm2 = otm2/max(otm2(:));
    otm3 = interp2((-2*my:2:2*my)',-2*mx:2:2*mx,otm1,(-my:my)',-mx:mx);
    otm3 = otm3/max(otm3(:));
    
    %make cutoff filter
    [x,y]=meshgrid(-mx:mx);
    filter = exp(-(x.^2+y.^2)/120^2/2);
    filter(filter>0.17)=0.17;    %everything in a radius of 226 (2*k_max) is taken, then smooth cutoff
    filter=filter/max(filter(:));

    weight = otm3./(0.001+otm2); %.*(otm3>0.01);
    res(:,:,k) = abs(fft2(fftshift(ifftshift(ifft2(im)).*weight)));
    %tmp = mConv2(res(:,:,k),res(:,:,k));
    %[rx,rx,rx,ry]=Gauss2D([],[],tmp(round(end/2-15:end/2+15),round(end/2-15:end/2+15)));
    %qfac(k) = mean([rx,ry]);
    %tmp = abs(ifftshift(ifft2(res(:,:,k)))); 
    %qfac(k) = sum(sum(x.*tmp))/sum(sum(tmp));

    mim(cat(3,im,res(:,:,k)))
end
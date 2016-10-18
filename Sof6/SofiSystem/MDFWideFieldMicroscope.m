function [mdf, exc] = MDFWideFieldMicroscope(NA,n0,n,n1,d0,d,d1,lamem,mag,focusv,pixel,zpos,nn,lamex,fd,over)

% Function MDFWideFieldMicroscope for calculating the PSF of a wide field 
% microscope
% (c) Joerg Enderlein, http://www.joerg-enderlein.de (2009)

%clf
if nargin==0
    NA = 1.4;
    n0 = 1.34;
    n = 1.334;
    n1 = 1.334;
    d0 = [];
    d = 0;
    d1 = [];
    lamem = 0.625;
    mag = 160;
    pixel = mag*0.100/4;
    nn = ceil(0.3*mag/pixel);
    focusv = 0;
    zpos = 0;
    lamex = 0.67;
    fd = 3e3;
    over = 7e3;
end

if length(nn)==1
    nn = [nn nn];
end

rhofield = [0 1.5*max(nn)*pixel/mag];
mdf = zeros(2*nn(1)+1,2*nn(2)+1,length(focusv));
if nargout>1
    exc = mdf;
end
for j=1:length(focusv)
    focus = focusv(j);
    if nargout>1
        exctmp = GaussExc(rhofield, zpos, NA, fd, n0, n, n1, d0, d, d1, lamex, over, focus);
        exctmp.rho = mag*exctmp.rho;
        [fx, fy, fz] = GaussExc2Grid(nn,pixel,exctmp);
        exc(:,:,j) = abs(fx).^2+abs(fy).^2+abs(fz).^2;
        exctmp = RotateEMField(exctmp,pi/2);
        [fx, fy, fz] = GaussExc2Grid(nn,pixel,exctmp);
        exc(:,:,j) = exc(:,:,j) + abs(fx).^2+abs(fy).^2+abs(fz).^2;
    end
    [intx inty intz, rho, tmp, fxx0, fxx2, fxz, byx0, byx2, byz] = SEPDipole(rhofield, zpos, NA, n0, n, n1, d0, d, d1, lamem, mag, focus);
    mdf(:,:,j) = SEPImage(pi/2,0,nn,pixel,rho,fxx0,fxx2,fxz,byx0,byx2,byz);
    mdf(:,:,j) = mdf(:,:,j) + SEPImage(pi/2,pi/2,nn,pixel,rho,fxx0,fxx2,fxz,byx0,byx2,byz);
    mdf(:,:,j) = mdf(:,:,j) + SEPImage(0,0,nn,pixel,rho,fxx0,fxx2,fxz,byx0,byx2,byz);
    %mim(mdf)
end


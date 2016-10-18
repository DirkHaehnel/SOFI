function [intx, inty, intz] = DefocImage(nn, pix, z, NA, n1, n, n2, d1, d, d2, lambda, mag, focpos, atf, ring, orient)

% Function DefocImage for calculating the image of a molecule with dipole
% orientation (theta,phi) (Euler angles) 

% input parameters
%
% nn - image will be calculated over (2nn+1) by (2nn+1) pixels
% pix - side length of one square pixel in mum
% z - vertical position of emitter
% NA - N.A. of objective
% n1 - vector of refractive indices of the stack below the molecule's layer
% n  - refracive index of the molecule's layer
% n2 - vector of refractive indices of the stack above the the molecule's layer
% d1 - vector of layer thickness values of the stack below the molecule's layer ( length(d0)=length(n0)-1 )
% d  - thickness of molecule's layer
% d2 - vector of layer thickness values of the stack above the molecule's layer ( length(d1)=length(n1)-1 )
% lambda - emission wavelength
% mag - magnification of imaging
% focpos - displacement of focal plane relative to molecule position
% theta - inclination of dipole towards the optical axis
% phi - azimuthal angle of dipole around the optical axis (with respect to x-axis)

if nargin<14
    atf = [];
end
if nargin<15
    ring = [];
end

if length(nn)==1
    nn = [nn nn];
end

[x,y] = meshgrid(-nn(1):nn(1),-nn(2):nn(2));
x = x*pix;
y = y*pix;
p = angle(x+1i*y);
r = sqrt(x.^2+y.^2);

[~, ~,  ~, rho, ~, fxx0, fxx2, fxz, byx0, byx2, byz] = SEPDipole([0 max(r(:))]/mag,z,NA,n1,n,n2,d1,d,d2,lambda,mag,focpos,atf,ring);

if nargin>15 && ~isempty(orient)
    for j=1:size(orient,1)
        theta = orient(j,1);
        phi = orient(j,2);
        intx(:,:,j) = SEPImage(theta,phi,nn,pix,rho,fxx0,fxx2,fxz,byx0,byx2,byz);
    end
    inty = []; intz = [];
else
    intx = SEPImage(pi/2,0,nn,pix,rho,fxx0,fxx2,fxz,byx0,byx2,byz);
    inty = SEPImage(pi/2,pi/2,nn,pix,rho,fxx0,fxx2,fxz,byx0,byx2,byz);
    intz = SEPImage(0,0,nn,pix,rho,fxx0,fxx2,fxz,byx0,byx2,byz);
end    
    

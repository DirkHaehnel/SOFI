% makes a filter for Fourier reweighting, cutting off all "impossible"
% frequencies

%requires a (square) image file (im) with an even number of pixels along both
%directions


lamex = 510;  % excitation wavelength in nm (for widefield put same as emission)
lamem = 510;  % emission wavelength in nm 
pixel=160;  %pixel size in nm
NA=1.40;   %NA of the objective

size = 50;%(size(im,1));
lambda = (lamex+lamem)/2;
k_max = 4*pi*NA*pixel/lambda;
fourierpixel = 2*pi/size;
k_max_pixel = k_max/fourierpixel;

c = k_max_pixel+40;
a = Disk(c);
b = zeros(size);
e = size/2;
b(e-c:e+c , e-c:e+c) = a;

[x,y] = meshgrid(-60:60);
f = exp(-(x.^2+y.^2)/20^2/2);
d = conv2(b,f,'same');
filter1 = d/max(max(d));
%save('filter605_SOFI','filter1')


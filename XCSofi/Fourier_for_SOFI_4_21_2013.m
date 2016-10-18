
% Find image size and make pixel grid around (0,0)
[nx,ny] = size(final);
mx = (nx-1)/2;
my = (ny-1)/2;
[x,y] = meshgrid(-my:my,-mx:mx);

% Calculate PSF (around (0,0) )
NA = 1.4;
n0 = 1.51;
n = 1.51;
n1 = 1.45;
d0 = [];
d = 0;
d1 = [];
lamem = 0.605;
mag = 160;
pixel = 16;
pic = 1;
be_res = [];
al_res = [];
focus = 1;
zpos=1;
mdf = MDFWideFieldMicroscope(NA,n0,n,n1,d0,d,d1,lamem,mag,focus,pixel,zpos,mx);

% Calculate OTFs

otm1 = abs(fftshift(fft2(mdf)));        % "Normal OTF"
otm2 = mConv2(otm1,otm1);               % theoretical SOFI OTF  (based on the experimental data, convolution of widefield PSF with itself)
otm2 = otm2/max(otm2(:));               % normalize this OTF

otm3 = interp2((-2*my:2:2*my)',-2*mx:2:2*mx,otm1,(-my:my)',-mx:mx);     % OTF which we want, theoretically (normal OTF, stretched by a factor of two)
otm3 = otm3/max(otm3(:));               % normalize this OTF

weight = otm3 ./ (otm2 + 0.001);        % weighting function: devide the OTF (gotten from the SOFI image) by the theoretical OTF and multiply with the OTF which we want to get. (0.001 is to avoid division by zero)

weight = weight/max(weight(:));


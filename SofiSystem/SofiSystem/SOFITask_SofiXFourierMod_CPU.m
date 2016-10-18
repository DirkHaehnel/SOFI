% NA = 1.4; % numerical aperture
% n1 = 1.334; % ref. index of sample
% n = n1; 
% n2 = n1;
% d1 = [];
% d = 0;
% d2 = [];
% lambda = 0.625; % emission wavelength in micron
% mag = 160; % magnification
% pix = mag*0.100/4; % virtual pixel size in micron

NA = handles.vMicNA; % numerical aperture
n1 = handles.vMicN1; % ref. index of sample
n = n1; 
n2 = n1;
d1 = [];
d = 0;
d2 = [];

% if(handles.vActualChannel == 1)
%     lambda = handles.vMicLambda; % emission wavelength in micron
% end
% if(handles.vActualChannel == 2)
%     lambda = handles.vMicLambda2; % emission wavelength in micron
% end

mag = handles.vMicMagnification; % magnification
pix = mag*0.100/4; % virtual pixel size in micron

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Calc SOFIX Fourier  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseSofiXFourier = imageSOFI;
baseSofiXFourierMod = imageSOFIMod;

baseSofiXFourierModInit = imageSOFIModInit;
[nxInit,nyInit,nzInit] = size(baseSofiXFourierModInit);
%%%%%%%%%%% Standar 

[nx,ny,nz] = size(baseSofiXFourier);
nn = ceil(0.3*mag/pix);
% z = handles.vMicZPos + handles.vMicZStep;
% focpos = handles.vMicFocPos;

[intx, inty, intz] = DefocImage(nn, pix, z, NA, n1, n, n2, d1, d, d2, lambda, mag, focpos);
mdf = intx+intx'+inty+inty'+intz+intz';
clear int*
mdf = [zeros(floor((nx-2*nn-1)/2),size(mdf,2)); mdf; zeros(ceil((nx-2*nn-1)/2),size(mdf,2))];
mdf = [zeros(size(mdf,1),floor((ny-2*nn-1)/2)), mdf, zeros(size(mdf,1),ceil((ny-2*nn-1)/2))];

%mdf = MDFWideFieldMicroscope(NA,n1,n,n2,d1,d,d2,lambda,mag,focpos,pix,z,nn,0.67,3e3,7e3);
%mdf = [zeros(floor((nx-2*nn-1)/2),size(mdf,2)); mdf; zeros(ceil((nx-2*nn-1)/2),size(mdf,2))];
%mdf = [zeros(size(mdf,1),floor((ny-2*nn-1)/2)), mdf, zeros(size(mdf,1),ceil((ny-2*nn-1)/2))];

mxInf = floor((nx-1)/2);
myInf = floor((ny-1)/2);
mxSup = ceil((nx-1)/2);
mySup = ceil((ny-1)/2);

otm1 = abs(fftshift(fft2(mdf)));
otm2 = mConv2(otm1,otm1);
otm2 = otm2/max(otm2(:));
otm3 = interp2((-2*myInf:2:2*mySup)',-2*mxInf:2:2*mxSup,otm1,(-myInf:mySup)',-mxInf:mxSup);
otm3 = otm3/max(otm3(:));

weight = otm3./(0.001+otm2); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imageSofiFourier = baseSofiXFourier;
imageSofiFourierMod = baseSofiXFourierMod;
imageSofiFourierModInit = baseSofiXFourierMod;

% imageSofiFourierForAnalysis = baseSofiXFourier;
% imageSofiFourierModForAnalysis = baseSofiXFourierMod;
% imageSofiFourierModInitForAnalysis = baseSofiXFourierMod;
otm2 = otm1;
for j=1:nz
     otm2 = mConv2(otm2,otm1);
     otm2 = otm2/max(otm2(:));
     
     otm3 = interp2((-(j+1)*myInf:(j+1):(j+1)*mySup)',-(j+1)*mxInf:(j+1):(j+1)*mxSup,otm1,(-myInf:mySup)',-mxInf:mxSup,'cubic');
     otm3 = otm3/max(otm3(:));
 
     weight = otm3./(0.00001+otm2); 
     
    imageSofiFourier(:,:,j) = abs(ifft2(ifftshift(fftshift(fft2(baseSofiXFourier(:,:,j))).*weight)));
    
    if(handles.vCalcSOFIX_Fourier_Mod == 1)
        imageSofiFourierMod(:,:,j) = abs(ifft2(ifftshift(fftshift(fft2(baseSofiXFourierMod(:,:,j))).*weight)));

        novo = fftshift(fft2(baseSofiXFourierModInit(:,:,j)));
        interpolationFourier = [zeros(floor((nx-nxInit)/2),ny);zeros(nxInit,floor((ny-nyInit)/2)),novo,zeros(nxInit,ceil((ny-nyInit)/2));zeros(ceil((nx-nxInit)/2),ny)];

    %     mxInf = floor((nx-1)/2);
    %     myInf = floor((ny-1)/2);
    %     mxSup = ceil((nx-1)/2);
    %     mySup = ceil((ny-1)/2);
    %     
    %     interpolationFourier = interp2((-2*myInf:2:2*mySup)',-2*mxInf:2:2*mxSup,interpolationFourier,(-myInf:mySup)',-mxInf:mxSup);
        interpolationFourier = interpolationFourier./max(interpolationFourier(:));
        imageSofiFourierModInit(:,:,j) = abs(ifft2(ifftshift(interpolationFourier.*weight)));

        %%% Only for verification
    %     imageSofiFourierForAnalysis(:,:,j) = abs(ifft2(ifftshift(fftshift(fft2(baseSofiXFourier(:,:,j))).*weight)));
    %     imageSofiFourierModForAnalysis(:,:,j) = abs(ifft2(ifftshift(fftshift(fft2(baseSofiXFourierMod(:,:,j))).*weight)));
    %     
    %     novo = fftshift(fft2(baseSofiXFourierModInit(:,:,j)));
    %     interpolationFourier = [zeros(floor((nx-nxInit)/2),ny);zeros(nxInit,floor((ny-nyInit)/2)),novo,zeros(nxInit,ceil((ny-nyInit)/2));zeros(ceil((nx-nxInit)/2),ny)];
    %     imageSofiFourierModInitForAnalysis(:,:,j) = abs(ifft2(ifftshift(interpolationFourier.*weight)));
    end
end

%imageSofiFourier = imageSofiFourier/max(imageSofiFourier(:));
clear NA n1 n n2 d1 d d2 lambda mag pix x y xi yi interpolationFourier novo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% XXXCalc SOFIX Fouriere %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=1:size(imageSofiFourier,3)
    imageSofiFourier(:,:,j)=imageSofiFourier(:,:,j)-min(min(imageSofiFourier(:,:,j)));
    imageSofiFourier(:,:,j)=imageSofiFourier(:,:,j)./max(max(imageSofiFourier(:,:,j)));
    imwrite(imageSofiFourier(:,:,j),strcat(externDirectory,externActualFileBase,'_2SofiFourier',int2str(j+1),'.tif'))

    if(handles.vCalcSOFIX_Fourier_Mod == 1)    
        imageSofiFourierMod(:,:,j)=imageSofiFourierMod(:,:,j)-min(min(imageSofiFourierMod(:,:,j)));
        imageSofiFourierMod(:,:,j)=imageSofiFourierMod(:,:,j)./max(max(imageSofiFourierMod(:,:,j)));
        imwrite(imageSofiFourierMod(:,:,j),strcat(externDirectory,externActualFileBase,'_2SofiFourierMOd',int2str(j+1),'.tif'))

        imageSofiFourierModInit(:,:,j)=imageSofiFourierModInit(:,:,j)-min(min(imageSofiFourierModInit(:,:,j)));
        imageSofiFourierModInit(:,:,j)=imageSofiFourierModInit(:,:,j)./max(max(imageSofiFourierModInit(:,:,j)));
        imwrite(imageSofiFourierModInit(:,:,j),strcat(externDirectory,externActualFileBase,'_2SofiFourierMOdInit',int2str(j+1),'.tif'))

    %%%%%%%%%%%%%%%%% For my personal analysis
    %     imageSofiFourierForAnalysis(:,:,j)=imageSofiFourierForAnalysis(:,:,j)-min(min(imageSofiFourierForAnalysis(:,:,j)));
    %     imageSofiFourierForAnalysis(:,:,j)=imageSofiFourierForAnalysis(:,:,j)./max(max(imageSofiFourierForAnalysis(:,:,j)));
    %     imwrite(imageSofiFourierForAnalysis(:,:,j),strcat(externDirectory,externActualFileBase,'_3SofiFourierForAnalysis',int2str(j+1),'.tif'))
    %     
    %     imageSofiFourierModForAnalysis(:,:,j)=imageSofiFourierModForAnalysis(:,:,j)-min(min(imageSofiFourierModForAnalysis(:,:,j)));
    %     imageSofiFourierModForAnalysis(:,:,j)=imageSofiFourierModForAnalysis(:,:,j)./max(max(imageSofiFourierModForAnalysis(:,:,j)));
    %     imwrite(imageSofiFourierModForAnalysis(:,:,j),strcat(externDirectory,externActualFileBase,'_3SofiFourierMOdForAnalysis',int2str(j+1),'.tif'))
    % 
    %     imageSofiFourierModInitForAnalysis(:,:,j)=imageSofiFourierModInitForAnalysis(:,:,j)-min(min(imageSofiFourierModInitForAnalysis(:,:,j)));
    %     imageSofiFourierModInitForAnalysis(:,:,j)=imageSofiFourierModInitForAnalysis(:,:,j)./max(max(imageSofiFourierModInitForAnalysis(:,:,j)));
    %     imwrite(imageSofiFourierModInitForAnalysis(:,:,j),strcat(externDirectory,externActualFileBase,'_3SofiFourierMOdInitForAnalysis',int2str(j+1),'.tif'))
    end
end

save(strcat(externDirectory,'Data_',externActualFileBase,'_ProccesedData','.mat'))
clear imageSof*
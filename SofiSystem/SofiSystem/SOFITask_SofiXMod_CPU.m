
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Calc SOFIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tic;
ncum = handles.vSofiOrder;
win = handles.vSofiWin;

if (ncum<2 || ncum>6)
    ncum = 2;
end

if win < 10
    win = 1e2;
end
[xOrigen,yOrigen,zOrigen] = size(im);
[x,y] = meshgrid(0:yOrigen-1,0:xOrigen-1);
[xi,yi] = meshgrid(0:1/ncum:(yOrigen-1),0:1/ncum:(xOrigen-1));
imageSOFI = zeros(ncum*(xOrigen-1)+1,ncum*(yOrigen-1)+1,ncum-1);
imageAmp = zeros(ncum*(xOrigen-1)+1,ncum*(yOrigen-1)+1);
tmp = zeros(ncum*(xOrigen-1)+1,ncum*(yOrigen-1)+1,win);

tiempo = zeros(1,ncum);
tiempoInit = zeros(1,ncum);
tiempoPerdida = 0;

imageSOFIModInit = zeros(xOrigen,yOrigen,ncum-1);
imageAmpMod = zeros(xOrigen,yOrigen);
tmpMod = zeros(xOrigen,yOrigen,win);

for k=1:floor(zOrigen/win)
    tic;
    startIndex = (k-1)*win+1;
    endIndex = (k)*win;
    tmpMod = im(:,:,startIndex:endIndex);
    
    imageAmpMod = imageAmpMod + sum(tmpMod,3); 

    % Standard analysis
    for jj = 1:win
        tempImage = tmpMod(:,:,jj);
        tmp(:,:,jj) = interp2(x,y,tempImage,xi,yi,'spline');
    end

    imageAmp = imageAmp + sum(tmp,3); 
    tmp = tmp - repmat(mean(tmp,3),[1 1 size(tmp,3)]);
    tmpMod = tmpMod - repmat(mean(tmpMod,3),[1 1 size(tmpMod,3)]);

    tiempoPerdida = tiempoPerdida + toc;
    % Generic stage
    for j=1:ncum-1
        tic;
        imageSOFI(:,:,j) = imageSOFI(:,:,j) + abs(SOFITask_CumulantMeanZeroOpt_CPU(tmp,j+1,1));
        tiempo(j) = tiempo(j) + toc;

        tic;
        imageSOFIModInit(:,:,j) = imageSOFIModInit(:,:,j) + abs(SOFITask_CumulantMeanZeroOpt_CPU(tmpMod,j+1,1));
        tiempoInit(j) = tiempoInit(j) + toc;
    end
    clear temp
end
clear im;
timeFORPRECALCSOFIX = tiempoPerdida
timeForSOFIX = tiempo

timeFORSOFIXMODIFIED = tiempoInit
%timeSOFIXAnalysis = toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% XXXCalc SOFIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%mim(cat(3,imageAmp,abs(imageSOFI(:,:,1))))
%colormap jet
% mim(cat(4,cat(3,sum(imageAmp,3),abs(imageSOFI(:,:,1))),abs(imageSOFI(:,:,2:3))))

imageAmp=imageAmp-min(min(imageAmp));
imageAmp=imageAmp./max(max(imageAmp));
imwrite(imageAmp,strcat(externDirectory,externActualFileBase,'_ExtendedImage.tif'));

imageAmpMod = interp2(x,y,imageAmpMod,xi,yi,'spline');
imageAmpMod=imageAmpMod-min(min(imageAmpMod));
imageAmpMod=imageAmpMod./max(max(imageAmpMod));
imwrite(imageAmpMod,strcat(externDirectory,externActualFileBase,'_ExtendedImageAmp.tif'));

imageSOFIMod = imageSOFI;
for j=1:size(imageSOFI,3)
    if(handles.vCalcSOFIX_Fourier_Mod == 1)
        imageSOFIModInit(:,:,j)=imageSOFIModInit(:,:,j)-min(min(imageSOFIModInit(:,:,j)));
        imageSOFIModInit(:,:,j)=imageSOFIModInit(:,:,j)./max(max(imageSOFIModInit(:,:,j)));
        imwrite(imageSOFIModInit(:,:,j),strcat(externDirectory,externActualFileBase,'_1SofiModInit',int2str(j+1),'.tif')) % For SOFI FOURIER MOD ... not use as a valid image...

        imageSOFIMod(:,:,j) = interp2(x,y,imageSOFIModInit(:,:,j),xi,yi,'spline');
        imageSOFIMod(:,:,j)=imageSOFIMod(:,:,j)-min(min(imageSOFIMod(:,:,j)));
        imageSOFIMod(:,:,j)=imageSOFIMod(:,:,j)./max(max(imageSOFIMod(:,:,j)));
        imwrite(imageSOFIMod(:,:,j),strcat(externDirectory,externActualFileBase,'_1SofiMod',int2str(j+1),'.tif')) % For SOFI FOURIER MOD ... not use as a valid image...
    end
    
    imageSOFI(:,:,j)=imageSOFI(:,:,j)-min(min(imageSOFI(:,:,j)));
    imageSOFI(:,:,j)=imageSOFI(:,:,j)./max(max(imageSOFI(:,:,j)));
    imwrite(imageSOFI(:,:,j),strcat(externDirectory,externActualFileBase,'_1Sofi',int2str(j+1),'.tif'))
end

clear j

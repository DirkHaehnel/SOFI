
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

SOFITask_ReadImage_ReadParams_CPU;
xOrigen = dimIm(1);
yOrigen = dimIm(2);
zOrigen = num_imagesTotal;
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
    SOFITask_ReadImage_ReadPartialImage_CPU;
    tmpMod = im;
    
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

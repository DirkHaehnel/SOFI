
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Calc SOFIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% XXXCalc SOFIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageAmp=imageAmp-min(min(imageAmp));
imageAmp=imageAmp./max(max(imageAmp));
imwrite(imageAmp,strcat(externDirectory,externActualFileBase,'_ExtendedImage.tif'));

imageAmpMod = interp2(x,y,imageAmpMod,xi,yi,'spline');
imageAmpMod=imageAmpMod-min(min(imageAmpMod));
imageAmpMod=imageAmpMod./max(max(imageAmpMod));
%imwrite(imageAmpMod,strcat(externDirectory,externActualFileBase,'_ExtendedImageAmp.tif'));

imageSOFIMod = imageSOFI;
for j=1:size(imageSOFI,3)
    if(handles.vCalcSOFIX_Fourier_Mod == 1)
        imageSOFIModInit(:,:,j)=imageSOFIModInit(:,:,j)-min(min(imageSOFIModInit(:,:,j)));
        imageSOFIModInit(:,:,j)=imageSOFIModInit(:,:,j)./max(max(imageSOFIModInit(:,:,j)));
        %imwrite(imageSOFIModInit(:,:,j),strcat(externDirectory,externActualFileBase,'_1SofiModInit',int2str(j+1),'.tif')) % For SOFI FOURIER MOD ... not use as a valid image...

        imageSOFIMod(:,:,j) = interp2(x,y,imageSOFIModInit(:,:,j),xi,yi,'spline');
        imageSOFIMod(:,:,j)=imageSOFIMod(:,:,j)-min(min(imageSOFIMod(:,:,j)));
        imageSOFIMod(:,:,j)=imageSOFIMod(:,:,j)./max(max(imageSOFIMod(:,:,j)));
        %imwrite(imageSOFIMod(:,:,j),strcat(externDirectory,externActualFileBase,'_1SofiMod',int2str(j+1),'.tif')) % For SOFI FOURIER MOD ... not use as a valid image...
    end
    
    imageSOFI(:,:,j)=imageSOFI(:,:,j)-min(min(imageSOFI(:,:,j)));
    imageSOFI(:,:,j)=imageSOFI(:,:,j)./max(max(imageSOFI(:,:,j)));
    imwrite(imageSOFI(:,:,j),strcat(externDirectory,externActualFileBase,'_1Sofi_Res_Cum',int2str(ncum),'_Order_',int2str(j+1),'.tif'))
end

clear j

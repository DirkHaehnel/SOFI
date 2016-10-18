function [sof, im0, soffull] = SOFIAnalysis(im,ncum,ntime,nraster)


% max cumulant order:
if nargin<2 || isempty(ncum)
    ncum = 6;
end

if nargin<3 || isempty(ntime)
    ntime = ceil(log2(1e2/ncum));
end

if nargin<4 || isempty(nraster)
    nraster = 0;
end

if ncum>6
    error('SOFIAnalysis:argChk', 'Higher cumulants than 6th order are stupid')
end

if ischar(im)
    warning off
    im = double(fastTiff(im));
    warning on
end

%im = im - repmat(mean(im,3),[1 1 size(im,3)]);
win = 2^ntime*ncum
soffull = zeros(2^nraster*(size(im,1)-1)+1,    2^nraster*(size(im,2)-1)+1,   ntime,     ncum-1,    floor(size(im,3)/win));
im0 = zeros(2^nraster*(size(im,1)-1)+1,2^nraster*(size(im,2)-1)+1,floor(size(im,3)/win));
tmp = zeros(2^nraster*(size(im,1)-1)+1,2^nraster*(size(im,2)-1)+1,win);
for k=1:floor(size(im,3)/win)
    if nargin>3 && ~(nraster==0)
        for jj=1:win
            tmp(:,:,jj) = interp2(im(:,:,(k-1)*win+jj),nraster,'cubic');
        end
    else
        tmp = im(:,:,(k-1)*win+1:k*win);
    end
    im0(:,:,k) = sum(tmp,3); 
    tmp = tmp - repmat(mean(tmp,3),[1 1 size(tmp,3)]);
    for kk=1:ntime
        if kk>1
            tmp = (tmp(:,:,1:2:end-1)+tmp(:,:,2:2:end))/2;
        end
        for j=1:ncum-1
            soffull(:,:,kk,j,k) = cumulant0(tmp,j+1,1);
            %disp([k kk j]);
        end
    end
end

sof = squeeze(mean(sum(soffull,5),3));
tmp = sum(im0,3);
% mim([(tmp-min(tmp(:)))/(max(tmp(:))-min(tmp(:))) (sof(:,:,1)-min(min(sof(:,:,1))))/(max(max(sof(:,:,1)))-min(min(sof(:,:,1))))]); colormap jet

return

x = tiffread('c:\Joerg\Doc\Microscopy\SOFI\PicoQuant\Alexa532_Mikrotubuli_Kammer2_3\Alexa532_Mikrotubuli_Kammer2_3_raw_data.tif');
y = zeros(205,131,1e4);
for j=1:1e4 y(:,:,j)=double(x(j).data); j, end
clear x

mim([(im1-min(min(im1)))/(max(max(im1))-min(min(im1))) sum(sof1,3)/max(max(sum(sof1,3)))]); colormap jet

return

x=-100:100;
z=1-0.1*abs(x); z(z<0)=0;
zz=conv(z,z);
zz=zz(length(z)/2:end-length(z)/2);
y2=real(fftshift(ifft(ifftshift(zz))));
y1=real(fftshift(ifft(ifftshift(z))));
y1=y1/max(y1);
y2=y2/max(y2);
b=ones(size(x)); b(z==0)=0;
bb=conv(b,b);
bb=bb(length(z)/2:end-length(z)/2);
b2=real(fftshift(ifft(ifftshift(bb))));
b1=real(fftshift(ifft(ifftshift(b))));
b1=b1/max(b1);
b2=b2/max(b2);
plot(x,y2,x,b2,'o')
[sqrt(sum(x.^2.*y2)/sum(y2)) sqrt(sum(x.^2.*b2)/sum(b2))]
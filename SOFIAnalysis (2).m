function [sof, im0, soffull] = SOFIAnalysis(im,ncum,ntime,nraster)
% Standard usage: sof = SOFIAnalysis(im, order)
%
% Computes SOFI images up to the specified order from a movie with fluctuating emitters.
% Note: You can use mim( sof(:,:, order-1) ) to visualize the result.
%
% Input
% im - Tiff image stack (either already loaded or filename)
% ncum - SOFI order
% ntime - Number of steps in 'averaging cascade' for 'logarithmic integration'
% nraster - Order of linear interpolation applied to the image stacklog 2
%
% Output
% sof(xdim, ydim, order-1) - SOFI results, e.g. sof(:,:,1) is the second
%                            order SOFI image.
% im0 - im0(xdim, ydim, k) is the sum intensity image for window k
% soffull(xdim, ydim, cascade_step, order, window) - Matrix of intermediate
%                                                    results


% max cumulant order:
if nargin<2 || isempty(ncum)
    ncum = 6;
end

% Estimate number of steps in cascade
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

win = 2^ntime*ncum; % choose window size large enough for cascade

% Allocate memory
soffull = zeros(2^nraster*(size(im,1)-1)+1,     2^nraster*(size(im,2)-1)+1,    ntime,    ncum-1,     floor(size(im,3)/win));
im0 = zeros(2^nraster*(size(im,1)-1)+1,         2^nraster*(size(im,2)-1)+1,    floor(size(im,3)/win));
tmp = zeros(2^nraster*(size(im,1)-1)+1,         2^nraster*(size(im,2)-1)+1,    win);


% Main computation loop

% We go through the data in windows of size win. This is reasonable for two reasons:
% 1) It prevents getting a SOFI signal from bleaching (as long as the time scale of bleaching is much larger than the window size).
% 2) The signal correlation drops down over time. Thus, limiting data to a window smaller or equal to this time scale improves the results.
for k=1:floor(size(im,3)/win) 

    % ---- Optional: Interpolate all images in window k and put into tmp
    if nargin>3 && ~(nraster==0)
        for jj=1:win  % This goes through all images in substack k
	    % (k-1)*win+jj) - choses image jj in substack k
            tmp(:,:,jj) = interp2(im(:,:,(k-1)*win+jj),nraster,'cubic');
        end
    else % do not interpolate, collect images in window k
        tmp = im(:,:,(k-1)*win+1:k*win);
    end
    % ----
    
    im0(:,:,k) = sum(tmp,3); % (Just needed for visual comparison later): Sum up intensity of all images in window k and save the result. 
   
    
    %--- Core SOFI Computation ---
    tmp = tmp - repmat(mean(tmp,3), [1 1 size(tmp,3)]); % Subtract (over time) mean from all pixels in tmp -> result: (F - <F>)
    
    
    for kk=1:ntime
        
        % Average difference-to-mean (F-<F>) over pairs of images/frames, the size of tmp (number of images) is cut by half each time
        % kk=1 | | | | | | | |  (no changes / original image stack)
        % kk=2  |   |   |   |
        % kk=3    |   |   |
        % etc.  A SOFI image is computed for every level in this averaging cascade
        if kk>1
            tmp = (tmp(:,:,1:2:end-1)+tmp(:,:,2:2:end))/2;
        end
        
        % For every SOFI order j, compute the (time delay = 1) cumulant. Note
        % that the effective time delay is 2^(kk-1), because the averaging
        % cascade reduces the time resolution by half each time.
        for j=1:ncum-1 
            soffull(:,:,kk,j,k) = cumulant0(tmp,j+1,1); %% Save SOFI result
            disp([k kk j]);
        end
    end
end

% Final SOFI Images are computed by taking the sum over the results of all
% windows and taking the mean over the results from the averaging cascade produced above.
% This procedure is known from FCS measurements and similar to integration with
% logarithmically growing bins of the cumulant (/correlation) function over time delay tau.
sof = squeeze(mean(sum(soffull,5),3)); 

% -- Visualization --
tmp = sum(im0,3); % This contains the summed up intensity (over all frames) for all image pixels. This is simply the averaged image (without normalization) for visual comparison.
mim([(tmp-min(tmp(:)))/(max(tmp(:))-min(tmp(:))) (sof(:,:,1)-min(min(sof(:,:,1))))/(max(max(sof(:,:,1)))-min(min(sof(:,:,1))))]); colormap jet

return

% >>>>>>>>>> Script ends here <<<<<<<<<






% x = tiffread('c:\Joerg\Doc\Microscopy\SOFI\PicoQuant\Alexa532_Mikrotubuli_Kammer2_3\Alexa532_Mikrotubuli_Kammer2_3_raw_data.tif');
% y = zeros(205,131,1e4);
% for j=1:1e4 y(:,:,j)=double(x(j).data); j, end
% clear x
% 
% mim([(im1-min(min(im1)))/(max(max(im1))-min(min(im1))) sum(sof1,3)/max(max(sum(sof1,3)))]); colormap jet
% 
% return

% x=-100:100;
% z=1-0.1*abs(x); z(z<0)=0;
% zz=conv(z,z);
% zz=zz(length(z)/2:end-length(z)/2);
% y2=real(fftshift(ifft(ifftshift(zz))));
% y1=real(fftshift(ifft(ifftshift(z))));
% y1=y1/max(y1);
% y2=y2/max(y2);
% b=ones(size(x)); b(z==0)=0;
% bb=conv(b,b);
% bb=bb(length(z)/2:end-length(z)/2);
% b2=real(fftshift(ifft(ifftshift(bb))));
% b1=real(fftshift(ifft(ifftshift(b))));
% b1=b1/max(b1);
% b2=b2/max(b2);
% plot(x,y2,x,b2,'o')
% [sqrt(sum(x.^2.*y2)/sum(y2)) sqrt(sum(x.^2.*b2)/sum(b2))]
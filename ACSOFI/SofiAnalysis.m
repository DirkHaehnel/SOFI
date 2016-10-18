function [sofi, common] = SofiAnalysis(im,ncum,ntime,win)

common = zeros(size(im,1),size(im,2),floor(size(im,3)/win));
sofi = zeros(size(im,1),size(im,2),ntime,floor(size(im,3)/win));

for k = 1:floor(size(im,3)/win)

    tmp = im(:,:,(k-1)*win+1:k*win);
    common(:,:,k) = sum(tmp,3);
    tmp = tmp - repmat(mean(tmp,3),[1 1 size(tmp,3)]);
    
    for kk=1:ntime
        if kk>1
            tmp = (tmp(:,:,1:2:end-1)+tmp(:,:,2:2:end))/2;
        end
        sofi(:,:,kk,k) = cumulants(tmp,ncum);
    end

end
sofi = sum(sofi,4);

return
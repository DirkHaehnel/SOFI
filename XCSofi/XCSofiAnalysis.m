function Sofi= XCSofiAnalysis(im,ncum,ntime,shifts)

Sofi = zeros(size(im,1),size(im,2),ntime);

for k=1:ntime
    
    if k>1
        im = (im(:,:,1:2:end-1)+im(:,:,2:2:end))/2;
    end
    
    Sofi(:,:,k) = XCcumulants(im,ncum,shifts(:,1),shifts(:,2),shifts(:,3));
    
end

Sofi = squeeze(mean(Sofi,3));

end


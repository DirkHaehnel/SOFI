function ncum = cumulants( im,n )
% the function assumes that the mean has already been subtracted

    switch n
        case 2 
            ncum = mean(im(:,:,1:end-1).*im(:,:,2:end),3);
        case 3
            ncum = mean(im(:,:,1:end-2).*im(:,:,2:end-1).*im(:,:,3:end),3);
        case 4
            ncum = -mean(im(:,:,1:end-3).*im(:,:,4:end),3).*mean(im(:,:,2:end-2).*im(:,:,3:end-1),3)-mean(im(:,:,1:end-3).*im(:,:,3:end-1),3).*mean(im(:,:,2:end-2).*im(:,:,4:end),3)-mean(im(:,:,1:end-3).*im(:,:,2:end-2),3).*mean(im(:,:,3:end-1).*im(:,:,4:end),3)+mean(im(:,:,1:end-3).*im(:,:,2:end-2).*im(:,:,3:end-1).*im(:,:,4:end),3);
    end

end


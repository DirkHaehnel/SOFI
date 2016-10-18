function cumulant = XCcumulants(im,n,a,b,c)

for i = 1:n % 4 is the edge length of the pool from which combinations are chosen
    x(i,:) = (a(i):(size(im,1)-(4-a(i))));
    y(i,:) = (b(i):(size(im,2)-(4-b(i))));
    t(i,:) = (c(i):(size(im,3)-(n-c(i))));
end
    
switch n
    case 2 
%         cumulant = mean(im(:,:,1:end-1).*im(:,:,2:end),3);
        cumulant = mean(im(x(1,:),y(1,:),t(1,:)).*im(x(2,:),y(2,:),t(2,:)),3);
    case 3
%         cumulant = mean(im(:,:,1:end-2).*im(:,:,2:end-1).*im(:,:,3:end),3);
        cumulant = mean(im(x(1,:),y(1,:),t(1,:)).*im(x(2,:),y(2,:),t(2,:)).*im(x(3,:),y(3,:),t(3,:)),3);
    case 4
%         cumulant = -mean(im(:,:,1:end-3).*im(:,:,4:end),3).*mean(im(:,:,2:end-2).*im(:,:,3:end-1),3)-mean(im(:,:,1:end-3).*im(:,:,3:end-1),3).*mean(im(:,:,2:end-2).*im(:,:,4:end),3)-mean(im(:,:,1:end-3).*im(:,:,2:end-2),3).*mean(im(:,:,3:end-1).*im(:,:,4:end),3)+mean(im(:,:,1:end-3).*im(:,:,2:end-2).*im(:,:,3:end-1).*im(:,:,4:end),3);
        cumulant = -mean(im(x(1,:),y(1,:),t(1,:)).*im(x(4,:),y(4,:),t(4,:)),3).*mean(im(x(2,:),y(2,:),t(2,:)).*im(x(3,:),y(3,:),t(3,:)),3)-mean(im(x(1,:),y(1,:),t(1,:)).*im(x(3,:),y(3,:),t(3,:)),3).*mean(im(x(2,:),y(2,:),t(2,:)).*im(x(4,:),y(4,:),t(4,:)),3)-mean(im(x(1,:),y(1,:),t(1,:)).*im(x(2,:),y(2,:),t(2,:)),3).*mean(im(x(3,:),y(3,:),t(3,:)).*im(x(4,:),y(4,:),t(4,:)),3)+mean(im(x(1,:),y(1,:),t(1,:)).*im(x(2,:),y(2,:),t(2,:)).*im(x(3,:),y(3,:),t(3,:)).*im(x(4,:),y(4,:),t(4,:)),3);
end
% rim is cut of -> 509x509. To make it 512x512 again
dummy = zeros(size(im,1),size(im,2));
dummy(2:size(cumulant,1)+1,2:size(cumulant,2)+1) = cumulant;
cumulant = dummy;
return
function [Z] = SofiSimReduce(nparticles,w0,bg,blink,rr,nframes)


% calculate center positions of emitters
rv = [0.5, 1, 2, 4];
pv = [-25 -25; -25 25; 25 -25; 25 25];
cnt = 1;

for j=1:numel(rv)
    for k=1:nparticles
        phi = 2*pi*rand;
        pos(:,cnt)= [pv(j,1) + rv(j)*cos(phi); pv(j,2) + rv(j)*sin(phi)];
        cnt = cnt+1;
    end
end
% calculate emitter images
[x,y] = meshgrid(rr,rr);
mm = zeros(size(x,1),size(x,2),size(pos,2));

pcolor(x,y,sum(mm,3)); shading interp; axis image; [x,y] = meshgrid(rr,rr); hold on; plot(pos(1,:),pos(2,:),'oc'); hold off

Z = zeros(size(100,1),size(100,2),nframes);

for j=1:size(pos,2)
    mm(:,:,j) = 10*exp(-(x-pos(1,j)).^2/w0^2/2-(y-pos(2,j)).^2/w0^2/2);
end

Zs = bg*ones(size(x,1),size(x,2));
state = logical(randi([0 1],1,size(pos,2)));
for k = 1:size(pos,2)
    
    if rand<blink
        state(k) = ~state(k);
        
        
    end
    if state(k)
        Zs = Zs + mm(:,:,k);
    end
end
Z=poissrnd(Zs);

end


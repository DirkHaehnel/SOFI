function [ sofiSimStackOut ] = SofiSimMap( nparticles,w0,bg,blink,rr,nframes,executeOnCluster )

if(executeOnCluster)
    numberOfNodesAvailable = matlabpool('size');
    if(numberOfNodesAvailable<=0)
        matlabpool open;
    end
    parfor j = 1:nframes
        Zcluster(:,:,j)=SofiSimReduce(nparticles,w0,bg,blink,rr,nframes);
    end
    sofiSimStackOut=Zcluster;
    matlabpool close;
    
else
    Zlocal=zeros(rr,nframes);
    for j = 1:nframes
        Zlocal(:,:,j)=SofiSimReduce(nparticles,w0,bg,blink,rr,nframes);
        if bld
            mim(Zlocal(:,:,j)); title(int2str(j)); drawnow;
        end
    end
    sofiSimStackOut=Zlocal;
end

end
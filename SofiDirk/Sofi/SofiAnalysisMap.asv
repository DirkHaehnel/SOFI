function [noSof,sofOut] = SofiAnalysisMap(im,ncum,ntime,nraster,par)

% max cumulant order:
if nargin<2 || isempty(ncum)
    ncum = 6;
end

% how often to coarsen time scale:
if nargin<3 || isempty(ntime)
    ntime = ceil(log2(1e2/ncum));
end

% how much interpolating pixels to insert: INTERP2(im,nraster) expands im
% by interleaving interpolates between every element, working recursively
% for nraster
if nargin<3 || isempty(nraster)
    nraster = 0;
end

if ncum>6
    error('SOFIAnalysis:argChk', 'Higher cumulants than 6th order are stupid')
end

%calculate sofi image on the cluster
if(par)
    numberOfNodesAvailable = matlabpool('size');
    if(numberOfNodesAvailable<=0)
        matlabpool open;
    end
    
    spmd
        meta.parWin=2^ntime*ncum;
        meta.parNraster=nraster;
        meta.parNtime=ntime;
        meta.parNcum=ncum;
        meta.parDim1=size(im,1);
        meta.parDim2=size(im,2);
        meta.parDim3=size(im,3);
        ParTmpGlobalSize = [2^meta.parNraster*(meta.parDim1-1)+1, 2^meta.parNraster*(meta.parDim2-1)+1,meta.parDim3];
        ParSoffullGlobalSize = [2^meta.parNraster*(meta.parDim1-1)+1, 2^meta.parNraster*(meta.parDim2-1)+1];
        parIm = codistributed(im,codistributor1d(3));
        localCube = getLocalPart(parIm);
        localCubeSize= size(localCube,3);
        
        for localCubeFrameIndex=1:localCubeSize
            localCubeInterpolated(:,:,localCubeFrameIndex)=interp2(localCube(:,:,localCubeFrameIndex),meta.parNraster,'linear');
        end
        
        ParTempCodistributor=codistributor1d(3,codistributor1d.unsetPartition,ParTmpGlobalSize);
        globalInd=ParTempCodistributor.globalIndices(3);
        globalInd=localCubeInterpolated(:,:,:);
        parGlobalTimeWiseTmp = codistributed.build(globalInd,ParTempCodistributor);
        parGlobalRowWise= codistributed(parGlobalTimeWiseTmp,codistributor1d(1));
        imRowWise=getLocalPart(parGlobalRowWise);
        
        parSoffull = zeros(2^meta.parNraster*(size(imRowWise,1)-1)+1,2^meta.parNraster*(size(imRowWise,2)-1)+1,meta.parNtime,meta.parNcum-1,floor(size(imRowWise,3)/meta.parWin));
        parIm0 = zeros(2^meta.parNraster*(size(imRowWise,1)-1)+1,2^meta.parNraster*(size(imRowWise,2)-1)+1,floor(size(imRowWise,3)/meta.parWin));
        parTmp = zeros(2^meta.parNraster*(size(imRowWise,1)-1)+1,2^meta.parNraster*(size(imRowWise,2)-1)+1,meta.parWin);
      
        for k=1:floor(size(imRowWise,3)/meta.parWin)
            parTmp = imRowWise(:,:,(k-1)*meta.parWin+1:k*meta.parWin);
            parIm0(:,:,k) = sum(parTmp,3);
            parTmp = parTmp - repmat(mean(parTmp,3),[1 1 size(parTmp,3)]);
            for kk=1:meta.parNtime
                if kk>1
                    parTmp = (parTmp(:,:,1:2:end-1)+parTmp(:,:,2:2:end))/2;
                end
                for j=1:parNcum-1
                    parSoffull(:,:,kk,j,k) = cumulant0(parTmp,j+1,1);
                end
            end
        end
        
        localSoffull = squeeze(mean(sum(parSoffull,5),3));
        ParSoffullCodistributor=codistributor1d(1,codistributor1d.unsetPartition,ParSoffullGlobalSize);
        globalIndRow=ParSoffullCodistributor.globalIndices(1);
        globalIndRow=localSoffull(:,:);
        parSoffullTimeWiseTmp = codistributed.build(globalIndRow,ParSoffullCodistributor);
        
    end
    
    sofOut=gather(parSoffullTimeWiseTmp);
    noSof = sum(parIm0,3);
    return
    
else
    
    %calculate the sofi image on a non cluster environment
    win = 2^ntime*ncum;
    soffull = zeros(2^nraster*(size(im,1)-1)+1,2^nraster*(size(im,2)-1)+1,ntime,ncum-1,floor(size(im,3)/win));
    im0 = zeros(2^nraster*(size(im,1)-1)+1,2^nraster*(size(im,2)-1)+1,floor(size(im,3)/win));
    tmp = zeros(2^nraster*(size(im,1)-1)+1,2^nraster*(size(im,2)-1)+1,win);
    
    for k=1:floor(size(im,3)/win)
        if nargin>3 && ~(nraster==0)
            for jj=1:win
                tmp(:,:,jj) = interp2(im(:,:,(k-1)*win+jj),nraster,'linear');
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
                disp([k kk j]);
            end
        end
    end
    
    sofOut = squeeze(mean(sum(soffull,5),3));
    noSof = sum(im0,3);
    
    return
end

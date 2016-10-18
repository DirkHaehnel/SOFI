function [Sofi position dFactor]= SofiTest( ncum,ntime,shiftTable,posTable,distFactor)

    currJob = getCurrentJob;
    part_img = get(currJob,'JobData');
    
    numRuns = ceil(size(shiftTable,1)/numlabs);
    Sofi = -1*ones(size(part_img,1),size(part_img,2),numRuns); %correlations or intensities will never be <0
    position = zeros(numRuns,2);
    dFactor = zeros(numRuns,1);
    LR = (labindex-1)*numRuns;

    % compute sofi images from all combinations in shiftTable and weighting with distance Factor
    for i = 1:numRuns
        if LR+i <= size(shiftTable,1)
            Sofi(:,:,i) = XCSofiAnalysis(part_img,ncum,ntime,squeeze(shiftTable(LR+i,:,:)));
            position(i,:) = posTable(LR+i,:);
            dFactor(i) = distFactor(LR+i);
        end
    end

    %All tempSofi images are computed by now.
    %now get rid of all dummy arrays that still hold -1*ones(512,512) (those from the idle workers)
    for i = numRuns:-1:1
        if isequal(squeeze(Sofi(:,:,i)),-1*ones(size(Sofi,1),size(Sofi,2)))
            Sofi(:,:,i) = [];
        end
    end

end
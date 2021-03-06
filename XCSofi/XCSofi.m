function [sofi normFactor position]= XCSofi( ncum,ntime,shiftTable,posTable,distFactor)

    currJob = getCurrentJob;
    part_img = get(currJob,'JobData');
    
    numRuns = ceil(size(shiftTable,1)/numlabs);
    tempSofi = -1*ones(size(part_img,1),size(part_img,2),numRuns); %correlations or intensities will never be <0
    
    LR = (labindex-1)*numRuns;
    
    % Sofi tasks distributed according to pixel position
    % not all workers need to compute numRuns runs, but some do -> the task wont finish
    % before those workers are done-> some workers remain idle in the last iteration.
    % diffpos holds the indices at which the positions stored in posTable change (works because posTable is sorted).
    % -> virtual pixel position is constant between diffpos(i) and diffpos(i+1)-1
    j = 1; 
    diffpos = zeros(ceil(ncum^2/numRuns),1);
    if LR+1 <= size(shiftTable,1)   %rest of the workers will remain idle
        diffpos(j) = LR+1;
    end

    % compute sofi images from all combinations in shiftTable 
    for i = 1:numRuns
        if LR+i <= size(shiftTable,1)
            tempSofi(:,:,i) = XCSofiAnalysis(part_img,ncum,ntime,squeeze(shiftTable(LR+i,:,:)));
            if size(diffpos,1) >= j
                if ~isequal(posTable(LR+i,:),posTable(diffpos(j),:))% mark the change of position
                        j = j+1; diffpos(j,1) = LR+i;
                end            
            end
        end
    end

    diffpos = diffpos(diffpos~=0);
    normFactor = zeros(size(diffpos,1),1);
    sofi = -1*ones(size(part_img,1),size(part_img,2),size(diffpos,1));
    %All tempSofi images are computed by now.
    %now get rid of all dummy arrays that still hold -1*ones(512,512) (those from the idle workers)
    for i = numRuns:-1:1
        if isequal(squeeze(tempSofi(:,:,i)),-1*ones(size(tempSofi,1),size(tempSofi,2)))
            tempSofi(:,:,i) = [];
        end
    end
    position = -1*ones(size(diffpos,1),2);    
    
    % summing (not averaging!) all sofi images belonging to a virtual pixel
    for i = 1:size(diffpos,1)
        if size(diffpos,1)>i
            sofi(:,:,i) = squeeze(sum(tempSofi(:,:,diffpos(i)-LR:(diffpos(i+1)-LR-1)),3));
            normFactor(i) = sum(distFactor(diffpos(i):(diffpos(i+1)-1)));
            position(i,:) = posTable(diffpos(i),:);
        %if the position does not change anymore or at least not in the next numRuns computations    
        elseif size(diffpos,1) == i
            if labindex*numRuns<= size(shiftTable,1) % not necessarily end of table (just delta diffpos > numRuns)
                sofi(:,:,i) = sum(tempSofi(:,:,diffpos(i)-LR:labindex*numRuns-LR),3);
                normFactor(i) = sum(distFactor(diffpos(i):labindex*numRuns));
                position(i,:) = posTable(diffpos(i),:);
            else % if end of table is reached 
                sofi(:,:,i) = sum(tempSofi(:,:,diffpos(i)-LR:end),3);
                normFactor(i) = sum(distFactor(diffpos(i):end));
                % no changes in position occur -> last entry in posTable
                position(i,:) = posTable(end,:);
            end
        end
    end

    for i = 1:size(position,1)
        if isequal(position(i,:),-1*ones(1,2))
            position(i,:) = [];
        end
    end
    
end
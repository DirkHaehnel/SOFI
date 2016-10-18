function  [finTable positionTable distanceFactor] = XCshift( ord, MaximumNumberOfSofiRuns,variance )
% function hands shift parameters for input image to jobs computing the 
% Sofi Analysis. This is plain ugly but doesnt have to be run with every
% program start. the tables created can be stored in mat files and can be
% loaded into the actual program doing the sofi analysis.

if ord == 2
    if MaximumNumberOfSofiRuns > 73 
        MaximumNumberOfSofiRuns = 73;   %these are the maximum numbers of combinations for a given order
    end
elseif ord == 3
    if MaximumNumberOfSofiRuns > 3571 
        MaximumNumberOfSofiRuns = 3571;
    end
else
    if MaximumNumberOfSofiRuns > 100000 %maximum number to compute is 166394, but is way too much
        MaximumNumberOfSofiRuns = 100000;
    end
end
[table occurrence distFactor] = XCtable(ord,variance);

% shiftTable = shiftTable(combinationNumber,virtual position,pixelNumber,[x-Shift y-Shift t-Shift]) 
% tabular holding the shift parameters (Shifts for each pixel in combination)
% sorted according to virtual position, all virtual positions should eventually be presented by an equal amount of combinations
shiftTable = zeros(ceil(MaximumNumberOfSofiRuns/(ord^2)),ord^2,ord,3); 
% final shift table
finTable  = zeros(MaximumNumberOfSofiRuns,ord,3); 
% table holding the virtual pixels coordinate for a shift set in shiftTable
posTable = zeros(ceil(MaximumNumberOfSofiRuns/(ord^2)),ord^2,2); 
positionTable = zeros(MaximumNumberOfSofiRuns,2);
% table holding the distance factor
dFactor = zeros(ceil(MaximumNumberOfSofiRuns/(ord^2)),ord^2);
distanceFactor = zeros(MaximumNumberOfSofiRuns,1);

for X = 1:ord % coordinates of virtual pixel in 4x4 array
    for Y = 1:ord 
        
        countPerPosition = 1;
        
        for i = 1:ord

             last = sum(occurrence(X,Y,i,:));
             for d = 1:last % d goes through all distance factors (some are equal)

                 if countPerPosition <= 1.5*MaximumNumberOfSofiRuns/(ord*ord);
                     % preparation for createShift
                     [slots piles] = createSlots(squeeze(table(X,Y,i,d,:,:)),ord);
                     for c = i:ord

                         if countPerPosition <= 1.5*MaximumNumberOfSofiRuns/(ord*ord);

                             % shifting of spatial combination in time
                             timeShifts = createShift(slots,piles,c);
                             % stores time shifts in table
                             for m = 1:size(timeShifts,1)

                                 if countPerPosition <=  1.5*MaximumNumberOfSofiRuns/(ord*ord);
                                     for n = 1:ord
                                        shiftTable(countPerPosition,(X-1)*ord+Y,n,:) = [squeeze(table(X,Y,i,d,n,1)) squeeze(table(X,Y,i,d,n,2)) timeShifts(m,n)];
                                     end 
                                     posTable(countPerPosition,(X-1)*ord+Y,:) = [X Y];
                                     dFactor(countPerPosition,(X-1)*ord+Y) = distFactor(X,Y,i,d);
                                     countPerPosition  = countPerPosition  +1;
                                 end

                             end
                         end

                     end
                 end

             end  
        end
        
    end
end

% find out how many combinations each position has
delimiter = ones(ord,ord,size(shiftTable,1));
for X=1:ord
    for Y=1:ord
        for k= 1:countPerPosition-1 %-1 because the last increase lies out of array bounds
            if isequal(squeeze(shiftTable(k,(X-1)*ord+Y,:,:)),zeros(ord,3))
                delimiter(X,Y,k) = 0;
            end
        end
    end
end

posCombsCount = zeros(ord^2,1);
for X=1:ord
    for Y=1:ord
        posCombsCount((X-1)*ord+Y) = sum(delimiter(X,Y,:),3);
    end
end

% set delimiter for each position, so that required amount of combinations
% is computed but all positions are represented as much as possible

while(sum(posCombsCount)>MaximumNumberOfSofiRuns)

    [maxComb maxInd] = max(posCombsCount);
    posCombsCount(maxInd) = posCombsCount(maxInd)-1;
    
end

iter = 1;
for k = 1:size(shiftTable,1)
    for X=1:ord
        for Y=1:ord
            if ~isequal(squeeze(shiftTable(k,(X-1)*ord+Y,:,:)),zeros(ord,3))
                if k<= posCombsCount((X-1)*ord+Y)
                    finTable(iter,:,:) = squeeze(shiftTable(k,(X-1)*ord+Y,:,:));
                    positionTable(iter,:) = posTable(k,(X-1)*ord+Y,:);
                    distanceFactor(iter) = dFactor(k,(X-1)*ord+Y);
                  iter = iter+1;                       
                end
            end
        end
    end    
end                      
                     
end                     
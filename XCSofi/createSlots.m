function [ slots,piles ] = createSlots( table,ord )

    % all pixel coordinates within a combination of time lag 0 (i = 1) are unique
    % for time lags >0 find out how many different sets x|y of pixel coordinates
    % exist within a combination and how many (and which) pixels overlap
    unqtable = unique(table,'rows');
    % piles = pile of pixels in one 'spatial slot'
    % pileMap shows which pixels in table have a twin in the combination 
    piles = zeros(ord,ord); pileMap = piles; 
    for c = 1:size(unqtable)
        [piles(:,c) pileMap(:,c)] = ismember(table,unqtable(c,:),'rows');% here piles == pileMap
    end % pileMap stores only ones because unqtable(t,:) has only one row
    piles = sum(piles,1); % get the number of overlapping pixels in a spatial slot
    [piles dummyIndex ]= sort(piles,'descend');
    slots = zeros(size(unqtable,1),max(piles),2);
    for c=1:size(unqtable) % c = columns, go through each empty slot
        s = 1;
        for r = 1:size(pileMap,2) % r = rows
            if pileMap(r,dummyIndex(c))~=0
                % store pixels in spatial slots, largest slot on the left side
                slots(c,s,:) = table(r,:); 
                s = s+1;
            end
        end
    end

end


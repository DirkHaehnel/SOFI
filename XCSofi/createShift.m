function [ timeShifts] = createShift( slots,piles,usedFrames )

    str1 = [];str2 = [];str3 = [];
    % commands for creating timeShifts for pixel combinations are created
    % dynamically as time lag and pile sizes change on each iteration
    for r = 1:size(slots,1) % go through each slot
        t{r,1} = nchoosek(1:usedFrames,piles(r));
        str1 = [str1 '1:size(t{' num2str(r) '},1),'];
        str2 = [str2 'p{' num2str(r) '} '];
        str3 = [str3 't{' num2str(r) '}(p{' num2str(r) '},:),'];
    end
    str1 = ['ndgrid(' str1(1:end-1) ');'];
    str2 = ['[' str2(1:end-1) ']'];
    eval([str2 '=' str1]);
    str3 = [ '[' str3(1:end-1) ']'];
    % timeShifts holds all 'temporal' combinations of ord pixels
    timeShifts = eval(str3);
    % combinations where first level is vacant will be deleted
    vacancies = zeros(size(timeShifts,1),usedFrames);
    firstLast = zeros(usedFrames,1);firstLast(1:2) = [1 usedFrames];

    if usedFrames==1
        for r = 1:size(timeShifts,1)
            vacancies(r,:) = ismember(usedFrames,timeShifts(r,:));
        end
        timeShifts = timeShifts((sum(vacancies,2)>=1)~=0,:);
    else
        for r = 1:size(timeShifts,1) % only restriction: first and last frame have to be occupied->firstLast
            unqShift = unique(timeShifts(r,:));
            vacancies(r,:) = ismember(firstLast,unqShift);
        end
        timeShifts = timeShifts((sum(vacancies,2)>=2)~=0,:);
    end


end


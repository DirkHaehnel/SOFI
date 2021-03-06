function [ ] = varianceTest(filename)
% Same procedure as initXCSofi. This time however only 2nd order cumulants are possible.
% you want to keep all unweighted sofi images in order to test for the
% right distance factor in the next step dFactorTest(the one where the final picture
% becomes smoothest).

%% setting parameters

if (nargin == 0 || isempty(filename))
    [filename, pathname] = uigetfile('*.tif', 'select image file');
    name = [ pathname, filename ];
end

ncum = 2;
ntime = ceil(log2(1e2/ncum));
win = 2^ntime*ncum;

cd(pathname);
resultDir = ['results' date] ; 
if exist(resultDir) ~= 7, mkdir(resultDir); end

% sort shiftTable according to virtual pixel positions
% arguments in XCshift are cumulant order, numberOfSofiRuns, variance
[shiftTable posTable distFactor] = XCshift( 2, 73,1);
[posTable index]= sortrows(posTable);
shiftTable = shiftTable(index,:,:);
distFactor = distFactor(index);

sched = findResource('scheduler','type','jobmanager','Name','hal9001','LookupURL','skynet');
%% Proxi Job to find out how many workers are available

proxiPJob = createParallelJob(sched);
set(proxiPJob,'FileDependencies',{'getWorkerInfo.m'});
set(proxiPJob,'MaximumNumberOfWorkers',80);
set(proxiPJob,'MinimumNumberOfWorkers',1);
set(proxiPJob,'Timeout',30);
createTask(proxiPJob,@getWorkerInfo,2,{});
submit(proxiPJob);
waitForState(proxiPJob,'finished');
result = getAllOutputArguments(proxiPJob);
destroy(proxiPJob); clear('proxiPJob');

%% actual jobs
fd1 = 'XCcumulants.m';
fd2 = 'SofiTest.m';
fd3 = 'XCSofiAnalysis.m';
    
warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning;
InfoImage = imfinfo(name); 
frames = length(InfoImage);
img_width = InfoImage(1).Width;
img_height = InfoImage(1).Height;
raw = zeros(img_width,img_height); % superposition of all frames without processing

for i = 1:floor(frames/win)

    part_img = fastTiff(name,1+(i-1)*win,i*win);
    raw = raw+sum(part_img,3);
    part_img = part_img-repmat(mean(part_img,3), [1 1 size(part_img,3)]);

    display(['setup of ','job ',num2str(i),'/',num2str(floor(frames/win))]);tic;
    JobStruct.(['pjob',num2str(i)]) = createParallelJob(sched);
    set(JobStruct.(['pjob',num2str(i)]),'FileDependencies',{fd1 fd2 fd3});
    set(JobStruct.(['pjob',num2str(i)]),'JobData',part_img);

    % for 128 512x512 frames in a Job (ncum = 2) the data can not be distributed
    % to more than 76 workers (probably because of headnode memory limitations)
    if size(result,1)>size(shiftTable,1)
        if size(shiftTable,1) <= 76
            set(JobStruct.(['pjob',num2str(i)]), 'MaximumNumberOfWorkers', size(shiftTable,1));        
            set(JobStruct.(['pjob',num2str(i)]), 'MinimumNumberOfWorkers', 1);
        else
            set(JobStruct.(['pjob',num2str(i)]), 'MaximumNumberOfWorkers', 76);        
            set(JobStruct.(['pjob',num2str(i)]), 'MinimumNumberOfWorkers', 1);
        end
    else
        if size(result,1) <= 76
            set(JobStruct.(['pjob',num2str(i)]), 'MaximumNumberOfWorkers', size(result,1));        
            set(JobStruct.(['pjob',num2str(i)]), 'MinimumNumberOfWorkers', 1);
        else
            set(JobStruct.(['pjob',num2str(i)]), 'MaximumNumberOfWorkers', 76);        
            set(JobStruct.(['pjob',num2str(i)]), 'MinimumNumberOfWorkers', 1);
        end
    end

    pTaskStruct.(['task',num2str(i)]) = createTask(JobStruct.(['pjob',num2str(i)]), @SofiTest,3, {ncum,ntime,shiftTable,posTable,distFactor});
    display(['submitting job',num2str(i),'...']);
    submit(JobStruct.(['pjob',num2str(i)]));toc;

    display(['job' num2str(i) ' computing...']);    tic;
    waitForState(JobStruct.(['pjob',num2str(i)]),'finished');
    errMsgStruct.(['pjob',num2str(i)]) = get(pTaskStruct.(['task',num2str(i)]),'Error');    toc;
    display(['job' num2str(i) ' retrieving results...']);   tic;
    resultStruct.(['result',num2str(i)]) = getAllOutputArguments(JobStruct.(['pjob',num2str(i)]));  toc;
   
end

%% gather and reassemble output

sofi = zeros(img_width,img_height,size(shiftTable,1));
position = zeros(size(posTable));
dFactor = zeros(size(distFactor));

% output of computation is gathered in three variables:
% sofi pictures (not yet weighted with distance factor),
% position of virtual pixel generated in the final picture,
% distance factor (gaussian) with variance = 1 pixel
for i = 1:floor(frames/win)
    m = 1;
    for j = 1:size(resultStruct.(['result',num2str(i)]),1)% go through all workers
        if size(resultStruct.(['result',num2str(i)]){j,1},3)~=0 % doppelt gemoppelt
            for k = 1:size(resultStruct.(['result',num2str(i)]){j,1},3)
                sofi(:,:,m) = sofi(:,:,m)+resultStruct.(['result',num2str(i)]){j,1}(:,:,k);
                if ~isequal(resultStruct.(['result',num2str(i)]){j,2}(k,:),zeros(1,2))
                    position(m,:) = resultStruct.(['result',num2str(i)]){j,2}(k,:);
                    dFactor(m) = resultStruct.(['result',num2str(i)]){j,3}();
                    m = m+1;
                end
            end
        end
    end
    destroy(JobStruct.(['pjob',num2str(i)]));
end

save([resultDir '\' 'template2ndOrderSofi.mat'],'sofi','position','dFactor');
end
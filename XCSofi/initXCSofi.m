function [] = initXCSofi( filename, ncum, MaximumNumberOfSofiRuns,variance)
% at present it is asumed, that the picture is 512x512,
% for larger pictures trouble could arise from memory issues.
% This program uses the skynet cluster. If you want to use different 
% resources go to line 99
% running this program will only compute one cumulant order.
% for more than one you need to rerun it.

% filename: file input
% ncum: cumulant order
% MaximumNumberOfSofiRuns: upper limit for number of pixelcombinations
%                          taken into account when calculating cumulants
% variance: variable related to the size of the PSF of an emitter.

%% getting list of files to process, setting parameters

if (nargin == 0 || isempty(filename))
    [filename, pathname] = uigetfile('*.tif', 'select image file');
    name = [ pathname, filename ];
end

if nargin < 2
    prompt = 'Enter cumulant order (between 2 and 4)';
    dlg_title = 'cumulant order';
    options.Resize = 'on';
    options.Windowstyle = 'normal';
    ncum = inputdlg(prompt,dlg_title,1,{'2'},options);
    if isempty(ncum{1})
        display('cumulant order set to 2');
        ncum = 2;
    else
        ncum = str2num(ncum{1});
    end
end
if ncum < 2
    display('cumulant order set to 2');
    ncum = 2;
end
if ncum > 4
    display('cumulant order set to 4');
    ncum = 4;
end
if nargin < 3
    prompt = 'Enter maximal number of pixel combinations used in computation';
    dlg_title = 'correlation count';
    MaximumNumberOfSofiRuns = inputdlg(prompt,dlg_title,1,{'800'},options);
    if isempty(MaximumNumberOfSofiRuns{1})
        display('number of combinations set to 800');
        MaximumNumberOfSofiRuns = 800;
    else
        MaximumNumberOfSofiRuns = str2num(MaximumNumberOfSofiRuns{1});
    end
end
if nargin < 4
    prompt = 'Enter size of PSF (FWHM in pixels)';
    dlg_title = 'PSF size';
    variance = inputdlg(prompt,dlg_title,1,{'2.55'},options);
    if isempty(variance{1})
        display('PSF size set to 2.55');
        variance = 2.55;
    else
        variance = str2num(variance{1});
    end
end

variance = variance^2/(2*log(2)); % PSF = FWHM = 2*sqrt(2*ln(2))*sigma, variance = sigma^2

% in 'SofiAnalysis' the time scale will be coarsened ntimes times (devide and conquer strategy
% to correlate nearest neighbour neighbours and so fourth) 
ntime = ceil(log2(96/ncum));
% number of frames within an independent part of the movie -> correlations do not extend beyound win frames
win = 2^ntime*ncum;

cd(pathname);
resultDir = ['results' date] ; 
if exist(resultDir) ~= 7, mkdir(resultDir); end 
cdirInfo = dir; % find out number and names of files in folder

nfile = 1;
for i = 1:numel(cdirInfo)
    if(~cdirInfo(i).isdir) % if its not a directory, it has to be a file
        filelist{nfile,1} = cdirInfo(i).name;
        nfile = nfile +1;
    end
end

% sort shiftTable according to virtual pixel positions
% XCshiftTable computes all possible ways to correlate pixels of the sample
% movie in space and time. posTable holds the center position of the
% correlated pixels (virtual pixels), distFactor is the factor with which a
% combination of correlated pixels will be weighted see (Dertinger et al. Sofi 2010) 
[shiftTable posTable distFactor] = XCshift( ncum, MaximumNumberOfSofiRuns,variance);
[posTable index]= sortrows(posTable);
shiftTable = shiftTable(index,:,:);
distFactor = distFactor(index);

display(['Number of combinations is ' num2str(size(shiftTable,1))]);

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

%% actual jobs: each file is computed in multiple jobs, each processing a part of the movie

% routines used by the cluster
fd1 = 'XCcumulants.m';
fd2 = 'XCSofi.m';
fd3 = 'XCSofiAnalysis.m';

for f = 1:numel(filelist)
    
    display(['file' num2str(f)])
    warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning;
    InfoImage = imfinfo(filelist{f}); 
    frames = length(InfoImage);
    img_width = InfoImage(1).Width;
    img_height = InfoImage(1).Height;
    
    raw = zeros(img_width,img_height);  
    sofi = zeros(img_width,img_height,ncum,ncum);
    normFactor = zeros(ncum,ncum);
    
    for i = 1:(floor(frames/win))
        
        % loading a part of the file and subtracting the mean
        part_img = fastTiff(filelist{f},1+(i-1)*win,i*win);
        % raw = unprocessed superposition of all frames for comparison 
        raw = raw+sum(part_img,3);
        part_img = part_img-repmat(mean(part_img,3), [1 1 size(part_img,3)]);
        
        display(['setup of ','job ',num2str(i),'/',num2str(floor(frames/win))]);
        JobStruct.(['pjob',num2str(i)]) = createParallelJob(sched);
        set(JobStruct.(['pjob',num2str(i)]),'FileDependencies',{fd1 fd2 fd3});
        set(JobStruct.(['pjob',num2str(i)]),'JobData',part_img);
        
        % for 128 512x512 frames in a Job (ncum =2/4) the data can not be distributed
        % to more than 76 workers (probably because of headnode memory limitations)

        maxWorkerCount = ceil(size(shiftTable,1)/ceil(size(shiftTable,1)/size(result,1)));
        if ncum == 2||ncum == 4
            if maxWorkerCount <76
               set(JobStruct.(['pjob',num2str(i)]), 'MaximumNumberOfWorkers', maxWorkerCount);
               set(JobStruct.(['pjob',num2str(i)]), 'MinimumNumberOfWorkers', 1);
            else
               set(JobStruct.(['pjob',num2str(i)]), 'MaximumNumberOfWorkers', 76);        
               set(JobStruct.(['pjob',num2str(i)]), 'MinimumNumberOfWorkers', 1);
            end
        else
            set(JobStruct.(['pjob',num2str(i)]), 'MaximumNumberOfWorkers', maxWorkerCount);
            set(JobStruct.(['pjob',num2str(i)]), 'MinimumNumberOfWorkers', 1);
        end

        pTaskStruct.(['task',num2str(i)]) = createTask(JobStruct.(['pjob',num2str(i)]), @XCSofi,3, {ncum,ntime,shiftTable,posTable,distFactor});
        display(['submitting job',num2str(i),'...']);
        submit(JobStruct.(['pjob',num2str(i)]));

        display(['job' num2str(i) ' computing...']);
        waitForState(JobStruct.(['pjob',num2str(i)]),'finished');
        errMsgStruct.(['pjob',num2str(i)]) = get(pTaskStruct.(['task',num2str(i)]),'Error');
        display(['job' num2str(i) ' retrieving results...']);
        resultStruct.(['result',num2str(i)]) = getAllOutputArguments(JobStruct.(['pjob',num2str(i)]));
        
        % gather output sorted by position of virtual pixel
        for k = 1:ncum
            for l = 1:ncum
                for j = 1:size(resultStruct.(['result',num2str(i)]),1)
                    for m = 1:size(resultStruct.(['result',num2str(i)]){j,3},1)
                        if size(size(resultStruct.(['result',num2str(i)]){j,2}),2) == 2
                            if isequal(resultStruct.(['result',num2str(i)]){j,3},[k l])
                                % output summed for a certain position and weighed with normFactor.
                                sofi(:,:,k,l) = sofi(:,:,k,l) + resultStruct.(['result',num2str(i)]){j,1};
                                if i == 1 % normFactor will be the same for all wins (all i)
                                    normFactor(k,l) = normFactor(k,l) + resultStruct.(['result',num2str(i)]){j,2};
                                end
                            end
                        else
                            if isequal(resultStruct.(['result',num2str(i)]){j,3}(m),[k l])
                                sofi(:,:,k,l) = sofi(:,:,k,l) + resultStruct.(['result',num2str(i)]){j,1}(:,:,m);
                                if i == 1
                                    normFactor(k,l) = normFactor(k,l) + resultStruct.(['result',num2str(i)]){j,2}(m);
                                end
                            end
                        end
                    end
                end
            end
        end

        destroy(JobStruct.(['pjob',num2str(i)]));     
    end
    
    flag = 0; % if not all virtual pixels are 'occupied' you can't create an extended image 
    for k = 1:ncum
        for l = 1:ncum
            if isequal(squeeze(sofi(:,:,k,l)),zeros(size(sofi,1),size(sofi,2)))
                flag = 1;
            else
                sofi(:,:,k,l) = sofi(:,:,k,l)/normFactor(k,l);
            end
        end
    end

    % Building the new larger sofi image. Subtract -3 because edges of sofi images are filled with zeros
    final = zeros((size(sofi,1)-3)*ncum,(size(sofi,2)-3)*ncum);
    
    for k = 1:ncum
        for l = 1:ncum
            % again mind the empty edges
            final(k:ncum:end-(ncum-k),l:ncum:end-(ncum-l)) = sofi(2:end-2,2:end-2,k,l);
        end
    end    

    % set background to zero (cancel negativ correlations) and write to tiff file
    % the reason for negativ correlations in higher order is unclear.
    % Perhaps taking the modulus is more correct
    if ncum == 2, 
        final(final<0) = 0; 
    end
    
    filename = regexprep( filelist{f}, '.tif', '.mat');
    filename = fullfile(resultDir,filename);
    tiffname = regexprep( filename, '.mat', '_processed.tif');
    
    % if all virtual positions have been computed, save the merged image,
    % if not, save the single sofi image
    if flag == true
        Sofi = squeeze(sofi(:,:,1,1));
        Sofi(Sofi<0) = 0;
        save(filename,'Sofi','raw');
        Sofi = Sofi/max(max((Sofi)));
        Sofi = im2uint16(Sofi);
        imwrite(Sofi,tiffname,'Compression','none');
    else
        save(filename,'raw','final','sofi');
        final = final/max(max(final)); 
        final = im2uint16(final);
        imwrite(final,tiffname,'Compression','none');
    end
    
end

end
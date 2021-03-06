function [  ] = ClientSofi(  filename, ncum, variance )
% same as initXCSofi but without cluster
% for client profiling (combcount vs time)

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
MaximumNumberOfSofiRuns = ncum^2; % every virtual position is represented with only one combination
ntime = ceil(log2(96/ncum));
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

[shiftTable posTable distFactor] = XCshift( ncum, MaximumNumberOfSofiRuns,variance);
[posTable index]= sortrows(posTable);
shiftTable = shiftTable(index,:,:);
distFactor = distFactor(index);

%% actual jobs

for f = 1:numel(filelist)
    
    display(['file' num2str(f)])
    warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning;
    InfoImage = imfinfo(filelist{f}); 
    frames = length(InfoImage);
    img_width = InfoImage(1).Width;
    img_height = InfoImage(1).Height;
    
    raw = zeros(img_width,img_height);  
    
    for i = 1:floor(frames/win)

        part_img = fastTiff(filelist{f},1+(i-1)*win,i*win);
        raw = raw+sum(part_img,3);
        part_img = part_img-repmat(mean(part_img,3), [1 1 size(part_img,3)]);

        display(['computing ','job ',num2str(i),'/',num2str(floor(frames/win))]);
        final = ClientSofiExecute(part_img,ncum,ntime,shiftTable,posTable,distFactor);

    end

    filename = regexprep( filelist{f}, '.tif', '.mat');
    filename = fullfile(resultDir,filename);
    tiffname = regexprep( filename, '.mat', '_processed.tif');
    
    save(filename,'raw','final');
    final = final/max(max(final)); 
    final = im2uint16(final);
    imwrite(final,tiffname,'Compression','none');
    
end
    
end
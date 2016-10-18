function [] = simplesofi( filename, ncum )
%serial Sofianalysis for cumulant order up to 4 (autocorrelations), no
%cluster involoved, input images should be square. All input within folder
%will be computed

% Parameters:
%            ncum : cumulant order -> sqrt(magnification)
%            win  : number of frames forming an independent block (concerning autocorrelation)
%            ntime: number of times win-blocks will be halfed in each
%                   iteration -> determining correlation length

if (nargin == 0 || isempty(filename))
    [filename, pathname] = uigetfile('*.tif', 'select image file');
    name = [ pathname, filename ];
end

if nargin < 2, ncum = 2; end
if ncum < 2, display('cumulant order set to 2'); ncum = 2; end
if ncum > 4, display('cumulant order set to 4'); ncum = 4; end

% setting parameters dependent on cumulant order.
ntime = zeros(ncum-1,1); 
win = zeros(ncum-1,1);
for i=1:ncum-1
    ntime(i) = (ceil(log2(1e2/(i+1))));
    win(i) = 2^ntime(i)*(i+1);
    if ncum == 2, win(2) = 192; end
end

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

for f = 1:numel(filelist)
    
    % getting frame count, image size and file ID
    warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning;
    InfoImage = imfinfo(filelist{f});
    img_width = InfoImage(1).Width;
    img_height = InfoImage(1).Height;
     frames = length(InfoImage);
%     frames = 1000;
    FileID = tifflib('open',filelist{f},'r');  
    rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);

    % in case the movie does not fit into memory k-loop is repeated
    % one frame has 2 MB (512*512*8) -> 1536 = 3 GB are processed in one iteration. 
    % you could choose a larger value for a good computer make sure that you
    % can devide it by 128 and 192, (mod(1536,128)=0 & mod(1536,192)=0)
    if frames > 1536, Wins = 1536;
    else
        if frames-mod(frames,win(1)) > frames-mod(frames,win(2)) %pick the larger block size
            Wins = frames-mod(frames,win(1)); frames = Wins;
        else
            Wins = frames-mod(frames,win(2)); frames = Wins;
        end
    end

    % preallocating containers for sofi calculation output
    raw = zeros(img_width,img_height,floor(frames/win(1)));
    % suffix indicates which cumulant order this will be used for (difference in 3rd dim)
    processed_2 = zeros(img_width,img_height,ntime(1),ceil(frames/Wins));
    if ncum > 2, processed_3 = zeros(img_width,img_height,ntime(2),ceil(frames/Wins)); end
    if ncum > 3, processed_4 = zeros(img_width,img_height,ntime(3),ceil(frames/Wins)); end

    for k = 1:ceil(frames/Wins)
        dummy = Wins; % for last iteration when Wins is changed.
        if k*Wins > frames % again pick the larger block size, truncate later.
            if frames-mod(frames,win(1)) > frames-mod(frames,win(2))
                Wins = frames-mod(frames,win(1))-(k-1)*Wins;
            else
                Wins = frames-mod(frames,win(2))-(k-1)*Wins;
            end
        end
        part_image = zeros(img_width,img_height,Wins);    

        %read image
        for i = 1:Wins
           tifflib('setDirectory',FileID,i+(k-1)*dummy);
           % Go through each strip of data.
           rps = min(rps,img_width);
           for r = 1:rps:img_width
              row_inds = r:min(img_width,r+rps-1);
              stripNum = tifflib('computeStrip',FileID,r);
              part_image(row_inds,:,i) = tifflib('readEncodedStrip',FileID,stripNum);
           end
        end

        %process part_image
        for j = 1:ncum-1
            [sofi,common] = SofiAnalysis(part_image,j+1,ntime(j),win(j));
            if j == 1
                processed_2(:,:,:,k) = sofi;
                raw(:,:,1+(k-1)*(Wins/win(1)):k*(Wins/win(1))) = common;
            elseif j == 2
                processed_3(:,:,:,k) = sofi;
            else
                processed_4(:,:,:,k) = sofi;
            end
        end
    end
    tifflib('close',FileID);
    % normalize intensity
    raw = (sum(raw,3)-min(raw(:)))/(max(raw(:))-min(raw(:)));
    final(:,:,1) = squeeze(mean(sum(processed_2,4),3));

    if ncum > 2,final(:,:,2) = squeeze(mean(sum(processed_3,4),3)); end
    if ncum > 3,final(:,:,3) = squeeze(mean(sum(processed_4,4),3)); end

    for m = 1:ncum-1
        final(:,:,m) = final(:,:,m)/max(max(final(:,:,m)));
    end
    % save to file
    filename = regexprep( filelist{f}, '.tif', '.mat');
    filename = fullfile(resultDir,filename);
    tiffname = regexprep( filename, '.mat', '_processed.tif');
    save(filename,'raw','final');
    mim(final);
    print('-dtiff',tiffname);
    display([num2str(f) '/' num2str(numel(filelist)) ' processed']);
end
    
end
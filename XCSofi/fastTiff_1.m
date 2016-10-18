function [ img, frames ] = fastTiff( name,firstImg,lastImg )

if (nargin == 0 || isempty(name))
    [filename, pathname] = uigetfile('*.tif;', 'select image file');
    name = [ pathname, filename ];
end

if (exist(name,'file') == 0)
    disp('file not found');
    return;
end

% img = [];

%check for matfile
% matfilename = regexprep(filename, '.tif|.stk|.lsm', '.mat');
% if (exist(matfilename,'file') > 0)
%     % load existing file, partial loading only works with matfile objects -> matlab >2011b
%     load(matfilename); %if variables in your matfiles all have the same name, you may include it here
%     frames = size(img, 3);
% else
    warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning;
    InfoImage = imfinfo(name);          % getting frame count and image size
    img_width = InfoImage(1).Width;
    img_height = InfoImage(1).Height;
    if nargin < 3
        if nargin < 2
            frames = length(InfoImage);
            firstImg = 1;
        else
            frames = length(InfoImage)+1-firstImg; 
            lastImg = length(InfoImage);
        end
    else
        frames = lastImg+1-firstImg;
    end
    FileID = tifflib('open',name,'r');  %direct call to tifflib without matlab wrapper
    rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);

    img = zeros(img_width, img_height, frames);
    % loop over entire tiff stack. if you want to avoid memory
    % issues with large data, you must loop over smaller portions
    % use first and last
    for j = 1:frames 
        
        tifflib('setDirectory',FileID,j-1+firstImg);
        rps = min(rps,img_width);   %"rows per strip"
        for r = 1:rps:img_width
            row_inds = r:min(img_width,r+rps-1);
            stripNum = tifflib('computeStrip',FileID,r);
            img(row_inds,:,j) = tifflib('readEncodedStrip',FileID,stripNum);
        end
    end
    tifflib('close',FileID);
% end

end


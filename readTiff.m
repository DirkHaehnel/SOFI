function [FinalImage] = readTiff(varargin)
% image = READTIFF(varargin)
% Fast Tiff reader for Matlab.
% READTIFF(filename) reads in whole image stack. READTIFF(filename,n) only reads in image # n. READTIFF(filename, n1,n2) reads in images # n1 to # n2. READTIFF(filename, n1, n2, filename 2) also saves a .mat file to filename 2.
% filename 1 and filename 2 are strings, n1 and n2 are integers.

if nargin == 0
    [filename,pathname]=uigetfile('*.tif', 'select image file');
    varargin{1}=[pathname,filename];
end    
    
FileTif=varargin{1};
matfilename = regexprep(FileTif, '.tif', '.mat');

if (exist(matfilename,'file') > 0)
    % load existing file
    load(matfilename,'FinalImage');
    
else
    InfoImage=imfinfo(FileTif);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;

        if nargin >= 3
            ImageStart=varargin{2};
            ImageEnd=varargin{3};
            NumberImages=abs(ImageEnd-ImageStart)+1;
        elseif nargin == 2
            ImageStart=varargin{2};
            ImageEnd=ImageStart;
            NumberImages=1;
        elseif nargin == 1
            NumberImages=length(InfoImage);
            ImageStart=1;
            ImageEnd=NumberImages;
        else
            error('Input method: readTiff(Filename,Start of Stack,End of Stack) or \n readTiff(Filename)');
        end

    % read unsigned 16Bit Integer - change if necessary!
    FinalImage=zeros(nImage,mImage,NumberImages,'double');
    FileID = tifflib('open',FileTif,'r');
    rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);

        for i=ImageStart:ImageEnd
        % for i=1:NumberImages
           tifflib('setDirectory',FileID,i);
           % Go through each strip of data.
           rps = min(rps,nImage);
           for r = 1:rps:nImage
              row_inds = r:min(nImage,r+rps-1);
              stripNum = tifflib('computeStrip',FileID,r);
              FinalImage(row_inds,:,i-ImageStart+1) = tifflib('readEncodedStrip',FileID,stripNum);
           end
        end
        if (nargin == 4 && varargin{4} == 1)
            save(matfilename, 'FinalImage');
        end
        tifflib('close',FileID);
end
%externDirectory
%externActualFile
%save(strcat(externDirectory,'Data_',externActualFile,'_OriginalData','.mat'),'-v7.3','im');

tic;
tempIm  = imread(nameFile);
dimIm   = size(tempIm);
infoImage = imfinfo(nameFile);
num_imagesTotal = numel(infoImage);

averageTimeReadParams = toc;
tic;
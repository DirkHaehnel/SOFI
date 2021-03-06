clear im;
im = zeros(dimIm(1),dimIm(2),num_images);

dummyMaximo = zeros(1,num_images);
dummyMaximo(1) = max(max(tempIm));
for j=1:num_images
    im(:,:,j) = imread(nameFile,startIndex-1 + j, 'Info', infoImage);
    dummyMaximo(j) = max(max(im(:,:,j)));
end
timeReadImages = toc;
averageTimeReadImages = timeReadImages/num_images;

tic;
% For manage troubles with black images
dummyTest = 1;
indexToDeleteDummy = 0;
dummyMaxMax = max(dummyMaximo);
dummyMean = mean(dummyMaximo);
dummyIndexToDelete(1) = 0;
while dummyTest
    [dummyMinimo, dummyIndex] = min(dummyMaximo);
    if(dummyMinimo < 0.1 * dummyMean)
        indexToDeleteDummy = indexToDeleteDummy + 1;
        num_images = num_images - 1;
        dummyMaximo(dummyIndex) = dummyMean;
        dummyIndexToDelete(indexToDeleteDummy) = dummyIndex;
    else
        dummyTest = 0;
    end
end
dummyTest = 1;
while dummyTest
    [dummyMaxMax, dummyIndex] = max(dummyMaximo);
    if(dummyMaxMax > 10 * dummyMean)
        indexToDeleteDummy = indexToDeleteDummy + 1;
        num_images = num_images - 1;
        dummyMaximo(dummyIndex) = dummyMean;
        dummyIndexToDelete(indexToDeleteDummy) = dummyIndex;
    else
        dummyTest = 0;
    end
end

dummyIndexToDelete = sort(dummyIndexToDelete,'descend');
for dummyDelete = 1: indexToDeleteDummy
    im(:,:,dummyIndexToDelete(dummyDelete)) = [];
end

timeTestImages = toc;

tic;
MaximaOriginalImage = max(im,[],3);
averageOriginalImage = mean(im,3);
averageOriginalImage = averageOriginalImage - min(min(averageOriginalImage));
averageOriginalImage = averageOriginalImage./max(max(averageOriginalImage));

MaximaOriginalImage = MaximaOriginalImage - min(min(MaximaOriginalImage));
MaximaOriginalImage = MaximaOriginalImage./max(max(MaximaOriginalImage));

averageTimeOriginalImage = toc;

%imwrite(averageOriginalImage,strcat(externDirectory,externActualFile,'_AverageImage.tif'));
%imwrite(MaximaOriginalImage,strcat(externDirectory,externActualFile,'_MaxImage.tif'));

%%save(strcat(externDirectory,'Data_',externActualFile,'_OriginalData','.mat'),'-v7.3','im');

clear MaximaOriginalImage averageOriginalImage *Time* *time* j
%clear im

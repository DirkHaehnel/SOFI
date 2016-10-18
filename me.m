
dirname='W:\Anja2\SOFI\RSFP Data\2014-01-23_3 rsEGFP2\movies\';
fnames = dir([dirname '*.tif']);

for j=1:length(fnames)
        %load([dirname fnames(j).name]);
        img=ReadTiff_CP([dirname fnames(j).name]); 
        m=mean(img,3);
        save([dirname fnames(j).name '_mean.txt'],'m','-ascii');
    end
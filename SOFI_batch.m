
dirname='W:\Anja2\SOFI\RSFP Data\2014-01-23_2 rsFastLime\movies\';
fnames = dir([dirname '*.tif']);

for j=1:length(fnames)
        im=ReadTiff_CP([dirname fnames(j).name]); 
        %im=FastTiff([dirname fnames(j).name]); 
        [sof, im0, soffull] =SOFIAnalysis1(im,4);
        sof2=sof(:,:,1);
        save([dirname fnames(j).name '_2nd.txt'],'sof2','-ascii');
        sof3=sof(:,:,2);
        save([dirname fnames(j).name '_3rd.txt'],'sof3','-ascii');
        sof4=sof(:,:,3);
        save([dirname fnames(j).name '_4th.txt'],'sof4','-ascii');
        tmp = sum(im0,3);
        save([dirname fnames(j).name '_tmp.txt'],'tmp','-ascii');
    end
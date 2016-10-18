
dirname='X:\Anja\SOFI\Neurons Data\NEU AC\mmh\';
fnames = dir([dirname '*.mat']);

for j=1:length(fnames)
        load([dirname fnames(j).name]);
        sof2=sof(:,:,1);
        save([dirname fnames(j).name '_SOFI.txt'],'a','-ascii');
    end
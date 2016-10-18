dirname='X:\Anja\SOFI\RSFP Data\2014-01-24_2 rsEGFP58 filled teal\test\';
fnames = dir([dirname '*.tif']);

for j=1:length(fnames)
        PAP_halftime6
        
       save([dirname fnames(j).name '_taurise.txt'],'taurise','-ascii');
       save([dirname fnames(j).name '_taufall.txt'],'taufall','-ascii');
       save([dirname fnames(j).name '_tauon.txt'],'tauon','-ascii');
    end
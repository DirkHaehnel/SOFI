close all;
clear all;


simData=true;
cumOrder=6;
interpolationGridPoints=2;
executeOnCluster=true;
tauBinning=8;
display=true;

if(simData)
    pathname=uigetdir('\\jesrv\WG-Data\*','Pick a path where your simulation data is saved');
    cd(pathname);
    pr=dir('*.mat');
else
    pathname=uigetdir('\\jesrv\WG-Data\*','Pick a path where your mesaurement data data is saved');
    cd(pathname);
    pr=dir('*.tiff');
end

filelist={pr.name};
for d = 1:length(filelist)
    fcell=strcat(pathname,'\',filelist(d));
    fname=fcell{1};
    if(simData)
        load(fname);
        imageStack=sofiSimOut;
    else
        imageStack = fastTiff(fname);
    end
    [noSof,sofOut] = SofiAnalysisMap(imageStack,cumOrder,tauBinning,interpolationGridPoints,executeOnCluster);
    fullPathToFile = fullfile(fname, 'SofiData1.mat');
    save(fullPathToFile,'sofOut','noSof','cumOrder','interpolationGridPoints');
    
    if(display)
        %show results
        mim(cat(3,noSof,sofOut));
    end
end






dirname = 'X:\Anja\SOFI\RSFP Data\2013-12-18_6 pLE7\rsEGFP1_4_9_20ms\rsEGFP1_4_9_20ms_square-im\';

fnames = dir([dirname '*SOFI*.mat']);
    for j=1:length(fnames)
        load([dirname fnames(j).name]);
        res = abs(fft2(fftshift(ifftshift(ifft2(final)).*weight)));  %.*filter  % inside the most inner bracket is the name of the variable save in the mat file
        save([dirname fnames(j).name '_res.txt'],'res','-ascii');
    end
    
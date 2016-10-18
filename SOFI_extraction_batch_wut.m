
dirname='X:\Anja\SOFI\Neurons Data\NEU AC\mmh\';
fnames = dir([dirname '*.mat']);

for j=1:length(fnames)
        load([dirname fnames(j).name]);
        a=sof(:,:,1); 
    
        name=fnames(1, 1).name;
        name = name(1:find(name,'.'));
        name = [name '.txt'];
        save(name,'a','-ascii');
        % save([dirname fnames(j).name '_SOFI.txt'],'a','-ascii');
end
    


    
   
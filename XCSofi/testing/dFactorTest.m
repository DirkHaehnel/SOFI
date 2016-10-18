function [  ] = dFactorTest(variance,filename)
% called on output from varianceTest saved in 'template2ndOrderSofi.mat'.
% This function takes unweighted 2nd order sofi images belonging to
% different combinations, and pieces them together to one image with virtual
% interpixels. The purpose is to test for the right size of an emitters PSF
% in pixel units

if nargin<1, variance =2.55; end
if (nargin < 2 || isempty(filename))
    [filename, pathname] = uigetfile('*.mat', 'select image file');
    name = [ pathname, filename ];
end

% in 'name' you should find variables 'sofi', 'position' and 'dFactor'
load(name);
if ~exist('sofi')||~exist('position')||~exist('dFactor')
    display('wrong input file');
    return
end

% old variance is 1. Taking the nth root means multiplying the old variance
% with a factor n (new variance)
dFactor = nthroot(dFactor,variance);

for i = 1:size(dFactor,1)
    sofi(:,:,i) = sofi(:,:,i).*dFactor(i);
end

quarter = zeros(size(sofi,1),size(sofi,2),2,2);
normFactor = zeros(2,2);
% sorting the 73 sofi images stemming from different combinations according
% to the center position of the generated virtual pixel (4 possibilities)
for m = 1:2
    for n = 1:2
        for i = 1:size(position,1)
            if isequal(position(i,:),[m n])
                quarter(:,:,m,n) = quarter(:,:,m,n) + sofi(:,:,i);
                normFactor(m,n) = normFactor(m,n) + dFactor(i);
            end
        end
        quarter(:,:,m,n) = quarter(:,:,m,n)/normFactor(m,n);
    end
end

% putting together the four quarters to one final image with fourfold pixel
% count. The Sofi images have zeros at the edges, therefor -3
final = zeros((size(quarter,1)-3)*2,(size(quarter,2)-3)*2);

for m = 1:2
    for n = 1:2
        % again mind the empty edges
        final(m:2:end-(2-m),n:2:end-(2-n)) = quarter(2:end-2,2:end-2,m,n);
    end
end    
    
final(final<0) = 0;
mim(final);
end
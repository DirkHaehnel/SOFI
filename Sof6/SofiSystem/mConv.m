function y = mConv(a, b)

% y = mConv(a, b) convolves vector a with b where it is assumed that b has
% smaller size than a.

if size(a,1)==1 
    a = a.';
end
if size(b,1)==1 
    b = b.';
end

na = length(a);
nb = length(b);
if rem(nb,2)==0
   nb = nb/2;
   nbb = 0;
else
   nb = (nb-1)/2;
   nbb = 1;
end
fa = fft([a(nb:-1:1); a; a(end:-1:end-nb+1)]);
mask = zeros(size(fa));
mask(1:nb+nbb) = b(nb+1:end);
mask(end-nb+1:end) = b(1:nb);
mask = fft(mask);
tmp = real(ifft(fa.*conj(mask)));
y = tmp(nb+1:end-nb);


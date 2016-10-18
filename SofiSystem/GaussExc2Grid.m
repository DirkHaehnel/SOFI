function [fx, fy, fz] = GaussExc2Grid(nn,pixel,exc)

if length(nn)==1
    nn = [nn nn];
end

if length(pixel)==1
    [x,y] = meshgrid(-nn(2):nn(2),-nn(1):nn(1));
    rho = exc.rho(:,1)/pixel;
else
    x = nn;
    y = pixel;
    rho = exc.rho(:,1);
end
p = angle(x+i*y);
r = sqrt(x.^2+y.^2);

for k=1:size(exc.fxc,2)
    fx(:,:,k) = interp1(rho,exc.fxc(:,k,1),r,'spline',0);
    fy(:,:,k) = interp1(rho,exc.fyc(:,k,1),r,'spline',0);
    fz(:,:,k) = interp1(rho,exc.fzc(:,k,1),r,'spline',0);
    for j=1:size(exc.fxc,3)-1
        fx(:,:,k) = fx(:,:,k) + cos(j*p).*interp1(rho,exc.fxc(:,k,j+1),r,'spline',0) + sin(j*p).*interp1(rho,exc.fxs(:,k,j),r,'spline',0);
        fy(:,:,k) = fy(:,:,k) + cos(j*p).*interp1(rho,exc.fyc(:,k,j+1),r,'spline',0) + sin(j*p).*interp1(rho,exc.fys(:,k,j),r,'spline',0);
        fz(:,:,k) = fz(:,:,k) + cos(j*p).*interp1(rho,exc.fzc(:,k,j+1),r,'spline',0) + sin(j*p).*interp1(rho,exc.fzs(:,k,j),r,'spline',0);
    end
end

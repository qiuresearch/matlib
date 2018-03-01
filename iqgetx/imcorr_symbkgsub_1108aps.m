function [im, bkgdata]  = bkg2d_subsym_1108aps(im, xycen, varargin)

% Mask the data
im_size = size(im);
[xgrid, ygrid] = meshgrid(1:im_size(2), 1:im_size(1));
[theta, r] = cart2pol(xgrid-xycen(1), ygrid-xycen(2));

theta_min = pi*0.95;
theta_max = pi*1.1;

beamstop_radius = 250;
iexcluded = find((theta>theta_min) | (theta<-theta_min));
iexcluded = [iexcluded; find(r<beamstop_radius)];

mask = ones(im_size, 'uint8');
mask(iexcluded)= 0;

% Divide the data into quadrants
num_xs = 2;
num_ys = 2;

xstep = im_size(2)/num_xs;
ystep = im_size(1)/num_ys;

% correct the data, block by block
bkgdata = im;
for i=1:num_xs
   for j=1:num_ys
      ix = (i-1)*xstep+1;
      iy = (j-1)*ystep+1;
      xycen_tmp = xycen-[ix-1,iy-1];
      [im(iy:iy+ystep-1, ix:ix+xstep-1), bkgdata(iy:iy+ystep-1, ...
                                                 ix:ix+xstep-1)] = ...
          bkg2d_subsym(im(iy:iy+ystep-1, ix:ix+xstep-1), xycen_tmp, ...
                       'mask', mask(iy:iy+ystep-1, ix:ix+xstep-1), varargin{:});
   end
end

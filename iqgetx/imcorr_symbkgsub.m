function [im, bkgdata]  = imcorr_symbkgsub(im, xycen, varargin)

% radius and rwidth are in pixels
verbose = 1;
mask = [];
num_points = 500;
negfraction = 0.10; % fraction of negative values after subtraction
parse_varargin(varargin);

showinfo('Perform symmetric background subtraction ...');

% convert masked region to NaN (ignored by mink.m)
if ~isempty(mask)
   mask(find(mask == 0))=NaN;
   im_masked = im .* double(mask);
else
   im_masked = im;
end

% convert to polar coordinates
im_size = size(im);
[xgrid, ygrid] = meshgrid(1:im_size(2), 1:im_size(1));
[theta, r] = cart2pol(xgrid-xycen(1), ygrid-xycen(2));
clear xgrid ygrid

% sort r, and bin r into grids
[r, i_sorted] = sort(r(:));
rwidth = (r(end)-r(1))/num_points;
r_bins = round(r/rwidth);
% each non-zero is the start of a new bin
r_bins = r_bins(2:end)-r_bins(1:end-1);
i_edges = [1; find(r_bins > 0)+1; im_size(1)*im_size(2)+1];

% initialize the bkgdata
bkgdata = zeros(im_size);
for i=1:length(i_edges)-1
   % find the nth smallest number as the background
   length_bin = i_edges(i+1)-i_edges(i);
   i_bin = i_sorted(i_edges(i):i_edges(i+1)-1);
   bkg = mink(im_masked(i_bin), ceil(length_bin*negfraction));

   bkgdata(i_bin) = bkg(end); % or take the mean of bkg
end
im = im- bkgdata;

%  OLD METHOD 
% for i=1:length(radius)
%    % disp(sprintf('Processing point #%i of %i', i, length(radius)))
% 
%    % find the "band" integrate
%    iselected= find((r >= (radius(i)-rwidth)) & (r <= (radius(i)+rwidth)));
%    
%    if isempty(iselected)
%       disp('No data found in this range, move to the next...')
%       continue
%    end
%       
%    % bkg = mean(im(iselected));
%    % [n, x] = hist(im(iselected));
%    % minimum = min(im(iselected));
%    bkg = median(im(iselected));
%    
%    % nsorted = sort(im(iselected));
%    % bkg = sorted(ceil(0.1*length(sorted)));
%     bkgdata(iselected) = bkgdata(iselected) + bkg;
%    count_bkgdata(iselected) = count_bkgdata(iselected)+1;
%    
% end


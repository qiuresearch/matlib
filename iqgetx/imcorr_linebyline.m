function [im_out, row_x] = lblcorrect_flicam(im_in, covered_columns, varargin)
% Correct the FLICAM line by line variations in dark counts.  Usually
% a stripe is covered by lead or alike, so that we can use the
% covered columns as the reference to the dark counts
%
if ~exist('covered_columns', 'var') || isempty(covered_columns)
  covered_columns = 918:1012;
  % 0704gline: 1:88
  % 1011gline: 918:1012
end

setbkgzero = 1; % 
parse_varargin(varargin);

%
[num_rows, num_cols] = size(im_in);

im_c = im_in(:,covered_columns);
avg = mean(im_c(:));
s = std(double(im_c(:)));

[zx, zy] = find(im_c>(s*2000+avg)); % possible zingers
im_c(zx, zy) = avg;
row_m = mean(im_c,2);
row_x = row_m-avg;
row_c = row_x(:,ones(num_cols,1));

% why???
im_out=double(im_in)-row_c;
if (setbkgzero == 1)
   im_out(:,:) = im_out(:,:) - total(im_out(:,covered_columns))/ ...
       numel(im_out(:, covered_columns));
end

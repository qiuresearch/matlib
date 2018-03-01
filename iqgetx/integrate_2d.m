function [data_out, data_bins] = integrate_2d(data_in, sPar)
% --- Usage:
%        [data_out, data_bins] = integrate_2d(data_in, sPar)
% --- Purpose:
%        do a radial integration of an image. This method is rather
%        slow. Five methods are implemented. I tried to optimize the
%        speed. But finally gave up. It may be more worthwhile to
%        write a better C code (without crashing all the time).
%
% --- Parameter(s):
%
%
% --- Return(s):
%        data_outs - the integrated data (Nx2 matrix)
%        data_bins - the number of bins of each point (1xN vector)
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: integrate_2d.m,v 1.1 2013/08/18 04:10:55 xqiu Exp $
%

% for easier use with MOA package
global MaskI X_cen Y_cen 

% 1) Simple check on input parameters

if (nargin < 1)
   error('You should give the 2D data as input!');
   return;
end

[num_rows, num_cols] = size(data_in);

if (nargin < 2)
   sPar.MaskI = MaskI; % ones(num_rows, num_cols
   sPar.X_cen = X_cen; % floor(num_cols/2);
   sPar.Y_cen = Y_cen; % floor(num_rows/2);
   sPar.Y_scale = 1.0; % a constant to scale Y
   sPar.rmin = 0.0;
   sPar.rmax = sqrt(max(sPar.X_cen, num_cols - sPar.X_cen)^2 + ...
                    max(sPar.Y_cen, num_rows - sPar.Y_cen)^2 );
   sPar.num_points = floor((sPar.rmax - sPar.rmin)/2);
   sPar.mode = 1; % not used yet
   sPar.method = 1;
end

% 2) Create the r values for data_out array
rgrid = (sPar.rmax - sPar.rmin)/(sPar.num_points-1); 
% the index of each pixel to the integrated array
index_matrix = round(1.0/rgrid*sqrt( repmat(sPar.Y_scale^2*([1: ...
                    num_cols]- sPar.Y_cen).^2, num_rows, 1) + ...
                                     repmat(([1: num_rows]'- ...
                                             sPar.X_cen).^2, 1, ...
                                            num_cols))) + 1;

x_out = linspace(sPar.rmin, sPar.rmax, sPar.num_points);
y_out = zeros(1, sPar.num_points);
data_bins = zeros(1, sPar.num_points);

% 3) do the integration
switch sPar.method
   case 1 % ad hoc method: process element one by one
      disp('INTEGRATE_2D:: ah hoc addition method, be patient!')
      data_in = data_in .* sPar.MaskI;
      i_overflow = find(index_matrix > sPar.num_points);
      if ~isempty(i_overflow)
         disp(['WARNING:: some elements are out of the range, set ' ...
               'to 1!'])
         index_matrix(find(index_matrix > sPar.num_points)) = 1;
      end
      for irow=1:num_rows
         for icol=1:num_cols
            y_out(index_matrix(irow,icol)) = y_out(index_matrix(irow,icol)) ...
                + data_in(irow,icol);
            data_bins(index_matrix(irow,icol)) = ...
                data_bins(index_matrix(irow,icol)) + sPar.MaskI(irow,icol);
            
         end
      end
      % handle the case when no bins for some points
      i_nobins = find(data_bins ==0);
      if isempty(i_nobins)
         y_out = y_out ./ data_bins;
      else
         data_bins(i_nobins) = 1;
         y_out = y_out ./ data_bins;
         data_bins(i_nobins) = 0;
      end
   case 2 % another ad hoc method: 
      index_matrix = index_matrix .* sPar.MaskI;
      for ip = 1:sPar.num_points
         data_ip = data_in(index_matrix == ip);
         if ~isempty(data_ip);
            data_bins(ip) = length(data_ip(:));
            y_out(ip) = 1.0/data_bins(ip)*sum(data_ip(:));
         end
      end
   case 3 % 
      index_matrix = index_matrix .* sPar.MaskI;
      for ip=1:sPar.num_points
         index_matrix = index_matrix -1;
         data_ip = data_in(~index_matrix);
         if ~isempty(data_ip);
            data_bins(ip) = length(data_ip(:));
            y_out(ip) = 1.0/data_bins(ip)*sum(data_ip(:));
         end      
      end
   case 4 % method 4: extract first the two rectangle coordinates
          % containing the annulus to sum, then only process the
          % area between the two rectangles
      mymask = zeros(num_rows, num_cols);
      factor = 1.0/sqrt(2);
      for ibin = 1:sPar.num_points-1
         corner1 = floor(x_out(ibin)*factor);
         corner2 = ceil(x_out(ibin+1));
         % rectangle #1
         rect1_row = [min(num_rows, max(1, -corner2+sPar.X_cen)): ...
                      min(num_rows, max(1, -corner1+sPar.X_cen)), ...
                      min(num_rows, max(1, corner1+sPar.X_cen)): ...
                      min(num_rows, max(1, corner2+sPar.X_cen))];
         rect1_col1 = min(num_cols, max(1, -corner2+sPar.Y_cen));
         rect1_col2 = min(num_cols, max(1,  corner2+sPar.Y_cen));
         rect2_row1 = min(num_rows, max(1, -corner1+sPar.X_cen));
         rect2_row2 = min(num_rows, max(1,  corner1+sPar.X_cen));
         rect2_col = [min(num_cols, max(1, -corner2+sPar.Y_cen)): ...
                      min(num_cols, max(1, -corner1+sPar.Y_cen)), ...
                      min(num_cols, max(1, corner1+sPar.Y_cen)): ...
                      min(num_cols, max(1, corner2+sPar.Y_cen))];
         mymask(rect1_row, rect1_col1:rect1_col2) = ...
             index_matrix(rect1_row,rect1_col1:rect1_col2) == uint16(ibin);
         mymask(rect2_row1:rect2_row2, rect2_col) = ...
             index_matrix(rect2_row1:rect2_row2, rect2_col) == uint16(ibin);
         
         y_out(ibin) = sum(sum(data_in(rect1_row, rect1_col1:rect1_col2) ...
                               .* mymask(rect1_row,rect1_col1:rect1_col2))) ...
             + sum(sum(data_in(rect2_row1:rect2_row2, rect2_col) .* ...
                       mymask(rect2_row1:rect2_row2, rect2_col)));
         num_totals =  sum(sum(mymask(rect1_row, rect1_col1:rect1_col2))) ...
             + sum(sum(mymask(rect2_row1:rect2_row2, rect2_col)));
         if (num_totals ~= 0.0) ;
            y_out(ibin) = y_out(ibin)/num_totals;
         end
      end
   case 5 % a similar method to 4
      mymask = repmat(false, num_rows, num_cols);
      factor = 1.0/sqrt(2);
      for ibin = 2:sPar.num_points-1
         corner1 = floor(x_out(ibin)*factor);
         corner2 = ceil(x_out(ibin+1));
         % rectangle #1
         rect1_row = [min(num_rows, max(1, -corner2+sPar.X_cen)): ...
                      min(num_rows, max(1, -corner1+sPar.X_cen)), ...
                      min(num_rows, max(1, corner1+sPar.X_cen)): ...
                      min(num_rows, max(1, corner2+sPar.X_cen))];
         rect1_col1 = min(num_cols, max(1, -corner2+sPar.Y_cen));
         rect1_col2 = min(num_cols, max(1,  corner2+sPar.Y_cen));
         rect2_row1 = min(num_rows, max(1, -corner1+sPar.X_cen));
         rect2_row2 = min(num_rows, max(1,  corner1+sPar.X_cen));
         rect2_col = [min(num_cols, max(1, -corner2+sPar.Y_cen)): ...
                      min(num_cols, max(1, -corner1+sPar.Y_cen)), ...
                      min(num_cols, max(1, corner1+sPar.Y_cen)): ...
                      min(num_cols, max(1, corner2+sPar.Y_cen))];

         mymask(rect1_row, rect1_col1:rect1_col2) = ...
             index_matrix(rect1_row,rect1_col1:rect1_col2) == uint16(ibin);
         mymask(rect2_row1:rect2_row2, rect2_col) = ...
             index_matrix(rect2_row1:rect2_row2, rect2_col) == ...
             uint16(ibin);
         data_ip = data_in(mymask);
         if ~isempty(data_ip) 
            y_out(ibin) = mean(data_ip);
         end
         mymask(rect1_row, rect1_col1:rect1_col2) = false;
         mymask(rect2_row1:rect2_row2, rect2_col) = false;
      end
   otherwise
end

% 4)
data_out = [x_out', y_out'];

      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: integrate_2d.m,v $
% Revision 1.1  2013/08/18 04:10:55  xqiu
% *** empty log message ***
%
% Revision 1.2  2013/02/28 16:51:44  schowell
% There should be no changes, only the time stamp updated.  I deleted these from my account on the server. Copied them back to my drive from xqiu/codev/matlib/ folder.  I sync'd these from the server to my computer then back.  When I do cvs update it says I made changes but did not.
%
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.3  2005/07/10 18:21:22  xqiu
% small changes
%
% Revision 1.2  2004/11/19 05:04:26  xqiu
% Added comments
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

function postfl = postfl_interp(postfl)
% --- Usage:
%        postfl = postfl_interp(postfl)
% --- Purpose:
%        interpolate the data from postfl.fem with cross section
%        settings from postfl.p1, p2, p3, p4, num_dims
% --- Parameter(s):
%         postfl - the postfl structure
% --- Return(s):
%        results - updated postfl structure
%
% --- Example(s):
%
% $Id: postfl_interp.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_interp
   return
end
if ~isfield(postfl, 'fem') || isempty(postfl.fem)
   disp('POSTFL_INTERP:: "fem" field does not exist, or is empty! ')
   return
end

% 0) get the constants in fem structure
postfl.const = fl_cell2struct(postfl.fem.const);

% 1) generate the cross section plane
postfl.num_dims = length(postfl.p1);

disp(['POSTFL_INTERP:: generating cross-section plane ...'])
switch length(postfl.num_points)
   case 1
      plotfl.xsection = line_gen(postfl.p1, postfl.p2, postfl.num_points);
   case 2
      postfl.xsection = plane_gen(postfl.p1, postfl.p2, postfl.p3, ...
                                  postfl.num_points);
   case 3
      postfl.xsection = volume_gen(postfl.p1, postfl.p2, postfl.p3, ...
                                   postfl.p4, postfl.num_points);
   otherwise
      disp(['POSTFL_INTERP:: the dimension can only be 1,2,or3!'])
      return
end

% 2) Exract u, v, w, c

disp(['POSTFL_INTERP:: extracting u,v,w,c data ...'])
switch postfl.num_dims
   case 2
      [postfl.u, postfl.v, postfl.c, i_nan] = postinterp(postfl.fem, ...
                                                        'u', 'v', ...
                                                        'c', postfl.xsection);
   case 3
      [postfl.u, postfl.v, postfl.w, postfl.c, i_nan] = ...
          postinterp(postfl.fem, 'u', 'v', 'w', 'c', postfl.xsection);
end
% check the existence of NAN
if ~isempty(i_nan)
   disp(['WARNING:: ' num2str(length(i_nan)) ' NANs found in the plane!'])
   disp(['           reset them to zero!!!']) % *** should think about this
   postfl.u(i_nan) = 0;
   postfl.v(i_nan) = 0;
   postfl.c(i_nan) = 0;
   if (postfl.num_dims == 3)
      postfl.w(i_nan) = 0;
   end
end
   
% 3) reshape the data into a two dimensional array
postfl.u = reshape(postfl.u, postfl.num_points);
postfl.v = reshape(postfl.v, postfl.num_points);
if (postfl.num_dims == 3) 
   postfl.w = reshape(postfl.w, postfl.num_points);
end
postfl.c = reshape(postfl.c, postfl.num_points);

% the x,y,z are mostly for late visualization purposes
postfl.x = reshape(postfl.xsection(1,:), postfl.num_points);
postfl.y = reshape(postfl.xsection(2,:), postfl.num_points);
if (postfl.num_dims == 3) 
   postfl.z = reshape(postfl.xsection(3,:), postfl.num_points);
end
postfl.xsection = []; % to save memory

% 4) show the summary of interpolated data
summary{1} = ['POSTFL_INTERP:: extracted cross section is from (' ...
              num2str(postfl.x(1,1)) ',' num2str(postfl.y(1,1)) [') ' ...
                    'to ('] num2str(postfl.x(postfl.num_points(1), ...
                                             postfl.num_points(2))) ...
              ',' num2str(postfl.y(postfl.num_points(1), ...
                                   postfl.num_points(2))) ')'];
summary{2} = ['                with size of ' num2str(postfl.num_points(2)) ...
              ' by ' num2str(postfl.num_points(1)) '.'];
for i=1:length(summary)
   disp(summary{i})
end

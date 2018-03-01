function postfl = postfl_getstream(postfl, varargin)
% --- Usage:
%        postfl = postfl_getstream(postfl, varargin)
% --- Purpose:
%        extracting the streams line from previously interpolated
%        u,v,w data. Starting line/plane points are taken from
%        postfl.p1,p2,p3,num_dims. The streamlines are then
%        reinterpolated to have the same x grids.  warning: the first
%        streamline is set to be at y==0. this may not be applicable
%        to some simulations.
%
% --- Parameter(s):
%        postfl - a postfl structure
%        varargin - 'refine' mesh refining for postplot (default: 2)
%
% --- Return(s):
%        postfl - postfl structure with "sldata" field updated
%
% --- Example(s):
%
% $Id: postfl_getstream.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_getstream
   return
end
refine = 2;
slstart = [];
parse_varargin(varargin);

postfl.num_dims = length(postfl.p1);

% 1) generate starting points

disp('POSTFL_GETSTREAM:: get starting coordinates for streamlines ...')
if isempty(slstart) % the default stream starting points: 
   switch length(postfl.num_points)
      case 1
         disp('ERROR:: no streamline in case of 1D!')
      case 2
         postfl.slstart = line_gen(postfl.p1, postfl.p2, postfl.num_points(1));
      case 3
         postfl.slstart = plane_gen(postfl.p1, postfl.p2, postfl.p4, ...
                                    postfl.num_points([1,3]));
      otherwise
         disp('ERROR:: the dimension can only be 1, 2, or 3!')
   end
else
   postfl.slstart = slstart;
end

slsize = size(postfl.slstart);
disp(['                   dimensions: ' int2str(slsize(1)) [', total ' ...
                    'number: '] int2str(slsize(2))])

% 2) Obtain the stream line

disp(['POSTFL_GETSTREAM:: extract the streamline ... be patient! ... '])
switch postfl.getstream_method
   case 1 % the new way: use FEMLAB postplot function
      disp('                   method: use FEMLAB postplot')
      hf = figure('visible', 'off');
      switch postfl.num_dims
         case 1
            disp('ERROR:: no streamline in case of 1D!')
         case 2
            flowstart = {postfl.slstart(1,:), postfl.slstart(2,:)};
            femdata=postplot(postfl.fem, 'flowdata',{'u','v'}, ...
                             'flowcolor',[1.0,0.0,0.0], ...
                             'flowstart',flowstart, 'flowtype','line', ...
                             'solnum',1, 'geom', 'off', 'flowback', ...
                             'off', 'flowmaxsteps', 8000, 'flowtol',0.2, ...
                             'outtype', 'postdata', 'flowrefine', refine);
         case 3
            flowstart = {postfl.slstart(1,:), postfl.slstart(2,:), ...
                         postfl.slstart(3,:)};
            femdata=postplot(postfl.fem, 'flowdata',{'u','v','w'}, ...
                             'flowcolor',[1.0,0.0,0.0], ...
                             'flowstart',flowstart, 'flowtype','line', ...
                             'solnum',1, 'geom', 'off', 'flowback', ...
                             'off', 'flowmaxsteps', 8000, 'flowtol',0.005, ...
                             'flowmaxtime', Inf, 'flowstattol', 0.01, ...
                             'outtype', 'postdata'); % , 'flowrefine', refine);
         otherwise
      end
      delete(hf);
      % clf(hf), set(hf, 'visible', 'on'), hold all
      femdata = femdata{1};
      femdata.grouping = [femdata.grouping, length(femdata.t(1,:))+1];
      
      ip = 1; % pointer to femdata.p
      [dummy, num_femdata_ps] = size(femdata.p);
      num_onepoints = 0; % number of streamlines with only one point
      postfl.slxyz = []; 
      for i=1:length(femdata.grouping)-1
         switch sign(femdata.grouping(i) - femdata.grouping(i+1))
            case 0   % only one point in the streamline, it doesn't have
                     % entry in femdata.t, use "ip" to find it
               postfl.slxyz{i} = transpose(femdata.p(:,ip));
               num_onepoints = num_onepoints + 1;
               ip = ip+1;
            case -1  % at least two points for the streamline
               i_start = femdata.t(1,femdata.grouping(i));
               if (i_start ~= ip) % safety check only
                  disp(['WARNING:: starting index of stream line # ' ...
                        int2str(i) ' may be corrupted!'])
               end
               i_end = femdata.t(2,femdata.grouping(i+1)-1);
               postfl.slxyz{i} = transpose(femdata.p(:,i_start:i_end));
               ip = i_end+1;
            case 1   % no points! the starting position is out of geometry!!!
               disp(['WARNING:: no points exist for streamline #' ...
                     int2str(i) ', out of range!!!' ])
               postfl.slxyz{i} = [];
         end
      end % for i=1:length(femdata.grouping)-1
      
      if (num_onepoints ~= 0)
         disp(['POSTFL_GETSTREAM:: ' int2str(num_onepoints)  ...
               ' streamlines have just one point!'])
      end
      flclear femdata;
   case 2  % the old way: interpolate the data, use MATLAB
           % streaming functions
      disp('                   method: use MATLAB stream2/3')
      switch postfl.num_dims
         case 1
            disp('ERROR:: no streamline in case of 1D!')
         case 2
            postfl.slxyz = stream2(postfl.x, postfl.y, postfl.u, ...
                                   postfl.v, postfl.slstart(1,:), ...
                                   postfl.slstart(2,: ), [0.23,80000]);
         case 3
            postfl.slxyz = stream3(postfl.x, postfl.y, postfl.z, ...
                                   postfl.u, postfl.v, postfl.w, ...
                                   postfl.slstart(1,:), ...
                                   postfl.slstart(2,:), ...
                                   postfl.slstart(3,:), [0.46,80000]);
         otherwise
            disp('ERROR:: the dimension can only be 1, 2, or 3!')
      end      
   otherwise
      disp('ERROR:: only two methods are implemented!!!')
end

% 3) Remove short/incomplete stream lines

% find the maximum streamline length
x_max=-inf;
i_max = 1;
for i=1:length(postfl.slxyz)
   dummydata = postfl.slxyz{i};
   if isempty(dummydata)
      continue
   end
   length_sls(i) = dummydata(end,1);
   %   size(dummydata)
   if (x_max < dummydata(end,1))
      x_max = dummydata(end,1);
      i_max = i;
   end
end
x_sl = postfl.slxyz{i_max};
num_slpoints = length(x_sl(:,1));
x_sl = linspace(x_sl(1,1), x_sl(num_slpoints,1), num_slpoints);

% remove short streamlines
disp(['POSTFL_GETSTREAM:: remove streamlines shorter than 40% ' ...
      'maximum length!!!']);
index_removed = [];
x_min = x_sl(num_slpoints) - 0.6*(x_sl(num_slpoints)-x_sl(1));
if (postfl.keep_firstsl == 1)  % *** ??? keep the first stream line
   disp('                   always keep first streamline?: YES')
   i_start = 2;
else
   disp('                   always keep first streamline?: NO')
   i_start = 1;
end
for i=i_start:length(postfl.slxyz)
   dummydata = postfl.slxyz{i};
   length_dummy = size(dummydata,1);
   if (length_dummy <= 1) % add to list if the streamline only has one point
      index_removed = [index_removed, i];
   else
      if (dummydata(length_dummy,1) < x_min) % add to list if shorter than x_min
         index_removed = [index_removed, i];
      end
   end
end
if ~isempty(index_removed) % show some information
   num_removed = length(index_removed);
   size_sl = cellfun('size', postfl.slxyz, 1);
   disp(['  ' num2str(num_removed) ' streamlines are removed!'])
   disp(['  they are: ' num2str(index_removed)])
   disp(['  with number of points: ' num2str(size_sl(index_removed))])
   disp(['  end positions: ' num2str(length_sls(index_removed))])
end

% ACTION of removing
if ~isempty(index_removed) 
   i_boolean = (ones(1, length(postfl.slxyz)) == 1);
   i_boolean(index_removed) = (1 == 0);
   postfl.slxyz = postfl.slxyz(i_boolean);
   postfl.slstart = postfl.slstart(:,i_boolean);
end

% re-adjust the 1st streamline --> y and z are all kept same as the
% starting point
if (postfl.keep_firstsl == 1)
   dummydata = zeros(num_slpoints,postfl.num_dims);
   dummydata(:,1) = x_sl;
   dummydata(:,2) = postfl.slstart(2,1);
   if (postfl.num_dims == 3)
      dummydata(:,3) = postfl.slstart(3,1);
   end
   postfl.slxyz{1} = dummydata;
   clear dummydata
end

% 4) show some information
disp(['POSTFL_GETSTREAM:: total number of streamlines: ' ...
      int2str(length(postfl.slxyz))   ', index of the longest: ' ...
      int2str(i_max)])
disp(['                   max. range: (' num2str(x_sl(1)) ',' ...
      num2str(x_sl(end), '%0.2g') '), number of points: ' ...
      num2str(num_slpoints)])

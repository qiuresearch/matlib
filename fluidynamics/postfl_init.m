function postfl = postfl_init(fem)
% --- Usage:
%        postfl = postfl_init(fem)
% --- Purpose:
%        initialize the postfl structure with all the fields used.
% --- Parameter(s):
%        fem - the fem java object 
% --- Return(s):
%        results - a postfl structure
%
% --- Example(s):
%
% $Id: postfl_init.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

disp('POSTFL_INIT::initialize the postfl structure ...')

% the fem object
if nargin < 1
   postfl.fem = [];
else
   postfl.fem = fem;
   postfl.const = fl_cell2struct(fem.const);
end
postfl.const.width_beam = 0;

% define the cross-section plane
postfl.num_dims = 2;
postfl.mode='xy'; % can be 'yz', 'xz'
% data processing settings
postfl.getstream_method = 1; % the new way
postfl.evalstream_method = 1; % the faster way
postfl.keep_firstsl = 0;
postfl.weight_mixtime = 1; % 1: by speed, 2: by width
postfl.force_mixorder = 0; % the mixing order will be reset
                           % to ensure the jet is mixed from
                           % outside to inside
postfl.num_points = [];
postfl.p1 = [];
postfl.p2 = [];
postfl.p3 = [];
postfl.p4 = [];

% the interpolated data direclty from postfl.fem
postfl.xsection= [];
postfl.x = [];
postfl.y = [];
postfl.z = [];

postfl.u = [];
postfl.v = [];
postfl.w = [];

postfl.c = [];

% the streamline data: the default is that half the points between
% postfl.p1 and postfl.p2xb

postfl.c0 = 1.3; % the minimum concentration of "mixed" state

postfl.slstart = []; % the starting points of the streamlines
postfl.slxyz = []; % coordinates of each streamline

postfl.mtdata = []; % the mixing time data

return
 
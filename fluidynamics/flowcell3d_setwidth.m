function [fem, geoconst] = flowcell3d_setwidth(varargin)
% --- Usage:
%        [fem, geoconst] = flowcell_setwidth(varargin)
% --- Purpose:
%        Standard units are used.
%
%Modification history:
%   
%   01/26/05: clean up, ready to use.
%   02/04/05: change to one geometry

% Femlab version
clear vrsn
vrsn.name = 'FEMLAB 3.1';
vrsn.ext = '';
vrsn.major = 0;
vrsn.build = 157;
vrsn.rcs = '$Name:  $';
vrsn.date = '$Date: 2007-09-19 04:45:38 $';
fem.version = vrsn;

% Constants
fem.const={'rho','0.99713e3', 'eta','0.891e-3', 'D','2.045e-9', ...
           'concen_sam','1.0', 'concen_buf', '2.0','v_sam', '3e-3', ...
           'v_buf','3e-2'};

% Geometry constants
width_inlet = 50e-6; % (default values ...)
width_side = 50e-6;
width_outlet = 50e-6;
height = 100e-6;
mesh_factor=1;   % the smaller, the finer mesh
parse_varargin(varargin)

% the geometry constants to return
geoconst.width_inlet = width_inlet;
geoconst.width_side = width_side; 
geoconst.width_outlet = width_outlet;
geoconst.height = height;
geoconst.mesh_factor = mesh_factor;

%*****************  NOTE ******************
%
%  WIDTHs are only HALF widths from here on
%
%******************************************
width_inlet = width_inlet/2;
width_side = width_side/2;
width_outlet = width_outlet/2;
height = height/2;

length_inlet = max([width_side, width_inlet])*3;
length_side = max([width_side, width_inlet, width_outlet])*3;
length_outlet = length_side*3;

geoconst.length_inlet = length_inlet;
geoconst.length_side = length_side;
geoconst.length_outlet = length_outlet;

fem = runfl_setconst(fem, geoconst);

% Build the geometry
carr={curve2([-length_inlet,-length_inlet],[width_inlet,0],[1,1]), ...
      curve2([-length_inlet,-length_inlet/2],[0,0],[1,1]), ...
      curve2([-length_inlet/2,-length_inlet/2],[0,width_inlet],[1,1]), ...
      curve2([-length_inlet/2,-length_inlet], [width_inlet, ...
                    width_inlet],[1,1])};
g1=geomcoerce('solid',carr);
carr={curve2([-length_inlet/2,-length_inlet/2],[width_inlet,0],[1,1]), ...
      curve2([-length_inlet/2,length_outlet/4],[0,0],[1,1]), ...
      curve2([length_outlet/4,length_outlet/4],[0,width_outlet],[1,1]), ...
      curve2([length_outlet/4,width_side],[width_outlet, ...
                    width_outlet],[1,1]), curve2([width_side, ...
                    width_side],[width_outlet,length_side/2],[1,1]), ...
      curve2([width_side,-width_side],[length_side/2,length_side/2],[1,1]), ...
      curve2([-width_side,-width_side],[length_side/2,width_inlet],[1,1]), ...
      curve2([-width_side,-length_inlet/2],[width_inlet,width_inlet],[1,1])};
g2=geomcoerce('solid',carr);
carr={curve2([-width_side,-width_side],[length_side,length_side/2],[1,1]), ...
      curve2([-width_side,width_side],[length_side/2,length_side/2],[1,1]), ...
      curve2([width_side,width_side],[length_side/2,length_side],[1,1]), ...
      curve2([width_side,-width_side],[length_side,length_side],[1,1])};
g3=geomcoerce('solid',carr);
carr={curve2([length_outlet/4,length_outlet/4],[width_outlet,0],[1,1]), ...
      curve2([length_outlet/4,length_outlet],[0,0],[1,1]), ...
      curve2([length_outlet,length_outlet], [0,width_outlet],[1,1]), ...
      curve2([length_outlet,length_outlet/4],[width_outlet, ...
                    width_outlet],[1,1])};
g4=geomcoerce('solid',carr);

% Geometry 2
g11=extrude(g1,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g12=extrude(g2,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g13=extrude(g3,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g14=extrude(g4,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);

clear s
s.objs={g11,g12,g13,g14};
s.name={'EXT1','EXT2','EXT3','EXT4'};
s.tags={'g11','g12','g13','g14'};

fem.draw=struct('s',s);
fem.geom=geomcsg(fem);

%********************
%
% Physics settings
%
%********************

% Application mode 1
clear appl
appl.mode.class = 'FlNavierStokes';
appl.mode.type = 'cartesian';
appl.dim = {'u','v','w','p'};
appl.sdim = {'x','y','z'};
appl.name = 'ns';
appl.shape = {'shlag(2,''u'')','shlag(2,''v'')','shlag(2,''w'')','shlag(1,''p'')'};
appl.gporder = {4,2};
appl.cporder = {2,1};
appl.sshape = 2;
appl.border = 'off';
appl.assignsuffix = '_ns';
clear prop
prop.elemdefault='Lagp2p1';
prop.stensor='full';
prop.weakconstr=struct('value',{'off'},'dim',{{'lm4','lm5','lm6'}});
appl.prop = prop;
clear pnt
pnt.p0 = 0;
pnt.pnton = 0;
pnt.ind = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
appl.pnt = pnt;
clear bnd
bnd.type = {'noslip','neutral','uv','slip','uv','out'};
bnd.u0 = {0,0,'v_sam',0,0,0};
bnd.v0 = {0,0,0,0,'-v_buf',0};
bnd.w0 = 0;
bnd.p0 = 0;
bnd.ind = [3,4,4,1,1,2,4,4,1,1,1,1,2,4,1,5,1,1,1,2,4,4,1,1,6];
appl.bnd = bnd;
clear equ
equ.shape = [1;2;3;4];
equ.gporder = {{1;1;1;2}};
equ.cporder = {{1;1;1;2}};
equ.init = 0;
equ.usage = 1;
equ.rho = 'rho';
equ.eta = 'eta';
equ.F_x = 0;
equ.F_y = 0;
equ.F_z = 0;
equ.idon = 0;
equ.delid = 0.5;
equ.sdon = 0;
equ.sdtype = 'pgc';
equ.delsd = 0.25;
equ.cdon = 0;
equ.cdtype = 'sc';
equ.delcd = 0.35;
equ.pson = 0;
equ.delps = 1;
equ.ind = [1,1,1,1];
appl.equ = equ;
fem.appl{1} = appl;

% Application mode 2
clear appl
appl.mode.class = 'FlConvDiff';
appl.mode.type = 'cartesian';
appl.dim = {'c'};
appl.sdim = {'x','y','z'};
appl.name = 'cd';
appl.shape = {'shlag(2,''c'')'};
appl.gporder = 4;
appl.cporder = 2;
appl.sshape = 2;
appl.border = 'off';
appl.assignsuffix = '_cd';
clear prop
prop.elemdefault='Lag2';
prop.equform='noncons';
prop.weakconstr=struct('value',{'off'},'dim',{{'lm7'}});
appl.prop = prop;
clear bnd
bnd.N = 0;
bnd.c0 = {0,0,'concen_sam','concen_buf',0};
bnd.type = {'N0','cont','C','C','Nc'};
bnd.ind = [3,1,1,1,1,2,1,1,1,1,1,1,2,1,1,4,1,1,1,2,1,1,1,1,5];
appl.bnd = bnd;
clear equ
equ.shape = 1;
equ.gporder = 1;
equ.cporder = 1;
equ.init = 0;
equ.usage = 1;
equ.D = 'D';
equ.dtensor = 1;
equ.dtype = 'iso';
equ.R = 0;
equ.Dts = 1;
equ.u = 'u';
equ.v = 'v';
equ.w = 'w';
equ.idon = 0;
equ.delid = 0.5;
equ.sdon = 0;
equ.sdtype = 'pgc';
equ.delsd = 0.25;
equ.cdon = 0;
equ.cdtype = 'sc';
equ.delcd = 0.35;
equ.ind = [1,1,1,1];
appl.equ = equ;
fem.appl{2} = appl;
fem.sdim = {'x','y','z'};

% Simplify expressions
fem.simplify = 'on';
fem.border = 1;

% Global expressions
fem.expr = {};

% Functions
clear fcns
fem.functions = {};

% Multiphysics
fem=multiphysics(fem);

% Initialize mesh
mesh_size = 6e-6*mesh_factor;
geoconst.mesh_size = mesh_size;
fem = runfl_setconst(fem, geoconst);
% only center line and cross region is more dense
fem.mesh=meshinit(fem, ...
                  'hmax',mesh_size*8, ...
                  'hmaxfact',1, ...
                  'hcutoff',0.01, ...
                  'hgrad',1.4, ...
                  'hcurve',0.4, ...
                  'hnarrow',1, ...
                  'hpnt',20, ...
                  'xscale',1.0, ...
                  'yscale',1.0, ...
                  'zscale',(50e-6)/height, ...
                  'jiggle','on', ...
                  'mlevel','sub', ...
                  'hgradfac', [7,1.2,8,1.2,21,1.2], ...
                  'hmaxedg',[17,mesh_size], ...
                  'hmaxfac',[7,mesh_size,8,mesh_size,10,mesh_size,11,mesh_size,21,mesh_size*1.6], ...
                  'hmaxsub',[2,mesh_size*1.6]);

% Extend mesh
fem.xmesh=meshextend(fem,'geoms',[1],'eqvars','on','cplbndeq', ...
                     'on','cplbndsh','off');

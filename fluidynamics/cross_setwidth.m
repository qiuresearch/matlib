function [fem, geoconst] = cross_setwidth(varargin)
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
           'v_buf','3e-2', 'concen_avg', ['(concen_sam*v_sam+' ...
                    'concen_buf*v_buf*2)/(v_sam+2*v_buf)'] };

% Geometry constants
width_inlet = 50e-6; % (default values ...)
width_side = 50e-6;
width_outlet = 50e-6;
length_inlet = 120e-6;
length_side = 120e-6;
length_outlet = 250e-6;
mesh_factor=1;   % the smaller, the finer mesh
parse_varargin(varargin)

% the geometry constants to return
femconst.width_inlet = width_inlet;
femconst.width_side = width_side; 
femconst.width_outlet = width_outlet;
femconst.length_inlet = length_inlet;
femconst.length_side = length_side;
femconst.length_outlet = length_outlet;

femconst.mesh_factor = mesh_factor;

fem = runfl_setconst(fem, femconst);

%*****************  NOTE ******************
%
%  WIDTHs are only HALF widths from here on
%
%******************************************
width_inlet = width_inlet/2;
width_side = width_side/2;
width_outlet = width_outlet/2;
width_max = max([width_inlet, width_side, width_outlet]);

% Build the geometry
carr={curve2([-length_inlet,-length_inlet],[width_inlet,0],[1,1]), ...
      curve2([-length_inlet,-width_max*1.6],[0,0],[1,1]), ...
      curve2([-width_max*1.6,-width_max*1.6],[0,width_inlet],[1,1]), ...
      curve2([-width_max*1.6,-length_inlet], [width_inlet, ...
                    width_inlet],[1,1])};
g1=geomcoerce('solid',carr);
carr={curve2([-width_max*1.6,-width_max*1.6],[width_inlet,0],[1,1]), ...
      curve2([-width_max*1.6, width_max*2.5],[0,0],[1,1]), ...
      curve2([ width_max*2.5, width_max*2.5],[0,width_outlet],[1,1]), ...
      curve2([width_max*2.5,width_side],[width_outlet, ...
                    width_outlet],[1,1]), curve2([width_side, ...
                    width_side],[width_outlet,width_max*1.6],[1,1]), ...
      curve2([width_side,-width_side],[width_max*1.6,width_max*1.6],[1,1]), ...
      curve2([-width_side,-width_side],[width_max*1.6,width_inlet],[1,1]), ...
      curve2([-width_side,-width_max*1.6],[width_inlet,width_inlet],[1,1])};
g2=geomcoerce('solid',carr);
carr={curve2([-width_side,-width_side],[length_side,width_max*1.6],[1,1]), ...
      curve2([-width_side,width_side],[width_max*1.6,width_max*1.6],[1,1]), ...
      curve2([width_side,width_side],[width_max*1.6,length_side],[1,1]), ...
      curve2([width_side,-width_side],[length_side,length_side],[1,1])};
g3=geomcoerce('solid',carr);
carr={curve2([width_max*2.5,width_max*2.5],[width_outlet,0],[1,1]), ...
      curve2([width_max*2.5,length_outlet/2],[0,0],[1,1]), ...
      curve2([length_outlet/2,length_outlet/2], [0,width_outlet],[1,1]), ...
      curve2([length_outlet/2,width_max*2.5],[width_outlet, ...
                    width_outlet],[1,1])};
g4=geomcoerce('solid',carr);

carr={curve2([length_outlet/2, length_outlet/2],[width_outlet,0],[1,1]), ...
      curve2([length_outlet/2, length_outlet],[0,0],[1,1]), ...
      curve2([length_outlet, length_outlet], [0,width_outlet],[1,1]), ...
      curve2([length_outlet,length_outlet/2],[width_outlet, ...
                    width_outlet],[1,1])};
g5=geomcoerce('solid',carr);

% Geometry
clear s
s.objs={g1,g2,g3,g4,g5};
s.name={'CO1','CO2','CO3','CO4','CO5'};
s.tags={'g1','g2','g3','g4','g5'};

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
appl.dim = {'u','v','p'};
appl.sdim = {'x','y','z'};
appl.name = 'ns';
appl.shape = {'shlag(2,''u'')','shlag(2,''v'')','shlag(1,''p'')'};
appl.gporder = {4,2};
appl.cporder = {2,1};
appl.sshape = 2;
appl.border = 'off';
appl.assignsuffix = '_ns';
clear prop
prop.elemdefault='Lagp2p1';
prop.stensor='full';
prop.weakconstr=struct('value',{'off'},'dim',{{'lm1','lm2'}});
appl.prop = prop;
clear pnt
pnt.p0 = 0;
pnt.pnton = 0;
pnt.ind = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
appl.pnt = pnt;
clear bnd
bnd.type = {'noslip','neutral','uv','slip','uv','strout'};
bnd.u0 = {0,0,'v_sam*3/2*(1-s*s)',0,0,0};
bnd.v0 = {0,0,0,0,'-v_buf*6*s*(1-s)',0};
bnd.p0 = 0;
bnd.ind = [3,4,1,2,4,1,1,1,2,5,1,1,1,2,4,1,2,4,1,6];
appl.bnd = bnd;
clear equ
equ.shape = [1;2;3];
equ.gporder = {{1;1;2}};
equ.cporder = {{1;1;2}};
equ.init = {{'v_sam*3/2*(1-4*(y/width_inlet)^2)';0;0},{'(v_sam+(x>-width_side/2)*(x+width_side/2)/(width_side*1.75)*2*v_buf)*3/2*(1-4*(y/width_inlet)^2)*(y<width_inlet/2)';'-v_buf*6*(x+width_side/2)/width_side*(1-(x+width_side/2)/width_side)*y/(width_inlet*0.75)*(x>-width_side/2)*(x<width_side/2)';0},{0;'-v_buf*6*(x+width_side/2)/width_side*(1-(x+width_side/2)/width_side)';0},{'(v_sam+2*v_buf)*3/2*(1-4*(y/width_outlet)^2)';0;0}};
equ.usage = 1;
equ.rho = 'rho';
equ.eta = 'eta';
equ.F_x = 0;
equ.F_y = 0;
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
equ.ind = [1,2,3,4,4];
appl.equ = equ;
fem.appl{1} = appl;

% Application mode 2
clear appl
appl.mode.class = 'FlConvDiff';
appl.mode.type = 'cartesian';
appl.dim = {'c'};
appl.sdim = {'x','y','z'};
appl.name = 'cd';
appl.shape = {'shlag(3,''c'')'};
appl.gporder = 6;
appl.cporder = 3;
appl.sshape = 3;
appl.border = 'off';
appl.assignsuffix = '_cd';
clear prop
prop.elemdefault='Lag3';
prop.equform='noncons';
prop.weakconstr=struct('value',{'off'},'dim',{{'lm3'}});
appl.prop = prop;
clear bnd
bnd.N = 0;
bnd.c0 = {0,0,'concen_sam','concen_buf',0};
bnd.type = {'N0','cont','C','C','Nc'};
bnd.ind = [3,1,1,2,1,1,1,1,2,4,1,1,1,2,1,1,2,1,1,5];
appl.bnd = bnd;
clear equ
equ.shape = 1;
equ.gporder = 1;
equ.cporder = 1;
equ.init = {'concen_sam','concen_avg - (concen_sam-concen_avg)*(y<width_inlet/2)*(x<-width_side/2)*(x+width_side/2)/(width_side)*4 + (concen_buf-concen_avg)*(y>width_inlet/2)*(x>-width_side/2)*(y-width_inlet/2)/(width_inlet)*4','concen_buf','concen_avg'};
equ.usage = 1;
equ.D = 'D';
equ.dtensor = 1;
equ.dtype = 'iso';
equ.R = 0;
equ.Dts = 1;
equ.u = 'u';
equ.v = 'v';
equ.idon = 0;
equ.delid = 0.5;
equ.sdon = 0;
equ.sdtype = 'pgc';
equ.delsd = 0.25;
equ.cdon = 0;
equ.cdtype = 'sc';
equ.delcd = 0.35;
equ.ind = [1,2,3,4,4];
appl.equ = equ;
fem.appl{2} = appl;
fem.sdim = {'x','y'};

% Simplify expressions
fem.simplify = 'on';
fem.border = 1;

% Global expressions
fem.expr = {};

% Multiphysics
fem=multiphysics(fem);

% Initialize mesh
mesh_size =0.6e-7*mesh_factor;
femconst.mesh_size = mesh_size;
fem = runfl_setconst(fem, femconst);

% only center line and cross region is more dense

fem.mesh=meshinit(fem, 'hmax',[mesh_size*30],  'hgradedg',[5,1.2,15, ...
                    1.2,18,1.2], 'hmaxedg',[5,mesh_size,6, ...
                    mesh_size,7,mesh_size,15,mesh_size*1.6,18, ...
                    mesh_size*3.2], 'hmaxsub',[1, mesh_size*30* ...
                    sqrt(width_inlet/width_max), 2, mesh_size*10,3, ...
                    mesh_size*30*sqrt(width_side/width_max),4, ...
                    mesh_size*30*sqrt(width_outlet/width_max)]);

% Extend mesh
fem.xmesh=meshextend(fem,'eqvars','on','cplbndeq', 'on','cplbndsh','off');

function [fem,geoconst] = flowcellsmooth_setwidth(varargin)

flclear fem

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
fem.const={'rho','1e3','eta','1e-3','concen_sam','1.0','concen_buf', ...
           '2.0','D','2.045e-9','v_sam','6e-2', 'v_buf','6e-2'};

% Geometry constants
width_inlet = 5e-5; % (default values)
width_side = 5e-5;
width_outlet = 5e-5;
mesh_factor=1; % the smaller, the finer mesh
parse_varargin(varargin)

% the geometry constants to return
geoconst.width_inlet = width_inlet;
geoconst.width_side = width_side; 
geoconst.width_outlet = width_outlet;
geoconst.mesh_factor = mesh_factor;

%*****************  NOTE ******************
%
%  WIDTHs are only HALF widths from here on
%
%******************************************
width_inlet = width_inlet/2;
width_side = width_side/2;
width_outlet =width_outlet/2;

length_inlet = max([width_side, width_inlet])*6;
length_side = max([width_side, width_inlet, width_outlet])*6;
length_outlet = length_side*6;

geoconst.length_inlet = length_inlet;
geoconst.length_side = length_side;
geoconst.length_outlet = length_outlet;

fem = runfl_setconst(fem, geoconst);

% Building the geometry
carr={curve2([-length_inlet,-length_inlet],[width_inlet,0],[1,1]), ...
      curve2([-length_inlet,-length_inlet/3],[0,0],[1,1]), ...
      curve2([-length_inlet/3,-length_inlet/3],[0,width_inlet],[1,1]), ...
      curve2([-length_inlet/3,-length_inlet], [width_inlet, ...
                    width_inlet],[1,1])};
g1=geomcoerce('solid',carr);
carr={curve2([-length_inlet/3,-length_inlet/3],[width_inlet,0],[1,1]), ...
      curve2([-length_inlet/3,length_outlet/6],[0,0],[1,1]), ...
      curve2([length_outlet/6,length_outlet/6],[0,width_outlet],[1,1]), ...
      curve2([length_outlet/6,width_side*1.5],[width_outlet, ...
                    width_outlet],[1,1]), curve2([width_side*1.5, ...
                    width_side,width_side],[width_outlet, ...
                    width_outlet,width_outlet+0.5*width_side],[1, ...
                    0.707106781186548,1]), curve2([width_side, ...
                    width_side],[width_outlet+0.5*width_side, ...
                    length_side/3],[1,1]), curve2([width_side,-width_side], ...
                                                  [length_side/3, ...
                    length_side/3],[1,1]), curve2([-width_side,- ...
                    width_side],[length_side/3,width_inlet*1.5],[1,1]), ...
      curve2([-width_side,-width_side,-width_side-0.5* ...
              width_inlet],[width_inlet*1.5,width_inlet, width_inlet],[1, ...
                    0.707106781186548,1]), curve2([-width_side-0.5* ...
                    width_inlet,-length_inlet/3],[width_inlet, ...
                    width_inlet],[1,1])};  % Beigzer curve is 0.5*width
g2=geomcoerce('solid',carr);
carr={curve2([-width_side,-width_side],[length_side,length_side/3],[1,1]), ...
      curve2([-width_side,width_side],[length_side/3,length_side/3],[1,1]), ...
      curve2([width_side,width_side],[length_side/3,length_side],[1,1]), ...
      curve2([width_side,-width_side],[length_side,length_side],[1,1])};
g3=geomcoerce('solid',carr);
carr={curve2([length_outlet/6,length_outlet/6],[width_outlet,0],[1,1]), ...
      curve2([length_outlet/6,length_outlet/2],[0,0],[1,1]), ...
      curve2([length_outlet/2,length_outlet/2], [0,width_outlet],[1,1]), ...
      curve2([length_outlet/2,length_outlet/6],[width_outlet, ...
                    width_outlet],[1,1])};
g4=geomcoerce('solid',carr);
carr={curve2([length_outlet/2, length_outlet/2],[width_outlet,0],[1,1]), ...
      curve2([length_outlet/2, length_outlet],[0,0],[1,1]), ...
      curve2([length_outlet, length_outlet], [0,width_outlet],[1,1]), ...
      curve2([length_outlet,length_outlet/2],[width_outlet, ...
                    width_outlet],[1,1])};
g5=geomcoerce('solid',carr);

clear s
s.objs={g1,g2,g3,g4,g5};
s.name={'CO1','CO2','CO3','CO4','CO5'};
s.tags={'g1','g2','g3','g4','g5'};
fem.draw=struct('s',s);
fem.geom=geomcsg(fem);

%***** Physics Settings *****

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
pnt.ind = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
appl.pnt = pnt;
clear bnd
bnd.type = {'noslip','neutral','uv','slip','uv','strout'};
bnd.u0 = {0,0,'v_sam*3/2*(1-s*s)',0,0,0};
bnd.v0 = {0,0,0,0,'-v_buf*6*s*(1-s)',0};
bnd.p0 = 0;
bnd.ind = [3,4,1,2,4,1,1,1,2,5,1,1,1,2,4,1,2,4,1,6,1,1];
appl.bnd = bnd;
clear equ
equ.shape = [1;2;3];
equ.gporder = {{1;1;2}};
equ.cporder = {{1;1;2}};
equ.init = {{'v_sam';0;0},{'v_sam';'-v_buf';0},{0;'-v_buf';0},{'v_sam+2*v_buf';0;0}};
equ.usage = 1;
equ.rho = {'rho','rho','rho','rho'};
equ.eta = {'eta','eta','eta','eta'};
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
appl.shape = {'shlag(2,''c'')'};
appl.gporder = 4;
appl.cporder = 2;
appl.sshape = 2;
appl.border = 'off';
appl.assignsuffix = '_cd';
clear prop
prop.elemdefault='Lag2';
prop.equform='noncons';
prop.weakconstr=struct('value',{'off'},'dim',{{'lm3'}});
appl.prop = prop;
clear bnd
bnd.N = 0;
bnd.c0 = {0,0,'concen_sam','concen_buf',0};
bnd.type = {'N0','cont','C','C','Nc'};
bnd.ind = [3,1,1,2,1,1,1,1,2,4,1,1,1,2,1,1,2,1,1,5,1,1];
appl.bnd = bnd;
clear equ
equ.shape = 1;
equ.gporder = 1;
equ.cporder = 1;
equ.init = {'concen_sam','concen_buf*0.2','concen_buf','concen_buf*0.6'};
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

% Functions
clear fcns
fem.functions = {};

% Multiphysics
fem=multiphysics(fem);

% Initialize mesh
mesh_size = 1.6e-7*mesh_factor;
geoconst.mesh_size = mesh_size;
% only center line and cross region is more dense
fem.mesh=meshinit(fem, 'hmax',[mesh_size*40], 'hmaxfact',1, 'hgrad',1.3, ...
                  'hcurve',0.3, 'hcutoff',0.001, 'hnarrow',1, ...
                  'hpnt',10, 'xscale',1.0, 'yscale',1.0, 'mlevel','sub', ...
                  'hgradedg', [5,1.2,15,1.2,18,1.2], 'hmaxedg',[5, ...
                    mesh_size, 15, mesh_size*1.6,18, mesh_size*2.5, ...
                    21, mesh_size*1.2], 'hmaxsub',[2,mesh_size*10, ...
                    4,mesh_size*30]);

% Extend mesh
fem.xmesh=meshextend(fem,'geoms',[1],'eqvars','on','cplbndeq','on','cplbndsh','off');

%  % Solve problem
%  fem.sol=femnlin(fem, ...
%                  'init',fem0.sol, ...
%                  'method','eliminate', ...
%                  'nullfun','auto', ...
%                  'blocksize',5000, ...
%                  'complexfun','off', ...
%                  'conjugate','on', ...
%                  'symmetric','off', ...
%                  'solcomp',{'c'}, ...
%                  'outcomp',{'c','u','p','v'}, ...
%                  'rowscale','on', ...
%                  'ntol',1.0E-6, ...
%                  'maxiter',25, ...
%                  'hnlin','off', ...
%                  'linsolver','umfpack', ...
%                  'thresh',0.1, ...
%                  'umfalloc',0.7, ...
%                  'uscale','auto', ...
%                  'mcase',0);
%  
%  % Save current fem structure for restart purposes
%  fem0=fem;

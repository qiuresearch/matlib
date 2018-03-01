function [fem, geoconst] = multismooth_setgeometry(varargin)

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
fem.const={'rho','1e3','eta','1e-3','concen_buf','2.0','concen_sam', ...
           '1.0','D','2.045e-9','v_sam','4e-3','v_buf','4e-2', ...
           'v_dia', '2e-3'};

%fem.const={'rho','9.9713e-13','eta','8.91e-7','D','2045','v_sam', ...
%           '4000','v_buf','40000','v_dia' ,'800','concen_buf','2.0', ...
%           'concen_sam', '1.0'};

% Geometry constants
width_inlet = 50e-6; % (default values)
width_side = 50e-6;
width_diag = 50e-6;
width_outlet = 50e-6;
length_curve = 2e-6;
angle_diag = 135/180.0*pi;
mesh_factor=15; % the larger, the finer mesh is
parse_varargin(varargin)

% the geometry constants to return
geoconst.width_inlet = width_inlet;
geoconst.width_side = width_side; 
geoconst.width_diag = width_diag;
geoconst.width_outlet = width_outlet;
geoconst.mesh_factor = mesh_factor;
geoconst.length_curve = length_curve;

%*****************  NOTE ******************
%
%  WIDTHs are only HALF widths from here on
%
%******************************************
width_inlet = width_inlet/2;
width_side = width_side/2;
width_diag = width_diag/2;
width_outlet =width_outlet/2;

length_inlet = max([width_side, width_inlet])*6;
length_diag = length_inlet;
length_side = max([width_side, width_inlet, width_outlet])*6;
length_outlet = length_side*4;

geoconst.length_inlet = length_inlet;
geoconst.length_diag = length_diag;
geoconst.length_side = length_side;
geoconst.length_outlet = length_outlet;

fem = runfl_setconst(fem, geoconst);

% Build Geometry
g1=rect2(length_inlet/2,width_inlet,'base','corner','pos',[-length_inlet,0]);
g4=rect2(width_side*2,length_side/2,'base','corner','pos',[-width_side,length_side/2]);
g5=rect2(length_outlet*5/6,width_outlet,'base','corner','pos',[length_outlet/6,0]);

% see notes on where are p0, p1, and p2
p0 = [width_diag*cos(angle_diag-pi/2), width_diag*sin(angle_diag-pi/2)];
p1 = [width_inlet/tan(angle_diag)-width_diag/cos(angle_diag-pi/2), ...
      width_inlet];
p2 = [-width_side, -width_side*tan(angle_diag)-width_diag/cos(angle_diag)];

carr={curve2([-length_inlet/2,length_outlet/6],[0,0],[1,1]), ...
  curve2([length_outlet/6,length_outlet/6],[0,width_outlet],[1,1]), ...
  curve2([length_outlet/6,width_side+length_curve],[width_outlet,width_outlet],[1,1]), ...
  curve2([width_side+length_curve,width_side,width_side],[width_outlet,width_outlet,width_outlet+length_curve],[1,0.707106781186548,1]), ...
  curve2([width_side,width_side],[width_outlet+length_curve,length_side/2],[1,1]), ...
  curve2([width_side,-width_side],[length_side/2,length_side/2],[1,1]), ...
  curve2([-width_side,-width_side],[length_side/2,p2(2)+length_curve],[1,1]), ...
  curve2([-width_side,-width_side,-width_side+length_curve*cos(angle_diag)],[p2(2)+length_curve,p2(2),p2(2)+length_curve*sin(angle_diag)],[1,0.707106781186548,1]), ...
  curve2([-width_side+length_curve*cos(angle_diag),p0(1)+length_diag/2*cos(angle_diag)],[p2(2)+length_curve*sin(angle_diag),p0(2)+length_diag/2*sin(angle_diag)],[1,1]), ...
  curve2([p0(1)+length_diag/2*cos(angle_diag),-p0(1)+length_diag/2*cos(angle_diag)],[p0(2)+length_diag/2*sin(angle_diag),-p0(2)+length_diag/2*sin(angle_diag)],[1,1]), ...
  curve2([-p0(1)+length_diag/2*cos(angle_diag),p1(1)+length_curve*cos(angle_diag)],[-p0(2)+length_diag/2*sin(angle_diag),p1(2)+length_curve*sin(angle_diag)],[1,1]), ...
  curve2([p1(1)+length_curve*cos(angle_diag),p1(1),p1(1)-length_curve],[p1(2)+length_curve*sin(angle_diag),p1(2),p1(2)],[1,0.707106781186548,1]), ...
  curve2([p1(1)-length_curve,-length_inlet/2],[width_inlet,width_inlet],[1,1]), ...
  curve2([-length_inlet/2,-length_inlet/2],[width_inlet,0],[1,1])};
g3=geomcoerce('solid',carr);

carr={curve2([-p0(1)+length_diag*cos(angle_diag),-p0(1)+ ...
              length_diag/2*cos(angle_diag)],[-p0(2)+length_diag* ...
                    sin(angle_diag),-p0(2)+length_diag/2* ...
                    sin(angle_diag)],[1,1]), curve2([-p0(1)+ ...
                    length_diag/2*cos(angle_diag), p0(1)+length_diag/2* ...
                    cos(angle_diag)],[-p0(2)+length_diag/2* ...
                    sin(angle_diag),p0(2)+ length_diag/2* ...
                    sin(angle_diag)],[1,1]), curve2([p0(1)+ ...
                    length_diag/2*cos(angle_diag),p0(1)+length_diag* ...
                    cos(angle_diag)],[p0(2)+length_diag/2*sin(angle_diag), ...
                    p0(2)+length_diag*sin(angle_diag)],[1,1]), ...
      curve2([p0(1)+length_diag*cos(angle_diag),-p0(1)+length_diag* ...
              cos(angle_diag)],[p0(2)+length_diag*sin(angle_diag),- ...
                    p0(2)+length_diag*sin(angle_diag)],[1,1])};
g2=geomcoerce('solid',carr);
clear s
s.objs={g4,g3,g1,g2,g5};
s.name={'R2','CO1','R1','CO2','R3'};
s.tags={'g4','g3','g1','g2','g5'};

fem.draw=struct('s',s);
fem.geom=geomcsg(fem);


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
pnt.ind = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
appl.pnt = pnt;
clear bnd
bnd.type = {'noslip','neutral','uv','slip','uv','uv','out'};
bnd.u0 = {0,0,'v_sam*3/2*(1-s*s)',0,'v_dia*6*s*(1-s)/1.414',0,0};
bnd.v0 = {0,0,0,0,'-v_dia*6*s*(1-s)/1.414','-v_buf*6*s*(1-s)',0};
bnd.p0 = 0;
bnd.ind = [3,4,1,5,1,1,2,4,1,1,2,1,1,1,2,6,1,1,1,2,4,1,7,1,1,1];
appl.bnd = bnd;
clear equ
equ.shape = [1;2;3];
equ.gporder = {{1;1;2}};
equ.cporder = {{1;1;2}};
equ.init = {{'v_sam*3/2*(1-s*s)';0;0},{'v_dia*6*s*(1-s)/1.414';'-v_dia*6*s*(1-s)/1.414';0},{'v_buf';0;0},{0;'-v_buf*6*s*(1-s)';0},{'(2*v_buf+v_sam+2*v_dia)*6*s*(1-s)';0;0}};
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
equ.ind = [1,2,3,4,5];
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
bnd.ind = [3,1,1,3,1,1,2,1,1,1,2,1,1,1,2,4,1,1,1,2,1,1,5,1,1,1];
appl.bnd = bnd;
clear equ
equ.shape = 1;
equ.gporder = 1;
equ.cporder = 1;
equ.init = {0,'concen_buf'};
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
equ.ind = [1,1,2,2,2];
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

% Init the mesh
mesh_size = 0.4*mesh_factor;
geoconst.mesh_size = mesh_size;
fem.mesh=meshinit(fem, ...
                  'hmax',[mesh_size*25], ...
                  'hmaxfact',0.8, ...
                  'hgrad',1.3, ...
                  'hcurve',0.3, ...
                  'hcutoff',0.001, ...
                  'hnarrow',1, ...
                  'hpnt',10, ...
                  'xscale',1.0, ...
                  'yscale',1.0, ...
                  'mlevel','sub', ...
                  'hgradedg',[8,1.2,21,1.2,24,1.2,25,1.2], ...
                  'hmaxedg',[8,mesh_size,9,mesh_size,10,mesh_size,21,mesh_size*1.2,24,mesh_size*2.5,25,mesh_size*2.5], ...
                  'hmaxsub',[3,mesh_size*6,5,mesh_size*8]);
  
% Extend mesh
fem.xmesh=meshextend(fem,'geoms',[1],'eqvars','on','cplbndeq', ...
                     'on','cplbndsh','off');

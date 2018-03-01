function [fem, geoconst] = multi3dsmooth_setgeometry(varargin)

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
fem.const={'rho','9.9713e-13','eta','8.91e-7','D','2045','v_sam', ...
           '4000','v_buf','40000','v_dia','800','C1','2', 'C0', '1'};

% Geometry constants
width_inlet = 50; % (default values)
width_side = 50;
width_diag = 50;
width_outlet = 50;
height=100;
length_curve = 16; % this number doesn't seem to change much of the curvature
angle_diag = 135/180.0*pi;
mesh_factor=1; % smaller gives finer mesh. 1 is the predefined size
parse_varargin(varargin)

% the geometry constants to return
geoconst.width_inlet = width_inlet;
geoconst.width_side = width_side; 
geoconst.width_diag = width_diag;
geoconst.width_outlet = width_outlet;
geoconst.height = height;

%*****************  NOTE ******************
%
%  WIDTHs are only HALF widths from here on
%
%******************************************
width_inlet = width_inlet/2;
width_side = width_side/2;
width_diag = width_diag/2;
width_outlet =width_outlet/2;
height = height/2;

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
g1=rect2(length_inlet-length_inlet/1.8,width_inlet,'base','corner','pos',[-length_inlet,0]);
g4=rect2(width_side*2,length_side-length_side/1.8,'base','corner','pos',[-width_side,length_side/1.8]);
g5=rect2(length_outlet*3/5,width_outlet,'base','corner','pos',[length_outlet/6,0]);

% see notes on where are p0, p1, and p2
p0 = [width_diag*cos(angle_diag-pi/2), width_diag*sin(angle_diag-pi/2)];
p1 = [width_inlet/tan(angle_diag)-width_diag/cos(angle_diag-pi/2), ...
      width_inlet];
p2 = [-width_side, -width_side*tan(angle_diag)-width_diag/cos(angle_diag)];

carr={curve2([-length_inlet/1.8,length_outlet/6],[0,0],[1,1]), ...
  curve2([length_outlet/6,length_outlet/6],[0,width_outlet],[1,1]), ...
  curve2([length_outlet/6,width_side+length_curve],[width_outlet,width_outlet],[1,1]), ...
  curve2([width_side+length_curve,width_side,width_side],[width_outlet,width_outlet,width_outlet+length_curve],[1,0.707106781186548,1]), ...
  curve2([width_side,width_side],[width_outlet+length_curve,length_side/1.8],[1,1]), ...
  curve2([width_side,-width_side],[length_side/1.8,length_side/1.8],[1,1]), ...
  curve2([-width_side,-width_side],[length_side/1.8,p2(2)+length_curve],[1,1]), ...
  curve2([-width_side,-width_side,-width_side+length_curve*cos(angle_diag)],[p2(2)+length_curve,p2(2),p2(2)+length_curve*sin(angle_diag)],[1,0.707106781186548,1]), ...
  curve2([-width_side+length_curve*cos(angle_diag),p0(1)+length_diag/1.8*cos(angle_diag)],[p2(2)+length_curve*sin(angle_diag),p0(2)+length_diag/1.8*sin(angle_diag)],[1,1]), ...
  curve2([p0(1)+length_diag/1.8*cos(angle_diag),-p0(1)+length_diag/1.8*cos(angle_diag)],[p0(2)+length_diag/1.8*sin(angle_diag),-p0(2)+length_diag/1.8*sin(angle_diag)],[1,1]), ...
  curve2([-p0(1)+length_diag/1.8*cos(angle_diag),p1(1)+length_curve*cos(angle_diag)],[-p0(2)+length_diag/1.8*sin(angle_diag),p1(2)+length_curve*sin(angle_diag)],[1,1]), ...
  curve2([p1(1)+length_curve*cos(angle_diag),p1(1),p1(1)-length_curve],[p1(2)+length_curve*sin(angle_diag),p1(2),p1(2)],[1,0.707106781186548,1]), ...
  curve2([p1(1)-length_curve,-length_inlet/1.8],[width_inlet,width_inlet],[1,1]), ...
  curve2([-length_inlet/1.8,-length_inlet/1.8],[width_inlet,0],[1,1])};
g3=geomcoerce('solid',carr);

carr={curve2([-p0(1)+length_diag*cos(angle_diag),-p0(1)+ ...
              length_diag/1.8*cos(angle_diag)],[-p0(2)+length_diag* ...
                    sin(angle_diag),-p0(2)+length_diag/1.8* ...
                    sin(angle_diag)],[1,1]), curve2([-p0(1)+ ...
                    length_diag/1.8*cos(angle_diag), p0(1)+length_diag/1.8* ...
                    cos(angle_diag)],[-p0(2)+length_diag/1.8* ...
                    sin(angle_diag),p0(2)+ length_diag/1.8* ...
                    sin(angle_diag)],[1,1]), curve2([p0(1)+ ...
                    length_diag/1.8*cos(angle_diag),p0(1)+length_diag* ...
                    cos(angle_diag)],[p0(2)+length_diag/1.8*sin(angle_diag), ...
                    p0(2)+length_diag*sin(angle_diag)],[1,1]), ...
      curve2([p0(1)+length_diag*cos(angle_diag),-p0(1)+length_diag* ...
              cos(angle_diag)],[p0(2)+length_diag*sin(angle_diag),- ...
                    p0(2)+length_diag*sin(angle_diag)],[1,1])};
g2=geomcoerce('solid',carr);

% 3D Geometry
g6=extrude(g3,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g7=extrude(g4,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g8=extrude(g1,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g9=extrude(g5,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g10=extrude(g2,'distance',[height],'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);

clear s
s.objs={g6,g7,g8,g9,g10};
s.name={'EXT1','EXT2','EXT3','EXT4','EXT5'};
s.tags={'g6','g7','g8','g9','g10'};

fem.draw=struct('s',s);
fem.geom=geomcsg(fem);

%------------  Physics Modeling settings ------------

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
pnt.ind = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
appl.pnt = pnt;
clear bnd
bnd.type = {'noslip','neutral','uv','slip','uv','uv','out'};
bnd.u0 = {0,0,'v_sam',0,'v_dia/1.414',0,0};
bnd.v0 = {0,0,0,0,'-v_dia/1.414','-v_buf',0};
bnd.w0 = 0;
bnd.p0 = 0;
bnd.ind = [3,4,4,1,1,5,1,4,1,1,2,4,4,1,1,1,2,1,1,1,1,1,2,4,1,6,1,1,1,1,2,4,4,1,1,7];
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
equ.ind = [1,1,1,1,1];
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
bnd.c0 = {0,0,'C0','C1',0};
bnd.type = {'N0','cont','C','C','Nc'};
bnd.ind = [3,1,1,1,1,3,1,1,1,1,2,1,1,1,1,1,2,1,1,1,1,1,2,1,1,4,1,1,1,1,2,1,1,1,1,5];
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
equ.ind = [1,1,1,1,1];
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
elem_size = 60*mesh_factor

fem.mesh=meshinit(fem, ...
                  'hmax',elem_size*3, ...
                  'hmaxfact',1, ...
                  'hcutoff',0.01, ...
                  'hgrad',1.4, ...
                  'hcurve',0.4, ...
                  'hnarrow',1, ...
                  'hpnt',20, ...
                  'xscale',1.0, ...
                  'yscale',1.0, ...
                  'zscale',50/height, ...
                  'jiggle','on', ...
                  'mlevel','sub', ...
                  'hgradfac', [12,1.2], ...
                  'hmaxfac',[12,elem_size, 13, elem_size,18,elem_size*2,20,elem_size*2, 32, elem_size*1.2], ...
                  'hmaxsub',[3,elem_size*1.3]);


% Extend mesh
fem.xmesh=meshextend(fem,'geoms',[1],'eqvars','on','cplbndeq','on','cplbndsh','off');

function [fem, geoconst] = flowcell_setangle_large(varargin)

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
fem.const={'rho','1e3','eta','1e-3', 'D_sam', '2.045e-9','concen_buf', ...
           '2.0','v_sam', '3e-3', 'v_buf','3e-2','concen_sam','1.0', ...
           'D_buf','2.045e-9'};

% Geometry parameters
width_inlet = 5e-5;
width_side = 5e-5;
width_outlet = 5e-5;
angle_side = 135.0/180.0*pi;
mesh_factor=15; % the larger, the finer mesh is
parse_varargin(varargin);

% the geometry constants to return
geoconst.width_inlet = width_inlet;
geoconst.width_side = width_side; 
geoconst.width_outlet = width_outlet;
geoconst.angle_side = angle_side;

%*****************  NOTE ******************
%
%  WIDTHs are only HALF widths from here on
%
%******************************************

width_inlet = width_inlet/2;
width_side = width_side/2;
width_outlet =width_outlet/2;

length_inlet = max([width_side, width_inlet])*5;
length_side = max([width_side, width_inlet, width_outlet])*5;
length_outlet = length_side*5;

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

% see notes for where are the points
p0 = [width_side*cos(angle_side-pi/2), width_side*sin(angle_side-pi/2)];
p1 = [width_inlet/tan(angle_side)-width_side/cos(angle_side-pi/2), ...
      width_inlet];
p2 = [width_outlet/tan(angle_side)+width_side/cos(angle_side-pi/2), ...
      width_outlet];

carr={curve2([-length_inlet/2,-length_inlet/2],[width_inlet,0],[1,1]), ...
      curve2([-length_inlet/2,length_outlet/6],[0,0],[1,1]), ...
      curve2([length_outlet/6,length_outlet/6],[0,width_outlet],[1,1]), ...
      curve2([length_outlet/6,p2(1)],[width_outlet,p2(2)],[1,1]), ...
      curve2([p2(1),p0(1)+length_side/1.5*cos(angle_side)],[p2(2), ...
                    p0(2)+length_side/1.5*sin(angle_side)],[1,1]), ...
      curve2([p0(1)+length_side/1.5*cos(angle_side),-p0(1)+ ...
              length_side/1.5*cos(angle_side)],[p0(2)+length_side/1.5* ...
                    sin(angle_side),-p0(2)+length_side/1.5* ...
                    sin(angle_side)],[1,1]), curve2([-p0(1)+ ...
                    length_side/1.5*cos(angle_side),p1(1)],[-p0(2)+ ...
                    length_side/1.5*sin(angle_side),width_inlet],[1,1]), ...
      curve2([p1(1),-length_inlet/2],[width_inlet,width_inlet],[1,1])};
g2=geomcoerce('solid',carr);

carr={curve2([-p0(1)+length_side*cos(angle_side),-p0(1)+ ...
              length_side/1.5*cos(angle_side)], [-p0(2)+length_side* ...
                    sin(angle_side),-p0(2)+ length_side/1.5* ...
                    sin(angle_side)],[1,1]), curve2([-p0(1)+ ...
                    length_side/1.5*cos(angle_side), p0(1)+ ...
                    length_side/1.5*cos(angle_side)], [-p0(2)+ ...
                    length_side/1.5*sin(angle_side),p0(2)+ length_side/1.5* ...
                    sin(angle_side)],[1,1]), curve2([p0(1)+ ...
                    length_side/1.5*cos(angle_side),p0(1)+length_side* ...
                    cos(angle_side)],[p0(2)+length_side/1.5*sin(angle_side), ...
                    p0(2)+length_side*sin(angle_side)],[1,1]), ...
      curve2([p0(1)+length_side*cos(angle_side),-p0(1)+length_side* ...
              cos(angle_side)],[p0(2)+length_side*sin(angle_side),- ...
                    p0(2)+length_side*sin(angle_side)],[1,1])};
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

% Geometry
clear s
s.objs={g1,g2,g3,g4,g5};
s.name={'CO1','CO2','CO3','CO4','CO5'};
s.tags={'g1','g2','g3','g4','g5'};

fem.draw=struct('s',s);
fem.geom=geomcsg(fem);

% Initialize mesh
fem.mesh=meshinit(fem , 'hmax',[1e-5], 'hmaxedg',[2,6e-6,7,4e-6,10,4e-6,11, ...
                    4e-6,12,4e-6,13,4e-6,15,4e-6,18,4e-6], ...
                  'hmaxsub',[3,5e-6,4,7e-6,5,8e-6]);


init_size = min([width_inlet, width_side, width_outlet])/mesh_factor;
% only center line and cross region is more dense
fem.mesh=meshinit(fem, 'hmax',[init_size*4],  'hgradedg',[5,1.2,15, ...
                    1.2,18,1.2], 'hmaxedg',[5,init_size/10,6, ...
                    init_size/10,9,init_size/10,15,init_size/6,18, ...
                    init_size/3], 'hmaxsub',[2, init_size,4,init_size*3]);


% Extend mesh
fem.xmesh=meshextend(fem, 'eqvars','on','cplbndeq', 'on','cplbndsh','off');

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
bnd.type = {'noslip','neutral','uv','slip','uv','out'};
bnd.u0 = {0,0,'v_sam*3/2*(1-s*s)',0,'-v_buf*6*s*(1-s)*cos(angle_side)',0};
bnd.v0 = {0,0,0,0,'-v_buf*6*s*(1-s)*sin(angle_side)',0};
bnd.p0 = 0;
bnd.ind = [3,4,1,2,4,1,1,5,1,1,1,1,1,2,4,1,2,4,1,6];
appl.bnd = bnd;
clear equ
equ.shape = [1;2;3];
equ.gporder = {{1;1;2}};
equ.cporder = {{1;1;2}};
equ.init = {{'v_sam';0;0},{'v_sam/2';'-v_buf/2';0},{0;'-v_buf';0},{'v_sam+v_buf*2';0;0}};
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
bnd.c0 = {'concen_sam','concen_buf',0,0,0};
%bnd.type = {'N0','cont','C','C','Nc'};
bnd.type = {'C','C','N0','cont','Nc'};
bnd.ind = [1,3,3,4,3,3,3,2,3,4,3,3,3,4,3,3,4,3,3,5];
appl.bnd = bnd;
clear equ
equ.shape = 1;
equ.gporder = 1;
equ.cporder = 1;
equ.init = {'concen_sam'}; %,'concen_buf*2/3','concen_buf'};
equ.usage = 1;
equ.D = 'D_buf';
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
equ.ind = [1,1,1,1,1];
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

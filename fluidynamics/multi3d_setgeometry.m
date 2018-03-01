function [fem, femconst] = multi3d_setgeometry(varargin)
% note that the units are not SI
%
% FEMLAB Model M-file
% Generated by FEMLAB 3.1 (FEMLAB 3.1.0.157, $Date: 2007-09-19 04:45:38 $)

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
fem.const={'rho','0.99713e3','eta','0.891e-3','concen_buf','2.0', ...
           'concen_sam','1.0','concen_dia', '1.0', 'D','2.045e-9', ...
           'v_sam','0.023333', 'v_buf','0.23333','v_dia', ...
           '0.0066667','concen_avg', ['(concen_sam*(v_sam+2*' ...
                    'v_dia)+concen_buf*v_buf*2)/(v_sam+2*' ...
                    'v_dia+2*v_buf)'],'width_inlet','5e-05', ...
           'width_side','5e-05','width_diag','5e-05', ...
           'width_outlet','5e-05','length_inlet','0.0001', ...
           'length_diag','0.0001','length_side','0.0001', ...
           'length_outlet','0.0002','height','0.0001', ...
           'angle_diag','2.3562','mesh_factor','0.76','mesh_size','7.6e-07'};

%fem.const={'rho','9.9713e-13','eta','8.91e-7','D','2045','v_sam', ...
%           '4000','v_buf','40000','v_dia' ,'800','concen_buf','2.0', ...
%           'concen_sam', '1.0'};

% Geometry constants
width_inlet = 50e-6; % (default values)
width_side = 50e-6;
width_diag = 50e-6;
width_outlet = 50e-6;
length_inlet = 120e-6;
length_side = 120e-6;
length_diag = 120e-6;
length_outlet=240e-6;

height = 100e-6;
angle_diag = 135/180.0*pi;
mesh_factor=1; % the smaller, the finer mesh is
parse_varargin(varargin)

% the geometry constants to return
femconst.width_inlet = width_inlet;
femconst.width_side = width_side;
femconst.width_diag = width_diag;
femconst.width_outlet = width_outlet;
femconst.length_inlet = length_inlet;
femconst.length_diag = length_diag;
femconst.length_side = length_side;
femconst.length_outlet = length_outlet;

femconst.height = height;
femconst.angle_diag = angle_diag;
femconst.mesh_factor = mesh_factor;

fem = runfl_setconst(fem, femconst);

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

% Build Geometry
width_inout = max([width_inlet, width_outlet]);

g1=rect2(length_inlet-width_side*3,width_inlet,'base','corner','pos',[-length_inlet,0]);
g2=rect2(length_outlet-width_side*3,width_outlet,'base','corner','pos',[width_side*3,0]);
g3=rect2(width_side*2,length_side-width_inout*3,'base','corner','pos',[-width_side,width_inout*3]);

% see notes on where are p0, p1, and p2
p0 = [width_diag*cos(angle_diag-pi/2), width_diag*sin(angle_diag-pi/2)];
p1 = [width_inlet/tan(angle_diag)-width_diag/cos(angle_diag-pi/2), ...
      width_inlet];
p2 = [-width_side, -width_side*tan(angle_diag)-width_diag/cos(angle_diag)];

carr={curve2([-width_side*3,width_side*3],[0,0],[1,1]), ...
  curve2([width_side*3,width_side*3],[0,width_outlet],[1,1]), ...
  curve2([width_side*3,width_side],[width_outlet,width_outlet],[1,1]), ...
  curve2([width_side,width_side],[width_outlet,width_inout*3],[1,1]), ...
  curve2([width_side,-width_side],[width_inout*3,width_inout*3],[1,1]), ...
  curve2([-width_side,-width_side],[width_inout*3,p2(2)],[1,1]), ...
  curve2([-width_side,p0(1)+width_inout*3*cos(angle_diag)],[p2(2),p0(2)+width_inout*3*sin(angle_diag)],[1,1]), ...
  curve2([p0(1)+width_inout*3*cos(angle_diag),-p0(1)+width_inout*3*cos(angle_diag)],[p0(2)+width_inout*3*sin(angle_diag),-p0(2)+width_inout*3*sin(angle_diag)],[1,1]), ...
  curve2([-p0(1)+width_inout*3*cos(angle_diag),p1(1)],[-p0(2)+width_inout*3*sin(angle_diag),p1(2)],[1,1]), ...
  curve2([p1(1),-width_side*3],[width_inlet,width_inlet],[1,1]), ...
  curve2([-width_side*3,-width_side*3],[width_inlet,0],[1,1])};
g4=geomcoerce('solid',carr);

carr={curve2([-p0(1)+width_inout*3*cos(angle_diag), p0(1)+width_inout*3* ...
              cos(angle_diag)],[-p0(2)+width_inout*3* ...
                    sin(angle_diag),p0(2)+ width_inout*3* ...
                    sin(angle_diag)],[1,1]), curve2([p0(1)+ ...
                    width_inout*3*cos(angle_diag),p0(1)+length_diag* ...
                    cos(angle_diag)],[p0(2)+width_inout*3*sin(angle_diag), ...
                    p0(2)+length_diag*sin(angle_diag)],[1,1]), ...
      curve2([p0(1)+length_diag*cos(angle_diag),-p0(1)+length_diag* ...
              cos(angle_diag)],[p0(2)+length_diag*sin(angle_diag),- ...
                    p0(2)+length_diag*sin(angle_diag)],[1,1]), ...
      curve2([-p0(1)+length_diag*cos(angle_diag),-p0(1)+ ...
              width_inout*3*cos(angle_diag)],[-p0(2)+length_diag* ...
                    sin(angle_diag),-p0(2)+width_inout*3* ...
                    sin(angle_diag)],[1,1])};
g5=geomcoerce('solid',carr);

% Geometry
g6=extrude(g1,'distance',height,'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g7=extrude(g2,'distance',height,'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g8=extrude(g3,'distance',height,'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g9=extrude(g4,'distance',height,'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);
g10=extrude(g5,'distance',height,'scale',[1;1],'displ',[0;0],'twist',[0],'face','none','wrkpln',[0 1 0;0 0 1;0 0 0]);

clear s
s.objs={g6,g7,g8,g9,g10};
s.name={'EXT1','EXT2','EXT3','EXT4','EXT5'};
s.tags={'g6','g7','g8','g9','g10'};

fem.draw=struct('s',s);
fem.geom=geomcsg(fem);


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
prop.weakconstr=struct('value',{'off'},'dim',{{'lm1','lm2','lm3'}});
appl.prop = prop;
clear pnt
pnt.p0 = 0;
pnt.pnton = 0;
pnt.ind = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
appl.pnt = pnt;
clear bnd
bnd.type = {'noslip','neutral','uv','slip','uv','noslip','uv','strout'};
bnd.u0 = {0,0,'v_sam*9/4*(1-s1*s1)*(1-s2*s2)',0,0,'-cos(angle_diag)*v_dia*9*s1*(1-s1)*(1-s2*s2)','-cos(angle_diag)*v_dia*9*s1*(1-s1)*(1-s2*s2)',0};
bnd.v0 = {0,0,0,0,'-v_buf*9*s1*(1-s1)*(1-s2*s2)','-sin(angle_diag)*v_dia*9*s1*(1-s1)*(1-s2*s2)','-sin(angle_diag)*v_dia*9*s1*(1-s1)*(1-s2*s2)',0};
bnd.w0 = 0;
bnd.p0 = 0;
bnd.ind = [3,4,4,1,1,6,7,4,1,1,4,4,1,1,1,1,1,1,1,1,2,4,1,5,1,1,1,2,4,4,1,1,8];
appl.bnd = bnd;
clear equ
equ.shape = [1;2;3;4];
equ.gporder = {{1;1;1;2}};
equ.cporder = {{1;1;1;2}};
equ.init = {{['v_sam*9/4*(1-4*(y/width_inlet)^2)*(1-4*(z/' ...
              'height)^2)'];0;0;0},{'-cos(angle_diag)*v_dia*9/4*(1-2*((x+y)/width_diag)^2)*(1-4*(z/height)^2)';'-sin(angle_diag)*v_dia*9/4*(1-2*((x+y)/width_diag)^2)*(1-4*(z/height)^2)';0;0},{'(v_sam+(x>-width_side/2)*(x+width_side/2)/(width_side*2)*2*(v_buf+v_dia))*9/4*(1-4*(y/width_inlet)^2)*(1-4*(z/height)^2)*(y<width_inlet/2) -cos(angle_diag)*v_dia*9/4*(1-2*((x+y)/width_diag)^2)*(1-4*(z/height)^2)*(abs(x+y)*sqrt(2)<width_diag)';'-v_buf*9*(x+width_side/2)/width_side*(1-(x+width_side/2)/width_side)*(1-4*(z/height)^2)*y/(width_inlet*1.5)*(x>-width_side/2)*(x<width_side/2)*(y>-width_side/2) -sin(angle_diag)*v_dia*9/4*(1-2*((x+y)/width_diag)^2)*(1-4*(z/height)^2)*(abs(x+y)*sqrt(2)<width_diag)';0;0},{0;'-v_buf*9*(x+width_side/2)/width_side*(1-(x+width_side/2)/width_side)*(1-4*(z/height)^2)';0;0},{'(v_sam+2*v_buf+2*v_dia)*9/4*(1-4*(y/width_outlet)^2)*(1-4*(z/height)^2)';0;0;0}};

% the newer settings, but not working, so commented out!
%  equ.init = {{'v_sam*9/4*(1-4*(y/width_inlet)^2)*(1-4*(z/height)^2)';0;0;0}, ...
%      {'-cos(angle_diag)*v_dia*9/4*(1-2*((x+y)/width_diag)^2)*(1-4*(z/height)^2)'; ...
%       '-sin(angle_diag)*v_dia*9/4*(1-2*((x+y)/width_diag)^2)*(1-4*(z/height)^2)';0;0}, ...
%              {'(v_sam+(x>-width_side/2)*(x+width_side/2)/(width_side*2)*2*(v_buf+v_dia))*9/4*(1-4*(y/width_inlet)^2)*(1-4*(z/height)^2)*(y<width_inlet/2) -cos(angle_diag)*v_dia*9/4*(1-2*((x+y)/width_diag)^2)*(1-4*(z/height)^2)*(abs(x+y)*sqrt(2)<width_diag)'; ...
%               '-v_buf*9*(x+width_side/2)/width_side*(1-(x+width_side/2)/width_side)*(1-4*(z/height)^2)*y/(width_inlet*1.5)*(x>-width_side/2)*(x<width_side/2)*(y>-width_side/2) -sin(angle_diag)*v_dia*9/4*(1-2*((x+y)/width_diag)^2)*(1-4*(z/height)^2)*(abs(x+y)*sqrt(2)<width_diag)';0;0}, ...
%              {0;'-v_buf*9*(x+width_side/2)/width_side*(1-(x+width_side/2)/width_side)*(1-4*(z/height)^2)';0;0}, ...
%              {'(v_sam+2*v_buf+2*v_dia)*9/4*(1-4*(y/width_outlet)^2)*(1-4*(z/height)^2)';0;0;0}};

equ.usage = 1;
equ.rho = 'rho';
equ.eta = 'eta';
equ.F_x = 0;
equ.F_y = 0;
equ.F_z = 0;
equ.idon = 0;
equ.delid = 0.5;
equ.sdon = 1;
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
appl.shape = {'shlag(3,''c'')'};
appl.gporder = 6;
appl.cporder = 3;
appl.sshape = 3;
appl.border = 'off';
appl.assignsuffix = '_cd';
clear prop
prop.elemdefault='Lag3';
prop.equform='noncons';
prop.weakconstr=struct('value',{'off'},'dim',{{'lm4'}});
appl.prop = prop;
clear bnd
bnd.N = 0;
bnd.c0 = {0,0,0,'concen_sam','concen_buf',0, 'concen_dia'};
bnd.type = {'C','N0','N0','C','C','Nc', 'C'};
bnd.ind = [4,2,2,2,2,3,7,2,2,1,2,2,2,2,2,1,2,2,2,2,1,2,2,5,2,2,2,1,2,2,2,2,6];
appl.bnd = bnd;
clear equ
equ.shape = 1;
equ.gporder = 1;
equ.cporder = 1;
equ.init = {'concen_sam','concen_avg - (concen_sam-concen_avg)*(y<width_inlet<2)*(x<-width_side/2)*(x+width_side/2)/(width_side) + (concen_buf-concen_avg)*(y>width_inlet/2)*(x>-width_side/2)*(y-width_inlet/2)/(width_inlet) + (concen_sam-concen_avg)*(abs(x-y)/width_inlet-1)/(3/sqrt(2)-1)*(x<-width_side/2)*(y>width_inlet/2)','concen_buf','concen_avg'};

% the newer and more correct initial condition, but doesn't
% work. so commented out!
%   equ.init = {'concen_sam','concen_sam', 'concen_avg - (concen_sam-concen_avg)*(y<width_inlet/2)*(x<-width_side/2)*(x+width_side/2)/(width_side) + (concen_buf-concen_avg)*(y>width_inlet/2)*(x>-width_side/2)*(y-width_inlet/2)/(width_inlet) + (concen_sam-concen_avg)*(abs(x-y)/width_inlet-1)/(3/sqrt(2)-1)*(x<-width_side/2)*(y>width_inlet/2)', ...
%    'concen_buf', 'concen_avg'};

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
equ.sdon = 1;
equ.sdtype = 'pgc';
equ.delsd = 0.16;
equ.cdon = 0;
equ.cdtype = 'sc';
equ.delcd = 0.35;
equ.ind = [1,1,2,3,4];
appl.equ = equ;
fem.appl{2} = appl;
fem.sdim = {'x','y','z'};

% Simplify expressions
fem.simplify = 'on';
fem.border = 1;

% Solution form
fem.form = 'weak';

% Global expressions
fem.expr = {};

% Functions
clear fcns
fem.functions = {};

% Multiphysics
fem=multiphysics(fem);

% Init the mesh
mesh_size = 1.3e-6*mesh_factor;
femconst.mesh_size = mesh_size;
fem = runfl_setconst(fem, femconst);
% 
fem.mesh=meshinit(fem, ...
                  'hmax',mesh_size*11, ...
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
                  'hgradfac', [11,1.2], ...
                  'hgradedg', [16,1.1], ...
                  'hmaxedg',[16,mesh_size], ...
                  'hmaxfac',[11,mesh_size*4,12,mesh_size*3,29,mesh_size*5], ...
                  'hmaxsub',[3,mesh_size*6]);
% Extend mesh
fem.xmesh=meshextend(fem,'geoms',[1],'eqvars','on','cplbndeq', ...
                     'on','cplbndsh','off');

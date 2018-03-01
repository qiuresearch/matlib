function [fem, geoconst] = flowcell_setangle_general(varargin)

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
fem.const={'rho','1e3','eta','1e-3', 'D', '2.045e-9','concen_buf', ...
           '2.0','v_sam', '3e-3', 'v_buf','3e-2','concen_sam','1.0'};

% Geometry parameters
width_inlet = 5e-5;
width_side = 5e-5;
width_outlet = 5e-5;
angle_side = 135.0/180.0*pi;
mesh_factor=1; % the smaller, the finer mesh
parse_varargin(varargin);

% the geometry constants to return
geoconst.width_inlet = width_inlet;
geoconst.width_side = width_side; 
geoconst.width_outlet = width_outlet;
geoconst.angle_side = angle_side;
geoconst.mesh_factor = mesh_factor;

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

%*** IMPORTANT ***
% Steps here are takens to obtain how EDGES are re-numbered by FEMLAB
%
% find the re-numbering of the compound object: the ith edge by FEMLAB
% is the jth edge in the order of appearance in the code
%
[g2, ctx_index]=geomcoerce('solid',carr, 'out', {'ctx'});
edge_count=0;
for id=1:length(ctx_index) % ctx_index is a sparse array of the mapping
   [i,j,s] = find(ctx_index{id}); % get one pair
   edge_index_d2(i) = edge_count + j; % record which number did "i"
                                      % get -> "j"
   edge_count = edge_count + length(j); % count how many edges have
                                        % been mapped
end


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
% do the same for geometry g3
[g3, ctx_index]=geomcoerce('solid',carr, 'out', {'ctx'});
edge_count=0;
for id=1:length(ctx_index)
   [i,j,s] = find(ctx_index{id});
   edge_index_d3(i) = edge_count + j;
   edge_count = edge_count + length(j);
end

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

%***** IMPORTANT
% Steps here are taken to obtain how DOMAINS are re-numbered
%
%
% get the new domain index: the current ith domain is the jth
% domain in the order of geometry building process (order of the
% match codes)
%
[fem.geom, st, ctx_index]=geomcsg(fem, 'out', {'g','st','ctx'} );
[i,j,s] = find(st);
domain_index = zeros(length(i),1);
domain_index(i) = j;

% get the new index of all edges
edge_count=0;
for id=1:length(ctx_index)
   [i,j,s] = find(ctx_index{id});
   if (id == 2) % the edges of g2 have been re-numbered, so...
      edge_index(i) = edge_count + edge_index_d2(j);
   elseif (id == 3) % so have g3
      edge_index(i) = edge_count + edge_index_d3(j);
   else
      edge_index(i) = edge_count + j;
   end
   
   edge_count = edge_count + length(j);
end

% the two variables are obtained by running this routine under the
% same settings originally setup by hand. 
% domain_index_manual would be the value of domain_index
% edge_index_manual would be the values of edge_index
% 
% this will ensure the physical boundary conditions for domains
% and edges will be re-arranged correctly.

domain_index_manual = [1,2,3,4,5];
edge_index_manual = [1     2     3     5     6    12    11    13 14 ...
                    16     9     8    15 17    18    19    21 22 23 24];
    
% find the mapping vector from domain_index to domain_index_manual
[dummy, index_new] = sort(domain_index);
[dummy, index_manual] = sort(domain_index_manual);
domain_imap = 1:length(domain_index);
domain_imap(index_manual) = index_new;

[dummy, index_new] = sort(edge_index);
[dummy, index_manual] = sort(edge_index_manual);
edge_imap = 1:length(edge_index);
edge_imap(index_manual) = index_new;

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
% note the change here
bnd_ind(edge_imap) = [3,4,1,2,4,1,1,1,2,5,1,1,1,2,4,1,2,4,1,6];
bnd.ind = bnd_ind;
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
equ_ind = [1,2,3,4,4];
equ.ind = equ_ind(domain_imap);
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
bnd.type = {'C','C','Nc','N0','cont'};
% note the change here
bnd_ind(edge_imap) = [1,4,4,5,4,4,4,4,5,2,4,4,4,5,4,4,5,4,4,3];
bnd.ind = bnd_ind;
appl.bnd = bnd;
clear equ
equ.shape = 1;
equ.gporder = 1;
equ.cporder = 1;
equ.init = {'concen_sam'};
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

% Init the mesh
mesh_size = 1.6e-7*mesh_factor;
geoconst.mesh_size = mesh_size;
% only center line and cross region is more dense
fem.mesh=meshinit(fem, 'hmax',[mesh_size*40],  'hgradedg', ...
                  [edge_imap(5),1.2,edge_imap(15), 1.2,edge_imap(18),1.2], ...
                  'hmaxedg',[edge_imap(5), mesh_size, edge_imap(6), ...
                    mesh_size, edge_imap(7), mesh_size,15, mesh_size*1.6, ...
                    edge_imap(18), mesh_size*3.2], 'hmaxsub', ...
                  [domain_imap(2), mesh_size*10, domain_imap(4),mesh_size*30]);

% Extend mesh
fem.xmesh=meshextend(fem, 'eqvars','on','cplbndeq', 'on','cplbndsh','off');

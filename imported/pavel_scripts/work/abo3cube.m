function HO = abo3cube( MNO, num, bnd )
% ABO3CUBE( MNO, NUM, BND ) just draw perovskite MxNxO lattice,
% NUM = 1   show atoms  and  NUM = 2 also adds numbering
% for MNO=2, A1:8, B1:8, O1:24 are numbered as in pdffit
% BND = 1   adds also atoms, that are on the boundary planes 

% defaults:
c_num = 2;
c_bnd = 1;
%%%%%%%%%%%
if nargin < 3; bnd = c_bnd; end
if nargin < 2; num = c_num; end
if nargin < 1; MNO = 2; end
MNO = MNO(:)';
if length(MNO) == 1
    MNO = MNO*[1 1 1];
end

ha = gca;
[xx, yy, zz] = cube_grid(MNO(1), MNO(2), MNO(3));
hc = plot3( xx, yy, zz, 'k', 'LineWidth', 0.15);

[m,n,o] = meshgrid([0:MNO(1)-1], [0:MNO(2)-1], [0:MNO(3)-1]);
m=m(:); n=n(:); o=o(:);

[A,B,O] = f_data( m, n, o, bnd );
save_hold = get( ha, 'NextPlot' );
hold on
if num > 0
    hA = plot3( 2*A(:,1), 2*A(:,2), 2*A(:,3),'m*' );
    hB = plot3( 2*B(:,1), 2*B(:,2), 2*B(:,3),'bs' );
    hO = plot3( 2*O(:,1), 2*O(:,2), 2*O(:,3),'ko' );
end

htA=[]; htB=[]; htO=[];
if num > 1
    nA = (1:min(8,size(A,1)))';
    htA = text( 2*A(nA,1), 2*A(nA,2), 2*A(nA,3), ...
	  [ char(' '+zeros(size(nA,1),1)) num2str(nA, '%3i') ], ...
	  'Color', 'm' );
    nB = (1:min(8,size(B,1)))';
    htB = text( 2*B(nB,1), 2*B(nB,2), 2*B(nB,3), ...
	  [ char(' '+zeros(size(nB,1),1)) num2str(nB, '%3i') ], ...
	  'Color', 'b' );
    nO = (1:min(24,size(O,1)))';
    htO = text( 2*O(nO,1), 2*O(nO,2), 2*O(nO,3), ...
	  [ char(' '+zeros(size(nO,1),1)) num2str(nO, '%3i') ], ...
	  'Color', 'k' );
    set( [htA; htB; htO], 'FontName', 'Times', 'FontSize', 7, ...
	  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom' )
end
set( ha, 'XLim', [0 MNO(1)], 'YLim', [0 MNO(2)], 'ZLim', [0 MNO(3)] )
view(22, 10)
axis equal
axis off
set( ha, 'NextPlot', save_hold )
if nargout > 0
    HO = struct( 'hg', hc, 'hA', hA, 'hB', hB, 'hO', hO, ...
	'txA', htA, 'txB', htB, 'txO', htO);
end

function [A,B,O] = f_data( m, n, o, bnd )
A = [
	0.25	0.25	0.25
	0.25	0.75	0.75
	0.75	0.25	0.75
	0.75	0.75	0.25
	0.25	0.25	0.75
	0.75	0.25	0.25
	0.25	0.75	0.25
	0.75	0.75	0.75
];
B = [
	0	0	0
	0	0.5	0.5
	0.5	0	0.5
	0.5	0.5	0
	0.5	0.5	0.5
	0.5	0	0
	0	0.5	0
	0	0	0.5
];
O = [
	0	0	0.25
	0	0.5	0.75
	0.5	0	0.75
	0.5	0.5	0.25
	0	0	0.75
	0	0.5	0.25
	0.5	0	0.25
	0.5	0.5	0.75
	0.25	0	0
	0.75	0	0.5
	0.75	0.5	0
	0.25	0.5	0.5
	0.75	0	0
	0.25	0	0.5
	0.25	0.5	0
	0.75	0.5	0.5
	0	0.25	0
	0.5	0.75	0
	0	0.75	0.5
	0.5	0.25	0.5
	0	0.75	0
	0.5	0.25	0
	0	0.25	0.5
	0.5	0.75	0.5
];

Auc = A( all(A<0.5,2) , : );
Buc = B( all(B<0.5,2) , : );
Ouc = O( all(O<0.5,2) , : );
if ( bnd )
    [me,ne,oe] = meshgrid( [0 max(m)], [0 max(n)], [0 max(o)] );
    me=me(:); ne=ne(:); oe=oe(:);
    bz = find(any(B==0,2));
    oz = find(any(O==0,2));
    for i=2:length(me);
	B = [ B; [ B(bz,1)+me(i), B(bz,2)+ne(i), B(bz,3)+oe(i) ] ];
	O = [ O; [ O(oz,1)+me(i), O(oz,2)+ne(i), O(oz,3)+oe(i) ] ];
    end
end
if max(m) > 1 | max(n) > 1 | max(o) > 1
    A = Auc;
    B = Buc;
    O = Ouc;
    for i=2:length(m)
	A = [ A; Auc(:,1)+.5*m(i), Auc(:,2)+.5*n(i), Auc(:,3)+.5*o(i) ]; 
	B = [ B; Buc(:,1)+.5*m(i), Buc(:,2)+.5*n(i), Buc(:,3)+.5*o(i) ]; 
	O = [ O; Ouc(:,1)+.5*m(i), Ouc(:,2)+.5*n(i), Ouc(:,3)+.5*o(i) ]; 
    end
end
mm = 0.5*max(m) + 0.5 + 1e-10;
mn = 0.5*max(n) + 0.5 + 1e-10;
mo = 0.5*max(o) + 0.5 + 1e-10;
A( A(:,1)>mm | A(:,2)>mn | A(:,3) > mo , :) = [];
B( B(:,1)>mm | B(:,2)>mn | B(:,3) > mo , :) = [];
O( O(:,1)>mm | O(:,2)>mn | O(:,3) > mo , :) = [];

function [u, v, w] = cube_grid(m, n, o)

%y-grid
u=zeros(3*n+3,1); v=u;
u(2:3:3*n+3) = m*ones(n+1,1);
u(3:3:3*n+3) = NaN+zeros(n+1,1);
v(1:3:3*n+3) = 0:n;
v(2:3:3*n+3) = 0:n;
v(3:3:3*n+3) = NaN+zeros(n+1,1);
%x-grid
U=zeros(3*m+3,1); V=U;
U(1:3:3*m+3) = 0:m;
U(2:3:3*m+3) = 0:m;
U(3:3:3*m+3) = NaN+ones(m+1,1);
V(2:3:3*m+3) = n*ones(m+1,1);
V(3:3:3*m+3) = NaN+ones(m+1,1);
u=[u;U]; v=[v;V];
len = length(u);
u(1:(o+1)*len) = u(:,ones(o+1,1));
v(1:(o+1)*len) = v(:,ones(o+1,1));
w=(0:o);
w(1:(o+1)*len) = w(ones(1,len),:);
[U,V]=meshgrid(0:m,0:n);
U=U(:); V=V(:);
len = (n+1)*(m+1);
U(2:3:3*len)=U(:);
U(3:3:3*len)=U(2:3:3*len);
V(2:3:3*len)=V(:);
V(3:3:3*len)=V(2:3:3*len);
W=zeros(3*len, 1);
W(1:3:3*len)=NaN+zeros(len,1);
W(3:3:3*len)=o*ones(len,1);
if o~=0
    u=[u;U]; v=[v;V]; w=[w(:);W];
else    
    w=0*u;
end

function HOut = plrbo6z( Rox0, zplane, varargin )
% PLRBO6Z     plot octahedra tilt projections in z=0 and z=0.5 planes
% H = PLRBO6Z( Rox0, zplane, P1, P2 ... )
% H  is struct with the following fiels: 
%    B, Oh, Ol, gh, gl, all
% possible additional arguments p:
%    'MB', mb   maximum B-O bond length, scalar [0.38]
%    'SL', sl   soft limits [xmin, xmax, ymin, ymax] for scheme cropping
%               default is [ -0.15 1.15, -0.15 1.15 ], scalar or 1by4
%    'RB', rb   positions of the B-cations, n by 3 matrix
%    'ZT', zt   z-tolerance to find the B-cations, scalar [0.05]


% limits for the reproduced cell
% soft
c_XYslims = [ -0.15 1.15,  -0.15 1.15 ];
% hard
c_XYhlims = [ -0.3 1.3,  -0.3 1.3 ];
% maximum B-O length 
c_mb = 0.38;
% default positions of B-cations:
[jx, jy, jz] = meshgrid( 0:.5:1, 0:.5:1, [0 .5] );
c_Rb = [ jx(:), jy(:), jz(:) ];
% z-tolerance:
c_zt = 0.05;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process the arguments

i=1; args=varargin;
while i<=length(args)
    curarg=args{i};
    switch(curarg)
    case 'mb',
        i=i+1;
        c_mb=args{i}(1);
    case 'sl',
        i=i+1;
        if length(args{i}) == 1
	    args{i} = [-args{i}, 1+args{i}, -args{i}, 1+args{i}];
	end
        c_XYslims=args{i}(1:4);
    case 'rb',
        i=i+1;
        c_Rb=args{i};
    case 'zt',
        i=i+1;
        c_zt=args{i}(1);
    otherwise,
	error(sprintf('unknown switch %s', curarg))
    end
    i=i+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reproduce the base cell:
[jx, jy, jz] = meshgrid( -1:1, -1:1, -1:0 );
jx = jx(:); jy = jy(:); jz = jz(:);
n0 = size( Rox0, 1 );
Rox = zeros( n0*length(jx), 3 );
for i = 1:length(jx)
    j = n0*(i-1) + (1:n0);
    Rox(j, 1) = Rox0(:,1) + jx(i);
    Rox(j, 2) = Rox0(:,2) + jy(i);
    Rox(j, 3) = Rox0(:,3) + jz(i);
end
Rox( Rox(:,1) < c_XYhlims(1) | Rox(:,1) > c_XYhlims(2) | ...
     Rox(:,2) < c_XYhlims(3) | Rox(:,2) > c_XYhlims(4), : ) = [];
nox = size(Rox, 1);

% now we can start
Rb = c_Rb( abs( c_Rb(:,3) - zplane ) < c_zt, : );
nb = size( Rb, 1 ); 
% get the distance matrix, B-rows, O-cols
Md = zeros( nb, nox );
eb = ones( nb, 1 );
eox = ones( nox, 1 );
for i = 1:3
    j1 = Rb(:,i*eox);
    j2 = Rox(:,i*eb)';
    Md = Md + ( j1-j2 ).^2;
end
Md = sqrt(Md);
% find the pairs
[j1,j2] = find( Md < c_mb );
% find the O below:
k = ( Rox(j2,3) < zplane ); 
ibl = j1(k);  iol = j2(k);
Roxl = Rox(iol,:);
Roxl( Roxl(:,1) < c_XYslims(1) | Roxl(:,1) > c_XYslims(2) | ...
      Roxl(:,2) < c_XYslims(3) | Roxl(:,2) > c_XYslims(4), : ) = [];
% and the rest are high:
ibh = j1(~k); ioh = j2(~k);
Roxh = Rox(ioh,:);
Roxh( Roxh(:,1) < c_XYslims(1) | Roxh(:,1) > c_XYslims(2) | ...
      Roxh(:,2) < c_XYslims(3) | Roxh(:,2) > c_XYslims(4), : ) = [];

s_hold = get( gca, 'NextPlot' );
hold on;

% now we can plot it
hol = plot3( Roxl(:,1), Roxl(:,2), Roxl(:,3), 'ko', 'MarkerSize', 4 );
hoh = plot3( Roxh(:,1), Roxh(:,2), Roxh(:,3), 'ko', 'MarkerSize', 3, ...
	     'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none' );
hb  = plot3( Rb(:,1), Rb(:,2), Rb(:,3), 'k.' );

% find low grid lines:
jx = [ Rb( ibl, 1 ), Rox( iol, 1 ), NaN + iol(:) ]'; jx=jx(:);
jy = [ Rb( ibl, 2 ), Rox( iol, 2 ), NaN + iol(:) ]'; jy=jy(:);
jz = [ Rb( ibl, 3 ), Rox( iol, 3 ), NaN + iol(:) ]'; jz=jz(:);
% cut at soft lims
kx = find( jx < c_XYslims(1) );
  jx0 = c_XYslims(1);
  jy(kx) = (jy(kx)-jy(kx-1))./(jx(kx)-jx(kx-1)) .* (jx0-jx(kx-1)) + jy(kx-1);
  jz(kx) = (jz(kx)-jz(kx-1))./(jx(kx)-jx(kx-1)) .* (jx0-jx(kx-1)) + jz(kx-1);
  jx(kx) = jx0;
kx = find( jx > c_XYslims(2) );
  jx0 = c_XYslims(2);
  jy(kx) = (jy(kx)-jy(kx-1))./(jx(kx)-jx(kx-1)) .* (jx0-jx(kx-1)) + jy(kx-1);
  jz(kx) = (jz(kx)-jz(kx-1))./(jx(kx)-jx(kx-1)) .* (jx0-jx(kx-1)) + jz(kx-1);
  jx(kx) = jx0;
ky = find( jy < c_XYslims(3) );
  jy0 = c_XYslims(3);
  jx(ky) = (jx(ky)-jx(ky-1))./(jy(ky)-jy(ky-1)) .* (jy0-jy(ky-1)) + jx(ky-1);
  jz(ky) = (jz(ky)-jz(ky-1))./(jy(ky)-jy(ky-1)) .* (jy0-jy(ky-1)) + jz(ky-1);
  jy(ky) = jy0;
ky = find( jy > c_XYslims(4) );
  jy0 = c_XYslims(4);
  jx(ky) = (jx(ky)-jx(ky-1))./(jy(ky)-jy(ky-1)) .* (jy0-jy(ky-1)) + jx(ky-1);
  jz(ky) = (jz(ky)-jz(ky-1))./(jy(ky)-jy(ky-1)) .* (jy0-jy(ky-1)) + jz(ky-1);
  jy(ky) = jy0;
hgl = plot3( jx, jy, jz, 'LineStyle', ':', 'Color', 'k' );

% find high grid lines:
jx = [ Rb( ibh, 1 ), Rox( ioh, 1 ), NaN + ioh(:) ]'; jx=jx(:);
jy = [ Rb( ibh, 2 ), Rox( ioh, 2 ), NaN + ioh(:) ]'; jy=jy(:);
jz = [ Rb( ibh, 3 ), Rox( ioh, 3 ), NaN + ioh(:) ]'; jz=jz(:);
% cut at soft lims
kx = find( jx < c_XYslims(1) );
  jx0 = c_XYslims(1);
  jy(kx) = (jy(kx)-jy(kx-1))./(jx(kx)-jx(kx-1)) .* (jx0-jx(kx-1)) + jy(kx-1);
  jz(kx) = (jz(kx)-jz(kx-1))./(jx(kx)-jx(kx-1)) .* (jx0-jx(kx-1)) + jz(kx-1);
  jx(kx) = jx0;
kx = find( jx > c_XYslims(2) );
  jx0 = c_XYslims(2);
  jy(kx) = (jy(kx)-jy(kx-1))./(jx(kx)-jx(kx-1)) .* (jx0-jx(kx-1)) + jy(kx-1);
  jz(kx) = (jz(kx)-jz(kx-1))./(jx(kx)-jx(kx-1)) .* (jx0-jx(kx-1)) + jz(kx-1);
  jx(kx) = jx0;
ky = find( jy < c_XYslims(3) );
  jy0 = c_XYslims(3);
  jx(ky) = (jx(ky)-jx(ky-1))./(jy(ky)-jy(ky-1)) .* (jy0-jy(ky-1)) + jx(ky-1);
  jz(ky) = (jz(ky)-jz(ky-1))./(jy(ky)-jy(ky-1)) .* (jy0-jy(ky-1)) + jz(ky-1);
  jy(ky) = jy0;
ky = find( jy > c_XYslims(4) );
  jy0 = c_XYslims(4);
  jx(ky) = (jx(ky)-jx(ky-1))./(jy(ky)-jy(ky-1)) .* (jy0-jy(ky-1)) + jx(ky-1);
  jz(ky) = (jz(ky)-jz(ky-1))./(jy(ky)-jy(ky-1)) .* (jy0-jy(ky-1)) + jz(ky-1);
  jy(ky) = jy0;
hgh = plot3( jx, jy, jz, 'LineStyle', '-', 'Color', 'k' );

view(2);
set( gca, 'NextPlot', s_hold );

HOut = struct( 'B', hb, 'Oh', hoh, 'Ol', hol, 'gh', hgh, 'gl', hgl, ...
	       'all', [ hb(:); hoh(:); hol(:); hgh(:); hgl(:); ] );


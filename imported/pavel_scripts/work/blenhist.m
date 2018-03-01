function hout = blenhist( raa , xh)
% H = BLENHIST( RAA, XH )
% RAA is [ r(:) atom1(:) atom2(:) ], where atom numbers are 1:3 (A, B, O)

yshift = 0;
xdefault = linspace( 1.7, 5.5, 75 );
Acolors = [
1   1 0	 %yellow
0 .75 0  %green
1   0 0  % red
];


if nargin < 2
    xh = xdefault;
end

ohold = get( gca, 'NextPlot' );
if strcmp( ohold, 'replace' )
    cla
end
set( gca, 'NextPlot', 'Add' );

hp = [];
ymx = 0;
for a1=1:3
    for a2=a1:3
	i = find( raa(:,2)==a1 & raa(:,3)==a2 );
	ni = hist( raa(i,1), xh );
	ni = ni./xh;
	warning off
	[xb, yb] = bar( xh, ni, .75 );
	warning on
	ymx = max( [ ymx ; yb ] );
	if a1 == a2
	    c = Acolors(a1,:);
	else
	    % create the color matrix:
	    lb = length(xb); 
	    c = zeros( lb, 1, 3 );
	    c1 = Acolors(a1,:);
	    c2 = Acolors(a2,:);
	    i1 = [1:5:lb 2:5:lb 5:5:lb];
	    i2 = [3:5:lb 4:5:lb];
	    c(i1,1,:) = c1(ones(length(i1),1),:);
	    c(i2,1,:) = c2(ones(length(i2),1),:);
	end
	hp = [hp ; patch( xb, yb, c )];
    end
end
for i = 2:length(hp)
    set( hp(i), 'YData', get(hp(i), 'YData') + (i-1)*ymx*yshift )
end
if nargout > 0
    hout = hp;
end
set( gca, 'NextPlot', ohold );
legend(hp([1 4 6]), 'A', 'B', 'O', 2)
title( 'hist(r) / r')
xlabel('r')
ylabel('Npairs / r')

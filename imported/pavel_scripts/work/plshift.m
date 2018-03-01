function [HOut,DOut] = iplshift( ri, c_sfmt, c_SC )
% function [HOut,DOut] = iplshift( ri, c_fmt, scale )
% c_sfmt is format for shift labels:
% 0 .. no labels,  1 .. dir,  [2] .. dir and magnitude

c_FN = 'Times'; c_FS = 6.5;  % fontname/size
dxdydz = [ .25 .25 .25 ] ;   % shift of all atoms
if nargin < 2,
    c_sfmt = 2;
end
if nargin < 3
    c_SC = 1;                    % scale factor
end


ri = mod(  ri(:,1:3) + 0.1+dxdydz(ones(size(ri,1),1),:), 1 ) - 0.1;
ri0 = round(ri*4)/4;
d0 = mean( ri - ri0 );
ri = ri - d0(ones(size(ri,1),1),:);
dr = ri-ri0;

cla
hold on

% PB:
ipb = 1:8;
dpb = ri(ipb,:) - ri0(ipb,:);
dpb_SC = c_SC * dpb;
hpb=quiver3( ri0(ipb,1), ri0(ipb,2), ri0(ipb,3),  ...
    dpb_SC(:,1), dpb_SC(:,2), dpb_SC(:,3), 0, 'm' );
ri_SC = ri0(ipb,:) + dpb_SC;
hpb = [ hpb ; plot3(ri_SC(:,1), ri_SC(:,2), ri_SC(:,3), 'ms',...
	'MarkerSize', 4, 'LineWidth', .25 ) ];

% SC:
isc = 9:12;
dsc = ri(isc,:) - ri0(isc,:);
dsc_SC = c_SC * dsc;
hsc=quiver3( ri0(isc,1), ri0(isc,2), ri0(isc,3),  ...
    dsc_SC(:,1), dsc_SC(:,2), dsc_SC(:,3), 0, 'b' );
ri_SC = ri0(isc,:) + dsc_SC;
hsc = [ hsc ; plot3(ri_SC(:,1), ri_SC(:,2), ri_SC(:,3), 'b.') ];

% W:
iw = 13:14;
dw = ri(iw,:) - ri0(iw,:);
dw_SC = c_SC * dw;
hw=quiver3( ri0(iw,1), ri0(iw,2), ri0(iw,3),  ...
    dw_SC(:,1), dw_SC(:,2), dw_SC(:,3), 0, 'g' );
set(hw, 'Color', [0 .5 0]);
ri_SC = ri0(iw,:) + dw_SC;
hw = [ hw ; plot3(ri_SC(:,1), ri_SC(:,2), ri_SC(:,3), '.', 'Color', [0 .5 0]) ];

% TI:
iti = 15:16;
dti = ri(iti,:) - ri0(iti,:);
dti_SC = c_SC * dti;
hti=quiver3( ri0(iti,1), ri0(iti,2), ri0(iti,3),  ...
    dti_SC(:,1), dti_SC(:,2), dti_SC(:,3), 0, 'r' );
ri_SC = ri0(iti,:) + dti_SC;
hti = [ hti ; plot3(ri_SC(:,1), ri_SC(:,2), ri_SC(:,3), 'r.') ];

% O:
io = 17:40;
do_ = ri(io,:) - ri0(io,:);
do_SC = c_SC * do_;
ho=quiver3( ri0(io,1), ri0(io,2), ri0(io,3),  ...
    do_SC(:,1), do_SC(:,2), do_SC(:,3), 0, 'k' );
ri_SC = ri0(io,:) + do_SC;
ho = [ ho ; plot3(ri_SC(:,1), ri_SC(:,2), ri_SC(:,3), 'ko') ];

set( [hsc(:); hw(:); hti(:)], 'MarkerSize', 8 )
set( ho, 'LineWidth', .25, 'MarkerSize', 3 );

[xm,ym] = meshgrid(0:.5:1, 0:.5:1); xm=xm(:); ym=ym(:); zm = 0*xm;
xm = [xm, xm, xm+NaN]; xm = xm'; xm=xm(:);
ym = [ym, ym, ym+NaN]; ym = ym'; ym=ym(:);
zm = [zm, 1+zm, zm+NaN]; zm = zm'; zm=zm(:);
xxm = [xm;NaN;ym;NaN;zm];
yym = [ym;NaN;zm;NaN;xm];
zzm = [zm;NaN;xm;NaN;ym];
hb = plot3( xxm, yym, zzm, '-.', 'LineWidth', .25, 'Color', [.5 .5 .5] );
axis off
axis equal
view(-12,14)
axis([0 1 0 1 0 1]);
hax = gca;

HOut = struct('pb', hpb, 'sc', hsc, 'w', hw, 'ti', hti, 'o', ho, 'edge', hb);
DOut = struct('pb', dpb, 'sc', dsc, 'w', dw, 'ti', dti, 'o', do_);

% now make those labels:
htxt = [];
for i=1:size(ri,1)
    if i <= 8;
	cf = get(hpb(3), 'Color');
    elseif 8<i & i<=12
	cf = get(hsc(3), 'Color');
    elseif 12<i & i<=14
	cf = get(hw(3), 'Color');
    elseif 14<i & i<=16
	cf = get(hti(3), 'Color');
    elseif 16<i
	cf = get(ho(3), 'Color');
    end
    xf = ri0(i,1) + c_SC*dr(i,1);
    yf = ri0(i,2) + c_SC*dr(i,2);
    zf = ri0(i,3) + c_SC*dr(i,3);
    switch c_sfmt;
    case 0, s_1 = '';
    case 1, s_1 = sprintf('  [%.0f,%.0f,%.0f]', 1e3*dr(i,:));
    case 2, s_1 = sprintf('  [%.0f,%.0f,%.0f]%.0f', ...
		    1e3*dr(i,:), 1e3*sqrt(sum(dr(i,:).^2)));
    otherwise, error('wrong value of c_sfmt' );
    end
    htxt = [htxt; text( xf, yf, zf, s_1, ...
      'VerticalAlignment', 'bottom', 'Color', cf ) ];
end
set(htxt, 'FontName', c_FN, 'FontSize', c_FS);
HOut.txt = htxt;
xlabel('x', 'Visible', 'off');
ylabel('y', 'Visible', 'off');
hleg = legend( [hpb(3) hsc(3) hw(3) hti(3)], 'Pb', 'Sc', 'W', 'Ti' , -1);
set( hleg, 'Units', 'normalized',...
	    'Position', [0.86869 0.611964 0.114286 0.163036] )
subpos( hax, 111 );

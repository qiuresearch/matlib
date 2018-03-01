function HCUT=latcut( plane )
%usage: latcut([h k l N]), i.e. hx + ky + lz = N

ax=findobj('type', 'axes', 'tag', 'latcut');
hcf=gcf;
N=plane(4);
hkl=plane(1:3);
hkl=hkl(:);

if isempty(ax)
    figure;
    ax=axes('tag', 'latcut');
    figure(hcf);
end
ax=ax(1);
delete(get(ax,'children'))
allax=findobj('type','axes');
if ax==gca
    myax=allax(allax~=ax);
    axes(myax(1))
end
HCut=[];
hl=findobj(gca,'type','line', 'linestyle', 'none');
for i=1:length(hl)
    hcl=hl(i);
    xl=get(hcl, 'xdata');
    yl=get(hcl, 'ydata');
    zl=get(hcl, 'zdata');
    rl=[xl(:) yl(:) zl(:)];
    if size(rl,2)==3
	i=find(abs(rl*hkl-N)<1e5*eps);
	if ~isempty(i)
	    hcut=copyobj(hcl, ax);
	    rl=rl(i,:);
	    nhkl=hkl/norm(hkl);
	    fi=atan2(nhkl(2), nhkl(1));
	    th=acos(nhkl(3));
	    R1=[cos(fi)		sin(fi)		0
		-sin(fi)	cos(fi)		0
		0		0		1];
	    R2=[cos(th)		0		sin(th)
		0		1		0
		-sin(th)	0		cos(th)];	
	    R=R2*R1;
	    rc=rl*R';
	    set(hcut, 'xdata', rc(:,1), 'ydata', rc(:,2), 'zdata', [])
	    set(ax, 'xlimmode', 'auto', 'ylimmode', 'auto', 'zlimmode', 'auto');
	    HCut=[HCut; hcut];
	end
    end
end
figure(get(ax, 'parent')); axes(ax); axis equal;
if nargout>0
    HCUT=HCut;
end

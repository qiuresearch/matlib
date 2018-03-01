function s=finspsw(x, element)
%FINSPSW   prepares ATOM lines for finax input for PSW xrd simulations
%	  S=FINSPSW(X, ELEMENT)
%         X is substitution rate
%	  ELEMENT can be 'z' for ZR4+ or 't' for TI4+

% 2000 by Pavol

x=x(1);
switch lower(element)
    case 'z',	el='ZR4+';
    case 't',	el='TI4+';
    otherwise,	error('unknown element...')
end
nl=sprintf('\n');
s0=[...
'ATOM   PB2+    .25 .25 .25/' nl,...
'ATOM   O2-.    .25 /' nl,...
];
if x<=0.25
    s1=sprintf('ATOM   SC3+ 1  /\n');
    if x~=0.25
	s1=[s1,...
	sprintf('ATOM   SC3+ 2  .5 .5 .5,, %.5f\n', (1-4*x)/3)];
    end
    s2=sprintf('ATOM   W6+  2  .5 .5 .5,, %.5f\n', (2-2*x)/3);
    if x>0
	s2=[s2,...
	sprintf('ATOM   %-4s 2  .5 .5 .5,, %.5f\n', el, 2*x)];
    end
elseif x<1 %x>0.25 & x<1
    s1=sprintf('ATOM   SC3+ 1  0  0  0 ,, %.5f\n', (1-x)*4/3);
    s1=[s1,...
       sprintf('ATOM   %-4s 1  0  0  0 ,, %.5f\n', el, (4*x-1)/3)];
    s2=sprintf('ATOM   W6+  2  .5 .5 .5,, %.5f\n', (2-2*x)/3);
    s2=[s2,...
       sprintf('ATOM   %-4s 2  .5 .5 .5,, %.5f\n', el, (2*x+1)/3)];
else	   %x==1
    s1=sprintf('ATOM   %-4s 1  0  0  0 /\n', el);
    s2=sprintf('ATOM   %-4s 2  .5 .5 .5/\n', el);
end

s=[s0 s1 s2];

function data=q(a,b,c1,d1,c2,d2,s)

global z;
global k;
global phi;

data=sigma(a,b,c1,d1,c2,d2,s) - tau(a,b,c1,d1,c2,d2,s).*exp(-s);
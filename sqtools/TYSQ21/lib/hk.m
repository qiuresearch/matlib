function data=hk(kk,myCk)

global z;
global k;
global phi;

rou = phi*6/pi;

data=myCk./(1-rou*myCk);


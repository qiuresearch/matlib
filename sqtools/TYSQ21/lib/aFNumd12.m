function data=aFNumd12()

global z;
global k;
global phi;

data=Ccd2_22.* Cdd1_12 .* v(1) - Ccd1_21.* Cdd2_22.* v(1) - ... 
  Ccd2_12.* Cdd1_12.* v(2) + Ccd1_11.* Cdd2_22.* v(2) + ... 
  Ccd1_21.* Ccd2_12.* w(2) - Ccd1_11.* Ccd2_22.* w(2);
  
%data=Ccd2_22*Cdd1_12*v(1)-Ccd1_21*Cdd2_22*v(1);
function t=ths_v2t(v)
%THS_V2T   convert voltage to temperature for S-type thermocouple
%   T = THS_V2T(V)   where V is in Volts, T in Celsius
%
%See also THS_T2V

vlo = [ -0.235          1.874           10.332           17.536 ]/1000;
vhi = [  1.874         11.950           17.536           18.693 ]/1000;
p = [ 
       0.00000000E+00  1.291507177E+01 -8.087801117E+01  5.333875126E+04
       1.84949460E+02  1.466298863E+02  1.621573104E+02 -1.235892298E+04
      -8.00504062E+01 -1.534713402E+01 -8.536869453E+00  1.092657613E+03
       1.02237430E+02  3.145945973E+00  4.719686976E-01 -4.265693686E+01
      -1.52248592E+02 -4.163257839E-01 -1.441693666E-02  6.247205420E-01
       1.88821343E+02  3.187963771E-02  2.081618890E-04  0.000000000E+00
      -1.59085941E+02 -1.291637500E-03  0.000000000E+00  0.000000000E+00
       8.23027880E+01  2.183475087E-05  0.000000000E+00  0.000000000E+00
      -2.34181944E+01 -1.447379511E-07  0.000000000E+00  0.000000000E+00
       2.79786260E+00  8.211272125E-09  0.000000000E+00  0.000000000E+00
       ];
p = flipud(p);
t = 0*v + NaN;
for i=1:length(vlo)
    j = find( v(:)>=vlo(i) & v(:)<vhi(i) );
    t(j) = polyval(p(:,i), 1000*v(j));
end

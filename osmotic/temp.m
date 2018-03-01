function pressure = temp(concen, pegtype, temperature)
% --- Usage:
%        pressure = osmotic_pressure(concen, pegtype, temperature)
% --- Purpose:
%        get the tabulated osmotic pressure.
%
% --- Parameter(s):
%        concen   - weight fraction of PEG
%        pegtype  - "PEG8K", ...
%        temperature - 20 (default)
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: osmotic_pressure.m,v 1.2 2012/11/09 23:30:46 xqiu Exp $
%

verbose = 1;

if ~exist('pegtype', 'var')
   pegtype = 'PEG8K';
end
if ~exist('temperature', 'var')
   temperature = 20; % in Celsius
end


peg_con = 0.01:0.01:0.6;

osmop8k = osmotic_pressure(peg_con, 'PEG8k', 20);

osmop20k = osmotic_pressure(peg_con, 'PEG20k', 20);


osmop20k_old = osmotic_pressure(peg_con, 'PEG20k', 20);

      a =   5.068385;
      b =  11.515383;
      c = -13.958688;
      d = 0;
      e = 0;
         case 20
            a2 = -0.073492;
            b2 =  1.024076;
            c2 = -0.0014824;
         case 25
            a2 = 0;
            b2 = 1;
            c2 = 0;
      

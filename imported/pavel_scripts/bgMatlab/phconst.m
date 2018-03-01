function out=phconst(name)
%PHCONST     values of some physical constants
%  PHCONST CONST returns a value of physical constant
%  PHCONST displays defined physical constants

%  $Id: phconst.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

phconst = {...
   %name        %value         %description
   'cuka',      1.541871,      '(A) weighted Cu Kalpha1, Kalpha2'
   'cuka1',     1.540598,      '(A) Cu Kalpha1'
   'cuka2',     1.544418,      '(A) Cu Kalpha2'
   'kb',        1.38062e-23,   'J/K'
   'NA',        6.022045e23,   'g/mol'
   'ec',        1.6021892e-19, 'Coulomb'
   'h',        	6.626176e-34,  'Js'
   'c',        	2.997924580e8, 'm/s'
   'hceV',      2.997924580e8*6.626176e-34/1.6021892e-19, 'eVm'
   'eps0',	1/(2.997924580e8^2*4e-7*pi),		  'F/m'
};

if nargin==0
   sp=' '*ones(size(phconst,1),1);
   disp(sprintf('\nDefined constants:'));
   disp([sp sp char(phconst{:,1}) sp sp sp char(phconst{:,3})]);
   return;
end
i=strcmp(name,{phconst{:,1}});
if isempty(i)
    error([name ' not found']);
end
out=phconst{i,2};

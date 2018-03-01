function secondvirial = secondvirial_vol2con(volume, molweight);
% --- Usage:
%        secondvirial = secondvirial_vol2con(volume, molweight);
% --- Purpose:
%        this function simply converts the hard core repulsion part to
%        the unit of concentration in weight/volume
%
% --- Parameter(s):
%        volume - volume of the particle in (A^3)
%        molweight - molecular weight (g/mol)
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: secondvirial_vol2con.m,v 1.1 2013/01/02 04:06:23 xqiu Exp $
%


NA = 6.023e23;

secondvirial = 4*volume*1e-24*NA/molweight^2;

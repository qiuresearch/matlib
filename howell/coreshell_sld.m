function sld = coreshell_sld(x, bp, R1, R2)
% --- Usage:
%        sld = coreshell_sld(x, bp, R1, R2)
%
% --- Purpose:
%        For determining the scatering length density 
%        of the core and shell (used for bacteria phage)
%        as a function of H20-D20:  SLD(H2O-D2O)
%
% --- Parameter(s):
%        x: H2O-D2O percentage
%        bp: Number of base pairs in the DNA
%        R1: Inner radius of the shel
%        R2: Outer radius of the shell
%
% --- Return(s): 
%        sld: the scattering length density as a function of H2O-D2O 
%
% --- Example(s):
%        sld = coreshell_sld( 0:.1:1, 37.8E3, 282.3, 361.9)
%        b221 data from .../0811NIST/datafit
%
% $Id: coreshell_sld.m,v 1.2 2012/12/07 19:38:48 schowell Exp $
%

b = [-0.53846,10/3,1.9];               % y intercept
m = [0.069231, 0.0083333, 0.01];       % slope

for i=1:3; y(i,:) = m(i)*x+b(i); end;  % i=1: water; i=2: dna; i=3: protein;

Vbp   = pi*(20/2)^2*3.4;         %A^2
Vdna = Vbp*bp;              %Volume of b221 DNA


VgpD = 2.64E4;           %A^3  Volume of gpD
VgpE = 4.88E4;		 %A^3  Volume of gpE: 38188.2amu *1.66E-24gm/amu*1cm^3/1.3gm *(10^7nm)^3/1cm^3 
Vpro = 405*(VgpD+VgpE);        %Volume of capsid protein
              
V1 = 4/3*pi*R1^3;              %A^3
V2 = 4/3*pi*(R2^3-R1^3);       %A^3


%%  rho1=(V_dna/V_total)*rho_dna
%%  rho2=(V_protein/V_total)*rho_pro
sld = [Vdna/V1 * (y(2,:) - y(1,:)); Vpro/V2  * (y(3,:) - y(1,:))]';


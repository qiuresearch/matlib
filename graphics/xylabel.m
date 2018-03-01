function xylabel(selection)
% --- Usage:
%        xylabel(selection)
%
% --- Purpose:
%
%
%
% --- Parameter(s):
%
%
% --- Return(s): 
%
%
% --- Example(s):
%        xylabel('iq')
%
% $Id: xylabel.m,v 1.22 2016/10/26 15:21:56 xqiu Exp $


verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

if ~exist('selection', 'var')
   selection = 'standard';
end
switch upper(selection)
   %% various scattering profiles 
   case {upper('standard'), upper('iq')}
      % if strcmpi(version('-release'), '2010b'); 
      set(xlabel('Q (\AA\textsuperscript{-1})', 'Interpreter', ...
                 'Latex'), 'FontName', 'Arial');
      set(ylabel('I(Q)', 'Interpreter', 'Latex'), 'FontName', 'Arial');
      % set(gca,'YTickLabel',[])

   case upper('pq')
      % if strcmpi(version('-release'), '2010b'); 
      set(xlabel('Q (\AA\textsuperscript{-1})', 'Interpreter', ...
                 'Latex'), 'FontName', 'Arial');
      set(ylabel('P(Q)', 'Interpreter', 'Latex'), 'FontName', 'Arial');
      % set(ax,'YTickLabel',[])

   case upper('iphi') % azimuthal angle dependence
      set(xlabel('$\phi$ (radian)', 'Interpreter', 'Latex'), 'FontName', 'Arial');
      set(ylabel('I(Q)', 'Interpreter', 'Latex'), 'FontName', 'Arial');
      
   case upper('guinier')
      set(xlabel('Q\textsuperscript{2} (\AA\textsuperscript{-2})', 'Interpreter', ...
                 'Latex'), 'FontName', 'Arial');
      set(ylabel('log(I(Q))', 'Interpreter', 'Latex'), 'FontName', 'Arial');
   
   case upper('guinier_rod')
      set(xlabel('Q\textsuperscript{2} (\AA\textsuperscript{-2})', ...
                 'Interpreter', 'Latex'), 'FontName', 'Arial');
      set(ylabel('log(Q\timesI(Q))', 'Interpreter', 'Latex'), 'FontName', 'Arial');
   
   case upper('kratky') % kratky
      set(xlabel('Q (\AA\textsuperscript{-1})', 'Interpreter', ...
                 'Latex'), 'FontName', 'Arial');
      set(ylabel('Q\textsuperscript{2}$\times$I(Q)', 'Interpreter', 'LaTex'), ...
                 'FontName', 'Arial');
      
   case upper('kratkyp') % kratky
      set(xlabel('Q (\AA\textsuperscript{-1})', 'Interpreter', ...
                 'Latex'), 'FontName', 'Arial');
      set(ylabel('Q\textsuperscript{2}$\times$P(Q)', 'Interpreter', 'LaTex'), ...
                 'FontName', 'Arial');
      
   case upper('pz')
      set(xlabel('z (\AA)', 'Interpreter', 'LaTex'), 'FontName', 'Arial');
      set(ylabel('P(z)'), 'FontName', 'Arial');

    case {upper('pr'), upper('pcf')}
      set(xlabel('r (\AA)', 'Interpreter', 'LaTex'), 'FontName', 'Arial');
      set(ylabel('P(r)', 'Interpreter', 'LaTex'), 'FontName', 'Arial');
      
   
   %% Omostic stressmethod
   case upper('osmoforce_dyne')
      xlabel('inter-axial distance (\AA)', 'Interpreter', 'LaTex');
      ylabel('log10(\Pi) (erg/cm^3)');%, 'Interpreter', 'LaTex');
   case {upper('osmoforce'), upper('osmoforce_pascal')}
      xlabel('inter-axial distance (\AA)', 'Interpreter', 'LaTex');
      ylabel('log10(\Pi) (Pa)');
   case {upper('osmoenergy')}
      xlabel('inter-axial distance (\AA)', 'Interpreter', 'LaTex');
      ylabel('energy (k$_B$T/\AA)', 'Interpreter', 'LaTex');

   %% Dynamic light scattering
   case upper('dls')
      xlabel('Delay Time $\tau$ $(\mu s$)', 'Interpreter', 'LaTex')
      ylabel('Auto-Correlation Function $g(\tau)$', 'Interpreter', 'LaTex')

   case upper('uvspec');
      xlabel('Wavelength (nm)');
      ylabel('Absorption (OD)');

   otherwise
      disp('label option not supported yet, defaulting to standard')
      xylabel('standard');
end

return

text(0.5, 0.8, '\textsf{sans serif}','interpreter','latex');
text(0.5, 0.7, '\textrm{roman}','interpreter','latex');
text(0.5, 0.6, '$$\mathsf{math\,\,mode\,\,sans\,\,serif}$$','interpreter','latex');
text(0.5, 0.5, '$$\mathrm{math\,\,mode\,\,roman}$$','interpreter','latex');

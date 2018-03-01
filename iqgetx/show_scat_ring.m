function hring = show_scat_ring(dspacing, varargin)
%        hring = show_scat_ring(dspacing, varargin)
%              varargin can be X_cen Y_cen X_Lambda Spec_to_Phos
%        return the handle to the ring
%  
   global X_cen Y_cen X_Lambda Spec_to_Phos
   
   parse_varargin(varargin);
   
   radius =  Spec_to_Phos*tan(2* asin(X_Lambda/2/dspacing));
   
   %   plot(X_cen, Y_cen, 'w*');

   theta = linspace(0, 2*pi, 299);
   hring=plot(X_cen+radius*cos(theta), Y_cen+ radius*sin(theta), ...
              'k--', 'linewidth', 0.5);

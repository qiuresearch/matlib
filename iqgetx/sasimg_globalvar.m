function sas = sasimg_globalvar(sas, varargin);

   verbose = 1;
   
   global X_cen Y_cen Spec_to_Phos X_Lambda MaskIfile MaskI MaskD
   
   if strmatch(varargin, 'disp')
      globalvar = struct('X_Lambda', X_Lambda, 'X_cen', X_cen, ...
                         'Y_cen', Y_cen, 'Spec_to_Phos', Spec_to_Phos, ...
                         'MaskIfile', MaskIfile, 'MaskI', MaskI, ...
                         'MaskD', MaskD)
   end
   
   for i=1:length(sas)
      
      if strmatch(varargin, 'set')
         X_cen = sas(i).X_cen;
         Y_cen = sas(i).Y_cen;
         Spec_to_Phos = sas(i).Spec_to_Phos;
         X_Lambda = sas(i).X_Lambda;
         MaskI = sas(i).MaskI;
         MaskD = sas(i).MaskD;
         sasimg_globalvar(sas(i), 'disp');
      end
      
      if strmatch(varargin, 'get')
         if isempty(X_cen);
            showinfo('Global variables have no values assigned!');
            return
         end
         sas(i).X_cen = X_cen;
         sas(i).Y_cen = Y_cen;
         sas(i).Spec_to_Phos = Spec_to_Phos;
         sas(i).X_Lambda = X_Lambda;
         sas(i).MaskI = MaskI;
         sas(i).MaskD = MaskD;
         sasimg_globalvar(sas(i), 'disp');
      end
   end
   
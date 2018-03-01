function sas = sasimg_run(sas, varargin);

verbose = 1;
do_plot = 1;
all = 0;
iq_get = 0;
iq_save = 0;
calib = 0;
mask_reset = 0;
mask_save = 0;
mask_auto = 0;
mask_exclude = 0;
mask_include = 0;
slice_pizza = 0;
roll_donut = 0;
sub_symbkg = 0;

parse_varargin(varargin);

for i=1:length(sas)
   
   if ((all == 1) || (calib == 1)) 
      if (numel(sas(i).calib_ringxy)>=6);
         
         [X_cen, Y_cen, radius]=circfit(sas(i).calib_ringxy(:,1), ...
                                        sas(i).calib_ringxy(:,2));
         
         Spec_to_Phos = radius/tan(2*asin(sas(i).X_Lambda/2/sas(i).calib_dspacing));
         
         disp(['NEW beam center: X_cen: ' num2str(X_cen) 'Y_cen: ' ...
               num2str(Y_cen) ', Spec_to_Phos: ' num2str(Spec_to_Phos)])
         
         sas(i).X_cen = X_cen;
         sas(i).Y_cen = Y_cen;
         sas(i).Spec_to_Phos = Spec_to_Phos;
      else
         showinfo('calib_ringxy: at least three points need to be provided!'); 
      end
   end
   
   if ((all == 1) || (mask_reset == 1))
      sas(i).MaskI(:) = 1;
      sas(i).MaskD(:) = 1;
   end
   
   if ((all == 1) || (mask_auto == 1))
      newmask = automask_mar(sas(i).im, [sas(i).X_cen, sas(i).Y_cen], ...
                             'dead_center_radius', sas(i).mask_deadcenradius, ...
                             'beam_stop_radius', sas(i).mask_bsradius, ...
                             'detector_radius', sas(i).mask_detradius);
      sas(i).MaskI = sas(i).MaskI.*newmask;
      sas(i).MaskD = sas(i).MaskD.*newmask;
   end
   
   if ((all == 1) || (mask_exclude == 1))
      if (numel(sas(i).mask_polygonxy)>=6);
         logicalmask = roipoly(sas(i).im, sas(i).mask_polygonxy(:,1), ...
                               sas(i).mask_polygonxy(:,2));
         %   sas(i).MaskD = sas(i).MaskD.*(1-newmask);
         sas(i).MaskI(logicalmask) = 0;
         sas(i).MaskD(logicalmask) = 0;
      else
         showinfo('mask_exclude: at least three points need to be provided!'); 
      end
   end
   
   if ((all == 1) || (mask_include == 1))
      if (numel(sas(i).mask_polygonxy)>=6);
         logicalmask = roipoly(sas(i).im, sas(i).mask_polygonxy(:,1), ...
                               sas(i).mask_polygonxy(:,2));
         sas(i).MaskI(logicalmask) = 1;
         sas(i).MaskD(logicalmask) = 1;
      else
         showinfo('mask_include: at least three points need to be provided!'); 
      end
   end
   
   if ((all == 1) || (mask_save == 1))
      if isempty(sas(i).MaskIfile)
         sas(i).MaskIfile = [sas(i).prefix '_MaskI.mat'];
      end
      showinfo(['Saving MaskI to file: ' fullfile(sas(i).MaskIfile)]);
      MaskI = uint8(sas(i).MaskI);
      save(sas(i).MaskIfile, 'MaskI');
   end
   
   
   if (all == 1) || (slice_pizza == 1);
      sasimg_globalvar(sas(i), 'set');
      [data, thetagrid] = integrate_slice(sas(i).im, sas(i).slice_num, ...
                                          sas(i).slice_dspacing, ...
                                          'autoalign', ...
                                          sas(i).slice_autoalign, ...
                                          'tolerance', sas(i).slice_tolerance);

      % reset the beam center calibrant ring radius
      if (sas(i).slice_autoalign == 1)
         sas(i) = sasimg_globalvar(sas(i), 'get');
      end
      
      if (do_plot == 0); continue; end

      % plot the borders of the slices
      for j=i:length(thetagrid)
         plot([sas(i).X_cen, sas(i).X_cen+ sas(i).im_size(1)*2*cos(thetagrid(j))], ...
              [sas(i).Y_cen, sas(i).Y_cen+ sas(i).im_size(1)*2*sin(thetagrid(j))], 'w--');
      end
      
      % plot the I(Q)s from the slices
      figure; hold all
      for i=1:sas(i).slice_num
         plot(data(:,1,i), data(:,2,i));
         lege{i} = num2str(thetagrid([i,i+1])*180/pi, ['Angle: [%6.2f, ' ...
                             '%6.2f]']);
      end
      legend(lege);legend boxoff
   end

   if (all == 1) || (roll_donut == 1)
      sasimg_globalvar(sas(i), 'set');
      [data, circ_box] = integrate_azimuthal(sas(i).im, ...
                                             sas(i).donut_Qcenter, ...
                                             sas(i).donut_Qwidth, ...
                                             'num_points', ...
                                             sas(i).donut_numpoints);
      if (do_plot == 0); continue; end

      % plot the circ box
      plot(circ_box(:,1), circ_box(:,2), '.w');

      % plot the angular dependence
      figure; hold all
      plot(data(:,1)*180/pi, data(:,2));
   end
   
   if (all ==1) || (sub_symbkg == 1)
      sas(i).im = imcorr_symbkgsub(sas(i).im, [sas(i).X_cen, ...
                          sas(i).Y_cen], 'mask', sas(i).MaskI, ...
                                   'num_points', sas(i).symbkg_numbins, ...
                                   'negfraction', sas(i).symbkg_negfraction);
      
   end
   
   if ((all == 1) || (iq_get == 1))
      sasimg_globalvar(sas(i), 'set');
      sas(i).iq = integrater(sas(i).im);
      if (sas(i).autosaveiq)
         sasimg_run(sas(i), 'iq_save');
      end
   end
   
   if ((all == 1) || (iq_save == 1))
      sas(i) = sasimg_run(sas(i), 'mask_save');
      iqgetx_saveiq(sas(i), [sas(i).prefix '.iq']);
   end
   
end


function siqgetx = iqgetx_batch_imageplate(siqgetx, varargin)

% only needed for slice integrate plot
global MaskI X_cen Y_cen Spec_to_Phos

verbose = 1;
plotslice_isa = 1;
showpeak_isa = 1;
saveeps_isa = 0;
saveiq_isa = 0;
istart = 1;
iend = length(siqgetx.names);
parse_varargin(varargin);

for i=istart:iend
%   siqgetx.(siqgetx.names{i}).autoalign_isa =1;
   if (siqgetx.(siqgetx.names{i}).autoalign_isa == 1)
      
   end
   [iq, siqgetx.(siqgetx.names{i})] = ...
       iqgetx_getiq_imageplate(siqgetx.(siqgetx.names{i}));
end

% 2) save data and visualize
hfigure = figure_size(figure, 'king'); clf;
subplot(2,1,1); cla; hold all; iqlabel;
subplot(2,1,2); cla; hold all; iqlabel; 
lege1 = {}; lege2 = {};
for i=istart:iend
   if (saveiq_isa == 1)
      datafile = ['iqdata/' siqgetx.names{i} '.iq']; 
      saveascii(siqgetx.(siqgetx.names{i}).iq, datafile);
      showinfo(['Save I(Q) data to file: ' datafile]);
   end

   refdata = siqgetx.(siqgetx.names{istart}).iq;
   % the final I(Q)s
   figure(hfigure);   subplot(2,1,1); 
   data = siqgetx.(siqgetx.names{i}).iq;
   [data, scalefactor] = match(data(:,[1,2]), refdata(:,[1,2]), [0.4,0.8]);
   xyplot(data);
   if (showpeak_isa == 1)
      showpeak(data, 2*pi/siqgetx.(siqgetx.names{i}).dspacing.*[0.95, ...
                          1.05], '%5.3g');
   end
   lege1 = {lege1{:} [siqgetx.(siqgetx.names{i}).title num2str(scalefactor, ...
                                                     '(x%4.2f)')]};

   figure(hfigure); subplot(2,1,2);
   data = siqgetx.(siqgetx.names{i}).iq;
   if (siqgetx.(siqgetx.names{i}).normalize == 0)
      refdata(:,2) = refdata(:,2)./refdata(:,3);
      data(:,2) = data(:,2)./data(:,3);
   else
      refdata(:,2) = refdata(:,2).*refdata(:,3);
      data(:,2) = data(:,2).*data(:,3);
   end
   [data, scalefactor] = match(data(:,[1,2]), refdata(:,[1,2]), [0.4,0.8]);
   xyplot(data);
   if (showpeak_isa == 1)
      showpeak(data, 2*pi/siqgetx.(siqgetx.names{i}).dspacing.*[0.95, ...
                          1.05], '%5.3g');
   end
   lege2 = {lege2{:} [siqgetx.(siqgetx.names{i}).title num2str(scalefactor, ...
                                                     '(x%4.2f)')]};

   if (plotslice_isa ~= 1) || isempty(siqgetx.(siqgetx.names{i}).im)
      
      continue
   end
   
   % plot the slice_integrate result
   numplots_slice = [2,3];
   if (mod(i, numplots_slice(1)*numplots_slice(2)) == 1)
      figure; haxes = axes_create(numplots_slice(1), numplots_slice(2), ...
                                  'xmargin', 0, 'ymargin', 0);
   end
   iplot = mod(i, numplots_slice(1)*numplots_slice(2));
   if (iplot == 0);
      iplot = numplots_slice(1)*numplots_slice(2);
   end
   axes(haxes(iplot)); hold all
   title(siqgetx.(siqgetx.names{i}).title);
   if ~isempty(siqgetx.(siqgetx.names{i}).im)
      if total(abs(size(siqgetx.(siqgetx.names{i}).im)-size(MaskI))) ~= 0 
         MaskI = uint8(ones(size(siqgetx.(siqgetx.names{i}).im)));
      end
      X_cen = siqgetx.(siqgetx.names{i}).X_cen;
      Y_cen = siqgetx.(siqgetx.names{i}).Y_cen;
      Spec_to_Phos = siqgetx.(siqgetx.names{i}).Spec_to_Phos;
      dummy = slice_integrate(siqgetx.(siqgetx.names{i}).im, 7, ...
                              siqgetx.(siqgetx.names{i}).dspacing, ...
                              'do_plot', 'normalize', ...
                              siqgetx.(siqgetx.names{i}).normalize);
   end
   legend off; 
   if (saveeps_isa == 1) && (mod(i, numplots_slice(1)*numplots_slice(2)) == 0)
      saveps(gcf, [siqgetx.(siqgetx.names{i}).prefix '_slice.eps']);
   end
end

figure(hfigure); subplot(2,1,1); legend(lege1{:}); legend boxoff;
subplot(2,1,2); legend(lege2{:}); legend boxoff;
if (saveeps_isa == 1)
   saveps(gcf, ['iqgetx.eps']);
end

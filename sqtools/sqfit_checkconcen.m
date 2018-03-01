function sqfit = sqfit_checkconcen(sqfit, varargin);
%        sqfit = sqfit_checkconcen(sqfit, varargin);
% --- Purpose:
%    Try different ways of normalizing data mostly to see whether concentration is correct. 
%
%
% --- Parameter(s):
%    sqfit   -- an array of structure (see sqfit_init.m for detail)
%    fitopts -- fitting options. The fitted parameter is order as
%               the following: scale, z_m, I, sigma, n
%    varargin  -- see parase_varargin.m for input
%                 formats. 
%                 Supported inputs are: 'match_range', 'set_concen'
%
% --- Return(s):
%        sqfit - the same as input with updated results
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sqfit_checkconcen.m,v 1.2 2011-04-27 18:05:26 xqiu Exp $
%

verbose =1;
match_range = [0.08,0.14];
plot_isa =1;
set_concen = 0;
xlimit = [0, inf];
ylimit = [0, inf];
parse_varargin(varargin)

% "sam_concen" is the measured concentration stored in msa.n
if ~exist('sam_concen', 'var')
   for i=1:length(sqfit)
      [dummy, name, ext] = fileparts(sqfit(i).fname);
      sam_concen.(name) = sqfit(i).msa.n;
      data_names{i} = name;
   end
end
sam_names = fieldnames(sam_concen);

% "data_name"default data name is also from "sqfit.fname"
if ~exist('data_names', 'var')
   for i=1:length(sqfit)
      [dummy, name, ext] = fileparts(sqfit(i).fname);
      data_names{i} = name;
   end
end

if (plot_isa == 1); clf; hold all; end
for i=1:length(sam_names)
   idata = strmatch(sam_names{i}, data_names, 'EXACT');
   if isempty(idata)
      idata = strmatch([sam_names{i} '_'], data_names);
      if ~isempty(idata)
         showinfo(['data name for sample: ' sam_names{i} ' --> ' ...
                   data_names{idata}]);
         idata = idata(1);
      else
         showinfo(['no data entry found for sample: ' sam_names{i} '!'], 'warning');
         continue
      end
   end
         
   iq = sqfit(idata).iq_raw;
   iq(:,2) = iq(:,2) - sqfit(idata).offset_iq;
   switch sqfit(idata).ff_use
      case 1
         ff = sqfit(idata).ff_sol;
      case 2
         ff = sqfit(idata).ff_vac;
      case 3
         ff = sqfit(idata).ff_exp;
      case 4
         ff = sqfit(idata).ff_inp;
      otherwise
         ff = [1,1];
   end

   % concentration determined by data (in arbitrary unit)
   [dummy, data_concen.(sam_names{i})] = match(iq, ff, match_range);
   data_concen.(sam_names{i}) = 1/data_concen.(sam_names{i});
   if (plot_isa == 1)
      subplot(2,2,1); hold all
      plot(iq(:,1), iq(:,2));
      subplot(2,2,2); hold all
      plot(iq(:,1), iq(:,2)/data_concen.(sam_names{i}));
      subplot(2,2,3); hold all
      plot(iq(:,1), iq(:,2)/sam_concen.(sam_names{i}));
   end
end

% fit the two concentrations to get the scale factor
common_names = fieldnames(data_concen);
for i=1:length(common_names)
   sam_value(i) = getfield(sam_concen, common_names{i});
   data_value(i) = getfield(data_concen, common_names{i});
end
scale_factor = total((data_value.*sam_value))/total(data_value.^2);

if (set_concen == 1) % will set the concentration according to the
                     % X-ray intensities by multiplying the scale factor
   for i=1:length(sqfit)
      iq = sqfit(i).iq_raw;
      iq(:,2) = iq(:,2) - sqfit(i).offset_iq;
      switch sqfit(i).ff_use
         case 1
            ff = sqfit(i).ff_sol;
         case 2
            ff = sqfit(i).ff_vac;
         case 3
            ff = sqfit(i).ff_exp;
         case 4
            ff = sqfit(i).ff_inp;
         otherwise
            ff = [1,1];
      end
      
      [dummy, new_concen] = match(iq, ff, match_range);
      new_concen = new_concen*scale_factor;
      showinfo(['concentration for <' sqfit(i).fname '> changed ' ...
                'from ' num2str(sqfit(i).msa.n, '%0.3f') ' to ' ...
                num2str(new_concen, '%0.3f')]);
      sqfit(i).msa.n = new_concen;
   end
end


if (plot_isa == 1)
   subplot(2,2,1);  title('raw data'); iqlabel; legend(common_names, 'Interpreter', 'None'); ...
       xlim(xlimit); ylim(ylimit); legend boxoff
   subplot(2,2,2);  title(['normalized by form ' 'factor']); iqlabel; ...
       legend(common_names, 'Interpreter', 'None'); xlim(xlimit); ylim(ylimit); legend boxoff
   subplot(2,2,3);  title(['normalized by ' 'concentration']); iqlabel; ...
       legend(common_names, 'Interpreter', 'None'); xlim(xlimit); ylim(ylimit); legend boxoff
   subplot(2,2,4);  title('normalization factors'); xlabel('sample ID'), ...
       ylabel('concentration (mM)')
   hold all
   plot(sam_value, 's');
   plot(data_value*scale_factor, 'o');
   legend('measured concentration', ['relative intensity*' ...
                       num2str(scale_factor, '%0.4e')])
   set(gca, 'XTick', 1:length(common_names), 'XTickLabel', common_names);
   %   xticklabel_rotate(1:length(common_names), 90, common_names);
   legend boxoff
end
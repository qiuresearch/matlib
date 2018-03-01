function [samdata, bufdata] = iqcorr_sambuf(xydata, varargin)
% --- Usage:
%        [samdata, bufdata] = iqcorr_sambuf(xydata, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        xydata  - either a structure with .data or an matrix of [Q,
%        IQ1, IQ2, IQ3]
%        varargin - 'psv', 'match_range', 'water_peak' 'offset',
%                   'savename' 'plotdata', 'newfig'
% 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iqcorr_sambuf.m,v 1.7 2016/10/26 15:21:56 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

refdata = [];
match_range = [];
water_peak = [];
offset = [];
savename = 'noname';
istep = 3;
psv = 0.73;
niter = 5;
plotdata = 1;
newfig = 1;
do_saveps = 1;
xmax = 0;
parse_varargin(varargin);

% 1) initilize some variables and sort the data
num_sams = length(xydata);
samconcens = reshape([xydata.concentration], 1, num_sams);
[samconcens, isort] = sort(samconcens, 2, 'descend');
datascales = samconcens;
xydata = xydata(isort);
maxconcen = samconcens(1);

% if not normalized by the transmitted beam, xydata should be
% normalized alternatively, e.g., by the water peak

if ~isempty(water_peak)
   for i=1:length(xydata)
      imin = locate(xydata(i).data(:,1), water_peak(1));
      imax = locate(xydata(i).data(:,1), water_peak(2));
      peakarea = total(abs(xydata(i).data(imin:end-1,2)-xydata(i).data(imin+1:end,2)));
      xydata(i).data(:,2:end) = xydata(i).data(:,2:end)/peakarea;
   end
end

% 2) prepare for iterating the fits
samseries = xydata; % store the sample contribution in each xydata
for i=1:length(samseries); 
   samseries(i).title = [samseries(i).title ' sam only'];
end
bufdata = xydata(1);
bufdata.title = [bufdata.title ' buf only'];
bufdata.concentration = 0;

% 3) do the fit and iterate if "match_range" if set
if ~isempty(match_range)
   [samseries.match] = deal(1);
   [samseries.match_scale] = deal(1);
   [samseries.match_offset] = deal(0);
   [samseries.match_range] = deal(match_range);
   if ~isempty(offset);
      [samseries.match_offset] = deal(offset);
   end
else
   niter = 1;
end

for i=1:niter
   % use the data scales instead of samconcens
   samconcens = datascales;

   % construct the matrixes and then solve the linear least square
   % the basis is that:
   % I(Q,c) = Ibuf(Q)*(1-psv*c/1000) + c*Isam(Q)
   % to conform to our solver: y=b+a*x, we need to have
   % I(Q,c)/(1-psv*c/1000) = Ibuf(Q) + c/(1-psv*c/1000)*Isam(Q)
   
   x_j1 = reshape(samconcens./(1-psv*samconcens/1000), numel(samconcens), 1);
   for k=1:length(xydata)
      y_ij(:,k) = xydata(k).data(:,2)/(1-psv*samconcens(k)/1000);
      dy_ij(:,k) = xydata(k).data(:,4)/(1-psv*samconcens(k)/1000);

      % if normalized by the water peak, scale with buffer volume pecentage
      if ~isempty(water_peak)
         y_ij(:,k) = y_ij(:,k)*(1-psv*samconcens(k)/1000);
         dy_ij(:,k) = dy_ij(:,k)*(1-psv*samconcens(k)/1000);
      end
   end
   
   % the code below can/should be modular
   
   inv_dy2_ij = 1./dy_ij.^2;
   inv_dy2_i1 = sum(inv_dy2_ij,2);
   inv_dy2_x_i1 = inv_dy2_ij*x_j1;
   inv_dy2_x2_i1 = inv_dy2_ij*(x_j1.^2);
   
   a_i1 = ((y_ij.*inv_dy2_ij*x_j1).*inv_dy2_i1 - ...
           inv_dy2_x_i1.*sum(y_ij.*inv_dy2_ij,2))./ ...
          (inv_dy2_x2_i1.*inv_dy2_i1 -inv_dy2_x_i1.^2);
   
   da_i1 = sqrt(((dy_ij.*inv_dy2_ij*x_j1).*inv_dy2_i1).^2 + ...
                (inv_dy2_x_i1.*sum(dy_ij.*inv_dy2_ij,2)).^2)./ ...
           (inv_dy2_x2_i1.*inv_dy2_i1 -inv_dy2_x_i1.^2);
   
   b_i1 = ((y_ij.*inv_dy2_ij*x_j1)-inv_dy2_x2_i1.*a_i1)./inv_dy2_x_i1;
   
   db_i1 = (dy_ij.*inv_dy2_ij*x_j1)./inv_dy2_x_i1;
   
   
   % 4) process the result and rematch the data  
   bufdata.data(:,2) = b_i1;
   bufdata.data(:,4) = db_i1;
   
   for k=1:length(samseries);
      if ~isempty(water_peak)
         samseries(k).data(:,2) = (xydata(k).data(:,2)-bufdata.data(:,2))*(1-psv*samconcens(k)/1000);
      else
         samseries(k).data(:,2) = xydata(k).data(:,2)-bufdata.data(:,2)*(1-psv*samconcens(k)/1000);
      end
      samseries(k).rawdata = samseries(k).data;
   end
   if ~isempty(refdata)
      [samseries.match_data] = deal(refdata);
   elseif (niter > 1)
      [samseries.match_data] = deal(samseries(1).data);
      showinfo('No refdata passed, use the most concentrated sample');
   end
   samseries = xypro_dataprep(samseries, 'readdata', 0);
   datascales = [samseries.scale_match];
   datascales = min(datascales)./datascales*maxconcen;
   showinfo(['samconcens/datascales: ' num2str(samconcens./datascales)]);
end


% 5) save data
samdata = samseries(1);
samdata.concentration = 0;
samdata.data(:,2) = a_i1;
samdata.data(:,4) = da_i1;
samdata.title = [savename ' sam_sambuf']; 
savedata = samdata;
if xmax; savedata.xmax = xmax; end;
savedata.data = savedata.data(savedata.data(:,1)<savedata.xmax,:);
specdata_savefile(savedata, [savedata.datadir savename '_sambuf.iq']);
bufdata.title = [savename ' buf_sambuf']; 
specdata_savefile(savedata, [savedata.datadir savename '_sambuf_buf.iq']);

% 5) plot result
if (plotdata == 1)
   if (newfig == 1)
      figure_size(figure, 'king'); hold all;
   end
   
   xypro_plot([xydata, bufdata, samdata], 'plotopt', struct('istep', istep, 'markersize', ...
                                                     5, 'errorbar', 0));
   
   for i=1:length(xydata);
      if ~isempty(water_peak)
         hplot=plot(samdata.data(:,1), samdata.data(:,2)* ...
                    samconcens(i)/(1-psv*samconcens(i)/1000)+ ...
                    bufdata.data(:,2));
      else
         hplot=plot(samdata.data(:,1), samdata.data(:,2)*samconcens(i)+ ...
                    bufdata.data(:,2)*(1-psv*samconcens(i)/1000));
      end
      legend_add(hplot, ['fit - ' xydata(i).title num2str(samconcens(i), ...
                                                        '(c=%0.2f)')]);
   end
 
   xylabel('iq');
   title('I(Q) sambuf correction');
   set(gca, 'XScale', 'Log', 'YScale', 'Log');
   legend('Location', 'SouthWest'); legend boxoff
   %autolimit('loglog');
   axis tight;
   %ylimit = get(gca, 'YLIM');
   % ylim([ylimit(1)*1.23, ylimit(2)*1.23]);
   
	if do_saveps;saveps(gcf, [savename '_sambuf.eps']);end;
end
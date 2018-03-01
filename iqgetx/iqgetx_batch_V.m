function sData = iqgetx_batch_V(hfunction, sData, index, varargin)
% --- Usage:
%        sData = getiq_batch_run(hfunction, sData, index, varargin)
%
% --- Purpose:
%        use mostly for synchrotron data analysis to batch process
%        raw image to get iq.
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iqgetx_batch_V.m,v 1.26 2016/10/26 15:21:56 xqiu Exp $
%
do_processimg = evalin('caller', 'do_processimg;');
do_plotimg = evalin('caller', 'do_plotimg;');
do_plotimg_range = evalin('caller', 'do_plotimg_range;');
do_plotimg_clim = evalin('caller', 'do_plotimg_clim;');
do_plotimg_print = evalin('caller', 'do_plotimg_print;');
do_plotimg_save = evalin('caller', 'do_plotimg_save;');
do_plotV = evalin('caller', 'do_plotV;');
do_plotV_save = evalin('caller', 'do_plotV_save;');
do_plotV_hide = evalin('caller', 'do_plotV_hide;');
do_saveiq = evalin('caller', 'do_saveiq;');
if evalin('caller', 'exist(''do_saveiq_sambuf'',''var'')')
    do_saveiq_sambuf = evalin('caller', 'do_saveiq_sambuf;');
else
    do_saveiq_sambuf = 0;
end
do_savegnomiq = evalin('caller', 'do_savegnomiq;');
is_logx = evalin('caller', 'is_logx');
is_logy = evalin('caller', 'is_logy');
pause_time = evalin('caller', 'pause_time;');
match_range = evalin('caller', 'match_range;');

parse_varargin(varargin);

if ~exist('index', 'var') || isempty(index)
   index=1:length(sData.names);
end

% process the data
for i=index
   
   disp(['Processing data #' num2str(i) '/' num2str(length(sData.names)) ...
         ': ' sData.names{i} ' - ' sData.(sData.names{i}).title]);
   
   if (do_processimg == 1)
      if (do_plotimg == 1); 
         keep_im(i) = sData.(sData.names{i}).keep_im;
         sData.(sData.names{i}).keep_im = 1;
      end
      [~, sData.(sData.names{i})] = hfunction(sData.(sData.names{i}));
   end

   if (do_plotV == 1)
      hf = iqgetx_plotV(sData.(sData.names{i}), 'newfigure', 1, ...
                        'ylog', is_logy, 'xlog', is_logx, ...
                        'match_range', match_range, 'hidden', do_plotV_hide);
      if (do_plotV_save == 1);
         if ~exist('iqplot', 'dir'); mkdir('iqplot'); end
         savefigps(hf, ['iqplot/', sData.names{i} '_plotV']);
      end
   end
   
   if (do_saveiq == 1)
      if ~exist('iqdata', 'dir'); mkdir('iqdata'); end
      datafile =  ['iqdata/' sData.names{i} '.iq'];
      iqgetx_saveiq(sData.(sData.names{i}), datafile);
      showinfo(['Saving I(Q) data into ' datafile]);

      if ~exist('csvdata', 'dir'); mkdir('csvdata'); end
      csvfile =  ['csvdata/' sData.names{i} '.csv'];
      csvwrite(csvfile, sData.(sData.names{i}).iq);
   end

   if (do_saveiq_sambuf == 1)
      if ~exist('iqdata', 'dir'); mkdir('iqdata'); end
      data = sData.(sData.names{i});

      % pull out the sam and buf data
      sam_iq = data.sam.iq;
      buf_iq = data.buf.iq;
      data = rmfield(data, {'sam'});
      data = rmfield(data, {'buf'});

      % save the sam data
      samfile =  ['iqdata/' sData.names{i} '.sam'];
      data.iq = sam_iq;
      iqgetx_saveiq(data, samfile);

      % save the buf data
      buffile =  ['iqdata/' sData.names{i} '.buf'];
      data.iq = buf_iq;
      iqgetx_saveiq(data, buffile);
      showinfo(['Saving sample and buffer I(Q) data into ' samfile ' and ' buffile]);
   end
   
   if (do_savegnomiq == 1)
      if ~exist('iqdata', 'dir'); mkdir('iqdata'); end
      gnom_savedata(sData.(sData.names{i}).iq(:,[1,2,4]), ['iqdata/' ...
                          sData.names{i} '.gdat'], 'err', 0.08, ...
                    'header', sData.(sData.names{i}).title);
   end

   if (pause_time < 0)
      input('Press any key to continue ...')
   else
      pause(pause_time)
   end
      
end

% plot each image (currently taken from sam.im)
if (do_plotimg == 1)
   global MaskD
   ia = 7;
   for i=1:length(index)

      if (ia > 6) ; % create a new figure
         figure_size(figure, 'king');
         figure_format('smallprint');
         haxes=axes_create(2,3,'xmargin',0.02, 'ymargin',0.05);
         imgsavefile = sData.names{index(i)};
         ia = 1;
      end
      axes(haxes(ia)); ia = ia +1;
      
      sam =sData.(sData.names{index(i)}).sam; 
      im = sam.im.*double(MaskD);
      if ~isempty(do_plotimg_range)
         im = im(do_plotimg_range(1):do_plotimg_range(2), ...
              do_plotimg_range(3):do_plotimg_range(4));
      end
      
      if isempty(do_plotimg_clim)
         imagesc(log(im));
         %plotimg_clim = [min(im(:)), max(im(:))];
      else
         imagesc(im, do_plotimg_clim);
      end
      
      % plot the aniso_circ rings if applicable
      if (sam.aniso_calc == 1) && ~isempty(sam.aniso_circ)
         plot(sam.aniso_circ(:,1)-do_plotimg_range(1), ...
              sam.aniso_circ(:,2)-do_plotimg_range(3), '--w');
      end
      
      title(sData.names{index(i)}, 'Interpreter', 'None', 'FontSize', 12);
      axis equal; axis tight;
      if (do_plotimg_save == 1) && ( (ia == 7) || (i == length(index)));
         if (ia<=6); delete(haxes(ia:6)); end
         if ~exist('imgdata', 'dir'); mkdir('imgdata'); end
         savepng(gcf, ['imgdata/', imgsavefile '.png']);
      end
      if (do_plotimg_print == 1); print -despc2; end

      % remove .im if not originally set?
      if (do_processimg == 1) && (keep_im(i) == 0)
         % not implemented yet
      end
   end

   
end

% plot the series if more than one data is processed
if (length(index) > 0)
   for i=index
      siq(i) = sData.(sData.names{i});
   end
   [hf, ha] = iqgetx_plotVs(siq, 'newfigure', 1, 'ylog', is_logy, 'xlog', ...
                      is_logx, 'iqonly', 1, 'match_range', match_range);
end

% plot the anisotropic results
if isfield(sData.(sData.names{index(1)}).sam, 'aniso_calc') && ...
       (sData.(sData.names{index(1)}).sam.aniso_calc == 1)
   figure_size(figure, 'king');
   figure_format('smallprint');
   haxes=axes_create(2,2,'xmargin',0.05, 'ymargin',0.05);

   for i=1:length(index)
      sam =sData.(sData.names{index(i)}).sam; 

      axes(haxes(1)); hold all
      hline = xyplot(sam.iq);
      xyplot(sam.aniso_ibkg, 'k--s', 'Color', get(hline, 'Color'));
      
      axes(haxes(2)); hold all;
      xyplot(sam.aniso_prof);

      axes(haxes(3)); hold all;
      xyplot(match(sam.aniso_prof, [1,1],[0,pi]));

      axes(haxes(4)); hold all;
      plot(i, sam.aniso_orderparam, 's');
      
   end
   axes(haxes(1)); xylabel('iq'); xlim([sam.aniso_qmin, sam.aniso_qmax]); 
   axes(haxes(2)); xylabel('iphi'); ylim([0, Inf]); 
   title('Azimuthal profile');
   axes(haxes(3)); xylabel('iphi'); ylim([0, Inf]); 
   title('Scaled azimuthal profile');
   axes(haxes(4)); xlabel('sample #'), ylabel('order parameter');
   
   if (do_plotimg_save == 1); 
      savepng(gcf, ['imgdata/', sData.names{index(1)} '_aniso.png']);
   end
end

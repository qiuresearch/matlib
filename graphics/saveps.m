function ok = saveps(hf, psfile)
% --- Usage:
%        ok = saveps(hf, psfile)
% --- Purpose:
%        save figure "hf" to ps file "psfile"
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: saveps.m,v 1.8 2016/10/26 15:21:56 xqiu Exp $
%

if (nargin < 1)
   help saveps
   return
end

%
if ischar(hf)
  hf = evalin('caller',  hf);
end

if strcmpi(get(hf(1), 'Type'), 'axes')
   f_tmp = figure('visible', 'off');
   hf = copyobj(hf, f_tmp);
   hf = f_tmp;
   legend show; legend boxoff
end

% convert all char(197) angstrom to char(320) before exporting
htext = findall(hf, 'Type', 'text');
for i=1:length(htext)
   textstring = get(htext(i), 'String');
   if ~isempty(textstring)
      [num_rows, num_cols] = size(textstring);
      for k = 1:num_rows
         textstring(k,:) = strrep(textstring(k,:), char(197), char(321));
      end
      set(htext(i), 'String', textstring);
   end
end

% set all axes tickmode to "manual"
haxes = get(hf, 'Children');
for i=1:length(haxes)
    if ~strcmpi(get(haxes(i), 'type'), 'axes'); continue; end
    haxes_xtickmode{i} = get(haxes(i), 'XTickMode');
    haxes_ytickmode{i} = get(haxes(i), 'YTickMode');
    set(haxes(i), 'XTickMode', 'Manual', 'YTickMode', 'Manual');
end

% print (note, sometimes, "ps2epsi" is needed for MS powerpoint)
print(hf, '-depsc2', '-noui', psfile);
disp(sprintf('Saving figure into EPS file: %s', psfile))
%if unix(['convert -density 230x230 ' psfile ' ' psfile '.png'])
%    disp(sprintf('Converted EPS to PNG: %s', [psfile '.png']))
%end

% change back tickmode
for i=1:length(haxes)
    if ~strcmpi(get(haxes(i), 'type'), 'axes'); continue; end
    set(haxes(i), 'XTickMode', haxes_xtickmode{i}, 'YTickMode', haxes_ytickmode{i});
end

% change back char(320) to char(197)
for i=1:length(htext)
   textstring = get(htext(i), 'String');
   if ~isempty(textstring)
      [num_rows, num_cols] = size(textstring);
      for k = 1:num_rows
         textstring(k,:) = strrep(textstring(k,:), char(320), char(197));
      end
      set(htext(i), 'String', textstring);
   end
end

if exist('f_tmp');
   close(f_tmp)
end
ok = 1;
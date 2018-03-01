function iq = iqpro_mergedata(loQ, hiQ, varargin)
% --- Usage:
%        iq = iqpro_mergedata(loQ, hiQ, varargin)
%
% --- Purpose:
%        merge overlapping data sets spanning two different x
%        values 
%
% --- Parameter(s):
%        data1 - a 2D array (ie. iq data)
%        data2 - a 2D array (ie. iq data)
%        name  - the name/descriptor for the data set
%
%
% --- Return(s): 
%        iq_mergeData - a 2D array (ie. iq data)
%
% --- Example(s):
%
% $Id: iqpro_mergedata.m,v 1.2 2013/09/02 00:11:31 xqiu Exp $
%

verbose = 1;
datadir = '';
ext = '.iq';
datanames = {'loQ', 'hiQ'};
savename = 'sas';
match_range = [];
offset = 0;
scale = 1;
hidden = 0;
do_savegnomiq =1;
do_saveiq = 1;
do_plotimg =1;
logx_isa = 1; logy_isa = 1;
do_saveimg = 1;

parse_varargin(varargin);

if ischar(loQ) % if file names are passed.
   loQ = specdata_readfile([datadir loQ]);
   hiQ = specdata_readfile([datadir hiQ]);
elseif isnumeric(loQ) % if data are passed
   loQ = xypro_init(loQ);
   hiQ = xypro_init(higQ);
end
if isstruct(loQ) && isfield(loQ, 'title');
   datanames = {loQ.title, hiQ.title};
end

if loQ.data(end,1)>hiQ.data(end,1)
   showinfo('low Q data has larger Qmax than high Q data!');
end

% find the match range and initilize the 
loQ.imin = locate(loQ.data(:,1),match_range(1));
hiQ.imin = locate(hiQ.data(:,1),match_range(1));
loQ.imax = locate(loQ.data(:,1),match_range(2));
hiQ.imax = locate(hiQ.data(:,1),match_range(2));

hiQ.rawdata = hiQ.data;
[hiQ.data, scale, offset] = match(hiQ.data, loQ.data, match_range, 'scale', scale, 'offset', offset);

% transition between the data
merge.loQ = loQ.data(loQ.imin:loQ.imax,1:4);
merge.hiQ = merge.loQ;
merge.hiQ(:,2) = interp1(hiQ.data(hiQ.imin:hiQ.imax,1), ...
                         hiQ.data(hiQ.imin:hiQ.imax,2), ...
                         loQ.data(loQ.imin:loQ.imax,1), 'spline');
merge.X = merge.loQ(:,1);
z2o = (merge.X-merge.X(1))/(merge.X(end)-merge.X(1));
o2z = (merge.X-merge.X(end))/(merge.X(1)-merge.X(end));
merge.loQ(:,[2,4]) = merge.loQ(:,[2,4]) .* [o2z,o2z];
merge.hiQ(:,[2,4]) = merge.hiQ(:,[2,4]) .* [z2o,z2o];
iq = merge.loQ;
iq(:,2) = merge.hiQ(:,2) + merge.loQ(:,2);
iq(:,4) = sqrt(merge.hiQ(:,4).^2 + merge.loQ(:,4).^2);

iq = [loQ.data(1:loQ.imin-1,1:4);iq;hiQ.data(hiQ.imax+ 1:end,1:4)];

% save results
if do_savegnomiq || do_saveiq
    if ~exist(datadir, 'dir') && ~1==mkdir(datadir)
       fprintf('ERROR creating folder iqmerged!!!');
    end
    
    if do_savegnomiq
        gnom_savedata(iq(:,[1,2,4]), [datadir savename ...
                            '.gdat'], 'err', 0.08, 'header', ...
                      ['Mergedata of ' datanames{:}]);
    end
    
    if do_saveiq
       datafile = [datadir savename ext];
       saveascii(iq, datafile);
       showinfo(['Saving I(Q) data into ' datafile]);
    end
end

% plot the result
if do_plotimg
    figure; figure_format('tinyprint');

    subplot(2,2,1); hold all;
    xyplot(loQ.data); xyplot(hiQ.rawdata); xyplot(hiQ.data);
    if logx_isa; logx; end;
    if logy_isa; logy; end;
    autolimit('loglog');
    legend({datanames{:} [datanames{2} num2str([scale, offset], ...
                                               'x%0.2f+%0.2g')]}, ...
           'Location', 'SouthWest');
    legend boxoff;
    xyplot(loQ.data([loQ.imin,loQ.imax],:), 'ok', 'MarkerSize', 5);
    xylabel('iq');
    title(['(a) raw and matched input data' ...
           num2str(match_range, '[%0.3f,%0.3f]')]);
    
    subplot(2,2,2); hold all;
    xyplot(loQ.data(1:loQ.imax,:),'x');
    xyplot(hiQ.data(hiQ.imin:end,:),'o');
    %s    errorbar(allQ.data(:,1),allQ.data(:,2),allQ.data(:,4),'r');
    plot(iq(:,1),iq(:,2),'r');
    legend('low Q data', 'hi Q data', 'merged data'); legend boxoff;
    if logx_isa; logx; end;
    if logy_isa; logy; end;
    autolimit('loglog');
    title('(b) merged data')
    xylabel('iq');
    
    subplot(2,2,3); hold all;
    xyplot(kratky(loQ.data(1:end,:))); xyplot(kratky(hiQ.data)); xyplot(kratky(iq));
    xyplot(kratky(iq([loQ.imin,loQ.imax],:)), 'ok', 'MarkerSize', 5);
    autolimit('kratky');
    legend({datanames{:}, 'merged data'}, 'Location', 'NorthEast');
    legend boxoff;
    xylabel('kratky');
    title('(c) Kratky plot');

    subplot(2,2,4); hold all;
    xyplot(kratky(loQ.data(1:end,:))); xyplot(kratky(hiQ.data)); xyplot(kratky(iq));
    xyplot(kratky(iq([loQ.imin,loQ.imax],:)), 'ok', 'MarkerSize', 5);
    autolimit('kratky');
    xlim(match_range + (match_range(2)-match_range(1))*[-1.5,1.5]);
    xylabel('kratky');
    title('(d) Kratky plot zoom-in');
    
    if (do_saveimg == 1)
       saveps(gcf, [savename '.eps']);
    end
end


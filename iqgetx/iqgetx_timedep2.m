function ok = iqgetx_timedep2(sIqgetx, varargin)

verbose = 1;
linewidth = 0.6;
fontsize = 12;
x0=0.09;
y0=0.72;
xmargin = 0.07;
ymargin = 0.10;
width = 0.4;
height = 0.19;
maxnum_curves = 8;

concen = 0;
xlimit = [];
xlimit_zoomin = [];
ylimit = [];
parse_varargin(varargin);

% automatic xlimit
if isempty(xlimit)
   imin = find(sIqgetx(1).iq(:,2) ~= 0);
   imax = imin(end);
   imin = imin(1);
   xrange = sIqgetx(1).iq(imax,1) - sIqgetx(1).iq(imin,1);
   xlimit(1)=max(0,sIqgetx(1).iq(imin,1)-xrange*0.05);
   xlimit(2)=sIqgetx(1).iq(imax,1)+xrange*0.05;
end
if isempty(xlimit_zoomin)
   imin = find(sIqgetx(1).iq(:,2) ~= 0);
   imax = imin(end);
   imin = imin(1);
   imax = imin+fix((imax-imin)/6);
   xrange = sIqgetx(1).iq(imax,1) - sIqgetx(1).iq(imin,1);
   xlimit_zoomin(1)=max(0,sIqgetx(1).iq(imin,1)-xrange*xmargin);
   xlimit_zoomin(2)=sIqgetx(1).iq(imax,1);
end

clf;
set(gcf, 'PaperPosition', [0.25,1,8,9],'DefaultAxesFontName', 'Times', ...
         'DefaultAxesFONTSIZE', fontsize, 'DefaultAxesLineWidth', ...
         linewidth, 'DefaultLineLineWidth', linewidth);

for i=1:min(6,length(sIqgetx))
   axes('Position', [x0+(width+xmargin)*mod(i+1,2), y0-(height+ ...
                                                     ymargin)*fix((i-1)/2), ...
                     width, height])
   cla, hold all, set(gca, 'box', 'on');
   
   lege = {};
   if (concen(min(i,end)) == 0)
      title(sIqgetx(i).title, 'Interpreter', 'None');
   else
      title([sIqgetx(i).title ', ' num2str(concen(min(i,end))) 'mM DNA' ], ...
             'Interpreter', 'None');
   end
   
   if (length(sIqgetx(i).samimgs) > maxnum_curves)
      index = fix(linspace(1,length(sIqgetx(i).samimgs),maxnum_curves));
   else
      index = 1:length(sIqgetx(i).samimgs);
   end

   for j=index
      plot(sIqgetx(i).samimgs(j).iq(:,1), sIqgetx(i).samimgs(j).iq(:,2))
      lege = {lege{:}, num2str(sIqgetx(i).samimgs(j).num)};
   end
   legend(lege, 'Location', 'SouthWest'); legend boxoff
   iqlabel; xlim(xlimit); 
   if isempty(ylimit)
      ylim([0, max(sIqgetx(i).iq(:,2))*1.1]);
   else
      ylim(ylimit)
   end
   
   if (mod(i+1,2) ~= 0); ylabel([]); end
   
   % 
   axes('Position', [x0+(width+xmargin)*mod(i+1,2)+width/2, y0-(height+ ...
                                                     ymargin)*fix((i-1)/2) ...
                     + height*2/5, width/2, height*3/5])

   cla, hold all, set(gca, 'box', 'on');
   for j=index
      plot(sIqgetx(i).samimgs(j).iq(:,1), sIqgetx(i).samimgs(j).iq(:,2))
   end
   axis tight;   xlim(xlimit_zoomin);
   imin = locate(sIqgetx(i).iq(:,1), xlimit_zoomin(1));
   if (sIqgetx(i).iq(imin,2) == 0)
      inozero = find(sIqgetx(i).iq(imin:end,2) ~=0);
      imin = imin + inozero(1) -1;
   end
   imax = locate(sIqgetx(i).iq(:,1), xlimit_zoomin(2));
   ymin = min(sIqgetx(i).iq(imin:imax,2));
   ymax = max(sIqgetx(i).iq(imin:imax,2));
   delta = ymax-ymin;
   ylim([ymin, (ymax+delta*0.2)]);
end

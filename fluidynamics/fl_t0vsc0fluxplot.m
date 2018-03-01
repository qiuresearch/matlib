function h = fl_t0vsc0fluxplot(data, varargin)
% 

% 1) set default parameter values 
irows = [1,2,3]; % flux ratio, c0, t0
ylog=0;
num_labels=12;
width_channel = 5e-5;
parse_varargin(varargin);

% 2) arrange data for contour plot
x=unique(data(:,irows(1)));
y=unique(data(:,irows(2)));
num_xs = length(x);
num_ys = length(y);

z=reshape(data(:,irows(3)),num_ys, num_xs);
[l,h]=contourf(x,y,z, num_labels);
clabel(l,h);
if (ylog == 1)
   logdata = log(z);
   labeldata = exp(linspace(min(logdata(:)), max(logdata(:)), num_labels));
   set(h,'LevelList', labeldata)
end
colorbar
shading flat
xlabel('Flow ratio: inlet/side');
ylabel('Threshold Concentration')
if exist('ylimit')
   ylim(ylimit)
end
if exist('xlimit')
   xlim(xlimit)
end


% 3) add the jet width axis
oaxis = gca;
odummy = copyobj(gca, gcf);
odummy = oaxis;
delete(get(odummy, 'Children'));
set(odummy, 'XAxisLocation', 'Top', 'YTick', 0);
ylabel(odummy, []);
xtick = get(odummy, 'XTick');
for i=1:length(xtick)
   xticklabel{i} = num2str(ratio_flux2width(xtick(i))*width_channel*1e6, ...
                           '%4.2f');
end
set(odummy, 'XTickLabel', xticklabel);
xlabel(odummy, 'Full jet width')

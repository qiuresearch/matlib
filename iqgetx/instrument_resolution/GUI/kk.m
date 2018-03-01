function kk()
  f = creatInterface();
    function f = creatInterface()
f.window = figure('Position', 200*ones(1,4));
left = uiextras.HBox('Parent',f.window);
s = struct();
s.cb = uicontrol('Parent',left,'String','cal');
s.cbb = uicontrol('Parent',left,'String','cal2');
s.text = uicontrol('Parent', left, 'String' , ' ', 'style', 'text');
s.ed = uicontrol( 'Parent', left, 'style', 'edit', 'String', ' ');
s.axe = axes('Parent', left);
s.r1 = 1;
a.r1 = 100; 
a.r2 =-20000000;
b =90000;
set(s.cb,'callback', {@k,a,b});
set(s.cbb,'callback', {@show,s});

    end
        function [] = show(varargin)
            I = varargin{3};
            symbol = str2num(get(I.ed, 'String'))*10^10;
            set(I.text, 'String', num2str(symbol));
            
        end
function [] = k(varargin)
    p = varargin{3};
    q = varargin{4};
    
x = 1:0.1:2;
y = ones(1,length(x));
for i = 1:length(x);
    y(i) = p.r2*x(i)+q;
end
plot(x,y)
end
    end

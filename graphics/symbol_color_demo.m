n_colors = length(colororder);
n_symbols = length(symbolorder);
% j = 11;
x=1:n_colors;
y=ones(n_colors);
figure;
hold on;

symbol_index = linspace(1, n_symbols, n_symbols);
symbol_index = repmat(symbol_index, 1, round(n_colors/n_symbols) + 1);
color_index = linspace(1, n_colors, n_colors);
color_index = repmat(color_index, 1, round(n_symbols/n_colors) + 1);

for i = 1:max(n_colors, n_symbols)
    y(:,i)=i;
    s = symbolorder{symbol_index(i)};
    c = colororder(color_index(i),:);
    plot(x, y(:,i), 'Marker', s, 'color', c,'linewidth', 0.5)
end
axis tight
legend(num2str(colororder))
name = 'matlab_symbol_color';
savepng(gcf, sprintf('%s.png', name));
saveps(gcf, sprintf('%s.eps', name));
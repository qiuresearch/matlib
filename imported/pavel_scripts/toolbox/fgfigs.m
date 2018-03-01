function fgfigs
% FGFIGS   bring all figures to foregroung
for f = fliplr( get(0, 'Children')' )
    figure(f)
end

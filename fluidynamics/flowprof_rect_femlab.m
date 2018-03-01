function flowprof = flowprof_rect_femlab(y, z, width, height, eta, v_avg)

% Just a intermediate step to call routine: flowprof_rect(). The
% problem was that FEMLAB doesn't reports a syntax error when passing
% strings as the argument

flowprof = flowprof_rect(y, z, 'a', width(1), 'b', height(1), 'mu', eta(1), ...
                         'v_avg', v_avg(1), 'M', width(1)*3e6, 'N', ...
                         height(1)*3e6, 'method', 2);

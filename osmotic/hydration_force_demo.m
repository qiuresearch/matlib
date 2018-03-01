function pressure = hydration_force_demo(magnitude, corrlength)

verbose = 1;

d = linspace(0.001, 60, 200);

repulsion = magnitude(1)./sinh(d/2/corrlength).^2;
clf; hold all; set(gca, 'YScale', 'Log');
plot(d, repulsion);

attraction = magnitude(min(2,length(magnitude)))./cosh(d/2/corrlength).^2;
plot(d, attraction);

pressure = repulsion-attraction;

plot(d, pressure);

legend('Repulsion', 'Attraction', 'Total');
legend boxoff

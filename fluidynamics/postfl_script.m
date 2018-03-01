
if ~exist('postfl') 
   postfl = postfl_init(fem);
end
if isempty(postfl.fem) 
   postfl.fem = fem;
end

postfl.num_points = [201,1001];
postfl.p1 = [-2e-4, 0.0];
postfl.p2 = [-2e-4, 2.5e-5];
postfl.p3 = [ 7e-4, 2.5e-5];
postfl.c0 = 0.3;

postfl = postfl_extract(postfl)



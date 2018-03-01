function [q, int, err] = superintegrater(img,map)
for i=1:size(img,3)
    [q, int(:,i), err(:,i)] = super_integrater(img(:,:,i),map);
end
end

function [q, int, err] = super_integrater(img,map)
%     map.nidx = nidx;
%     map.idxmat = idxmat;
%     map.q = q;
%     map.energy = energy;
%     map.spectophos = spectophos;
%     map.xcen = xcen;
%     map.ycen = ycen;
%     map.mask = mask;

q = map.q;
int = accumarray((map.idxmat(:)+1),img(:),[length(q)+1,1]);
int = int(2:end)./map.nidx;
intsq = accumarray((map.idxmat(:)+1),img(:).^2,[length(q)+1,1]);
err = sqrt((intsq(2:end)./map.nidx - int.^2)./map.nidx);
end
function map = generate_map(xcen,ycen,mask,energy,spectophos,qmin,qmax,npts)
    [ximsize,yimsize]=size(mask);
    xmat=repmat((1:ximsize)',1,yimsize);
    ymat=repmat((1:yimsize),ximsize,1);
    rmat_decimal = sqrt((xmat-xcen).^2+(ymat-ycen).^2);
    if nargin == 5
        qmat_decimal = pixeltoq(rmat_decimal,energy,spectophos);
        rmax = floor(max(rmat_decimal(logical(mask))));
        rmin = ceil(min(rmat_decimal(logical(mask))));
        q1 = pixeltoq([rmin,rmax],energy,spectophos);
        q = linspace(q1(1),q1(2),rmax-rmin+1)';
        dq = q(2)-q(1);
        map.energy = energy;
        map.spectophos = spectophos;
    elseif nargin==8
        qmat_decimal = pixeltoq(rmat_decimal,energy,spectophos);
        q=linspace(qmin,qmax,npts)';
        dq = q(2)-q(1);
        map.energy = energy;
        map.spectophos = spectophos;
    elseif nargin==3
        qmat_decimal = rmat_decimal;
        q = 0:round(max(rmat_decimal(:)));
        q = q';
        dq = 1;
    end
    idxmat = zeros(ximsize,yimsize);
    for i=1:ximsize
        for j=1:yimsize
            [dist,idxmat(i,j)] = min(abs(q-qmat_decimal(i,j)));
            if (dist >= (dq/2)) || (mask(i,j)==0)
                idxmat(i,j) = 0;
            end
        end
    end
    nidx=accumarray((idxmat(:)+1),1,[length(q)+1,1]); nidx = nidx(2:end);
    %imk = accumarray((idxmat(:)+1),idxmat(:),[length(q)+1,1]);imk = imk(2:end);
    %figure(2);plot(q,imk./nidx);
    map.nidx = nidx;
    map.idxmat = idxmat;
    map.xcen = xcen;
    map.ycen = ycen;
    map.mask = mask;
    map.q = q;
end

function q = pixeltoq(r,energy,spectophos)
s = spectophos;
lambda = 12.39842/energy;
q = (4*pi/lambda)*sin (0.5 * atan(r / s));
end
function [Hon,Hoff]=shind(N, which)
%SHIND     shows or hides indexes text on DIFR plots
%          SHIND(N, WHICH) applies to DIFR plot number N
%          SHIND(WHICH) applies to all DIFR plot in current axis
%          WHICH can be one of following:
%          'necc'   shows only first 4 necessary indexes
%          'near'   shows nearest indexes
%          'all'    shows all indexes
%          'none'   hides all indexes
%          [Hon,Hoff]=SHIND(N, WHICH) only returns handles of
%          indexes to be shown and hidden 
           
% 1997 by Pavol

if nargin==0
	N=gdn;
	which='near';
elseif nargin==1
	if isstr(N)
		which=N;
		N=gdn;
	else
		which='necc';
	end
end
hon=[]; hoff=[];
if length(N)>1
   for i=1:length(N)
      [h1,h2]=shind(N(i), which);
      hon=[hon; h1];
      hoff=[hoff; h2];
   end
else
   h=hdifr(N, 'text'); h0=[];
   if strcmp(which, 'none')
      hon=[]; hoff=h;
   elseif strcmp(which, 'all')
      hon=h; hoff=[];
   else
      j=hdifr(N, 'plot');
      for i=1:length(j)
         if get(j(i),'LineStyle')=='-'             %ignore if rings plot
            return;
         end
      end
      x=[]; y=[]; ind=[];
      for i=1:length(h)
         pos=get(h(i), 'Position');
         x=[x; pos(1)];
         y=[y; pos(2)];
	 ind=[ind; get(h(i),'UserData')];
      end
      Rind=sqrt((sum((ind.^2)'))');
      [Rind,i]=sort(Rind); 
      x=x(i); y=y(i); h=h(i); ind=ind(i,:);
      i=find(Rind==0);
      if length(i)>0
	 h0=h(i);
         hon=[hon; h0];
         x(i)=[]; y(i)=[]; Rind(i)=[]; h(i)=[]; ind(i,:)=[];
      end
      k=[1; 1+find(diff(Rind)>eps); length(Rind)+1];
      j=find(k>=min(6,max(k))); j=j(1);
      len=k(j)-1;
      hon=[hon; h(1:len)]; 
      hoff=[hoff; h(len+1:length(h))];
      x=x(1:len); y=y(1:len); 
      ind=ind(1:len,:); h=h(1:len); Rind=Rind(1:len);
      if strcmp(which, 'near')                     %it is OK if near
      elseif strcmp(which, 'necc')
         fi=atan2(y, x);
         i=find(abs(Rind-Rind(1))<eps);
         fimin=fi(i);
	 i=find(fimin>-eps); fimin=min(fimin(i));
	 [fi,i]=sort(fi);
	 h=h(i);
         ok=(fi>=fimin & fi<pi);
         i=find(ok); j=find(~ok);
	 j=[j;i(4:length(i))]; i=i(1:3);
	 hon=[h0; h(i)]; hoff=[hoff; h(j)];
      else fprintf(2, 'Unknown option %s\nIgnoring...\n', which);
         hon=[];
         hoff=[];
         return;
      end      
   end
end
if nargout>0
   Hon=hon;
   Hoff=hoff;
else
   set(hon, 'visible', 'on');
   set(hoff, 'visible', 'off');
end

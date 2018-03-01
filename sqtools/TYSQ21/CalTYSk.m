function [calSk,rootCounter,calr,calGr,errorCode,cVar]=CalTYSk(Z1,Z2,K1,K2,volF,Q,choice)
%[calSk,rootCounter,calr,calGr,errorCode, cVar]=CalTYSk(Z1,Z2,K1,K2,volF,Q,choice)
%
%The hardcore is automatically taken to be one  !!!!!!!
%
%When the number of input arguments are 6, cVar = 0;
%When the number of input arguments are 7:
%
%Returned values
%   if choice ==1, cVar is coefficient
%               a00=coe(1);
%               b00=coe(2);
%               v1=coe(3);
%               v2=coe(4);
%               a=coe(5);
%               b=coe(6);
%               c1=coe(7);
%               d1=coe(8);
%               c2=coe(9);
%               d2=coe(10);
%
%calSk: calculated structure factor
%calr: spatial distance variable, r,  for pair distribution function g(r)
%calGr: pair distribution function g(r)

if nargin == 6
    choice = 0;
    cVar = 0;
elseif nargin < 6
    fprintf('too less input argument');
    return
end

if max(Q) < 700
    fprintf('Maximum Q is too small,  potential error when checking g(r)\n');
    fprintf('Please increase the maximum Q at leat to 700\n');
    calSk=zeros(size(Q));
    rootCounter=-1;
    calr=0;
    calGr=1;
    errorCode=-1;
    cVar=0;
    return
end

if max(Q)/length(Q) >0.05
    fprintf('Please make the interval of neighbouring Q smaller\n');
    fprintf('max(Q)/length(Q) >0.05\n');
    calSk=zeros(size(Q));
    rootCounter=-1;
    calr=0;
    calGr=1;
    errorCode=-1;
    cVar=0;    
    return
end

%if  Q(1)==0
%    fprintf('Q can not be equal to zero\n');
%    rootCounter=-1;
%    calr=0;
%    calGr=1;
%    errorCode=-1;
%    cVar=0;    
%    return
%end

global z
global k
global phi

global Ecoefficient
global d1Factor
global d2Factor

global debugFlag

d1Factor =1;
d2Factor =1;

z(1)=Z1;
z(2)=Z2;
k(1)=K1*exp(z(1));
k(2)=K2*exp(z(2));
phi=volF;


%Calculate the coefficients of two equations for d1 and d2
CalCoeff;

%Calculate the root for d1 and d2
[Rd1,Rd2]=CalRealRoot;
Rd1 = Rd1 *d1Factor;
Rd2 = Rd2 *d2Factor;

%initialize errorCode and rootCounter
errorCode=0;
rootCounter = 0;
goodRoot = 0;

for i=1:length(Rd2);

    for j=1:2
      
        %Check if there is NaN root
        if isnan(Rd1(j,i)) | Rd2(i) ==0
    
        %haha=1
            continue
        end;
        
        %based on the solution of d1 and d2, calcualte other coefficients in Blum's method
        coe= CxCoef(Rd1(j,i),Rd2(i));

        %Assign the calculated result to different variable
        a00=coe(1)*1;
        b00=coe(2)*1;
        v1=coe(3)*1;
        v2=coe(4)*1;
        a=coe(5);
        b=coe(6);
        c1=coe(7);
        d1=coe(8);
        c2=coe(9);
        d2=coe(10);
    
        kk=Q;
        r=(0.001:0.01:10);
 
        %Calculate C(k) and C(r)
        eCk=Ck(a00,b00,v1,v2,kk);
        [rC,eCr]=Cr(a00,b00,v1,v2,r);
        
        %Calculate h(k) and S(k)
        ehk=hk(kk,eCk);
        eSk = Sk(kk,ehk);

        %Calculate h(r) and g(r) from h(k)
%        tehk=zeros(1,length(ehk)*2-1);
%        tkk=zeros(size(tehk));
%        index=(length(ehk):1:length(ehk)*2-1);
%        tehk(index)=ehk;
%        tkk(index)=kk;
%        index=(1:length(ehk));
%        tehk(index)=fliplr(ehk);
%        tkk(index)=fliplr(-1*kk);
        [rh,hc_r] = TInvFourier(kk,4*pi*ehk.*kk,0.8);
%        index=(2:length(rh));
%        rh=rh(index);
%        hc_r=hc_r(index);
        h_r=-imag(hc_r)./rh/4/pi/pi;
        g_r=h_r+1;
            
                
        if debugFlag 
       
            figure

            %Plot C(r)
            subplot(3,1,1);
            plot(rC,-eCr,'g*-');
            index = find ( r>1 );
            
            tempMin = min(-eCr(index));
            tempMax = max(-eCr(index));
            maxPos = r(find(-eCr==tempMax));
            axis([r(index(1)),4,min(-eCr(index)),max([1,tempMax])]);
                grid on;
            text(0.5*4,0.4*(tempMax-tempMin)+tempMin,['Maximum value = ',num2str(tempMax), ' Position=',num2str(maxPos)]);
            xlabel('r/\sigma');
            ylabel('-c(r)');
            title(['\phi=',num2str(phi),'; ','z(1)=',num2str(z(1)),'; z(2)=',num2str(z(2)),'; K(1)=',num2str(k(1)*exp(-z(1))),'; K(2)=',num2str(k(2)*exp(-z(2)))]);
    
            %Plot S(k)
            subplot(3,1,2);
            plot(kk,eSk,'bo-');
            xlabel('k\sigma');
            ylabel('S(k)');
            title(['\phi=',num2str(phi),'; ','z(1)=',num2str(z(1)),'; z(2)=',num2str(z(2)),'; K(1)=',num2str(k(1)*exp(-z(1))),'; K(2)=',num2str(k(2)*exp(-z(2)))]);
            axis([0,5*pi,0,max(eSk)]);
            grid on;
            
            %Plot g(r)
            subplot(3,1,3);
            plot(rh,g_r,'bo-');
            axis([0,8,-inf,inf]);
            xlabel('r/\sigma');
            ylabel('g(r)');     
            title(['Root: (',num2str(i),', ',num2str(j),')']);
            grid on;
        end
        
        %Throw away the results, which are obviously wrong
        if testGr(rh,g_r)==1
            continue
        end
 
        rootCounter = rootCounter + 1;
        
        %If debug allowed, display the root information in the figure.
        if debugFlag, title(['Root:',num2str(i),'  rootCounter=',num2str(rootCounter)]),end;
               

        if v1*k(1) >= 0 & v2*k(2) >= 0 & a>0            
            goodRoot = goodRoot+1;
            goodRootPos(goodRoot) = rootCounter;
            if debugFlag, title(['Root:',num2str(i),'  rootCounter=',num2str(rootCounter),' goodRoot=',num2str(goodRoot)]),end;
        end
        

        calCoeArray(rootCounter,:) = coe;
        calrArray(rootCounter,:) = rh;
        calGrArray(rootCounter,:) = g_r;
        calSkArray(rootCounter,:) = eSk;
        
       
    end
end


%NO good roots and reasonable solution
if rootCounter == 0
    errorCode=-1;
    calr = 0;
    calGr = 0;
    calSk = zeros(size(Q));
    if choice == 1, cVar = zeros(1,10), end;
    return;
end

%There is some result which may be resonable
%There is more than one good solution, only one of them is sent back
if goodRoot > 1
    
    errorCode = goodRoot;
    position = findSGr(calrArray,calGrArray,goodRootPos);
    %position = goodRootPos(1);
    calr = calrArray(position,:);
    calGr = calGrArray(position,:);
    calSk = calSkArray(position,:);
    if choice == 1 
        cVar = calCoeArray(position,:);
    end
    testGr(calr,calGr,1);
    if debugFlag, fprintf(['\n rootCounter= ',num2str(position),' is returned']),end;
    return
end

% There is only one good result
if goodRoot == 1
    errorCode = 1;
    position = goodRootPos(1);
    calr = calrArray(position,:);
    calGr = calGrArray(position,:);
    calSk = calSkArray(position,:);
%    fprintf('Warning, only one good root, check g(r) to ensure the correctness');
    disp('Warning, only one good root, check g(r) to ensure the correctness')
%    if choice == 1 
%        cVar = calCoeArray(position,:);
%    end    
%    testGr(calr,calGr,1);
%    if debugFlag, fprintf(['\n rootCounter= ',num2str(position),' is returned']),end;
    return;
end

%Sorry, no good result, but some of them can be sent back to be checked
if goodRoot == 0
    errorCode =0;
    %position = 1;
    position = findSGr(calrArray,calGrArray);    
    calr = calrArray(position,:);
    calGr = calGrArray(position,:);
    calSk = calSkArray(position,:);
    %fprintf('Warning, No good root, check g(r) to ensure the correctness');
    disp('Warning, No good root, check g(r) to ensure the correctness')
%    if choice == 1
%        cVar = calCoeArray(position,:);
%    end    
%    testGr(calr,calGr,1);
%    if debugFlag, fprintf(['\n rootCounter= ',num2str(position),' is returned']),end;    
    return;
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function position = findSGr(calrArray,calGrArray,positionArray)

if nargin == 2
    
    position = 1;
    sumHardcore = 1000;
    
    for i=1:length(calrArray(:,2))
        index=find(calrArray(i,:)<0.95);
        tempSum = sum(abs(calGrArray(i,(2:length(index)))))/length(calGrArray(i,(2:length(index))));
        if sumHardcore > tempSum 
            sumHardcore = tempSum;
            position = i;
        end
    end
    
    return
elseif nargin == 3
    
    position = 1;
    sumHardcore = 1000;
    signSum = 0;
    
    for i=1:length(positionArray)
        j=positionArray(i);
        %calGrArray(j,(1:5))
        index=find(calrArray(j,:)<0.95);
      
        tempSum = sum(abs(calGrArray(j,(2:length(index)))))/length(calGrArray(j,(2:length(index))));
        if sumHardcore > tempSum             
            sumHardcore = tempSum;
            position = j;
        end
    
    end
    
    if calGrArray(position,2) < 0
        
    end
end

return
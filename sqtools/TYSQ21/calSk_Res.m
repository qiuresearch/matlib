function data=calSk_Res(Q,depth,width,Z2,K2,volF,radius,amp,choice)
%[calSk,rootCounter,calr,calGr,errorCode,coe]=CalTYSk(Z1,Z2,K1,K2,volF,Q,choice)

%
%data=calIk(Q,depth,width,Z2,K2,volF,radius,amp,choice)
%
%if choice == 1
%    K1=(depth-K2);
%    Z1=log(-K1/K2 * exp(Z2*width) ) /width;
%elseif choice == 2
%    K1 = -depth-K2;
%    Z1 = 1/width/2;
%elseif choice == 3
%    K1 = depth - K2;
%    Z1 = log(2)/width;
%else
%    K1=  depth;
%    Z1 = width;
%end

global rescaleFlag;

flag = 1;

if  choice == 1    
    if width < 0 | Z2 < 0
        fprintf('width and Z2 should be positive');
        return
    end
 
    K1=(depth-K2);
    Z1=log(-K1/K2 * exp(Z2*width) ) /width;
elseif choice == 2
    K1 = -depth-K2;
    Z1 = 1/width/2;
elseif choice == 3
    K1 = depth;
    Z1 = log(2)/width;
elseif choice == 4
    K1=depth;
    Z1=2/((1+width)^2-1);
else
    K1=  depth;
    Z1 = width;
end

if Z1 < 0 | Z2 < 0 | radius < 0 
    %fprintf('\n Z2,Z1 > 0');
    dataTemp = 1000*ones(size(Q));
    return
end

numberDensity = volF * 6 / pi / (2*radius).^3;

normQ=(0.0001:0.005:16*10)*2*pi;

counter = 0;
maximumCounter = 10;
while flag
    counter = counter + 1;
    fprintf(['Z1=',num2str(Z1),'; Z2=',num2str(Z2),'; K1=',num2str(K1),'; K2=',num2str(K2),'; Vol=',num2str(volF),'; amp=',num2str(amp),'; radius=',num2str(radius)])
    [calSk,rootCounter,calr,calGr,errorCode]=CalTYSk(Z1,Z2,K1,K2,volF,normQ);
    %[calSk,rootCounter,calr,calGr,errorCode]=CalTYSk(7.8836,1,-7,1,0.3,normQ);

    fprintf(['\n errorCode=',num2str(errorCode)]);

    if errorCode == -1
        fprintf('\n Sorry, no good root');
        dataTemp = 1000*ones(size(Q));
        break;
    end

    index = find(calr >= 1);
    
    %if g(r) >=0 for the first time calculation, no need for rescale, break loop
    if calGr(index(1)) >= 0 & counter == 1
        break
    end
    
    
    %g(1) < 0, rescale needed, check if the program wants to force rescale
    if rescaleFlag ~= 1
        Flag = 0;
        break;
    else
        if volF > 0.6
            fprintf('\n Rescale failed (rescaled volume fraction too large) !!!!!!');
            %Restore the original value of radius
            radius = radius_old(1);
            volF = volF_old(1);
            break
        end
        
        fprintf('\n Rescale enforced');
        
        volF_old(counter) = volF;
        radius_old(counter) = radius;
        if calGr(index(1)) < 0
            status_rescale(counter) = -1;
        else
            status_rescale(counter) = 1;
        end
        
        
        %Now decide what is the radius for the next step
        if counter == 1
            volF = volF + 0.1
        elseif counter >= 2
            if abs(volF_old(counter) - volF_old(counter -1)) < 0.02;
                fprintf('Rescale successfully');
                %Rescale the wave vector
                normQ = normQ * radius / radius_old(1);
                %Restore the original value of radius
                radius = radius_old(1);
                volF = volF_old(1);
                break;
            end
            
            if volF > 0.5;
                volF = (volF + 0.6) /2 ;
            else
                if status_rescale(counter) == -1 & status_rescale(counter-1) == -1
                    volF = volF + 0.1;
                else
                    volF = (volF_old(counter) + volF_old(counter-1))/2;
                end
            end
         end 
         
         %Rescale the fitting parameters
         radius = (volF * 6 / pi / numberDensity)^(1/3) / 2;
         ratio = radius_old (counter) / radius;
         K1 = K1*ratio;
         K2 = K2*ratio;
         Z1 = Z1/ratio;
         Z2 = Z2/ratio;
    end
    
    if counter == maximumCounter, flag =0, end
end

   
return


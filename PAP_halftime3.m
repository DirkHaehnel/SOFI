subseqlength=15; %[s]

horder=4;
[fn,pn]=uigetfile('*.tif','MultiSelect','on');
if ~iscell(fn)
    tmp=cell(1,1);
    tmp{1}=fn;
    fn=tmp;
end

n=1;
while n<=length(fn)
    %stack=[];
    fileinfo = imfinfo([pn fn{n}]);
    Nframes=length(fileinfo);
    stack=zeros(fileinfo(1).Height,fileinfo(1).Width,Nframes);
    
    fig=statusbar('Read stack...');
    for m=1:Nframes
        if n*m==1
            stack=double(imread([pn fn{n}],m,'info',fileinfo));
        else
            stack(:,:,m)=double(imread([pn fn{n}],m,'info',fileinfo));
        end
        fig=statusbar(m/Nframes,fig);
        if isempty(fig)
            break;
        end
    end
    delete(fig);
    
    if (n+1<=length(fn)) && (~isempty(strfind(fn{n+1},'X2.tif')))
        fileinfo = imfinfo([pn fn{n+1}]);
        Nframes=length(fileinfo);
         fig=statusbar('Read stack, part 2...');
        for m=1:Nframes
            stack(:,:,end+1)=double(imread([pn fn{n+1}],m,'info',fileinfo));
            fig=statusbar(m/Nframes,fig);
            if isempty(fig)
                break;
            end
        end
        delete(fig);
        n=n+1;
    end
    n=n+1;
end
% get mean intensity of each frame, plot vs. time
 mtrace=squeeze(mean(mean(stack)));
 figure; plot(mtrace);
 xlabel('Frames');
 ylabel('Brightness, AU')
    
 x=(1:length(mtrace));
 x=x';
 y=mtrace; 

%% masking; find average intensity inside mask (vs. time)
 Stack=mean(stack,3);                       % calculate time-averaged image
 thrhold=median(Stack(:))+std(Stack(:));
 mask = Stack > thrhold;                    % mask=area with intensity > median+std.deviation
 %imagesp(mask); %picture of the mask: doesn't work with my MATLAB version
 Stack=stack;
 Stack=permute(Stack,[3 1 2]);
 Stack=Stack(:,mask);   % Stack is 2d matrix, contains pixels inside mask: 1st coordinate=time, 2nd coordinate=pixel number
 Stack=mean(Stack,2);   % Stack is 1d vector, contains average intensity inside mask: 1st coordinate=time

 %% background subtraction 
 figure;
 line(x,Stack,'Color','green');
 background=(y(:)*size(stack,1)*size(stack,2) - Stack*sum(mask(:)))/(size(stack,1)*size(stack,2)-sum(mask(:))); % mean intensity of pixels outside mask
 plot(x,Stack,'r');
 line(x,background,'Color','green');
 title('signal&background');
 %figure;plot(x,Stack-background,'r');
 %title('signal with subtracted background');
 y=Stack - conv(background,ones(10,1)/10,'same');
 %figure;plot(x,y);
 %title('signal with subtracted background convolved');
 Y=conv(y,ones(10,1)/10,'same');
 figure;plot(x,Y,'r'); 
 title('signal with subtracted background convolved; convolved');
 
%% exponential decay approximation and subtraction
 
% figure; plot(Y);
% model=inline('p(1)*exp(-x/p(2))+p(3)-Y','p','x','Y');
% % x=x(50:end-2000);
% % Y=Y(50:end-2000);
% param=lsqnonlin(model,[mean(mtrace) length(mtrace)/3 mean(mtrace)],[],[],[],x,Y);
% Y1 = model(param,x,0);
% line(x,Y1,'Color','red');
% resid=Y-Y1;
% figure;
% plot(x,resid,'r');
% tr=mean(resid); % crucial
% 
% plot(x,resid,'r',x,resid > tr,'k');
% 
% low=resid < tr;
% Plo=lsqnonlin(model,[mean(mtrace) length(mtrace)/3 mean(mtrace)],[],[],[],x(low),Y(low));
% figure; 
% plot(x,Y,'r',x,model(Plo,x,0),'k');
% Phi=lsqnonlin(model,[mean(mtrace) length(mtrace)/3 mean(mtrace)],[],[],[],x(~low),Y(~low));
% line(x,model(Phi,x,0));
% 
% figure;
% plot(x,Y-(model(Phi,x,0)+model(Plo,x,0))/2,'r');
% line(x,Y-Y1);
% Y=Y-(model(Phi,x,0)+model(Plo,x,0))/2;

%end of bleaching

%% identify on-off switching events 
 mask1=Y > mean(Y); % mask=1 during on-period, mask=0 during off-period
%   mask1=Y > 170; % maybe manual insertion needed
 % figure;
 % line(x,mask1);
 % title('on-off');
 
 mask1=diff(mask1); % switching between on and off: mask=1 at on-switching, mask=-1 at off-switching 
 figure; 
 plot(mask1);
 title('switching on (+1) or off (-1)');
 on=find(mask1 > 0)
 off=find(mask1 < 0)
 % Make sure there are at least 100 frames between subsequent on-events:
 a=size(on);
 if a(1)~=1
 j=1;
    while j< a(1)-1
     if on(j+1) - on(j)<100 
         z=find(off >= on(j) & off <= on(j+1)); % find the off-entry between the two on-events on(j) and on(j+1)
         off=cat(1,off(1:z-1),off(z+1:end));    % throw entry off(z) out of the off-vector
         
         on(j)= (on(j+1) + on(j))/2;        % make one on-event out of the two on-events
         a(1)=a(1)-1;
         on= cat(1, on(1:j), on(j+2:end));
        
     else    
     j=j+1;  
     end
    end
 end
 % Make sure there are at least 100 frames between subsequent off -events: 
 a=size(off);
 if a(1)~=1
 j=1;
 while j< a(1)-1
     if off(j+1) - off(j)<100
         z=find(on >= off(j) & on <= off(j+1));
         on=cat(1,on(1:z-1),on(z+1:end));
         
         off(j)= (off(j+1) + off(j))/2;
         a(1)=a(1)-1;
         off= cat(1, off(1:j), off(j+2:end));
     else
     j=j+1;
     end
 end
 end
 
% if smth wrong in the beginning of sequence
%        on=on(2:end);
%        off=off(2:end);

 
 %% fit functions for on-switching events (modelOn) and off-switching events (modelOff)
 modelOn=inline('p(1)+p(2)*(1-exp(-max(0,x-p(3))/p(4)))-y','p','x','y');
 modelOff=inline('p(1)+p(2)*exp(-max(0,x-p(3))/p(4))-y','p','x','y');

 Pon=[];    % will store fit parameters p(1),p(2),p(3),p(4) for on-switching events
 Poff=[];   % will store fit parameters p(1),p(2),p(3),p(4) for off-switching events
 
 area1=500;    % each on-switching event is fitted using 2*area1 datapoints
 area2=500;    % each off-switching event is fitted using 2*area2 datapoints
 
 non=size(on,1);    % how many on-switching events in total?
 noff=size(off,1);  % how many off-switching events in total?

 % ACTUAL FITTING OF THE DATA
 if on(1)<off(1)   % first jump is an "on"-jump
    for j=1:non
        dataL=max(1,on(j)-area1);       % left border of data-evaluation area
        dataR=min(Nframes,on(j)+area1); % right border of data-evaluation area
        if j==1
            Pon=cat(1, Pon, lsqnonlin(modelOn,[mean(Y(1:on(j))) mean(Y(on(j):off(j))) on(j) 5],[],[],[],x(dataL:dataR),Y(dataL:dataR)));
        elseif j<=noff
            Pon=cat(1, Pon, lsqnonlin(modelOn,[mean(Y(off(j-1):on(j))) mean(Y(on(j):off(j))) on(j) 5],[],[],[],x(dataL:dataR),Y(dataL:dataR)));
        else
            Pon=cat(1, Pon, lsqnonlin(modelOn,[mean(Y(off(j-1):on(j))) mean(Y(on(j):Nframes)) on(j) 5],[],[],[],x(dataL:dataR),Y(dataL:dataR)));
        end
    end
    for j=1:noff
        dataL=max(1,off(j)-area2);       % left border of data-evaluation area
        dataR=min(Nframes,off(j)+area2); % right border of data-evaluation area
        if j+1<=non
            Poff=cat(1, Poff, lsqnonlin(modelOff,[mean(Y(off(j):on(j+1))) mean(Y(on(j):off(j))) off(j) 5],[],[],[],x(dataL:dataR),Y(dataL:dataR)));
        else
            Poff=cat(1, Poff, lsqnonlin(modelOff,[mean(Y(off(j):Nframes)) mean(Y(on(j):off(j))) off(j) 5],[],[],[],x(dataL:dataR),Y(dataL:dataR)));
        end
    end
 else  % first jump is an "off"-jump
     for j=1:non
         dataL=max(1,on(j)-area1);
         dataR=min(Nframes,on(j)+area1);
         if j+1<=noff
            Pon=cat(1, Pon, lsqnonlin(modelOn,[mean(Y(off(j):on(j))) mean(Y(on(j):off(j+1))) on(j) 10],[],[],[],x(dataL:dataR),Y(dataL:dataR)));
         else
            Pon=cat(1, Pon, lsqnonlin(modelOn,[mean(Y(off(j):on(j))) mean(Y(on(j):Nframes)) on(j) 10],[],[],[],x(on(j)-area1:on(j)+area1),Y(on(j)-area1:on(j)+area1)));
         end
     end
     for j=1:noff
         dataL=max(1,off(j)-area2);
         dataR=min(Nframes,off(j)+area2);
         if j==1
            Poff=cat(1, Poff, lsqnonlin(modelOff,[mean(Y(off(j):on(j))) mean(Y(1:off(j))) off(j) 10],[],[],[],x(dataL:dataR),Y(dataL:dataR)));  
         elseif j<=non
            Poff=cat(1, Poff, lsqnonlin(modelOff,[mean(Y(off(j):on(j))) mean(Y(on(j-1):off(j))) off(j) 10],[],[],[],x(dataL:dataR),Y(dataL:dataR))); 
         else
            Poff=cat(1, Poff, lsqnonlin(modelOff,[mean(Y(off(j):Nframes)) mean(Y(on(j-1):off(j))) off(j) 10],[],[],[],x(dataL:dataR),Y(dataL:dataR))); 
         end
     end
 end
 
 %% Show data & fitted curves
 Pon
 Poff
 figure;
 title('Fit. Curves');
 xlabel('Frames');
 ylabel('Brightness, AU')
 plot(x,Y,'r');
 for j=1:non
    dataL=max(1,on(j)-area1);
    dataR=min(Nframes,on(j)+area1);
    line(x(dataL:dataR),modelOn(Pon(j,:),x(dataL:dataR),0));
 end
 for j=1:noff
    dataL=max(1,off(j)-area2);
    dataR=min(Nframes,off(j)+area2);
    line(x(dataL:dataR),modelOff(Poff(j,:),x(dataL:dataR),0),'color', 'black');
 end
 

 %% ignore last off-switching if it might be corrupt (-> deviates more than factor 1.5 from mean of rest)
 if mean(Poff(1:end-1,4))> 1.5*Poff(end,4); % time constant too big
     timeOff=mean(Poff(1:end-1,4)); 
 elseif 1.5*mean(Poff(1:end-1,4))<Poff(end,4); % time constant too small
     timeOff=mean(Poff(1:end-1,4));
 else timeOff=mean(Poff(:,4));
 end 
 
%% ignore first on-switching if it is too early (within the first 300 frames, very probably corrupt)
 if Pon(1,3)<300;
     timeOn=mean(Pon(2:end,4));
 else timeOn=mean(Pon(:,4));
 end
 
  %% Save characteristics of the fit
 Onstd=std(Pon(:,4));
 Offstd=std(Poff(:,4));
 lowerlevel=mean(Pon(:,1));
 upperlevel=mean(Poff(:,1));
 if non == 1
     Onstd=NaN;
 end
 if noff == 1
     Offstd=NaN;
 end
 %% 1/e --*0.693--> 1/2 , *2.5 (frame time in ms)
 taurise=timeOn*1.7325
 taufall=timeOff*1.7325
 tauon=1/(1/taurise-1/taufall)
 
 %save([pn 'Analysis\'  '/' num2str(fn{n}(1:end-4)) '.mat'],'timeOn','timeOff','Onstd', 'Offstd', 'lowerlevel','upperlevel','mask','mtrace','x','Y', 'on', 'off', 'modelOn', 'modelOff','nbursts', 'Pon', 'Poff');

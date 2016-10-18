 timeOn=mean(Pon(2:end,4)); % first rise might be corrupt
 timeOff=mean(Poff(1:end-1,4)); % last fall might be corrupt
 
 taurise=timeOn*1.7325
 taufall=timeOff*1.7325
 tauon=1/(1/taurise-1/taufall)
 
 
 timeOn=(Pon(2,4)+Pon(3,4)+Poff(4,4))/3
 timeOff=(Poff(1,4)+Poff(2,4)+Poff(3,4))/3
 
 taurise=timeOn*1.7325
 taufall=timeOff*1.7325
 tauon=1/(1/taurise-1/taufall)
 
 
 
 
%% ignore last off-switching if it is corrupt (-> deviates more than factor 2 from mean of rest)
 
 if mean(Poff(1:end-1,4))> 1.5*Poff(end,4); % time constant too small
     timeOff=mean(Poff(1:end-1,4)); 
 elseif 1.5*mean(Poff(1:end-1,4))<Poff(end,4); % time constant too big
     timeOff=mean(Poff(1:end-1,4));
 else timeOff=mean(Poff(:,4));
 end 
 
 if mean(Pon(1:end-1,4))> 1.5*Pon(end,4); % time constant too small
     timeOn=mean(Pon(1:end-1,4));
 elseif 1.5*mean(Pon(1:end-1,4))<Pon(end,4); % time constant too big
     timeOn=mean(Pon(1:end-1,4));
 else timeOn=mean(Pon(:,4));
 end 
%% ignore first on-switching if it is too early (must be corrupt)
 if Pon(1,3)<100;
     timeOn=mean(Pon(2:end,4));
 else timeOn=mean(Pon(:,4));
 end
 
 %% only use specific switches to calculate tau
 timeOn=mean(Pon(1:end-1,4))
 timeOff=mean(Poff(2:end,4))
 
 taurise=timeOn*1.7325
 taufall=timeOff*1.7325
 tauon=1/(1/taurise-1/taufall)
 
 %% test
  if mean(A(1:end-1,4))> 1.5*A(end,4); % time constant too small
     timeOn=mean(A(1:end-1,4));
 elseif 1.5*mean(A(1:end-1,4))<A(end,4); % time constant too big
     timeOn=mean(A(1:end-1,4));
 else timeOn=mean(A(:,4));
 end 
 timeOn
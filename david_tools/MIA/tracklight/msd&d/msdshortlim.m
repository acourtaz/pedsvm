function  [Msdout,FullMsdOut] = msdshortlim (Trc,maxCalcMsd, limlag)
% function [Msdout,FullMsdOut] = msdshortlim (Trc,maxCalcMsd,limlag)
% calculate the mean-square displacement from the traces Trc
% maxCalcMsd: nombre max de points pour lesquels le msd est calcul� (prend en compte tous les points de la trajectoire)
% Trc: matrix of particle traces as output from mktrace().
% version original: 8.7.1994 author:  ts version: <01.30> from <941014.0000>
%
% modificado para adaptarlo a trayectorias QD
% limlag: numero max de tlags a considerar
% usado para step analysis en tracking.m v1.2
%
% MR jan/06  
%------------------------------------------------------------

MaxPart = max(Trc(:,1));
Msdout  = [];FullMsdOut=[];

%loop through all particles

for Ipart=1:MaxPart
	iTrc = Trc(find(Trc(:,1)==Ipart),2:4);
   
   if (~isempty(iTrc) & length(iTrc)>2)
		Nlag = size(iTrc,1);   % nombre de points de la trajectoire, (Nlag-1)= nombre d'intervalles, pas forc�ments tous �gaux
		
        % mod para tener un limite max de tlags a considerar
        
        if Nlag>limlag
            Nlag=limlag;
        end
        
        
        Mlag = iTrc(Nlag,1)-iTrc(1,1); % intervalle de temps maximum
	  	H2  = [];
  
  		% MSD from 1 to Nlag-2
		if Nlag>2
        
        disp (['Step # '])

            
        %for lag=1:Nlag-2   
   		for lag=1:min(Nlag-2,maxCalcMsd-1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MSD sur les maxCalcMsd-1 ou Nlag-2 premiers intervalles
	     disp (num2str(lag))
            L = iTrc(1+lag:Nlag,1)-iTrc(1:Nlag-lag,1);
          H = (iTrc(1:Nlag-lag,2:3)-iTrc(1+lag:Nlag,2:3)).^2;
	   	  H = sum(H');
      		for il=1:length(L)
                H1 = zeros(1,Mlag);
                H1(L(il)) = H(il);
      		    H2 = [H2;H1];
            end
		end
		end
      
      %lag = Nlag-1
      if (iTrc(Nlag,1)-iTrc(1,1))<=maxCalcMsd %%%%%%%%%%%%%%%%%%%%%%% ici MSD de l'intervalle maxCalcMsd ou Nlag-1
         H  = (iTrc(1,2:3)-iTrc(Nlag,2:3)).^2;
         H2 = [H2;zeros(1,Mlag-1),sum(H)];
     end
     % H2 contient tous les �carts carr�s : intervalle de temps, 1 image dans la colonne 1, 2 images dans la colonne 2 ...
      
     diff=size(H2,2)-size(FullMsdOut,2);
      if diff>0 
         FullMsdOut=[FullMsdOut,zeros(size(FullMsdOut,1),diff)];
      end
      if diff<0
         H2=[H2,zeros(size(H2,1),-diff)];
      end
      FullMsdOut=[FullMsdOut;H2];
      % FullMsdOut contient toutes les traces
      Lag=[]; Msd=[]; dMsd=[];
	  
      for il=1:min(maxCalcMsd,Mlag)
		 noZ  = find(H2(:,il));
         H1   = H2(noZ,il);
         if length(noZ)>0
            Lag  = [Lag,il];
            Msd  = [Msd,mean(H1)];
            if length(noZ)>1
					dMsd = [dMsd,std(H1)/sqrt(length(noZ))];
		     else
      			dMsd = [dMsd,Msd(length(Msd))];
		     end
         end
      end
      
      %MSD of that trace
      
      %nettoyage des points au del� de maxCalcMsd intervalles (ils ne sont pas calcul�s sur tous les points de la trajectoire)
      
      Lagclean=Lag(:,1:min(length(Lag),maxCalcMsd));
      Msdclean=Msd(:,1:min(length(Lag),maxCalcMsd));
      dMsdclean=dMsd(:,1:min(length(Lag),maxCalcMsd));
      
      Msdout = [Msdout; Ipart*ones(min(length(Lag),maxCalcMsd),1),Lagclean',Msdclean',dMsdclean'];
	end % if ~isempty
end

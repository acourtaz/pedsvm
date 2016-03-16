%Written by Damien Jullié, adapted from poolnorm2, to 120 frames analysis,
%exo at 11


poolcount=[];
pooltrackev=[];
list_files = dir;
normal=[];
access=[];
final=[];
poolred=[];
areaevent=[];
length=[];
pool=[];
finalpers=[];
finaltrans=[];
finalpersr=[];
finaltransr=[];
lowmat=[];
lowmatr=[];

%select files to pool
for i = 1:size(list_files,1)
    f = list_files(i).name;
    isxls = ~isempty(strfind(f,'xls'));
    if isxls
        [type,sheets] = xlsfinfo(f);
     %sort sheets
        for j=1:size(sheets,2)
            isGreen = strfind(sheets{j},'Green');
            isBrowse = strfind(sheets{j},'summary');
            isRed = strfind(sheets{j},'red');
            if ~isempty(isGreen)
                green = j;
                [dataGreen,textGreen] = xlsread(f,sheets{green});

            elseif ~isempty(isBrowse)
                browse = j;
                [dataBrowse,textBrowse] = xlsread(f,sheets{browse});
                
            elseif ~isempty(isRed)
                red = j;
                [dataRed,textRed] = xlsread(f,sheets{red});
                
            end
        end
                m=dataGreen(10:end, 9:end);
                frame=dataBrowse(1:end,2);
                r=dataRed(10:end, 4:end);
           %average for the ten first green events 
            moy=m(:,1);
            M=[];
            final=[];
            for n=2:10
                moy=moy+m(:,n);
            end

            moy=moy/100;
            %normalisation
            max=m(:,11)-moy;

            for q=1:size(m,2)
                c=m(:,q)-moy;
                M=[M,c];
            end

            for p=1:size(M,2)
                d=M(:,p)./max;
                final=[final,d];
            end

            final=final*100;
            
                                  
            
            %normalised average
            somme=[];
            for q=1:size (final,2)
                total=0;
                for n=1:size (final,1)
                    total=total+final(n,q);
                end
            somme=[somme,total];
            end
            moyenne=somme/size (final,1);

            areaevent=sum(dataGreen(10:end,3))/size(dataGreen,1);

            length=sum(dataGreen(10:end,5))/size(dataGreen,1);


            stdmoy=std(final);
            ET=stdmoy./sqrtm(size(final,1));
            
            %normalized red
            
            normred=r/dataRed(2,13);
            poolred=[poolred;normred];
            avred=sum(normred)/size(normred,1);

            %transient/persistent
            
            low=[];
            Persmat=[];
            Transmat=[];
            lowr=[];
            Persmatr=[];
            Transmatr=[];
            AnnotP=[];
            AnnotT=[];
            for j=1:size(final,1)
              lowevent=final(j,11:end)>50;
              [a,classement]=min(lowevent);
              low=cat(2,classement,final(j,:));
              lowr=cat(2,classement,normred(j,:));
              lowmat=cat(1,lowmat,low);
              lowmatr=cat(1,lowmatr,lowr);

                if classement >3
                    Persmat=[Persmat;low];
                    Persmatr=[Persmatr;lowr];
                    AnnotP=[AnnotP;dataBrowse(j,:)];
              
                    %cas ou passe pas sous 50 classement==1
                elseif classement== 1
                    Persmat=[Persmat;low];
                    Persmatr=[Persmatr;lowr];
                    AnnotP=[AnnotP;dataBrowse(j,:)];
                    
                else
                    Transmat=[Transmat;low];
                    Transmatr=[Transmatr;lowr];
                    AnnotT=[AnnotT;dataBrowse(j,:)];
                 end
            end

            Avpers=sum(Persmat(:,2:end),1)/size(Persmat,1);
            stdPers=std(Persmat(:,2:end));
            ETpers=stdPers./sqrtm(size(Persmat,1));
            
            Avtrans=sum(Transmat(:,2:end),1)/size(Transmat,1);
            stdTrans=std(Transmat(:,2:end));
            ETtrans=stdTrans./sqrtm(size(Transmat,1));
            
            persprop=(size(Persmat,1))/(size(Persmat,1)+size(Transmat,1));
            
            finalpers=[finalpers;Persmat];
            finaltrans=[finaltrans;Transmat];
            
            Avpersr=sum(Persmatr(:,2:end),1)/size(Persmatr,1);
            stdPersr=std(Persmatr(:,2:end));
            ETpersr=stdPersr./sqrtm(size(Persmatr,1));
            
            Avtransr=sum(Transmatr(:,2:end),1)/size(Transmatr,1);
            stdTransr=std(Transmatr(:,2:end));
            ETtransr=stdTransr./sqrtm(size(Transmatr,1));
            
            finalpersr=[finalpersr;Persmatr];
            finaltransr=[finaltransr;Transmatr];
            
            
            [fp,pp] = uiputfile([f(1:end-4),'P_annotate.txt'],'Where to put the textfile with Persistents info');
            if ischar(fp)&&ischar(pp)
            dlmwrite([pp,fp],AnnotP,'delimiter','\t');
            end
            
            [ft,pt] = uiputfile([f(1:end-4),'T_annotate.txt'],'Where to put the textfile with Transients info');
            if ischar(ft)&&ischar(pt)
            dlmwrite([pt,ft],AnnotT,'delimiter','\t');
            end
            
            %Exocytosis speed
            cViT=[];
            cViP=[];
            cVi=[];
            for i=11:(size(AnnotT,1)-11)
                ViT=polyfit(AnnotT([i-10:i+10],2),((1:21)'),1);
                ViT=[ViT(1),AnnotT(i,2)];
                cViT=[cViT;ViT];
            end
            
            for i=11:(size(AnnotP,1)-11)
                ViP=polyfit(AnnotP([i-10:i+10],2),((1:21)'),1);
                ViP=[ViP(1),AnnotP(i,2)];
                cViP=[cViP;ViP];
            end
            
            for i=11:(size(frame,1)-11)
                Vi=polyfit(frame([i-10:i+10]),((1:21)'),1);
                Vi=[Vi(1),frame(i)];
                cVi=[cVi;Vi];
            end
            
            %plot normalised average
            figure 
            errorbar(-10:110,moyenne, ET,'-og','MarkerEdgeColor','k')
            xlabel('time')
            ylabel('normalised intensity')
            title(f)
            uiputfile([f(1:end-5),'gav.fig'],'save green trace');
            saveas(gcf,[f(1:end-5),'gav.fig'])
            max=max/dataGreen(2,13);
            final=[max,final];
            final=[frame,final];
            normal=cat(1,normal,num2cell(final));
            access=[access;dataGreen(10:end,1:6)];

            
            %plot cummulative frequency
            frecum=[1:size(frame,1)]';
            normfrecum=[1:size(frame,1)]'/size(frame,1);
            p=polyfit(frame,frecum,1);
            reglin=(p(2)+frame*p(1));
            figure
            plot (frame,frecum,'-g',frame,reglin,'-k');
            title(f)
            uiputfile([f(1:end-5),'reg.fig'],'save cumul freq');
            saveas(gcf,[f(1:end-5),'reg.fig'])

            freq=(60*p(1))/dataGreen(2,13);
            
            poolav=[persprop,areaevent, length,dataGreen(2,13),dataRed(2,13),freq,moyenne,avred];
            poolav=cat(2,f,num2cell(poolav));
            pool=cat(1,pool,poolav);
            
 
            
            
            %construct xls file
            final=num2cell(final);
            refcum=num2cell(frecum);
            final=cat(2,refcum,final);
            final=cat(2,num2cell(dataGreen(10:end,1:6)),final);
            legend=cell(9,size(final,2));
            legend(9,1:9)=textGreen(9,1:9);
            legend(1:7,1:12)=textGreen(1:7,:);
            legend(3,1:7)=num2cell(dataGreen(3,1:7));
            legend(5,10:end)=num2cell(dataGreen(4,9:end));
            legend(1:2,13)=num2cell(dataGreen(1:2,13));
            legend(9,9)={'intensity'};
            final=cat(1,legend,final);
            final(1,10)={'coeff'};
            final(6,10:end)=num2cell(moyenne);
            final(7,10:end)=num2cell(ET);
            final(2,10)=num2cell(p(1));
            final(1,11)={'freq µm²/min'};
            final(2,11)=num2cell(freq);
            normred=num2cell(normred);
            avred=cat(1,num2cell(avred),cell(1,size(avred,2)));
            normred=cat(1,avred,normred);
            normred=cat(1,num2cell(dataGreen(5,9:end)),normred);
            sheetR = [f,' Red'];
            sheetG = [f,' Green'];
            xlswrite('compilation.xlsx', final, sheetG, 'A1')            
            xlswrite('compilation.xlsx', normred, sheetR , 'A1')
            sheetVi = [f,' ExSpeed'];
            legVi={'coeff Tot','frame Tot','coeff T', 'frame T', 'coeff P', 'frame P'};
            xlswrite('compilation.xlsx',legVi , sheetVi,  'A1');
            
            
            xlswrite('compilation.xlsx', cVi , sheetVi, 'A2');
            
            if ~isempty (cViT)
            xlswrite('compilation.xlsx', cViT ,sheetVi, 'C2');
            end
            
            if ~isempty (cViP)
            xlswrite('compilation.xlsx', cViP ,sheetVi, 'E2');
            end
            
            c=0;
            count=[];
            trackcell=[];
            trackev=[];
            tracklist=[];
            tracklist2=[];
            for j=0:dataGreen(3,3)
                for i=10:size(final,1)
                    if final{i,2}==j
                        c=c+1;
                        trackev=cat(2,num2cell(j),final(i,:));
                        tracklist=cat(2,strcat(f),trackev);
                        tracklist2=cat(1,tracklist2,tracklist);
                    end
                end
                trackcell=cat(1,trackcell,tracklist2);
                track=[j,c];
                count=[count;track];
                c=0;
                tracklist=[];
                tracklist2=[];
                trackev=[];
            end
            
            poolcount=[poolcount,count(:,2)];
            pooltrackev=cat(1,pooltrackev,trackcell);
           
       

           
    end 

    
end
poolcount=cat(2,count(:,1),poolcount);




ordtrack=[];
sorttrack=[];
ETtrack=[];
finaltrack=[];
stdmoytrack=[];
moysorttrack=[];

for j=1:dataGreen(3,3)
   for i=1:size(pooltrackev,1)
       if pooltrackev{i,2}==j
            sorttrack=cat(1,sorttrack,pooltrackev(i,:));
       end
   end


         if ~isempty(sorttrack)
         ordtrack=cat(1,sorttrack,cell(1,size(sorttrack,2)));
         sorttrack=cell2mat(sorttrack(:,12:end));
         moysorttrack=sum(sorttrack,1)/size(sorttrack,1);
         stdmoytrack=std(sorttrack);
         ETtrack=stdmoy./sqrtm(size(sorttrack,1));         
         ETtrack=cat(2,{'','','','','','','','','','ecart type',j},num2cell(ETtrack));
         moysorttrack=cat(2,{'','','','','','','','','','moyenne',j},num2cell(moysorttrack));
         ordtrack=cat(1,ordtrack,moysorttrack);
         ordtrack=cat(1,ordtrack,ETtrack);
         ordtrack=cat(1,ordtrack,cell(3,size(ordtrack,2)));
         finaltrack=cat(1,finaltrack,ordtrack);    

       end
     sorttrack=[];
     moysorttrack=[];
     ETtrack=[];
     stdmoytrack=[];
     ordtrack=[];
end

%Construct figures for T/P
%green

if isempty(finalpers)
    Avfinalpers=ones(1,121);
    ETfinalpers=ones(1,121);
else

Avfinalpers=sum(finalpers(:,2:end),1)/size(finalpers,1);
stdfinalpers=std(finalpers(:,2:end));
ETfinalpers=stdfinalpers./sqrtm(size(finalpers,1));
end

if isempty(finaltrans)
    Avfinaltrans=ones(1,121);
    ETfinaltrans=ones(1,121);
else
Avfinaltrans=sum(finaltrans(:,2:end),1)/size(finaltrans,1);
stdfinaltrans=std(finaltrans(:,2:end));
ETfinaltrans=stdfinaltrans./sqrtm(size(finaltrans,1));
end


figure
errorbar(-10:120,Avfinaltrans, ETfinaltrans,'-ob','MarkerEdgeColor','b')
hold on
errorbar(-10:120,Avfinalpers, ETfinalpers,'-oc','MarkerEdgeColor','c')

uiputfile('greenPT.fig','green average PT');
saveas(gcf,'PTgreen.fig')


Avfinalpers=cat(2,'AvPers',num2cell(Avfinalpers));
ETfinalpers=cat(2,'ETpers',num2cell(ETfinalpers));
Avfinaltrans=cat(2,'AvTrans',num2cell(Avfinaltrans));
ETfinaltrans=cat(2,'ETTrans',num2cell(ETfinaltrans));


lowmat=cat(1,Avfinalpers,ETfinalpers,Avfinaltrans,ETfinaltrans,num2cell(lowmat));

%red
if isempty(finalpersr)
    Avfinalpersr=ones(1,121);
    ETfinalpersr=ones(1,121);
else  
Avfinalpersr=sum(finalpersr(:,2:end),1)/size(finalpersr,1);
stdfinalpersr=std(finalpersr(:,2:end));
ETfinalpersr=stdfinalpersr./sqrtm(size(finalpersr,1));
end

if isempty(finaltransr)
    Avfinaltransr=ones(1,121);
    ETfinaltransr=ones(1,121);
else            
Avfinaltransr=sum(finaltransr(:,2:end),1)/size(finaltransr,1);
stdfinaltransr=std(finaltransr(:,2:end));
ETfinaltransr=stdfinaltransr./sqrtm(size(finaltransr,1));
end


figure
errorbar(-10:110,Avfinaltransr, ETfinaltransr,'-ob','MarkerEdgeColor','b')
hold on
errorbar(-10:110,Avfinalpersr, ETfinalpersr,'-oc','MarkerEdgeColor','c')

uiputfile('redPT.fig','red average PT');
saveas(gcf,'PTred.fig')


Avfinalpersr=cat(2,'AvPers',num2cell(Avfinalpersr));
ETfinalpersr=cat(2,'ETpers',num2cell(ETfinalpersr));
Avfinaltransr=cat(2,'AvTrans',num2cell(Avfinaltransr));
ETfinaltransr=cat(2,'ETTrans',num2cell(ETfinaltransr));

lowmatr=cat(1,Avfinalpersr,ETfinalpersr,Avfinaltransr,ETfinaltransr,num2cell(lowmatr));

normal=cat(2,num2cell(access),normal);
moypoolred=sum(poolred)/size(poolred,1);
poolred=num2cell(poolred);
moypoolred=cat(1,num2cell(moypoolred),cell(1,size(moypoolred,2)));
moypoolred=cat(1,num2cell(dataGreen(5,9:end)),moypoolred);
poolred=cat(1,moypoolred,poolred);
legendframe=(-10:1:dataGreen(3,3));
legendpool={'cell','pers prop','area','length','average green','average red','frequency'};
legendpool=cat(2,legendpool,num2cell(legendframe),num2cell(legendframe));
avpool=sum(cell2mat(pool(:,2:end)),1)/size(pool,1);
stdpool=std(cell2mat(pool(:,2:end)),1);
ETpool=stdpool./sqrtm(size(pool,1));
avpool=cat(2,'average',num2cell(avpool));
ETpool=cat(2,'ET',num2cell(ETpool));
pool=cat(1,pool,avpool);
pool=cat(1,pool,ETpool);

pool=cat(1,legendpool,pool);

xlswrite('compilation.xlsx', finaltrack, 'pooltrack', 'B5')
xlswrite('compilation.xlsx', pool, 'analyse', 'P1')
xlswrite('compilation.xlsx', pooltrackev, 'analyse', 'D40')
%xlswrite('compilation.xlsx', poolcount, 'analyse', 'A1')
xlswrite('compilation.xlsx', poolred, 'poolred', 'B5')
xlswrite('compilation.xlsx', lowmat, 'lowmatG', 'B5')
xlswrite('compilation.xlsx', lowmatr, 'lowmatR', 'B5')
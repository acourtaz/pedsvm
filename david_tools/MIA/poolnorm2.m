poolcount=[];
pooltrackev=[];
list_files = dir;
normal=[];
access=[];
final=[];
poolred=[];
%select files to pool
for i = 1:size(list_files,1)
    f = list_files(i).name;
    isdata = ~isempty(strfind(f,'data'));
    isxls = ~isempty(strfind(f,'xls'));
    if isdata && isxls
        [type,sheets] = xlsfinfo(f);
     %sort sheets
        for j=1:size(sheets,2)
            isGreen = strfind(sheets{j},'Green');
            isBrowse = strfind(sheets{j},'browse');
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
                m=dataGreen(9:end, 9:end);
                frame=dataBrowse(1:size(m,1),2);
                r=dataRed(9:end, 4:end);
           %average for the ten first green events 
            moy=m(:,1);
            M=[];
            final=[];
            for n=2:10
                moy=moy+m(:,n);
            end

            moy=moy/10;
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

            stdmoy=std(final);
            ET=stdmoy./sqrtm(size(final,1));
            
            %normalized red
            
            normred=r/dataRed(1,9);
            poolred=[poolred;normred];
            avred=sum(normred)/size(normred,1);
            
            %plot normalised average
            figure 
            errorbar(-10:30,moyenne, ET,'-og','MarkerEdgeColor','k')
            xlabel('frame')
            ylabel('normalised intensity')
            title(f)
            final=[frame,final];
            normal=cat(1,normal,num2cell(final));
            access=[access;dataGreen(9:end,1:6)];
            %uiputfile('*.fig','save green trace');
            
            %plot cummulative frequency
            frecum=[1:size(frame,1)]';
            normfrecum=[1:size(frame,1)]'/size(frame,1);
            p=polyfit(frame,frecum,1);
            reglin=(p(2)+frame*p(1));
            figure
            plot (frame,frecum,'-g',frame,reglin,'-k')
            title(f)
            %uiputfile('*.fig','save cumul freq');
            

            freq=(60*p(1))/dataGreen(1,8);
            
            %construct xls file
            final=num2cell(final);
            refcum=num2cell(frecum);
            final=cat(2,refcum,final);
            final=cat(2,num2cell(dataGreen(9:end,1:6)),final);
            legend=cell(9,size(final,2));
            legend(9,1:8)=textGreen(9,:);
            legend(1:7,1:8)=textGreen(1:7,:);
            legend(3,1:7)=num2cell(dataGreen(2,1:7));
            legend(5,9:end)=num2cell(dataGreen(4,9:end));
            final=cat(1,legend,final);
            final(1,10)={'coeff'};
            final(6,9:end)=num2cell(moyenne);
            final(7,9:end)=num2cell(ET);
            final(2,10)=num2cell(p(1));
            final(1,11)={'freq µm²/min'};
            final(2,11)=num2cell(freq);
            normred=num2cell(normred);
            avred=cat(1,num2cell(avred),cell(1,size(avred,2)));
            normred=cat(1,avred,normred);
            normred=cat(1,num2cell(dataGreen(4,9:end)),normred);
            sheetR = [f,' Red'];
            sheetG = [f,' Green'];
            xlswrite('compilation', final, sheetG, 'A1')            
            xlswrite('compilation', normred, sheetR , 'A1')             
            
            c=0;
            count=[];
            trackcell=[];
            trackev=[];
            tracklist=[];
            tracklist2=[];
            for j=0:dataGreen(2,3)
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

for j=1:dataGreen(2,3)
   for i=1:size(pooltrackev,1)
       if pooltrackev{i,2}==j
            sorttrack=cat(1,sorttrack,pooltrackev(i,:));
       end
   end


         if ~isempty(sorttrack)
         ordtrack=cat(1,sorttrack,cell(1,size(sorttrack,2)));
         sorttrack=cell2mat(sorttrack(:,11:end));
         moysorttrack=sum(sorttrack,1)/size(sorttrack,1);
         stdmoytrack=std(sorttrack);
         ETtrack=stdmoy./sqrtm(size(sorttrack,1));         
         ETtrack=cat(2,{'','','','','','','','','ecart type',j},num2cell(ETtrack));
         moysorttrack=cat(2,{'','','','','','','','','moyenne',j},num2cell(moysorttrack));
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

normal=cat(2,num2cell(access),normal);
moypoolred=sum(poolred)/size(poolred,1);
poolred=num2cell(poolred);
moypoolred=cat(1,num2cell(moypoolred),cell(1,size(moypoolred,2)));
moypoolred=cat(1,num2cell(dataGreen(4,9:end)),moypoolred);
poolred=cat(1,moypoolred,poolred);

xlswrite('compilation', normal, 'poolgreen', 'B5')
xlswrite('compilation', poolcount, 'analyse', 'A1')
xlswrite('compilation', finaltrack, 'pooltrack', 'B5')
xlswrite('compilation', pooltrackev, 'analyse', 'D40')
xlswrite('compilation', poolcount, 'analyse', 'A1')
xlswrite('compilation', poolred, 'poolred', 'B5')

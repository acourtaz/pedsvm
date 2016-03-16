poolcount=[];
pooltrackev={};
list_files = dir;
normal=[];
access=[];

for i = 1:size(list_files,1)
    f = list_files(i).name;
    isdata = ~isempty(strfind(f,'data'));
    isxls = ~isempty(strfind(f,'xls'));
    if isdata && isxls
        [type,sheets] = xlsfinfo(f);
     
        for j=1:size(sheets,2)
            isGreen = strfind(sheets{j},'green');
            isBrowse = strfind(sheets{j},'browse');
            if ~isempty(isGreen)
                green = j;
                [dataGreen,textGreen] = xlsread(f,sheets{green});
                m=dataGreen(8:end, 9:end);
            elseif ~isempty(isBrowse)
                browse = j;
                [dataBrowse,textBrowse] = xlsread(f,sheets{browse});
                frame=dataBrowse(:,2);
            end
        end
            
            
            moy=m(:,1);
            M=[];
            final=[];
            for n=2:10
                moy=moy+m(:,n);
            end

            moy=moy/10;
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
            
            
            figure 
            errorbar(-10:30,moyenne, ET,'-og','MarkerEdgeColor','k')
            xlabel('frame')
            ylabel('normalised intensity')
            title(f)
            final=[frame,final];
            normal=[normal;final];
            access=[access;dataGreen(8:end,1:6)];
            
            
            frecum=[1:size(frame,1)]';
            normfrecum=[1:size(frame,1)]'/size(frame,1);
            p=polyfit(frame,frecum,1);
            reglin=(p(2)+frame*p(1));
            figure
            plot (frame,frecum,'-g',frame,reglin,'-k')
            title(f)
            
            c=0;
            count=[];
            trackcell=[];
            trackev=[];
            tracklist={};
            tracklist2={};
            for j=0:dataGreen(1,3)
                for i=8:size(final,1)
                    if dataGreen(i,2)==j
                        c=c+1;
                        trackev=[j,dataGreen(i,:)];
                        tracklist={f,trackev};
                        tracklist2=[tracklist2;tracklist];
                    end
                end
                trackcell=[trackcell; tracklist2];
                track=[j,c];
                count=[count;track];
                c=0;
                tracklist={};
                tracklist2={};
                trackev=[];
            end
            
            poolcount=[poolcount,count(:,2)];
            pooltrackev=[pooltrackev;trackcell];
                
            xlswrite('compilation', final, f, 'I10')
            xlswrite('compilation', textGreen(9,:), f, 'B9') 
            xlswrite('compilation', dataGreen(8:end,1:6), f, 'B10')            
            xlswrite('compilation', textGreen(1:7,:), f, 'B1')
            xlswrite('compilation', dataGreen(1,1:7), f, 'B3')
            xlswrite('compilation', dataGreen(3,9:end), f, 'J5')
            xlswrite('compilation', textGreen(1,5), f, 'A9')            
            xlswrite('compilation', moyenne, f, 'J6')
            xlswrite('compilation', ET, f, 'J7')
            xlswrite('compilation', frecum, f, 'H10')
            xlswrite('compilation', p(1), f, 'J2')
            

    end 

    
end
poolcount=[count(:,1),poolcount];
pooltrackev1=vertcat(pooltrackev{:,1});
pooltrackev1=cellstr(pooltrackev1);
pooltrackev2=vertcat(pooltrackev{:,2});
pooltrackev2=num2cell(pooltrackev2);
pooltrackev=horzcat(pooltrackev1,pooltrackev2);

finalsort=[];
sorttrack=[];
ETtrack=[];
finalETtrack=[];
stdmoytrack=[];
moysorttrack=[];
%for j=0:dataGreen(1,7)
 %   for i=1:size(pooltrackev2,1)
 %       if pooltrackev2{i,1}==j
  %      sorttrack=[sorttrack;cell2mat(pooltrackev2(i,:))];
  %      end
 %   end
 %   sorttrack=sorttrack(:,10:end);
 %       if ~isempty(sorttrack)
        
  %      moysorttrack=sum(sorttrack)/size(sorttrack,1);
  %      moysorttrack=[j,moysorttrack];
  %      finalsort=[finalsort;moysorttrack];
  %      stdmoytrack=std(sorttrack);
  %      ETtrack=stdmoy./sqrtm(size(sorttrack,1));
   %     ETtrack=[j,ETtrack];
   %     finalETtrack=[finalETtrack;ETtrack];

  %      end
  %  sorttrack=[];
  %  moysorttrack=[];
  %  ETtrack=[];
  %  stdmoytrack=[];
%end

%xlswrite('compilation', finalsort, 'pooltrack', 'D5')
%xlswrite('compilation', finalETtrack, 'pooltrack', 'D30')
xlswrite('compilation', pooltrackev, 'analyse', 'D40')
xlswrite('compilation', normal, 'compil', 'I10')
xlswrite('compilation', textGreen (9,:), 'compil', 'B9') 
xlswrite('compilation', access, 'compil', 'B10')
xlswrite('compilation', dataGreen(3,9:end), 'compil', 'J5')
xlswrite('compilation', poolcount, 'analyse', 'A1')


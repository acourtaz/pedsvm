function updatereport(handles,text,code)
%

if nargin<3
    code=0;
end

posrep=get(handles.report,'value');
if posrep==0
   report{1}= date; posrep=1;
   set(handles.report,'userdata',report);
   set(handles.report,'value',posrep+1);
   posrep=posrep+1;
end

report=get(handles.report,'userdata');

if code==2 | code==3
    report{posrep+1}=[' '];
    posrep=posrep+1;
end

report{posrep+1}=text;

if code==1 | code==3
    posrep=posrep+1;
    report{posrep+1}=[' '];
end

set(handles.report,'userdata',report);
set(handles.report,'value',posrep+1);
    
set(handles.text10,'userdata',report);
set(handles.text10,'value',posrep+1);

%end of file

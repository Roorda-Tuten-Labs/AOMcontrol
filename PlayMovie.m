function PlayMovie()
% PlayMovie()
%

global SYSPARAMS StimParams VideoParams; %#ok<NUSED>
if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end

hAomControl = getappdata(0,'hAomControl');
Mov = getappdata(hAomControl, 'Mov');
setappdata(hAomControl,'handles',handles);

SYSPARAMS.PupilDuration=(Mov.duration*1/30)+etime(clock,[2000 1 1 0 0 0]);                %%cmp
SYSPARAMS.PupilSavingPath=[VideoParams.videofolder,VideoParams.vidprefix,'\']; 

if SYSPARAMS.PupilTCACorrection==1,                                                       %%cmp
    if ~(SYSPARAMS.PupilTCAx==-10000),                                                      %%cmp
        CFG = getappdata(hAomControl, 'CFG');                                             %%cmp
        PupilOffsetpix_x=CFG.pixperdeg*SYSPARAMS.PupilTCAx/60;                            %%cmp
        PupilOffsetpix_y=CFG.pixperdeg*SYSPARAMS.PupilTCAy/60;                            %%cmp
    else                                                                                  %%cmp
        sound(rand(500,1),800);                                                           %%cmp
        PupilOffsetpix_x=0;                                                               %%cmp
        PupilOffsetpix_y=0;                                                               %%cmp
    end                                                                                   %%cmp
end                                                                                       %%cmp
 
if SYSPARAMS.sysmode == 2 || SYSPARAMS.sysmode == 3
    if ~isempty(Mov.seq) && ischar(Mov.seq)
        Mov.frm = 1;
        Mov.duration = 0;
        temp = Mov.seq;
        while (any(temp)) %Sequence
            [chopped,temp] = strtok(temp); %#ok<STTOK>
            commapos = findstr(',', chopped);
            Mov.duration = Mov.duration+1;
            Mov.aom0seq(Mov.duration) = str2num(chopped(1:commapos(1)-1)); %#ok<ST2NM>
            Mov.aom0pow(Mov.duration) = str2double(chopped(commapos(1)+1:commapos(2)-1));
            Mov.aom0locx(Mov.duration) = str2num(chopped(commapos(2)+1:commapos(3)-1)); %#ok<ST2NM>
            Mov.aom0locy(Mov.duration) = str2num(chopped(commapos(3)+1:commapos(4)-1));
            Mov.aom1seq(Mov.duration) = str2num(chopped(commapos(4)+1:commapos(5)-1));
            Mov.aom1pow(Mov.duration) = str2double(chopped(commapos(5)+1:commapos(6)-1));
            Mov.aom1offx(Mov.duration) = str2num(chopped(commapos(6)+1:commapos(7)-1));
            Mov.aom1offy(Mov.duration) = str2num(chopped(commapos(7)+1:commapos(8)-1));
            Mov.aom2seq(Mov.duration) = str2num(chopped(commapos(8)+1:commapos(9)-1));
            Mov.aom1pow(Mov.duration) = str2double(chopped(commapos(9)+1:commapos(10)-1));
            Mov.aom1offx(Mov.duration) = str2num(chopped(commapos(10)+1:commapos(11)-1));
            Mov.aom1offy(Mov.duration) = str2num(chopped(commapos(11)+1:commapos(12)-1));
            pos = 12;
            if SYSPARAMS.aoms_enable(4) == 1
                Mov.aom3seq(Mov.duration) = str2num(chopped(commapos(pos)+1:commapos(pos+1)-1));
                pos = pos+1;
                Mov.aom3pow(Mov.duration) = str2double(chopped(commapos(pos)+1:commapos(pos+1)-1));
                pos = pos+1;
                Mov.aom3offx(Mov.duration) = str2num(chopped(commapos(pos)+1:commapos(pos+1)-1));
                pos = pos+1;
                Mov.aom3offy(Mov.duration) = str2num(chopped(commapos(pos)+1:commapos(pos+1)-1));
                pos = pos+1;
            end
            Mov.gainseq(Mov.duration) = str2double(chopped(commapos(pos)+1:commapos(pos+1)-1));
            pos = pos+1;
            Mov.angleseq(Mov.duration) = str2num(chopped(commapos(pos)+1:commapos(pos+1)-1));
            pos = pos+1;
            Mov.stimbeep(Mov.duration) = str2num(chopped(commapos(pos)+1:end));            
        end
    elseif SYSPARAMS.sysmode == 2
        return;
    end
end
if SYSPARAMS.sysmode == 3 && SYSPARAMS.realsystem == 1%Experiment
    if ~isfield(Mov, 'aom2seq')
        Mov.aom2seq = zeros(size(Mov.aom0seq));
        Mov.aom2pow = zeros(size(Mov.aom0seq));
        Mov.aom2offx = zeros(size(Mov.aom0seq));
        Mov.aom2offy = zeros(size(Mov.aom0seq));
    end
    if Mov.duration > 0
        if SYSPARAMS.aoms_enable(4) ~= 1
            for i = 1:Mov.duration
                if i == 1
                    Mov.seq = [num2str(Mov.aom0seq(i)) ',' num2str(Mov.aom0pow(i)) ',' num2str(Mov.aom0locx(i)) ',' num2str(Mov.aom0locy(i)) ',' num2str(Mov.aom1seq(i)) ',' num2str(Mov.aom1pow(i)) ',' num2str(Mov.aom1offx(i)) ',' num2str(Mov.aom1offy(i)) ',' num2str(Mov.aom2seq(i)) ',' num2str(Mov.aom2pow(i)) ',' num2str(Mov.aom2offx(i)) ',' num2str(Mov.aom2offy(i)) ',' num2str(Mov.gainseq(i)) ','  num2str(Mov.angleseq(i)) ','  num2str(Mov.stimbeep(i)) sprintf('\t')];
                elseif i>1 && i<length(Mov.aom0seq)
                    Mov.seq = [Mov.seq num2str(Mov.aom0seq(i)) ',' num2str(Mov.aom0pow(i)) ',' num2str(Mov.aom0locx(i)) ',' num2str(Mov.aom0locy(i)) ',' num2str(Mov.aom1seq(i)) ',' num2str(Mov.aom1pow(i)) ',' num2str(Mov.aom1offx(i)) ',' num2str(Mov.aom1offy(i)) ',' num2str(Mov.aom2seq(i)) ',' num2str(Mov.aom2pow(i)) ',' num2str(Mov.aom2offx(i)) ',' num2str(Mov.aom2offy(i)) ',' num2str(Mov.gainseq(i)) ','  num2str(Mov.angleseq(i)) ','  num2str(Mov.stimbeep(i)) sprintf('\t')]; %#ok<AGROW>
                elseif i == length(Mov.aom0seq)
                    Mov.seq = [Mov.seq num2str(Mov.aom0seq(i)) ',' num2str(Mov.aom0pow(i)) ',' num2str(Mov.aom0locx(i)) ',' num2str(Mov.aom0locy(i)) ',' num2str(Mov.aom1seq(i)) ',' num2str(Mov.aom1pow(i)) ',' num2str(Mov.aom1offx(i)) ',' num2str(Mov.aom1offy(i)) ',' num2str(Mov.aom2seq(i)) ',' num2str(Mov.aom2pow(i)) ',' num2str(Mov.aom2offx(i)) ',' num2str(Mov.aom2offy(i)) ',' num2str(Mov.gainseq(i)) ','  num2str(Mov.angleseq(i)) ','  num2str(Mov.stimbeep(i))]; %#ok<AGROW>
                end
            end
        else
            for i = 1:Mov.duration
                if i == 1
                    Mov.seq = [num2str(Mov.aom0seq(i)) ',' num2str(Mov.aom0pow(i)) ',' num2str(Mov.aom0locx(i)) ',' num2str(Mov.aom0locy(i)) ',' num2str(Mov.aom1seq(i)) ',' num2str(Mov.aom1pow(i)) ',' num2str(Mov.aom1offx(i)) ',' num2str(Mov.aom1offy(i)) ',' num2str(Mov.aom2seq(i)) ',' num2str(Mov.aom2pow(i)) ',' num2str(Mov.aom2offx(i)) ',' num2str(Mov.aom2offy(i)) ',' num2str(Mov.aom3seq(i)) ',' num2str(Mov.aom3pow(i)) ',' num2str(Mov.aom3offx(i)) ',' num2str(Mov.aom3offy(i)) ',' num2str(Mov.gainseq(i)) ','  num2str(Mov.angleseq(i)) ','  num2str(Mov.stimbeep(i)) sprintf('\t')];
                elseif i>1 && i<length(Mov.aom0seq)
                    Mov.seq = [Mov.seq num2str(Mov.aom0seq(i)) ',' num2str(Mov.aom0pow(i)) ',' num2str(Mov.aom0locx(i)) ',' num2str(Mov.aom0locy(i)) ',' num2str(Mov.aom1seq(i)) ',' num2str(Mov.aom1pow(i)) ',' num2str(Mov.aom1offx(i)) ',' num2str(Mov.aom1offy(i)) ',' num2str(Mov.aom2seq(i)) ',' num2str(Mov.aom2pow(i)) ',' num2str(Mov.aom2offx(i)) ',' num2str(Mov.aom2offy(i)) ',' num2str(Mov.aom3seq(i)) ',' num2str(Mov.aom3pow(i)) ',' num2str(Mov.aom3offx(i)) ',' num2str(Mov.aom3offy(i)) ',' num2str(Mov.gainseq(i)) ','  num2str(Mov.angleseq(i)) ','  num2str(Mov.stimbeep(i)) sprintf('\t')]; %#ok<AGROW>
                elseif i == length(Mov.aom0seq)
                    Mov.seq = [Mov.seq num2str(Mov.aom0seq(i)) ',' num2str(Mov.aom0pow(i)) ',' num2str(Mov.aom0locx(i)) ',' num2str(Mov.aom0locy(i)) ',' num2str(Mov.aom1seq(i)) ',' num2str(Mov.aom1pow(i)) ',' num2str(Mov.aom1offx(i)) ',' num2str(Mov.aom1offy(i)) ',' num2str(Mov.aom2seq(i)) ',' num2str(Mov.aom2pow(i)) ',' num2str(Mov.aom2offx(i)) ',' num2str(Mov.aom2offy(i)) ',' num2str(Mov.aom3seq(i)) ',' num2str(Mov.aom3pow(i)) ',' num2str(Mov.aom3offx(i)) ',' num2str(Mov.aom3offy(i)) ',' num2str(Mov.gainseq(i)) ','  num2str(Mov.angleseq(i)) ','  num2str(Mov.stimbeep(i))]; %#ok<AGROW>
                end
            end
        end
    else
        return;
    end
end

if SYSPARAMS.sysmode == 2 || SYSPARAMS.sysmode == 3
    if SYSPARAMS.realsystem == 1
        if SYSPARAMS.sysmode == 2 || SYSPARAMS.sysmode == 3 % NMP 8/11/14 add  || SYSPARAMS.sysmode == 3
            command = ['Loop#' num2str(SYSPARAMS.loop) '#'];
            if SYSPARAMS.board == 'm'
                MATLABAomControl32(command);
            else
                netcomm('write',SYSPARAMS.netcommobj,int8(command));
            end
        end
        command = ['Sequence' '#' char(Mov.seq) '#']; %#ok<NASGU>
        if SYSPARAMS.board == 'm'
            MATLABAomControl32(command);
        else
            aom0seq = Mov.aom0seq;
            aom0pow = Mov.aom0pow;
            aom0locx = Mov.aom0locx;
            aom0locy = Mov.aom0locy;
            aom1seq = Mov.aom1seq;
            aom1pow = Mov.aom1pow;
            if SYSPARAMS.PupilTCACorrection==1, % aeb 11/30/16
                aom1offx = Mov.aom1offx + PupilOffsetpix_x;   %%cmp
                aom1offy = Mov.aom1offy + PupilOffsetpix_y;   %%cmp
            else
                aom1offx = Mov.aom1offx;   %%cmp
                aom1offy = Mov.aom1offy;   %%cmp
            end
            aom2seq = Mov.aom2seq;
            aom2pow = Mov.aom2pow;
            aom2offx = Mov.aom2offx;
            aom2offy = Mov.aom2offy;
            gainseq = Mov.gainseq;
            angleseq = Mov.angleseq;
            stimbeep = Mov.stimbeep;
            save G:\Seqfile aom0seq aom0pow aom0locx aom0locy aom1seq aom1pow aom1offx aom1offy aom2seq aom2pow aom2offx aom2offy gainseq angleseq stimbeep;
            command = ['Sequence' '#' num2str(size(Mov.aom0seq,2)) '#']; %#ok<NASGU>
            netcomm('write',SYSPARAMS.netcommobj,int8(command));
        end
        pause(size(Mov.seq,2)*0.0001);
        if get(handles.exp_radio1, 'Value') == 1 && VideoParams.vidrecord == 1
            %if running an experiment, this is where the video capturing gets
            %triggered
            command = ['VL#' sprintf('%2.2f',VideoParams.videodur) '#']; %#ok<NASGU>
            if SYSPARAMS.board == 'm'
                MATLABAomControl32(command);
            else
                netcomm('write',SYSPARAMS.netcommobj,int8(command));
            end
            command = ['GRVIDT#' VideoParams.vidname '#']; %#ok<NASGU>
            if SYSPARAMS.board == 'm'
                MATLABAomControl32(command);
            else
                netcomm('write',SYSPARAMS.netcommobj,int8(command));
            end
        else
            %if not running experiment, just play the movie
            if SYSPARAMS.board == 'm'
                MATLABAomControl32('Trigger#');
            else
                netcomm('write',SYSPARAMS.netcommobj,int8('Trigger#'));
            end
        end
    end
elseif SYSPARAMS.sysmode == 1 %AVI
    Mov.MovObj = VideoReader(Mov.avi);
    Mov.duration = round(Mov.MovObj.FrameRate*Mov.MovObj.Duration); 
    Mov.curreplayiter = 1;
    Mov.aom0seq = ones(1,Mov.duration);
    Mov.aom0pow = Mov.aom0seq;
    Mov.aom0pow = Mov.aom0pow * SYSPARAMS.aompowerLvl(1);
    Mov.aom0locx = zeros(1, Mov.duration);
    Mov.aom0locy = Mov.aom0locx;
    Mov.aom1seq = (2:1:Mov.duration+1);        
    Mov.aom1pow = Mov.aom0seq;
    Mov.aom1pow = Mov.aom1pow * SYSPARAMS.aompowerLvl(2);
    Mov.aom1offx = Mov.aom0locx;
    Mov.aom1offy = Mov.aom0locx;
    if (SYSPARAMS.aoms_enable(3))
        Mov.aom2seq = (2:1:Mov.duration+1);
        Mov.aom2pow = Mov.aom0seq;
        Mov.aom2pow = Mov.aom2pow * SYSPARAMS.aompowerLvl(3);
        Mov.aom2offx = Mov.aom0locx;
        Mov.aom2offy = Mov.aom0locx;
    end
    if (SYSPARAMS.aoms_enable(4))
        Mov.aom3seq = (2:1:Mov.duration+1);
        Mov.aom3pow = Mov.aom0seq;
        Mov.aom3pow = Mov.aom3pow * SYSPARAMS.aompowerLvl(4);
        Mov.aom3offx = Mov.aom0locx;
        Mov.aom3offy = Mov.aom0locx;
    end
    Mov.frm = 1;
end

setappdata(hAomControl, 'Mov', Mov);

t=timerfindall;
delete(t);
movietimer = timer('TimerFcn', @Movie_Timer_Fcn,'StartFcn', @Start_Movie_Timer_Fcn,'StopFcn', @Stop_Movie_Timer_Fcn,'Period', .034, 'ExecutionMode', 'fixedRate', 'TasksToExecute', Mov.duration);
start(movietimer);

function Movie_Timer_Fcn(hObject, eventdata, handles)
global SYSPARAMS StimParams CurFrame;

hAomControl = getappdata(0,'hAomControl');
Mov = getappdata(hAomControl, 'Mov');
handles = getappdata(hAomControl, 'handles');

if Mov.frm == Mov.duration;
    Mov.frm = 2;
else
    Mov.frm = Mov.frm+1;
end

if Mov.frm == Mov.duration
    %do nothing - Stop_Movie_Fcn displays last frame
    %elseif str2num(cur_frame) == str2num(prev_frame)
    %do nothing - frame has not changed
else    
    locupdate = 0;
    update = 0;
    if SYSPARAMS.sysmode == 1
        Mov.MovObj.CurrentTime = (Mov.frm-1)*(1/Mov.MovObj.FrameRate);
        aviframe_d = double(readFrame(Mov.MovObj));
    else
        if (Mov.aom0locx(Mov.frm) ~= Mov.aom0locx(Mov.frm-1)) || (Mov.aom0locy(Mov.frm) ~= Mov.aom0locy(Mov.frm-1))
            locupdate = 1;
        end
    end
    %display the next frame in raster0 axes (child of im_panel0)
    locx = Mov.aom0locx(Mov.frm);
    locy = Mov.aom0locy(Mov.frm);

    if SYSPARAMS.aoms_state(1) == 1 %IR
        CurFrame(:,:,1) = uint8(50*Mov.aom0pow(Mov.frm));
        if Mov.aom0seq(Mov.frm) ~= 0 && Mov.aom0seq(Mov.frm) ~= 1
            if locupdate || (Mov.aom0seq(Mov.frm) ~= Mov.aom0seq(Mov.frm-1))
                if SYSPARAMS.sysmode ~= 1
                    fullpath0 = [Mov.dir Mov.pfx num2str(Mov.aom0seq(Mov.frm)) '.' StimParams.fext];
                    temp_im_d = double(imageread(fullpath0)).*Mov.aom0pow(Mov.frm);
                else
                    temp_im_d = double(aviframe_d(:,:,3)).*SYSPARAMS.aompowerLvl(1);
                end
                temp_im_d = ((temp_im_d-min(min(temp_im_d)))*(50/((max(max(temp_im_d))-min(min(temp_im_d)))+1)));
                temp_im_dim = size(temp_im_d);
                CurFrame(floor(256+locy-temp_im_dim(1)/2)+1:floor(256+locy-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx-temp_im_dim(2)/2)+1:floor(256+locx-temp_im_dim(2)/2)+temp_im_dim(2),1) = uint8(temp_im_d);
                update = 1;
            end
        elseif (Mov.aom0seq(Mov.frm) == 0 && Mov.aom0seq(Mov.frm-1) ~= 0) || (Mov.aom0seq(Mov.frm) == 1 && Mov.aom0seq(Mov.frm-1) ~= 1)
            update = 1;
        end
    end

    if SYSPARAMS.aoms_state(2) == 1 %red
        if Mov.aom1seq(Mov.frm) == 1
            CurFrame(:,:,1) = CurFrame(:,:,1)+uint8(205*Mov.aom1pow(Mov.frm));
        elseif Mov.aom1seq(Mov.frm) ~= 0 && Mov.aom1seq(Mov.frm) ~= 1
            if locupdate || (Mov.aom1seq(Mov.frm) ~= Mov.aom1seq(Mov.frm-1))
                if SYSPARAMS.sysmode ~= 1
                    fullpath1 = [Mov.dir Mov.pfx num2str(Mov.aom1seq(Mov.frm))  '.' StimParams.fext];
                    temp_im_d = double(imageread(fullpath1)).*Mov.aom1pow(Mov.frm);
                else
                    temp_im_d = double(aviframe_d(:,:,1)).*SYSPARAMS.aompowerLvl(2);
                end
                temp_im_d = ((temp_im_d-min(min(temp_im_d)))*((255-51)/((max(max(temp_im_d))-min(min(temp_im_d)))+1)));
                temp_im_dim = size(temp_im_d);
                CurFrame(floor(256+locy+StimParams.aomoffs(1,2)+Mov.aom1offy(Mov.frm)-temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(1,2)+Mov.aom1offy(Mov.frm)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+StimParams.aomoffs(1,1)+Mov.aom1offx(Mov.frm)-temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(1,1)+Mov.aom1offx(Mov.frm)-temp_im_dim(2)/2)+temp_im_dim(2),1) = uint8(temp_im_d)+CurFrame(floor(256-temp_im_dim(1)/2)+1:floor(256-temp_im_dim(1)/2)+temp_im_dim(1),floor(256-temp_im_dim(2)/2)+1:floor(256-temp_im_dim(2)/2)+temp_im_dim(2),1);
                update = 1;
            end
        elseif (Mov.aom1seq(Mov.frm) == 0 && Mov.aom1seq(Mov.frm-1) ~= 0) || (Mov.aom1seq(Mov.frm) == 1 && Mov.aom1seq(Mov.frm-1) ~= 1)
            update = 1;
        end
    end

    if SYSPARAMS.aoms_state(3) == 1 && SYSPARAMS.aoms_enable(3) == 1
        if Mov.aom2seq(Mov.frm) == 1
            CurFrame(:,:,2) = 255;
        elseif Mov.aom2seq(Mov.frm) ~= 0 && Mov.aom2seq(Mov.frm) ~= 1
            if locupdate || (Mov.aom2seq(Mov.frm) ~= Mov.aom2seq(Mov.frm-1))
                if SYSPARAMS.sysmode ~= 1
                    fullpath2 = [Mov.dir Mov.pfx num2str(Mov.aom2seq(Mov.frm))  '.' StimParams.fext];
                    temp_im_d = double(imageread(fullpath2)).*Mov.aom2pow(Mov.frm);
                else
                    temp_im_d = double(aviframe_d(:,:,2)).*SYSPARAMS.aompowerLvl(3);
                end
                temp_im_dim = size(temp_im_d);
                CurFrame(floor(256+locy+StimParams.aomoffs(2,2)+Mov.aom2offy(Mov.frm)-temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(2,2)+Mov.aom2offy(Mov.frm)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+StimParams.aomoffs(2,1)+Mov.aom2offx(Mov.frm)-temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(2,1)+Mov.aom2offx(Mov.frm)-temp_im_dim(2)/2)+temp_im_dim(2),2) = uint8(temp_im_d);
                update = 1;
            end
        elseif (Mov.aom2seq(Mov.frm) == 0 && Mov.aom2seq(Mov.frm-1) ~= 0) || (Mov.aom2seq(Mov.frm) == 1 && Mov.aom2seq(Mov.frm-1) ~= 1)
            if Mov.aom2seq(Mov.frm) == 0
                CurFrame(:,:,2) = 0;
            else
                CurFrame(:,:,2) = 255;
            end
            update = 1;
        end
    end
    
    if SYSPARAMS.aoms_state(4) == 1 && SYSPARAMS.aoms_enable(4) == 1
        if Mov.aom3seq(Mov.frm) == 1
            CurFrame(:,:,3) = 255;
        elseif Mov.aom3seq(Mov.frm) ~= 0 && Mov.aom3seq(Mov.frm) ~= 1
            if locupdate || (Mov.aom3seq(Mov.frm) ~= Mov.aom3seq(Mov.frm-1))
                if SYSPARAMS.sysmode ~= 1
                    fullpath3 = [Mov.dir Mov.pfx num2str(Mov.aom3seq(Mov.frm))  '.' StimParams.fext];
                    temp_im_d = double(imageread(fullpath3)).*Mov.aom3pow(Mov.frm);
                else
                    temp_im_d = double(aviframe_d(:,:,3)).*SYSPARAMS.aompowerLvl(3);
                end
                temp_im_dim = size(temp_im_d);
                CurFrame(floor(256+locy+StimParams.aomoffs(3,2)+Mov.aom2offy(Mov.frm)-temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(3,2)+Mov.aom2offy(Mov.frm)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+StimParams.aomoffs(3,1)+Mov.aom2offx(Mov.frm)-temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(3,1)+Mov.aom2offx(Mov.frm)-temp_im_dim(2)/2)+temp_im_dim(2),3) = uint8(temp_im_d);
                update = 1;
            end
        elseif (Mov.aom3seq(Mov.frm) == 0 && Mov.aom3seq(Mov.frm-1) ~= 0) || (Mov.aom3seq(Mov.frm) == 1 && Mov.aom3seq(Mov.frm-1) ~= 1)
            if Mov.aom2seq(Mov.frm) == 0
                CurFrame(:,:,3) = 0;
            else
                CurFrame(:,:,3) = 255;
            end
            update = 1;
        end
    end    
    if update == 1
        axes(get(handles.im_panel1, 'Child')); %#ok<MAXES>
        imshow(CurFrame);
    end
end

setappdata(hAomControl, 'Mov', Mov);
if isfield(Mov,'suppress') == 0
    Mov.suppress = 0;
else
end

if Mov.suppress == 1
    %suppress messages
elseif Mov.suppress == 0
    message = [Mov.msg ' - Playing Movie - Frame ' num2str(Mov.frm) ' of ' num2str(Mov.duration)];
    set(handles.aom1_state, 'String',message);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Stop_Movie_Timer_Fcn(hObject, eventdata, handles)

global SYSPARAMS StimParams CurFrame;
hAomControl = getappdata(0,'hAomControl');
Mov = getappdata(hAomControl, 'Mov');
handles = getappdata(hAomControl, 'handles');
locupdate = 0;
update = 0;
if SYSPARAMS.sysmode == 1
        Mov.MovObj.CurrentTime = (Mov.Duration-1)*(1/Mov.MovObj.FrameRate);
        aviframe_d = double(readFrame(Mov.MovObj));
else
    if (Mov.aom0locx(end) ~= Mov.aom0locx(end-1)) || (Mov.aom0locy(end) ~= Mov.aom0locy(end-1))
        locupdate = 1;
    end
end
%display the next frame in raster0 axes (child of im_panel0)
locx = Mov.aom0locx(Mov.frm);
locy = Mov.aom0locy(Mov.frm);

if SYSPARAMS.aoms_state(1) == 1
    CurFrame(:,:,1) = uint8(50*Mov.aom0pow(end));
    if Mov.aom0seq(end) ~= 0 && Mov.aom0seq(end) ~= 1
        if locupdate || (Mov.aom0seq(end) ~= Mov.aom0seq(end-1))
            if SYSPARAMS.sysmode ~= 1
                fullpath0 = [Mov.dir Mov.pfx num2str(Mov.aom0seq(end))  '.' StimParams.fext];
                temp_im_d = double(imageread(fullpath0)).*Mov.aom0pow(end);
            else
                temp_im_d = double(aviframe_d(:,:,3)).*SYSPARAMS.aompowerLvl(1);
            end
            temp_im_d = ((temp_im_d-min(min(temp_im_d)))*(50/((max(max(temp_im_d))-min(min(temp_im_d)))+1)));
            temp_im_dim = size(temp_im_d);
            CurFrame(floor(256+locy-temp_im_dim(1)/2)+1:floor(256+locy-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx-temp_im_dim(2)/2)+1:floor(256+locx-temp_im_dim(2)/2)+temp_im_dim(2),1) = uint8(temp_im_d);
            update = 1;
        end
    elseif Mov.aom0seq(Mov.frm) == 0 && Mov.aom0seq(Mov.frm-1) ~= 0
        update = 1;
    end
end

if SYSPARAMS.aoms_state(2) == 1
    if Mov.aom1seq(end) == 1
        CurFrame(:,:,1) = CurFrame(:,:,1)+uint8(205*Mov.aom1pow(end));
    elseif Mov.aom1seq(end) ~= 0 && Mov.aom1seq(end) ~= 1
        if locupdate || (Mov.aom1seq(end) ~= Mov.aom1seq(end-1))
            if SYSPARAMS.sysmode ~= 1
                fullpath1 = [Mov.dir Mov.pfx num2str(Mov.aom1seq(end))  '.' StimParams.fext];
                temp_im_d = double(imageread(fullpath1)).*Mov.aom1pow(end);
            else
                temp_im_d = double(aviframe_d(:,:,1)).*SYSPARAMS.aompowerLvl(2);
            end
            temp_im_d = ((temp_im_d-min(min(temp_im_d)))*((255-51)/((max(max(...
                temp_im_d))-min(min(temp_im_d)))+1)));
            
            temp_im_dim = size(temp_im_d);
            CurFrame(floor(256+locy+StimParams.aomoffs(1,2)+Mov.aom1offy(end)-...
                temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(1,2)+...
                Mov.aom1offy(end)-temp_im_dim(1)/2)+temp_im_dim(1),...
                floor(256+locx+StimParams.aomoffs(1,1)+Mov.aom1offx(end)-...
                temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(1,1)+...
                Mov.aom1offx(end)-temp_im_dim(2)/2)+temp_im_dim(2),1) = CurFrame(...
                floor(256+locy+Mov.aom1offy(end)-temp_im_dim(1)/2)+1:floor(...
                256+locy+Mov.aom1offy(end)-temp_im_dim(1)/2)+temp_im_dim(1),...
                floor(256+locx+Mov.aom1offx(end)-temp_im_dim(2)/2)+1:floor(...
                256+locx+Mov.aom1offx(end)-temp_im_dim(2)/2)+temp_im_dim(2),1)+uint8(temp_im_d);
            update = 1;
        end
    elseif Mov.aom1seq(end) == 0 && Mov.aom1seq(end-1) ~= 0
        update = 1;
    end
end

if SYSPARAMS.aoms_state(3) == 1 && SYSPARAMS.aoms_enable(3) == 1
    if Mov.aom2seq(end) == 1
        CurFrame(:,:,2) = 255;
    elseif Mov.aom2seq(end) ~= 0 && Mov.aom2seq(end) ~= 1
        if locupdate || (Mov.aom2seq(end) ~= Mov.aom2seq(end-1))
            if SYSPARAMS.sysmode ~= 1
                fullpath2 = [Mov.dir Mov.pfx num2str(Mov.aom2seq(end))  '.' StimParams.fext];
                temp_im_d = double(imageread(fullpath2)).*Mov.aom2pow(end);
            else
                temp_im_d = double(aviframe_d(:,:,2)).*SYSPARAMS.aompowerLvl(3);
            end
            temp_im_dim = size(temp_im_d);
            CurFrame(floor(256+locy+StimParams.aomoffs(2,2)+Mov.aom2offy(end)-temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(2,2)+Mov.aom2offy(end)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+StimParams.aomoffs(2,1)+Mov.aom2offx(end)-temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(2,1)+Mov.aom2offx(end)-temp_im_dim(2)/2)+temp_im_dim(2),2) = uint8(temp_im_d);
            update = 1;
        end
    elseif Mov.aom2seq(end) == 0 && Mov.aom2seq(end-1) ~= 0
        CurFrame(:,:,2) = 0;
        update = 1;
    end
end
%
if SYSPARAMS.aoms_state(4) == 1 && SYSPARAMS.aoms_enable(4) == 1
    if Mov.aom3seq(end) == 1
        CurFrame(:,:,3) = 255;
    elseif Mov.aom3seq(end) ~= 0 && Mov.aom3seq(end) ~= 1
        if locupdate || (Mov.aom3seq(end) ~= Mov.aom3seq(end-1))
            if SYSPARAMS.sysmode ~= 1
                fullpath3 = [Mov.dir Mov.pfx num2str(Mov.aom3seq(end))  '.' StimParams.fext];
                temp_im_d = double(imageread(fullpath3)).*Mov.aom3pow(end);
            else
                temp_im_d = double(aviframe_d(:,:,3)).*SYSPARAMS.aompowerLvl(4);
            end
            temp_im_dim = size(temp_im_d);
            CurFrame(floor(256+locy+StimParams.aomoffs(3,2)+Mov.aom2offy(end)-temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(3,2)+Mov.aom2offy(end)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+StimParams.aomoffs(3,1)+Mov.aom2offx(end)-temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(3,1)+Mov.aom2offx(end)-temp_im_dim(2)/2)+temp_im_dim(2),3) = uint8(temp_im_d);
            update = 1;
        end
    elseif Mov.aom3seq(end) == 0 && Mov.aom3seq(end-1) ~= 0
        CurFrame(:,:,3) = 0;
        update = 1;
    end
end

if update == 1
    axes(get(handles.im_panel1, 'Child')); %#ok<MAXES>
    imshow(CurFrame);
end
CurFrame(:,:,:) = 0;
setappdata(hAomControl, 'Mov', Mov);
if isfield(Mov,'suppress') == 0
    Mov.suppress = 0;
else
end

if Mov.suppress == 1
    %do nothing
elseif Mov.suppress == 0
    message = [Mov.msg ' - Movie Stopped - Displaying Frame ' num2str(Mov.duration) ' of ' num2str(Mov.duration)];
    if get(handles.seq_radio1, 'Value') == 1
        message2 = 'Press Play to Show the Sequence Again';
        newmessage = sprintf('%s\n%s', message, message2);
        set(handles.aom1_state, 'String',newmessage);
    else
        set(handles.aom1_state, 'String',message);
    end
end

if StimParams.wavfileplay == 1
    audObj = audioplayer(StimParams.wavfile, 22000);
    play(audObj);
end

t = timerfind('TimerFcn', @Movie_Timer_Fcn,'StartFcn', @Start_Movie_Timer_Fcn,'StopFcn', @Stop_Movie_Timer_Fcn);
delete(t);
if SYSPARAMS.loop == 1 && SYSPARAMS.sysmode ~= 3
    if StimParams.avireplayinfinite == 1 || Mov.curreplayiter < StimParams.avireplaytimes
        Mov.curreplayiter = Mov.curreplayiter+1;
        setappdata(hAomControl, 'Mov', Mov);
        movietimer = timer('TimerFcn', @Movie_Timer_Fcn,'StartFcn', @Start_Movie_Timer_Fcn,'StopFcn', @Stop_Movie_Timer_Fcn,'Period', .050, 'ExecutionMode', 'fixedRate', 'TasksToExecute', Mov.duration);
        start(movietimer);
    end
end

function Start_Movie_Timer_Fcn(hObject, eventdata, handles)
global SYSPARAMS StimParams CurFrame; %#ok<NUSED>

hAomControl = getappdata(0,'hAomControl');
Mov = getappdata(hAomControl, 'Mov');
handles = getappdata(hAomControl, 'handles');

if SYSPARAMS.sysmode == 1
        Mov.MovObj.CurrentTime = (Mov.Duration-1)*(1/Mov.MovObj.FrameRate);
        aviframe_d = double(readFrame(Mov.MovObj));
end
locx = Mov.aom0locx(1);
locy = Mov.aom0locy(1);

if SYSPARAMS.aoms_state(1) == 1
    CurFrame(:,:,1) = uint8(50*Mov.aom0pow(1));
    if Mov.aom0seq(1) ~= 0 && Mov.aom0seq(1) ~= 1
        if SYSPARAMS.sysmode ~= 1
            fullpath0 = [Mov.dir Mov.pfx num2str(Mov.aom0seq(1))  '.' StimParams.fext];
            temp_im_d = double(imageread(fullpath0)).*Mov.aom0pow(1);
        else
            temp_im_d = double(aviframe_d(:,:,3)).*SYSPARAMS.aompowerLvl(1);
        end        
        temp_im_d = ((temp_im_d-min(min(temp_im_d)))*(50/((max(max(temp_im_d))-min(min(temp_im_d)))+1)));
        temp_im_dim = size(temp_im_d);
        CurFrame(floor(256+locy-temp_im_dim(1)/2)+1:floor(256+locy-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx-temp_im_dim(2)/2)+1:floor(256+locx-temp_im_dim(2)/2)+temp_im_dim(2),1) = uint8(temp_im_d);
    end
end

if SYSPARAMS.aoms_state(2) == 1
    if Mov.aom1seq(1) == 1
        CurFrame(:,:,1) = CurFrame(:,:,1)+uint8(205*Mov.aom1pow(1));
    elseif Mov.aom1seq(1) ~= 0 && Mov.aom1seq(1) ~= 1
        if SYSPARAMS.sysmode ~= 1
            fullpath1 = [Mov.dir Mov.pfx num2str(Mov.aom1seq(1))  '.' StimParams.fext];
            temp_im_d = double(imageread(fullpath1))*Mov.aom1pow(1);
        else
            temp_im_d = double(aviframe_d(:,:,1)).*SYSPARAMS.aompowerLvl(2);
        end
        temp_im_d = ((temp_im_d-min(min(temp_im_d)))*((255-51)/((max(max(temp_im_d))-min(min(temp_im_d)))+1)));
        temp_im_dim = size(temp_im_d);
        CurFrame(floor(256+locy+StimParams.aomoffs(1,2)+Mov.aom1offy(1)-temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(1,2)+Mov.aom1offy(1)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+StimParams.aomoffs(1,1)+Mov.aom1offx(1)-temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(1,1)+Mov.aom1offx(1)-temp_im_dim(2)/2)+temp_im_dim(2),1) = CurFrame(floor(256+locy+Mov.aom1offy(1)-temp_im_dim(1)/2)+1:floor(256+locy+Mov.aom1offy(1)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+Mov.aom1offy(1)-temp_im_dim(2)/2)+1:floor(256+locx+Mov.aom1offx(1)-temp_im_dim(2)/2)+temp_im_dim(2),1)+uint8(temp_im_d);
    end
end

if SYSPARAMS.aoms_state(3) == 1 && SYSPARAMS.aoms_enable(3) == 1
    if Mov.aom2seq(1) == 1 %Green
        CurFrame(:,:,2) = 255;
    elseif Mov.aom2seq(1) ~= 0 && Mov.aom2seq(1) ~= 1
        if SYSPARAMS.sysmode ~= 1
            fullpath2 = [Mov.dir Mov.pfx num2str(Mov.aom2seq(1))  '.' StimParams.fext];
            temp_im_d = double(imageread(fullpath2))*Mov.aom2pow(1);
        else
            temp_im_d = double(aviframe_d(:,:,2)).*SYSPARAMS.aompowerLvl(3);
        end
        temp_im_dim = size(temp_im_d);
        CurFrame(floor(256+locy+StimParams.aomoffs(2,2)+Mov.aom2offy(1)-temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(2,2)+Mov.aom2offy(1)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+StimParams.aomoffs(2,1)+Mov.aom2offx(1)-temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(2,1)+Mov.aom2offx(1)-temp_im_dim(2)/2)+temp_im_dim(2),2) = uint8(temp_im_d);
    end
end

if SYSPARAMS.aoms_state(4) == 1 && SYSPARAMS.aoms_enable(4) == 1
    if Mov.aom3seq(1) == 1 %Green
        CurFrame(:,:,3) = 255;
    elseif Mov.aom3seq(1) ~= 0 && Mov.aom3seq(1) ~= 1
        if SYSPARAMS.sysmode ~= 1
            fullpath3 = [Mov.dir Mov.pfx num2str(Mov.aom3seq(1))  '.' StimParams.fext];
            temp_im_d = double(imageread(fullpath3))*Mov.aom3pow(1);
        else
            temp_im_d = double(aviframe_d(:,:,3)).*SYSPARAMS.aompowerLvl(4);
        end
        temp_im_dim = size(temp_im_d);
        CurFrame(floor(256+locy+StimParams.aomoffs(3,2)+Mov.aom2offy(1)-temp_im_dim(1)/2)+1:floor(256+locy+StimParams.aomoffs(3,2)+Mov.aom2offy(1)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+locx+StimParams.aomoffs(3,1)+Mov.aom2offx(1)-temp_im_dim(2)/2)+1:floor(256+locx+StimParams.aomoffs(3,1)+Mov.aom2offx(1)-temp_im_dim(2)/2)+temp_im_dim(2),3) = uint8(temp_im_d);
    end
end

axes(get(handles.im_panel1, 'Child')); %#ok<MAXES>
imshow(CurFrame);

if isfield(Mov,'suppress') == 0
    Mov.suppress = 0;
else
end

if Mov.suppress == 1
    %suppress messages
elseif Mov.suppress == 0
    message = [Mov.msg ' - Playing Movie - Frame ' num2str(Mov.frm) ' of ' num2str(Mov.duration)];
    set(handles.aom1_state, 'String',message);
end

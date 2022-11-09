 function PupilTrackingAlg(obj,event,himage)
% Most updated Version Feb 22, 2018 with buffer
DEPTH_OF_BUFFER=5;

global SYSPARAMS StimParams %% CMP

global PupilParam;
global VideoToSave;
s=size(event.Data);
%*********************************************
% D=zeros(s);
% load F
% r1=F(1)+2*rand; if r1>500, r1=100; end; r2=F(2)+2*rand(); if r2>500, r2=100; end; R=F(3)+2*rand(); if R>500, R=400; end; 
% F=[r1 r2 R];
% save F F
% [X,Y]=meshgrid(1:s(1),1:s(2));
% idx1=find(((X-r2).^2 + (Y-r1).^2)<R^2);
% s2=s(1:2);
% for ii=1:length(idx1)
%     [xxx,yyy]=ind2sub(s2,idx1(ii));
%     D(xxx,yyy,:)=[255 255 255];
% end
% event.Data=uint8(D);
%********************************************
set(himage, 'CData', event.Data*4);


xcBE=s(2);
ycBE=s(1);

RBE=[5*PupilParam.Pixel_calibration 10*PupilParam.Pixel_calibration 15*PupilParam.Pixel_calibration];
if RBE(3)> (s(1)/2), RBE(3)=0; end
if RBE(2)> (s(1)/2), RBE(2)=0; end
if RBE(1)> (s(1)/2), RBE(1)=0; end

hps=get(get(get(himage,'Parent'),'Parent'),'Children');
col1=[1 0.5 0];

% for i=1:17
%     fprintf('%d %s\n',i,get(hps(i),'Tag'));
% end


% r1=PupilParam.AvoidedBorder; r2=s(1)-PupilParam.AvoidedBorder;
% c1=PupilParam.AvoidedBorder; c2=s(2)-PupilParam.AvoidedBorder;
% x0=round(mean([PupilParam.x1,PupilParam.x2]))-r1;
% y0=round(mean([PupilParam.y1,PupilParam.y2]))-c1;

% r1=s(1)-min(466,s(1))+1; r2=s(1);
% c1=max(1,round(s(2)/2-233)); c2=min(s(2),round(s(2)/2 + 233-1));
% c1=s(2)-min(466,s(2))+1; c2=s(2);
% r1=max(1,round(s(1)/2-233)); r2=min(s(1),round(s(1)/2 + 233-1));
%c1=s(2)-min(466,s(2))+1; c2=s(2);

 
if PupilParam.DisableTracking==0 
    [PupilParam.x1,PupilParam.x2,PupilParam.y1,PupilParam.y2,PupilParam.TrackError]=...
        TrackPupilV2017_Retro_Double_9(double(rgb2gray(event.Data)),0);
else
    Error=0;
    PupilParam.x1=-1; PupilParam.x2=-1; PupilParam.y1=-1; PupilParam.y2=-1; PupilParam.TrackError=-10;
end

  
% PupilParam.x1=PupilParam.x1+c1; PupilParam.x2=PupilParam.x2+c1;
% PupilParam.y1=PupilParam.y1+r1; PupilParam.y2=PupilParam.y2+r1;
x0=mean([PupilParam.x1,PupilParam.x2]);
y0=mean([PupilParam.y1,PupilParam.y2]);

Block_fps=clock;
Recording=[PupilParam.x1/PupilParam.Pixel_calibration PupilParam.x2/PupilParam.Pixel_calibration...
        PupilParam.y1/PupilParam.Pixel_calibration PupilParam.y2/PupilParam.Pixel_calibration PupilParam.TrackError Block_fps];

if PupilParam.PTFlag==1, 
    PupilParam.PTData=[PupilParam.PTData;Recording]; 
end

gc=get(hps(6),'BackgroundColor');
if PupilParam.Sync==1 & etime(clock,[2000 1 1 0 0 0]) - SYSPARAMS.PupilDuration < 0 %%cmp

     if gc(1)==0.75, set(hps(6),'String','Recording ...'); set(hps(6),'BackgroundColor',[1 0.5 0]); end
     PupilParam.DataSync=[PupilParam.DataSync;Recording];
    % whithin trial
else
    if gc(1)==1, set(hps(6),'String','Wait for Sync'); set(hps(6),'BackgroundColor',[0.75 0  0]); end    
end

h=get(himage,'Parent');
set(h,'NextPlot','add')

% H1=round(s(1)./2);
% V1=round(s(2)./2);
% Dmm=1*PupilParam.Pixel_calibration;
% delete(PupilParam.r1); PupilParam.r1=plot(h,V1,1:s(1)); set(PupilParam.r1,'LineWidth',6); set(PupilParam.r1,'Color',[1 0 0]);
% delete(PupilParam.r2); PupilParam.r2=plot(h,V1,[[(H1-Dmm):-Dmm:0]';[(H1+Dmm):Dmm:s(1)]'],'+'); set(PupilParam.r2,'LineWidth',2); set(PupilParam.r2,'Color',[1 0 0]);
% delete(PupilParam.r3); PupilParam.r3=plot(h,1:s(2),H1); set(PupilParam.r3,'LineWidth',6); set(PupilParam.r3,'Color',[1 0 0]);
% delete(PupilParam.r4); PupilParam.r4=plot(h,[[(V1-Dmm):-Dmm:0]';[(V1+Dmm):Dmm:s(2)]'],H1,'+'); set(PupilParam.r4,'LineWidth',2); set(PupilParam.r4,'Color',[1 0 0]);



if PupilParam.TrackError>-1,
    %rx=((PupilParam.x2 - PupilParam.x1)./2)*cos([0:0.05:2*pi,0]) + (PupilParam.x1 + PupilParam.x2)/2; rx=[rx,rx(1)];
    %ry=((PupilParam.y2 - PupilParam.y1)./2)*sin([0:0.05:2*pi,0]) + (PupilParam.y1 + PupilParam.y2)/2; ry=[ry,ry(1)];
    rx=[PupilParam.x1 PupilParam.x2 PupilParam.x2 PupilParam.x1 PupilParam.x1]; 
    ry=[PupilParam.y1 PupilParam.y1 PupilParam.y2 PupilParam.y2 PupilParam.y1];
    
    delete(PupilParam.p1); PupilParam.p1=plot(h,rx,ry); set(PupilParam.p1,'LineWidth',2); set(PupilParam.p1,'Color',col1);
    %     delete(PupilParam.p2); PupilParam.p2=plot(h,PupilParam.xr,PupilParam.yr,'.'); set(PupilParam.p2,'MarkerSize',12); set(PupilParam.p2,'Color',c1);
    %     delete(PupilParam.p3); PupilParam.p3=plot(h,PupilParam.xc,PupilParam.yc,'o'); set(PupilParam.p3,'LineWidth',2);
    %
    %     c=[0 0 1];
    %     RefPRx1Tmp=min(PupilParam.xr);
    %     RefPRx2Tmp=max(PupilParam.xr);
    %     RefPRy1Tmp=min(PupilParam.yr);
    %     RefPRy2Tmp=max(PupilParam.yr);
    %     delete(PupilParam.l1); PupilParam.l1=plot(h,[RefPRx1Tmp RefPRx2Tmp],[RefPRy1Tmp RefPRy1Tmp]); set(PupilParam.l1,'Color',c); set(PupilParam.l1,'LineWidth',2);
    %     delete(PupilParam.l2); PupilParam.l2=plot(h,[RefPRx1Tmp RefPRx2Tmp],[RefPRy2Tmp RefPRy2Tmp]); set(PupilParam.l2,'Color',c); set(PupilParam.l2,'LineWidth',2);
    %     delete(PupilParam.l11); PupilParam.l11=plot(h,[RefPRx1Tmp RefPRx1Tmp],[RefPRy1Tmp RefPRy2Tmp]); set(PupilParam.l11,'Color',c); set(PupilParam.l11,'LineWidth',2);
    %     delete(PupilParam.l22); PupilParam.l22=plot(h,[RefPRx2Tmp RefPRx2Tmp],[RefPRy1Tmp RefPRy2Tmp]); set(PupilParam.l22,'Color',c); set(PupilParam.l22,'LineWidth',2);
    
else
    %PupilParam.xc=-1; PupilParam.yc=-1; PupilParam.Re=-1000;
    delete(PupilParam.p1); PupilParam.p1=plot(h,1,1);
    %     delete(PupilParam.p2); PupilParam.p2=plot(h,1,1);
    %     delete(PupilParam.p3); PupilParam.p3=plot(h,1,1);
    %     delete(PupilParam.l1);  PupilParam.l1=plot(h,1,1);
    %     delete(PupilParam.l2);  PupilParam.l2=plot(h,1,1);
    %     delete(PupilParam.l11);  PupilParam.l11=plot(h,1,1);
    %     delete(PupilParam.l22);  PupilParam.l22=plot(h,1,1);
end

% ****************************** * * * * * * * *************************

if PupilParam.ShowReference==1,
    c=[0.75 0.75 0.75];
    %rx=((PupilParam.Refx2 - PupilParam.Refx1)./2)*cos([0:0.05:2*pi,0]) + (PupilParam.Refx1 + PupilParam.Refx2)/2; rx=[rx,rx(1)];
    %ry=((PupilParam.Refy2 - PupilParam.Refy1)./2)*sin([0:0.05:2*pi,0]) + (PupilParam.Refy1 + PupilParam.Refy2)/2; ry=[ry,ry(1)];
    rx0Ref=(PupilParam.Refx2 + PupilParam.Refx1)./2;
    ry0Ref=(PupilParam.Refy2 + PupilParam.Refy1)./2;
    rx=[PupilParam.Refx1 PupilParam.Refx2 PupilParam.Refx2 PupilParam.Refx1 PupilParam.Refx1]; 
    ry=[PupilParam.Refy1 PupilParam.Refy1 PupilParam.Refy2 PupilParam.Refy2 PupilParam.Refy1];
    delete(PupilParam.l3); PupilParam.l3=plot(h,rx,ry); set(PupilParam.l3,'Color',c); set(PupilParam.l3,'LineWidth',2);
else
    delete(PupilParam.l3);  PupilParam.l3=plot(h,1,1);
end

if PupilParam.idx_reftime>10, PupilParam.idx_reftime=1; else; PupilParam.idx_reftime=PupilParam.idx_reftime+1; end
PupilParam.fps(PupilParam.idx_reftime)=etime(Block_fps,PupilParam.reftime); PupilParam.reftime=Block_fps;
if sum(PupilParam.fps==0)==0
    Current_fps=round(1/mean(PupilParam.fps));
else 
    Current_fps=0;
end
SYSPARAMS.PupilCamerafps=Current_fps;



if PupilParam.BEFlag==1,
    H1=round(s(1)./2);
    V1=round(s(2)./2);
    Dmm=1*PupilParam.Pixel_calibration;
    delete(PupilParam.r1); PupilParam.r1=plot(h,V1,1:s(1)); set(PupilParam.r1,'LineWidth',6); set(PupilParam.r1,'Color',[1 0 0]);
    delete(PupilParam.r2); PupilParam.r2=plot(h,V1,[[(H1-Dmm):-Dmm:0]';[(H1+Dmm):Dmm:s(1)]'],'+'); set(PupilParam.r2,'LineWidth',2); set(PupilParam.r2,'Color',[1 0 0]);
    delete(PupilParam.r3); PupilParam.r3=plot(h,1:s(2),H1); set(PupilParam.r3,'LineWidth',6); set(PupilParam.r3,'Color',[1 0 0]);
    delete(PupilParam.r4); PupilParam.r4=plot(h,[[(V1-Dmm):-Dmm:0]';[(V1+Dmm):Dmm:s(2)]'],H1,'+'); set(PupilParam.r4,'LineWidth',2); set(PupilParam.r4,'Color',[1 0 0]);
else
    delete(PupilParam.r1);  PupilParam.r1=plot(h,1,1);
    delete(PupilParam.r2);  PupilParam.r2=plot(h,1,1);
    delete(PupilParam.r3); PupilParam.r3=plot(h,1,1);
    delete(PupilParam.r4);  PupilParam.r4=plot(h,1,1);        
end

PupilParam.Ltotaloffx=PupilParam.Ltotaloffx+1; if PupilParam.Ltotaloffx > DEPTH_OF_BUFFER, PupilParam.Ltotaloffx=1; end

if PupilParam.TrackError>-1,
    c=[0.75 0.75 0.75];
    if PupilParam.ShowReference==1
        delete(PupilParam.l4); PupilParam.l4=plot(h,[rx0Ref x0],[ry0Ref y0]); set(PupilParam.l4,'Color',c); set(PupilParam.l4,'LineWidth',2);
        difx=rx0Ref - x0; 
        dify=ry0Ref - y0; 
    else
        delete(PupilParam.l4); PupilParam.l4=plot(h,[xcBE/2 x0],[ycBE/2 y0]); set(PupilParam.l4,'Color',c); set(PupilParam.l4,'LineWidth',2);
        difx=round(xcBE/2 - x0); 
        dify=round(ycBE/2 - y0); 
    end
    %Stringhps9=['fps=',num2str(Current_fps),' dx=',num2str(difx),' dy=',num2str(dify)];
    Distance=sqrt(difx^2+dify^2)/PupilParam.Pixel_calibration;
    SYSPARAMS.PupilTCAx=PupilParam.TCAmmX*difx/PupilParam.Pixel_calibration;
    SYSPARAMS.PupilTCAy=PupilParam.TCAmmY*dify/PupilParam.Pixel_calibration;
    
    %*********************************************************************
    %*********************************************************************
    %*********************************************************************
    %*********************************************************************
    if PupilParam.EnableTCAComp ==1 ,               % if automatic TCA control is enabled
        % SYSPARAMS.PupilTCAx and SYSPARAMS.PupilTCAy is arcmn of TCA based on
        % subject's own ratio
        pixperarcmin = SYSPARAMS.pixelperdeg/60;
        xoffset=round(SYSPARAMS.PupilTCAx*pixperarcmin);   % in pixels
        yoffset=round(SYSPARAMS.PupilTCAy*pixperarcmin);   % in pixels
        
        if (abs(xoffset)>0 | abs(yoffset)>0) & PupilParam.ShowReference==1
            
            PupilParam.totaloffx = StimParams.aomoffs(1, 1) + xoffset; %StimParams.aomoffs(1, 1) = xoffset; % changed by AEB on 5/30
            PupilParam.totaloffy = StimParams.aomoffs(1, 2) - yoffset; %StimParams.aomoffs(1, 2) = -yoffset; % changed by AEB on 5/30

            if SYSPARAMS.realsystem == 1
                % aligncommand changed on 5/30/17 by AEB
                %aligncommand = ['UpdateOffset#' num2str(StimParams.aomoffs(1, 1)) '#' num2str(StimParams.aomoffs(1, 2)) '#' num2str(StimParams.aomoffs(2, 1)) '#' num2str(StimParams.aomoffs(2, 2)) '#' num2str(StimParams.aomoffs(3, 1)) '#' num2str(StimParams.aomoffs(3, 2)) '#'];   %#ok<NASGU>
                aligncommand = ['UpdateOffset#' num2str(PupilParam.totaloffx) '#' num2str(PupilParam.totaloffy) '#' num2str(StimParams.aomoffs(2, 1)) '#' num2str(StimParams.aomoffs(2, 2)) '#' num2str(StimParams.aomoffs(3, 1)) '#' num2str(StimParams.aomoffs(3, 2)) '#'];   %#ok<NASGU>
                if SYSPARAMS.board == 'm'
                    MATLABAomControl32(aligncommand);
                else
                    netcomm('write',SYSPARAMS.netcommobj,int8(aligncommand));
                end
            end
        end
    end
    
    
    %*********************************************************************
    %*********************************************************************
    %*********************************************************************
    
    SYSPARAMS.Pupildiffx(PupilParam.Ltotaloffx) = difx/PupilParam.Pixel_calibration;
    SYSPARAMS.Pupildiffy(PupilParam.Ltotaloffx) = dify/PupilParam.Pixel_calibration;
    if Current_fps<10,
        Stringhps9=sprintf('Hz= %d mm(%.1f, %.1f) TCA=%.1f',Current_fps,difx/PupilParam.Pixel_calibration,dify/PupilParam.Pixel_calibration,sqrt((SYSPARAMS.PupilTCAx)^2 + (SYSPARAMS.PupilTCAy)^2)); 
    else
        Stringhps9=sprintf('Hz=%d mm(%.1f, %.1f) TCA=%.1f',Current_fps,difx/PupilParam.Pixel_calibration,dify/PupilParam.Pixel_calibration,sqrt((SYSPARAMS.PupilTCAx)^2 + (SYSPARAMS.PupilTCAy)^2));
    end
    if Distance>PupilParam.TolleratedPupilDistance, beep; end
else
    delete(PupilParam.l4);  PupilParam.l4=plot(h,1,1);
    if Current_fps<10, 
        Stringhps9=sprintf('fps= %d no tracking',Current_fps);
    else
        Stringhps9=sprintf('fps=%d no tracking',Current_fps);
    end
    SYSPARAMS.PupilTCAx=-10000;
    SYSPARAMS.PupilTCAy=-10000;
    SYSPARAMS.Pupildiffx(PupilParam.Ltotaloffx) = -10000;
    SYSPARAMS.Pupildiffy(PupilParam.Ltotaloffx) = -10000;
    %Stringhps9=['fps=',num2str(Current_fps),' no tracking'];
end


if PupilParam.SavingVideo==1 & PupilParam.FrameCount<PupilParam.MAX_NUM_OF_SAVABLE_FRAMES & toc>PupilParam.SAVING_FREQUENCY
    VideoToSave=[VideoToSave;char(event.Data)];
    PupilParam.FrameCount=PupilParam.FrameCount+1;
    
    tic;
else
    if PupilParam.SavingVideo==1 & PupilParam.FrameCount>=PupilParam.MAX_NUM_OF_SAVABLE_FRAMES
        PupilParam.SavingVideo=0;
        set(hps(11),'String','Saving ...');
        Prefix=get(hps(7),'String');
        DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
        save(['.\VideoAndRef\',Prefix,'VideoPupil_',DateString], 'VideoToSave')
        VideoToSave=[];
        set(hps(11),'String','Save Video');
        set(hps(11),'BackgroundColor',[0.941176 0.941176 0.941176]); set(hps(11),'ForegroundColor',[0 0 0]);
        if PupilParam.PTFlag==1
            PupilParam.PTFlag=0;
            set(hps(8),'String','Save Pupil Tracking');
            set(hps(8),'BackgroundColor',[0.941176 0.941176 0.941176]); set(hps(8),'ForegroundColor',[0 0 0]);
            DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
            PupilData.Data=PupilParam.PTData; PupilData.Pixel_calibration=PupilParam.Pixel_calibration;
            save(['.\VideoAndRef\',Prefix,'DataPupil_',DateString], 'PupilData')
            PupilParam.PTData=[];
            
%             set(hps(6),'String','Sync Save');
%             set(hps(6),'BackgroundColor',[0.941176 0.941176 0.941176]); set(hps(6),'ForegroundColor',[0 0 0]);
%             PupilParam.Sync=0;
        end
    end
end

if PupilParam.ShowFocus==1,
    FM = imfilter(double(rgb2gray(event.Data(round(s(1)/2)-30:round(s(1)/2)+30,1:s(2),:))), PupilParam.LAP, 'replicate', 'conv');
    FM = round(mean2(FM.^2));
    Stringhps9=sprintf('%s F=%d',Stringhps9,FM);
    %Stringhps9=[['Focus = ',num2str(FM),' '],Stringhps9];
end

set(hps(9),'String',Stringhps9); set(hps(9),'HorizontalAlignment','left');
function varargout = PupilVideoTracking(varargin)
% PUPILVIDEOTRACKING MATLAB code for PupilVideoTracking.fig
%      PUPILVIDEOTRACKING, by itself, creates a new PUPILVIDEOTRACKING or raises the existing
%      singleton*.
%
%      H = PUPILVIDEOTRACKING returns the handle to a new PUPILVIDEOTRACKING or the handle to
%      the existing singleton*.
%
%      PUPILVIDEOTRACKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PUPILVIDEOTRACKING.M with the given input arguments.
%
%      PUPILVIDEOTRACKING('Property','Value',...) creates a new PUPILVIDEOTRACKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PupilVideoTracking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PupilVideoTracking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PupilVideoTrackingF

% Last Modified by GUIDE v2.5 16-Sep-2016 17:00:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PupilVideoTracking_OpeningFcn, ...
    'gui_OutputFcn',  @PupilVideoTracking_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PupilVideoTracking is made visible.
function PupilVideoTracking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PupilVideoTracking (see VARARGIN)

% Choose default command line output for PupilVideoTracking
handles.output = hObject;
set(hObject,'Name','PupilVideoTracking V1.22')

% Update handles structure
guidata(hObject, handles);
global PupilParam;
PupilParam.x1=-1; PupilParam.x2=-1; PupilParam.y1=-1; PupilParam.y2=-1;
PupilParam.graylevel=255;
PupilParam.Re=-1000; PupilParam.Th=-1;
PupilParam.Flag=0;
PupilParam.Video=0;
PupilParam.SavingVideo=0;
PupilParam.MAX_NUM_OF_SAVABLE_FRAMES=5;
PupilParam.SAVING_FREQUENCY=0.3;
PupilParam.FrameCount=PupilParam.MAX_NUM_OF_SAVABLE_FRAMES;
PupilParam.BEFlag=0;
PupilParam.PTFlag=0;
PupilParam.Sync=0;
PupilParam.ShowReference=0;
PupilParam.DisableTracking=0;
PupilParam.reftime=clock;
PupilParam.idx_reftime=11;
PupilParam.fps=[0 0 0 0 0 0 0 0 0 0];
PupilParam.vidRes=1024;
PupilParam.ShowFocus=0;
PupilParam.EnableTCAComp=0; % off
PupilParam.Ltotaloffx=1;



set(handles.edit1,'String',num2str(ceil(PupilParam.MAX_NUM_OF_SAVABLE_FRAMES*PupilParam.SAVING_FREQUENCY)));
set(handles.edit2,'String',num2str(round(1/PupilParam.SAVING_FREQUENCY)));

set(handles.text5,'String',' ');

%     Brightness = 0 [-10 30]
%     Contrast = 0 [-10 30]
%     Exposure = -13 [-13 -2]
%     ExposureMode = manual {'auto'  'manual'}
%     FrameRate = 35.5000 {'35.5000'  '30.0000'  '15.0000'  '10.0000'}
%     Gain = 16 [8 31]
%     GainMode = auto {'auto'  'manual'}
%     Gamma = 100 [1 500]
%     Hue = 0 [-180 180]
%     Saturation = 64 [0 255]
%     Sharpness = 0 [0 14]
%     WhiteBalance = 0 [0 0]
global CameraSetting;
CameraSetting.Brightness=0;
CameraSetting.Contrast=0;
CameraSetting.Exposure=-3;
CameraSetting.ExposureMode=1; %1=manual, 2 =auto
CameraSetting.Gain=31;
CameraSetting.Gamma=100;
CameraSetting.Hue=0;
CameraSetting.Saturation=64;
CameraSetting.Sharpness=0;
CameraSetting.ROI=[128 0 768 768];
SetCameraSetting(handles,CameraSetting)



%******************************************************************
%******************************************************************
% global MyVideo;
% global vidHeight;
% global vidWidth;
% global IndexTot;
% IndexTot=1;
% %FN='C:\Claudio\MiscFromLab\AOSLO\AOMcontrol_V3_2\EyeTrack\Video_Folder\cmp2.avi';
% FN='C:\Documents and Settings\aosloii_ao\Desktop\PupilTracker\cmp2.avi';
%
% xyloObj = VideoReader(FN);
% nFrames = xyloObj.NumberOfFrames;
% vidHeight = xyloObj.Height;
% vidWidth = xyloObj.Width;
% MyVideo=zeros(vidHeight,vidWidth,nFrames,'uint8');
% for k=1:nFrames, MyVideo(:,:,k)= rgb2gray(read(xyloObj,k)); end;
%*********************************************************************
%******************************************************************
% UIWAIT makes PupilVideoTracking wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PupilVideoTracking_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS PupilParam;
SYSPARAMS.PupilTracker=0;
DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
Prefix=get(handles.edit3,'String');
if isfield(PupilParam,'DataSync'), 
    PupilData=PupilParam.DataSync;
    save(['.\VideoAndRef\','Trial_DataPupil_',Prefix,'_',DateString], 'PupilData'); 
end
close;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
global VideoToSave;
global CameraSetting
%%global MyVideo; % ***
global PupilParam;
PupilParam.Flag=0;

%global IndexTot;  % ***
if  get(hObject,'UserData')==0,
    
    vid= videoinput('winvideo', 1,'RGB24_1024x768');   %TSLO
    %vid= videoinput('winvideo', 3,'RGB24_1024x768');    %office 416
    %vid= videoinput('winvideo', 2,'RGB24_1280x720');
    %vid= videoinput('winvideo', 1,'RGB24_640x480');
    
    
    vidRes = vid.VideoResolution;
    nBands = vid.NumberOfBands;
    load CalibrationSetting
    PupilParam.vidRes=vidRes;
    PupilParam.Pixel_calibration=CalibrationSetting(1);
    PupilParam.TCAmmX=CalibrationSetting(2);
    PupilParam.TCAmmY=CalibrationSetting(3);
    PupilParam.TolleratedPupilDistance=CalibrationSetting(4);
    
    h = image( zeros(CameraSetting.ROI(4), CameraSetting.ROI(3), nBands) );
    
    preview(vid,h);
    %preview(vid)
    axes(handles.axes1);
    hold on
    src_obj = getselectedsource(vid); PupilParam.Camerafps= str2num(get(src_obj,'FrameRate'));
    %**************************************************%
    %********* settings camera variables **************%
    %PupilParam.ShowReference=0;
    %PupilParam.l1=plot(1,1);
    %PupilParam.l2=plot(1,1);
    %PupilParam.l11=plot(1,1);
    %PupilParam.l22=plot(1,1);
    PupilParam.l3=plot(1,1);
    PupilParam.l4=plot(1,1);
    PupilParam.l5=plot(1,1);
    PupilParam.l6=plot(1,1);
    PupilParam.l7=plot(1,1);
    PupilParam.l8=plot(1,1);
    PupilParam.p1=plot(1,1);
    %PupilParam.p2=plot(1,1);
    %PupilParam.p3=plot(1,1);
    
    PupilParam.v1=plot(1,1);
    PupilParam.v2=plot(1,1);
    PupilParam.v3=plot(1,1);
    PupilParam.v4=plot(1,1);
    
    PupilParam.c1=plot(1,1);
    PupilParam.c2=plot(1,1);
    PupilParam.c3=plot(1,1);
    PupilParam.c4=plot(1,1);
    PupilParam.c5=plot(1,1);
    
    PupilParam.r1=plot(1,1);
    PupilParam.r2=plot(1,1);
    PupilParam.r3=plot(1,1);
    PupilParam.r4=plot(1,1);
    PupilParam.LAP = fspecial('laplacian');
    PupilParam.DataSync=[];
    
    PupilParam.AvoidedBorder=round(CameraSetting.ROI(3)/5.1);
    
    
    setappdata(h,'UpdatePreviewWindowFcn',@PupilTrackingAlg);
    set(handles.edit3,'String','')
    
    %preview(vid, h);
    %preview(vid, get(handles.axes1,'Children'));
    PupilParam.Video=1;
    
    SetCameraValues(vid,CameraSetting);
end
if  get(hObject,'UserData')==1,
    closepreview(vid);
    PupilParam.Video=0;
    Prefix=get(handles.edit3,'String');
    set(handles.pushbutton5,'String','Save Video');
    set(handles.pushbutton5,'BackgroundColor',[0.941176 0.941176 0.941176]); set(handles.pushbutton5,'ForegroundColor',[0 0 0]);
    set(handles.pushbutton9,'String','Sync Save'); set(handles.pushbutton9,'BackgroundColor',[0.941176 0.941176 0.941176]); set(handles.pushbutton9,'ForegroundColor',[0 0 0]);  PupilParam.Sync=0;
    Prefix=get(handles.edit3,'String');
    PupilData=PupilParam.DataSync;
    DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
    if ~isempty(PupilParam.DataSync), save(['.\VideoAndRef\','Trial_DataPupil_',Prefix,'_',DateString], 'PupilData'); end
    PupilParam.DataSync=[];
    if PupilParam.SavingVideo==1
        save(['.\VideoAndRef\',Prefix,'VideoPupil_',DateString], 'VideoToSave')
        clear VideoToSave
    end
    PupilParam.SavingVideo=0;
    
    if PupilParam.PTFlag==1,
        PupilParam.PTFlag=0;
        set(handles.pushbutton8,'String','Save Pupil Tracking');
        set(handles.pushbutton8,'BackgroundColor',[0.941176 0.941176 0.941176]); set(handles.pushbutton8,'ForegroundColor',[0 0 0]);
        PupilData.Data=PupilParam.PTData; PupilData.Pixel_calibration=PupilParam.Pixel_calibration;
        
        save(['.\VideoAndRef\',Prefix,'DataPupil_',DateString], 'PupilData')
        PupilParam.PTData=[];
    end
    
end

if  get(hObject,'UserData')==0,
    set(hObject,'UserData',1);
    set(hObject,'String','Stop Video');
else,
    set(hObject,'UserData',0); set(hObject,'String','Start Video');
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilParam
if PupilParam.ShowReference==0,
    if PupilParam.x1>1,
        PupilParam.ShowReference=1;
        PupilParam.Refx1=min(PupilParam.x1);
        PupilParam.Refx2=max(PupilParam.x2);
        PupilParam.Refy1=min(PupilParam.y1);
        PupilParam.Refy2=max(PupilParam.y2);
        
        Refx1=PupilParam.Refx1;
        Refx2=PupilParam.Refx2;
        Refy1=PupilParam.Refy1;
        Refy2=PupilParam.Refy2;
        
        set(hObject,'String','Unset Reference');
        
        DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
        save(['.\VideoAndRef\RefPupil_',DateString],'Refx1','Refx2','Refy1','Refy2');
    end
else
    PupilParam.ShowReference=0;
    set(hObject,'String','Set Reference');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('RefPupil_*');
if ~(FileName==0)
    global PupilParam
    load([PathName,FileName]);
    PupilParam.ShowReference=1;
    PupilParam.Refx1=Refx1;
    PupilParam.Refx2=Refx2;
    PupilParam.Refy1=Refy1;
    PupilParam.Refy2=Refy2;
    set(handles.pushbutton3,'String','Unset Reference');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilParam
global VideoToSave;
if PupilParam.Video==1 & PupilParam.SavingVideo==0
    PupilParam.SavingVideo=1;
    set(hObject,'String','Recording Video ...');
    set(hObject,'BackgroundColor',[0.75 0 0]); set(hObject,'ForegroundColor',[1 1 1]);
    PupilParam.FrameCount=1;
    VideoToSave=[];
    tic;
    
    if PupilParam.PTFlag==0,
        PupilParam.PTFlag=1;
        PupilParam.PTT0=now;
        set(handles.pushbutton8,'String','Recording Pupil ...');
        set(handles.pushbutton8,'BackgroundColor',[0.75 0 0]); set(handles.pushbutton8,'ForegroundColor',[1 1 1]);
        PupilParam.PTData=[];
    end
    
else
    if  PupilParam.Video==1 & PupilParam.SavingVideo==1
        PupilParam.SavingVideo=0;
        Prefix=get(handles.edit3,'String');
        set(hObject,'String','Save Video');
        set(hObject,'BackgroundColor',[0.941176 0.941176 0.941176]); set(hObject,'ForegroundColor',[0 0 0]);
        DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
        save(['.\VideoAndRef\',Prefix,'VideoPupil_',DateString], 'VideoToSave')
        VideoToSave=[];
        
        %set(handles.pushbutton9,'String','Sync Save'); set(handles.pushbutton9,'BackgroundColor',[0.941176 0.941176 0.941176]); set(handles.pushbutton9,'ForegroundColor',[0 0 0]); PupilParam.Sync=0;
        
        if PupilParam.PTFlag==1
            PupilParam.PTFlag=0;
            set(handles.pushbutton8,'String','Save Pupil Tracking');
            set(handles.pushbutton8,'BackgroundColor',[0.941176 0.941176 0.941176]); set(handles.pushbutton8,'ForegroundColor',[0 0 0]);
            DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
            PupilData.Data=PupilParam.PTData; PupilData.Pixel_calibration=PupilParam.Pixel_calibration;
            save(['.\VideoAndRef\',Prefix,'DataPupil_',DateString], 'PupilData')
            PupilParam.PTData=[];
        end
        
    end
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global PupilParam;
E1=str2num(get(handles.edit1,'String'));
E2=str2num(get(handles.edit2,'String'));
PupilParam.MAX_NUM_OF_SAVABLE_FRAMES=E1*E2;
PupilParam.SAVING_FREQUENCY=1/E2;

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global PupilParam;
E1=str2num(get(handles.edit1,'String'));
E2=str2num(get(handles.edit2,'String'));
PupilParam.MAX_NUM_OF_SAVABLE_FRAMES=E1*E2;
PupilParam.SAVING_FREQUENCY=1/E2;

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilParam;
if PupilParam.BEFlag==0,
    PupilParam.BEFlag=1; set(hObject,'String','Hide BE');
else
    PupilParam.BEFlag=0; set(hObject,'String','Draw BE');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilParam SYSPARAMS;
if PupilParam.Video==1 & PupilParam.PTFlag==0,
    PupilParam.PTFlag=1;
    PupilParam.PTT0=now;
    set(hObject,'String','Recording Pupil ...');
    set(hObject,'BackgroundColor',[0.75 0 0]); set(hObject,'ForegroundColor',[1 1 1])
    Block_fps=clock;
    PupilParam.PTData=[0 0 0 0 0 Block_fps];
    
    if SYSPARAMS.board == 'm'
        MATLABAomControl32('MarkFrame#');
    else
        % marks the video frame when the subject responds.
        netcomm('write',SYSPARAMS.netcommobj,int8('MarkFrame#'));
    end
else
    %set(handles.pushbutton9,'String','Sync Save'); set(handles.pushbutton9,'BackgroundColor',[0.941176 0.941176 0.941176]); set(handles.pushbutton9,'ForegroundColor',[0 0 0]); PupilParam.Sync=0;
    
    if PupilParam.Video==1 & PupilParam.PTFlag==1
        PupilParam.PTFlag=0;
        set(hObject,'String','Save Pupil Tracking');
        set(hObject,'BackgroundColor',[0.941176 0.941176 0.941176]); set(hObject,'ForegroundColor',[0 0 0]);
        DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
        PupilData.Data=PupilParam.PTData; PupilData.Pixel_calibration=PupilParam.Pixel_calibration;
        Prefix=get(handles.edit3,'String');
        save(['.\VideoAndRef\',Prefix,'DataPupil_',DateString], 'PupilData')
        PupilParam.PTData=[];
    end
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilParam
if PupilParam.Sync==0 && PupilParam.Video==1,
    PupilParam.Sync=1;
    PupilParam.DataSync=[];
    set(hObject,'String','Wait for Sync');
    set(hObject,'BackgroundColor',[0.75 0 0]); set(hObject,'ForegroundColor',[1 1 1]);
else
    set(hObject,'String','Sync Save');
    set(hObject,'BackgroundColor',[0.941176 0.941176 0.941176]); set(hObject,'ForegroundColor',[0 0 0]);
    PupilParam.Sync=0;
    if ~isempty(PupilParam.DataSync)  
        DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
        Prefix=get(handles.edit3,'String');
        PupilData=PupilParam.DataSync;
        save(['.\VideoAndRef\','Trial_DataPupil_',Prefix,'_',DateString], 'PupilData')
        PupilParam.DataSync=[];
    end
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid
global CameraSetting
if CameraSetting.ExposureMode==1
    CameraSetting.ExposureMode=2;
    %     disp(CameraSetting.Exposure)
    %     disp(CameraSetting.Gain)
    SetCameraSetting(handles,CameraSetting)
    set(hObject,'String','Auto');
else
    CameraSetting.ExposureMode=1;
    set(hObject,'String','Manual');
end
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end



% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global CameraSetting;
CameraSetting.Brightness=round(get(hObject,'Value'));
SetCameraSettingText(handles,CameraSetting);
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global CameraSetting
CameraSetting.Contrast=round(get(hObject,'Value'));
SetCameraSettingText(handles,CameraSetting);
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global CameraSetting
CameraSetting.Exposure=round(get(hObject,'Value'));
SetCameraSettingText(handles,CameraSetting);
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global CameraSetting
CameraSetting.Gain=round(get(hObject,'Value'));
SetCameraSettingText(handles,CameraSetting);
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global CameraSetting
CameraSetting.Gamma=round(get(hObject,'Value'));
SetCameraSettingText(handles,CameraSetting);
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end

% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global CameraSetting
CameraSetting.Hue=round(get(hObject,'Value'));
SetCameraSettingText(handles,CameraSetting);
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end

% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global CameraSetting
CameraSetting.Saturation=round(get(hObject,'Value'));
SetCameraSettingText(handles,CameraSetting);
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end

% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider10_Callback(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global CameraSetting
CameraSetting.Sharpness=round(get(hObject,'Value'));
SetCameraSettingText(handles,CameraSetting);
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end

% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CameraSetting
CS=CameraSetting;
save CS CS


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CameraSetting
load CS
CameraSetting=CS;
SetCameraSetting(handles,CameraSetting)
global vid;
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CameraSetting;    
CameraSetting.Brightness=0;
CameraSetting.Contrast=0;
CameraSetting.Exposure=-13;
CameraSetting.ExposureMode=2; %1=manual, 2 =auto
CameraSetting.Gain=16;
CameraSetting.Gamma=100;
CameraSetting.Hue=0;
CameraSetting.Saturation=64;
CameraSetting.Sharpness=0;

global vid;
SetCameraSetting(handles,CameraSetting)
if get(handles.pushbutton2,'UserData')==1, %video in progress
    SetCameraValues(vid,CameraSetting);
    set(handles.pushbutton10,'String','Auto');
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SYSPARAMS PupilParam
OrgnlColor=[0.941176 0.941176 0.941176];

if PupilParam.EnableTCAComp==0
    set(hObject,'String','Disable TCA Correction');
    PupilParam.EnableTCAComp=1;
    PupilParam.totaloffx=[];
    PupilParam.totaloffy=[];
    set(hObject,'BackgroundColor',[0.75 0 0]);
    set(hObject,'ForegroundColor',[1 1 1]);
else
    
    if SYSPARAMS.realsystem == 1
        % AEB changed aligncommand on 5/30/2017
        % removes the TCA-pupil correction from the aom offsets 
        global StimParams 
        aligncommand = ['UpdateOffset#' num2str(StimParams.aomoffs(1, 1)) '#' num2str(StimParams.aomoffs(1, 2)) '#' num2str(StimParams.aomoffs(2, 1)) '#' num2str(StimParams.aomoffs(2, 2)) '#' num2str(StimParams.aomoffs(3, 1)) '#' num2str(StimParams.aomoffs(3, 2)) '#'];   %#ok<NASGU>
        %aligncommand = ['UpdateOffset#' num2str(0) '#' num2str(0) '#' num2str(0) '#' num2str(0) '#' num2str(0) '#' num2str(0) '#'];   %#ok<NASGU>
        if SYSPARAMS.board == 'm'
            MATLABAomControl32(aligncommand);
        else
            netcomm('write',SYSPARAMS.netcommobj,int8(aligncommand));
        end
    end
    PupilParam.EnableTCAComp=0;
    
    set(hObject,'String','Enable TCA Correction');
    set(hObject,'BackgroundColor',OrgnlColor);
    set(hObject,'ForegroundColor',[0 0 0]);
    % 
end



% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilParam
if PupilParam.DisableTracking==0;
    set(hObject,'String','Enable Tracking');
    PupilParam.DisableTracking=1;
else
    set(hObject,'String','Disable Tracking');
    PupilParam.DisableTracking=0;
end


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
global CameraSetting;
global PupilParam;
if CameraSetting.ROI(4)==768
    set(hObject,'String','Zoom Out');
    CameraSetting.ROI=[312  184 400 400];
    PupilParam.AvoidedBorder=round(CameraSetting.ROI(3)/5.1);
else
    set(hObject,'String','Zoom In');
    CameraSetting.ROI=[128 0 768 768];
    PupilParam.AvoidedBorder=round(CameraSetting.ROI(3)/5.1);
end

SetCameraValues(vid,CameraSetting);

if  get(handles.pushbutton2,'UserData')==1,
    stoppreview(vid)
    nBands = vid.NumberOfBands;
    axes(handles.axes1);
    hold off
    %set(ha,'DataAspectRatio',[(CameraSetting.ROI(3) - CameraSetting.ROI(1)) (CameraSetting.ROI(4)-CameraSetting.ROI(2)) 1]);
    %set(handles.axes1,'BeingDeleted','on')
    h = image(zeros(CameraSetting.ROI(4),CameraSetting.ROI(3), nBands), 'parent', handles.axes1);
    %     set(handles.axes1,'CameraPosition',[((CameraSetting.ROI(3) - CameraSetting.ROI(1))/2 +0.5)...
    %         ((CameraSetting.ROI(4)-CameraSetting.ROI(2))./2+0.5) 9.5]);
    %     set(handles.axes1,'CameraTarget',[((CameraSetting.ROI(3) - CameraSetting.ROI(1))/2 +0.5)...
    %         ((CameraSetting.ROI(4)-CameraSetting.ROI(2))./2+0.5) 0.5]);
    %     set(handles.axes1,'DataAspectRatio',[((CameraSetting.ROI(3) - CameraSetting.ROI(1)))...
    %         ((CameraSetting.ROI(4)-CameraSetting.ROI(2))) 1]);
    %
    %     set(handles.axes1,'CameraTargetMode','manual')
    %setappdata(h,'UpdatePreviewWindowFcn',@PupilTrackingAlg);
    
    preview(vid,h);
    axes(handles.axes1);
    hold on
    
    %set(ha,'DataAspectRatio',[(CameraSetting.ROI(3) - CameraSetting.ROI(1)) (CameraSetting.ROI(4)-CameraSetting.ROI(2)) 1]);
    %hold on
    src_obj = getselectedsource(vid); PupilParam.Camerafps= str2num(get(src_obj,'FrameRate'));
    %**************************************************%
    %********* settings camera variables **************%
    %PupilParam.ShowReference=0;
    %PupilParam.l1=plot(1,1);
    %PupilParam.l2=plot(1,1);
    %PupilParam.l11=plot(1,1);
    %PupilParam.l22=plot(1,1);
    PupilParam.l3=plot(1,1);
    PupilParam.l4=plot(1,1);
    PupilParam.l5=plot(1,1);
    PupilParam.l6=plot(1,1);
    PupilParam.l7=plot(1,1);
    PupilParam.l8=plot(1,1);
    PupilParam.p1=plot(1,1);
    %PupilParam.p2=plot(1,1);
    %PupilParam.p3=plot(1,1);
    
    PupilParam.v1=plot(1,1);
    PupilParam.v2=plot(1,1);
    PupilParam.v3=plot(1,1);
    PupilParam.v4=plot(1,1);
    
    
    PupilParam.c1=plot(1,1);
    PupilParam.c2=plot(1,1);
    PupilParam.c3=plot(1,1);
    PupilParam.c4=plot(1,1);
    PupilParam.c5=plot(1,1);
    
    PupilParam.r1=plot(1,1);
    PupilParam.r2=plot(1,1);
    PupilParam.r3=plot(1,1);
    PupilParam.r4=plot(1,1);
    
    PupilParam.x1=-1; PupilParam.x2=-1; PupilParam.y1=-1; PupilParam.y2=-1;
    PupilParam.graylevel=255;
    PupilParam.Re=-1000; PupilParam.Th=-1;
    
    setappdata(h,'UpdatePreviewWindowFcn',@PupilTrackingAlg);
    
    PupilParam.Video=1;
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
global PupilParam
load CalibrationSetting
CalibrationSetting(4)=str2num(get(hObject,'String'));
save CalibrationSetting CalibrationSetting
PupilParam.TolleratedPupilDistance=CalibrationSetting(4);
%PupilParam.Pixel_calibration=PupilParam.vidRes(1)/CalibrationSetting(1);


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
load CalibrationSetting
set(hObject,'Value',CalibrationSetting(4));
set(hObject,'String',num2str(CalibrationSetting(4)));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
global PupilParam
load CalibrationSetting
Str=get(hObject,'String'); idx=strfind(Str,'/'); 
if length(idx)==1
    CalibrationSetting(2)=str2num(Str(1:idx-1));
    CalibrationSetting(3)=str2num(Str((idx+1):end));
    save CalibrationSetting CalibrationSetting
    PupilParam.TCAmmX=CalibrationSetting(2);
    PupilParam.TCAmmY=CalibrationSetting(3);
end



% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
load CalibrationSetting
Str=[num2str(CalibrationSetting(2)),'/',num2str(CalibrationSetting(3))];
set(hObject,'Value',CalibrationSetting(2)*100+CalibrationSetting(3));
set(hObject,'String',Str);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilParam
if PupilParam.ShowFocus==0,
    PupilParam.ShowFocus=1;
    set(hObject,'String','Hide Focus');
else
    PupilParam.ShowFocus=0;
    set(hObject,'String','Show Focus');
end




function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global SYSPARAMS PupilParam
SYSPARAMS.PupilTracker=0;
DateString = datestr(clock); Spaceidx=findstr(DateString,' '); DateString(Spaceidx)='_'; Spaceidx=findstr(DateString,':'); DateString(Spaceidx)='_';
Prefix=get(handles.edit3,'String');
PupilData=PupilParam.DataSync;
if ~isempty(PupilParam.DataSync), save(['.\VideoAndRef\','Trial_DataPupil_',Prefix,'_',DateString], 'PupilData'); end
delete(hObject);

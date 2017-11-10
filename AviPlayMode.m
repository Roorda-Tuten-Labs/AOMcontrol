function varargout = AviPlayMode(varargin)
% AVIPLAYMODE M-file for AviPlayMode.fig
%      AVIPLAYMODE, by itself, creates a new AVIPLAYMODE or raises the existing
%      singleton*.
%
%      H = AVIPLAYMODE returns the handle to a new AVIPLAYMODE or the handle to
%      the existing singleton*.
%
%      AVIPLAYMODE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AVIPLAYMODE.M with the given input arguments.
%
%      AVIPLAYMODE('Property','Value',...) creates a new AVIPLAYMODE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AviPlayMode_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AviPlayMode_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AviPlayMode

% Last Modified by GUIDE v2.5 15-Dec-2011 16:22:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AviPlayMode_OpeningFcn, ...
                   'gui_OutputFcn',  @AviPlayMode_OutputFcn, ...
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


% --- Executes just before AviPlayMode is made visible.
function AviPlayMode_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AviPlayMode (see VARARGIN)

% Choose default command line output for AviPlayMode
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AviPlayMode wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SYSPARAMS StimParams VideoParams;
if (VideoParams.vidrecord == 1)    
    save_avi_Callback(hObject, eventdata, handles);
else
    play_avi_Callback(hObject, eventdata, handles);
end
set(handles.replay_times_edit, 'String', num2str(StimParams.avireplaytimes));
set(handles.loop_infinite, 'Value', StimParams.avireplayinfinite);
set(handles.loop_video, 'Value', SYSPARAMS.loop);
loop_video_Callback(hObject, eventdata, handles);
loop_infinite_Callback(hObject, eventdata, handles);
set(handles.prefix_edit, 'String', VideoParams.vidprefix);



% --- Outputs from this function are returned to the command line.
function varargout = AviPlayMode_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in play_avi.
function play_avi_Callback(hObject, eventdata, handles)
% hObject    handle to play_avi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of play_avi
set(handles.save_avi,'Value',0);
set(handles.play_avi,'Value',1);
set(handles.prefix_lbl,'Visible','off');
set(handles.prefix_edit,'Visible','off');
if get(handles.loop_video, 'Value') == 1
    set(handles.loop_infinite, 'Visible', 'on');
    set(handles.replay_times_edit,'Visible','on');
    set(handles.replay_times_lbl,'Visible','on');
    if get(handles.loop_infinite, 'Value') == 0        
        set(handles.replay_times_edit,'Enable','on');
    else         
        set(handles.replay_times_edit,'Enable','off');
    end
end


% --- Executes on button press in save_avi.
function save_avi_Callback(hObject, eventdata, handles)
% hObject    handle to save_avi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save_avi
set(handles.play_avi,'Value',0);
set(handles.save_avi,'Value',1);
if get(handles.loop_video, 'Value') == 1
    set(handles.replay_times_edit,'Enable','on');
    set(handles.replay_times_edit,'Visible','on');
    set(handles.replay_times_lbl,'Visible','on');
end
set(handles.prefix_lbl,'Visible','on');
set(handles.prefix_edit,'Visible','on');
set(handles.loop_infinite, 'Value', 0);
set(handles.loop_infinite, 'Visible', 'off');



function replay_times_edit_Callback(hObject, eventdata, handles)
% hObject    handle to replay_times_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of replay_times_edit as text
%        str2double(get(hObject,'String')) returns contents of replay_times_edit as a double
if str2num(get(handles.replay_times_edit, 'String')) < 2
    set(handles.replay_times_edit, 'String', '2');
end


% --- Executes during object creation, after setting all properties.
function replay_times_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to replay_times_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loop_video.
function loop_video_Callback(hObject, eventdata, handles)
% hObject    handle to loop_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loop_video
global SYSPARAMS StimParams;
if get(handles.loop_video,'Value') == 1
    set(handles.replay_times_edit,'Visible','on');
    set(handles.replay_times_edit,'Enable','on');
    set(handles.replay_times_lbl,'Visible','on');
    if get(handles.save_avi,'Value')==1
        set(handles.loop_infinite,'Visible','off');
    else
        set(handles.loop_infinite,'Visible','on');
    end
else    
    set(handles.replay_times_edit,'Visible','off');
    set(handles.replay_times_lbl,'Visible','off');
    set(handles.loop_infinite,'Visible','off');
end
loop_infinite_Callback(hObject, eventdata, handles);


% --- Executes on button press in loop_infinite.
function loop_infinite_Callback(hObject, eventdata, handles)
% hObject    handle to loop_infinite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loop_infinite
if get(handles.loop_infinite,'Value') == 1
    set(handles.replay_times_edit,'Enable','off');
else    
    set(handles.replay_times_edit,'Enable','on');
end



function prefix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefix_edit as text
%        str2double(get(hObject,'String')) returns contents of prefix_edit as a double


% --- Executes during object creation, after setting all properties.
function prefix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS StimParams VideoParams;
VideoParams.vidprefix = get(handles.prefix_edit, 'String');
SYSPARAMS.loop = get(handles.loop_video,'Value');
StimParams.avireplayinfinite = get(handles.loop_infinite,'Value');
StimParams.avireplaytimes = str2num(get(handles.replay_times_edit, 'String'));
StimParams.avireplayinfinite = get(handles.loop_infinite,'Value');
if (get(handles.save_avi,'Value')==1)
    VideoParams.vidrecord = 1;
else
    VideoParams.vidrecord = 0;
end
close;


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



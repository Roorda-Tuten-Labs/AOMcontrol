function varargout = TCAdetails(varargin)
% TCADETAILS MATLAB code for TCAdetails.fig
%      TCADETAILS, by itself, creates a new TCADETAILS or raises the existing
%      singleton*.
%
%      H = TCADETAILS returns the handle to a new TCADETAILS or the handle to
%      the existing singleton*.
%
%      TCADETAILS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TCADETAILS.M with the given input arguments.
%
%      TCADETAILS('Property','Value',...) creates a new TCADETAILS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TCAdetails_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TCAdetails_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TCAdetails

% Last Modified by GUIDE v2.5 17-Mar-2022 13:36:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TCAdetails_OpeningFcn, ...
                   'gui_OutputFcn',  @TCAdetails_OutputFcn, ...
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


% --- Executes just before TCAdetails is made visible.
function TCAdetails_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TCAdetails (see VARARGIN)

% Choose default command line output for TCAdetails
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TCAdetails wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TCAdetails_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function subjectID_Callback(hObject, eventdata, handles)
% hObject    handle to subjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectID as text
%        str2double(get(hObject,'String')) returns contents of subjectID as a double


% --- Executes during object creation, after setting all properties.
function subjectID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function videoDuration_Callback(hObject, eventdata, handles)
% hObject    handle to videoDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of videoDuration as text
%        str2double(get(hObject,'String')) returns contents of videoDuration as a double


% --- Executes during object creation, after setting all properties.
function videoDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in computeTCA.
function computeTCA_Callback(hObject, eventdata, handles)
% hObject    handle to computeTCA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set video prefix and video duration
global SYSPARAMS VideoParams;
VideoParams.vidprefix = get (handles.subjectID, 'String');
VideoParams.videodur = str2num(get(handles.videoDuration, 'String'));
VideoParams.numofvideos = str2num(get(handles.numofVideos, 'String'));
psyfname = set_VideoParams_PsyfileName();
%construct filename
ind = strfind(psyfname,'\');
CFG.filepath = psyfname(1:ind(length(ind)));
% tempfilename = psyfname(ind(length(ind))+1:end);
% ind = strfind(tempfilename,'_');
CFG.filename = [VideoParams.vidprefix '_TCA_'];
CFG.validateTCA =  get(handles.validatetca_cb, 'Value');
CFG.ok = 1;
hAomControl = getappdata(0,'hAomControl');
setappdata(hAomControl, 'CFG', CFG);
close;


% --- Executes on button press in tcadetailsCancel.
function tcadetailsCancel_Callback(hObject, eventdata, handles)
% hObject    handle to tcadetailsCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hAomControl = getappdata(0,'hAomControl');
CFG.ok = 0;
setappdata(hAomControl, 'CFG', CFG);
close;



function numofVideos_Callback(hObject, eventdata, handles)
% hObject    handle to numofVideos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numofVideos as text
%        str2double(get(hObject,'String')) returns contents of numofVideos as a double


% --- Executes during object creation, after setting all properties.
function numofVideos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numofVideos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in validatetca_cb.
function validatetca_cb_Callback(hObject, eventdata, handles)
% hObject    handle to validatetca_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CFG.validateTCA =  get(handles.validatetca_cb, 'Value');
% Hint: get(hObject,'Value') returns toggle state of validatetca_cb

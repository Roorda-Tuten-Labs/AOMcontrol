function varargout = AOMselection(varargin)
% AOMSELECTION M-file for AOMselection.fig
%      AOMSELECTION, by itself, creates a new AOMSELECTION or raises the existing
%      singleton*.
%
%      H = AOMSELECTION returns the handle to a new AOMSELECTION or the handle to
%      the existing singleton*.
%
%      AOMSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AOMSELECTION.M with the given input arguments.
%
%      AOMSELECTION('Property','Value',...) creates a new AOMSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AOMselection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AOMselection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AOMselection

% Last Modified by GUIDE v2.5 15-Jun-2011 10:43:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AOMselection_OpeningFcn, ...
                   'gui_OutputFcn',  @AOMselection_OutputFcn, ...
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


% --- Executes just before AOMselection is made visible.
function AOMselection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AOMselection (see VARARGIN)
global SYSPARAMS;
% Choose default command line output for AOMselection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.irsel, 'Visible', 'Off');
set(handles.redsel, 'Visible', 'Off');
set(handles.greensel, 'Visible', 'Off')
set(handles.bluesel, 'Visible', 'Off');
if SYSPARAMS.aoms_state(1) == 1
    set(handles.irsel, 'Visible', 'On');
    if sum(SYSPARAMS.aoms_state) == 1
        set(handles.irsel, 'Value', 1);
    end
end
if SYSPARAMS.aoms_state(2) == 1
    set(handles.redsel, 'Visible', 'On');
    if sum(SYSPARAMS.aoms_state) == 1
        set(handles.redsel, 'Value', 1);
    end
end
if SYSPARAMS.aoms_state(3) == 1
    set(handles.greensel, 'Visible', 'On');
    if sum(SYSPARAMS.aoms_state) == 1
        set(handles.greensel, 'Value', 1);
    end
end
if SYSPARAMS.aoms_state(4) == 1
    set(handles.bluesel, 'Visible', 'On');
    if sum(SYSPARAMS.aoms_state) == 1
        set(handles.bluesel, 'Value', 1);
    end
end
if ~isempty(varargin)
    if strcmp(varargin, 'N') 
        set(handles.clearbuf, 'Visible', 'Off');
    end
end

% UIWAIT makes AOMselection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AOMselection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in clearbuf.
function clearbuf_Callback(hObject, eventdata, handles)
% hObject    handle to clearbuf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of clearbuf


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS;
AOMSel.loadbuf = 0;
if SYSPARAMS.aoms_state(1) == 1
    if get(handles.irsel, 'Value') == 1
    AOMSel.loadbuf = 0;
    end
end
if SYSPARAMS.aoms_state(2) == 1
    if get(handles.redsel, 'Value') == 1
        AOMSel.loadbuf = 1;
    end
end
if SYSPARAMS.aoms_state(3) == 1
    if get(handles.greensel, 'Value') == 1
        AOMSel.loadbuf = 2;
    end
end
if SYSPARAMS.aoms_state(4) == 1
    if get(handles.bluesel, 'Value') == 1
        AOMSel.loadbuf = 3;
    end
end
AOMSel.clearbuf = get(handles.clearbuf, 'Value');
hAomControl = getappdata(0,'hAomControl');
setappdata(hAomControl, 'AOMSel', AOMSel);
close;




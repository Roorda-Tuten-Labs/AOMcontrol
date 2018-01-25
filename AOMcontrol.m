function varargout = AOMcontrol(varargin)
% AOMCONTROL M-file for AOMcontrol.fig
% Interfaces available
% Strategic - runs only two channels
% FPGA - currently runs only two channels on AOSLOII, 3channels on AOSLOIV
% Commands available
% Common for both FPGA/Strategic interfaces-


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AOMcontrol_OpeningFcn, ...
                   'gui_OutputFcn',  @AOMcontrol_OutputFcn, ...
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


% --- Executes just before AOMcontrol is made visible.
function AOMcontrol_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AOMcontrol (see VARARGIN)

% Choose default command line output for AOMcontrol
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SYSPARAMS VideoParams StimParams OrigFrame CurFrame ExpCfgParams; %#ok<NUSED>

setappdata(0, 'hAomControl', gcf);
hAomControl = getappdata(0,'hAomControl');
set(gcf, 'Position', [1300 225 614 757])
imglist = cell(0);
imglist{1,1} = '<select from disk>';
imglist{2,1} = 'gridscale 0.5 degree';
imglist{3,1} = 'gridscale 1 degree';
imglist{4,1} = 'gridscale 2 degree';
imglist{5,1} = 'gridscale 2.5 degree';
imglist{6,1} = 'gridscale 3 degree';
imglist{7,1} = 'fixation target';
imglist{8,1} = '20/20 E';
setappdata(hAomControl, 'ImageList', imglist);
buflist = cell(0);
buflist{1,1}='-';
buflist{1,2}='-';
buflist{1,3}='-';
setappdata(hAomControl, 'BufList', buflist);
set(handles.bufferlist, 'Value', 1);
set(handles.bufferlist, 'String', char(buflist{:,2}));

init_load = 0;
if exist('Initialization.mat','file')==2
    load 'Initialization.mat';
    init_load = 1;
    SYSPARAMS.aompowerLvl(1) = 1; %IR
    SYSPARAMS.aompowerLvl(2) = 1; %Red
    SYSPARAMS.aompowerLvl(3) = 1; %Green
else
    SYSPARAMS.aoms_enable = zeros(4,1);
    SYSPARAMS.aoms_enable(1) = 1;
    SYSPARAMS.aoms_enable(2) = 1;
    SYSPARAMS.aoms_enable(3) = 1;
    SYSPARAMS.aoms_enable(4) = 0;
    SYSPARAMS.aompowerLvl(1) = 1; %IR
    SYSPARAMS.aompowerLvl(2) = 0; %Red
    SYSPARAMS.aompowerLvl(3) = 0; %Green
    SYSPARAMS.aompowerLvl(4) = 0; %Blue
    SYSPARAMS.aomuWPower(1) = 1; %IR
    SYSPARAMS.aomuWPower(2) = 1; %Red
    SYSPARAMS.aomuWPower(3) = 1; %Green
    SYSPARAMS.aomuWPower(4) = 0; %Blue
    SYSPARAMS.system = 4;
    StimParams.filepath = cell(0);
    StimParams.filepath{1} = '-'; % IR filename
    StimParams.filepath{2} = '-'; % Red filename
    StimParams.filepath{3} = '-'; % Green filename
    StimParams.filepath{4} = '-'; % Blue filename
    StimParams.aomoffs(1,1) = 0; %Red OffsX
    StimParams.aomoffs(1,2) = 0; %Red OffsY
    StimParams.aomoffs(2,1) = 0; %Green OffsX
    StimParams.aomoffs(2,2) = 0; %Green OffsY
    StimParams.aomoffs(3,1) = 0; %Blue OffsX
    StimParams.aomoffs(3,2) = 0; %Blue OffsY
end

SYSPARAMS.PupilTracker=0;       %%cmp
SYSPARAMS.PupilDuration=0;      %%cmp
SYSPARAMS.PupilTCAx=-10000;     %%cmp
SYSPARAMS.PupilTCAy=-10000;     %%cmp
SYSPARAMS.PupilTCACorrection=0; %%cmp, 0 is no correction 1 is correction

system = 4; %this is the system number for AOSLO I or AOSLO II or AOSLOIV
if SYSPARAMS.system ~= system
    init_load = 0;
    SYSPARAMS.system = system;
end
if system == 1
    if (init_load == 0)
        SYSPARAMS.rasterV = 480;
        SYSPARAMS.rasterH = 512;
    end
    SYSPARAMS.aoms_enable(3) = 0;
    set(handles.blue_on_off, 'Visible', 'Off');
    set(handles.green_on_off, 'Visible', 'Off');
    set(handles.aom2_power_radio, 'Visible', 'Off');
    set(handles.aom3_power_radio, 'Visible', 'Off');
    OrigFrame.ir = uint8(ones(SYSPARAMS.rasterH, SYSPARAMS.rasterV)*50);
    OrigFrame.red = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV));    
    set(handles.alignredh, 'Enable', 'On');    
    set(handles.alignredh, 'Visible', 'On'); 
    set(handles.alignredv, 'Enable', 'On');    
    set(handles.alignredv, 'Visible', 'On'); 
elseif system == 2 
    if (init_load == 0)
        SYSPARAMS.rasterV = 512;
        SYSPARAMS.rasterH = 512;
    end
    SYSPARAMS.aoms_enable(3) = 0;
    set(handles.blue_on_off, 'Visible', 'Off');
    set(handles.green_on_off, 'Visible', 'Off');
    set(handles.aom2_power_radio, 'Visible', 'Off');
    set(handles.aom3_power_radio, 'Visible', 'Off');
    OrigFrame.ir = uint8(ones(SYSPARAMS.rasterH, SYSPARAMS.rasterV)*50);
    OrigFrame.red = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
    set(handles.alignredh, 'Enable', 'On');    
    set(handles.alignredh, 'Visible', 'On'); 
    set(handles.alignredv, 'Enable', 'On');    
    set(handles.alignredv, 'Visible', 'On');     
elseif system == 4 
    if (init_load == 0)
        SYSPARAMS.rasterV = 512;
        SYSPARAMS.rasterH = 512;
    end
    set(handles.blue_on_off, 'Visible', 'Off');
    set(handles.aom3_power_radio, 'Visible', 'Off');
    OrigFrame.ir = uint8(ones(SYSPARAMS.rasterH, SYSPARAMS.rasterV)*50);
    OrigFrame.red = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
    OrigFrame.green = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
    set(handles.alignredh, 'Enable', 'On');    
    set(handles.alignredh, 'Visible', 'On');  
    set(handles.alignredv, 'Enable', 'On');    
    set(handles.alignredv, 'Visible', 'On');  
    set(handles.aligngrh, 'Enable', 'On');    
    set(handles.aligngrh, 'Visible', 'On');  
    set(handles.aligngrv, 'Enable', 'On');    
    set(handles.aligngrv, 'Visible', 'On');      
elseif system == 5 %virtual system with 4 channels for now
    if (init_load == 0)
        SYSPARAMS.rasterV = 512;
        SYSPARAMS.rasterH = 512;
    end
    OrigFrame.ir = 0;
    OrigFrame.red = 0;
    OrigFrame.green = 0;
    OrigFrame.blue = 0;
    set(handles.alignredh, 'Enable', 'On');    
    set(handles.alignredh, 'Visible', 'On');  
    set(handles.alignredv, 'Enable', 'On');    
    set(handles.alignredv, 'Visible', 'On');  
    set(handles.aligngrh, 'Enable', 'On');    
    set(handles.aligngrh, 'Visible', 'On');  
    set(handles.aligngrv, 'Enable', 'On');    
    set(handles.aligngrv, 'Visible', 'On');   
    set(handles.alignblueh, 'Enable', 'On');    
    set(handles.alignblueh, 'Visible', 'On');  
    set(handles.alignbluev, 'Enable', 'On');    
    set(handles.alignbluev, 'Visible', 'On');   
end
CurFrame  = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV, 3));
CurFrame(:,:,1) = 50;
SYSPARAMS.realsystem = 0;
if (init_load == 0)
    SYSPARAMS.loop = 1;
    VideoParams.rootfolder = fullfile('D:', 'Video_Folder');
    VideoParams.videofolder = 'no video folder';
    VideoParams.vidprefix = 'Sample';
    VideoParams.videodur = 1;
    VideoParams.vidrecord = 0;
    StimParams.stimpath = fullfile(pwd, 'BMP_files');
    StimParams.fext = 'bmp';
    StimParams.avireplaytimes = 2;
    StimParams.avireplayinfinite = 0;
    SYSPARAMS.aoms_state(1) = 1;
    SYSPARAMS.aoms_state(2) = 0;
    SYSPARAMS.aoms_state(3) = 0;
    SYSPARAMS.aoms_state(4) = 0;
    SYSPARAMS.aom_pow_sel = 0;
    SYSPARAMS.sysmode = 0;
    SYSPARAMS.tracking = 0;
    SYSPARAMS.aomoffshsel = 1;
    SYSPARAMS.aomoffsvsel = 1;
end
%check for the validity of root folder
if (exist(VideoParams.rootfolder, 'dir') ~= 7)
    VideoParams.rootfolder = fullfile('D:', 'Video_Folder');    
    if (exist(VideoParams.rootfolder, 'dir') ~= 7)
        mkdir(VideoParams.rootfolder);
    end
end
set(handles.ir_on_off, 'Value', SYSPARAMS.aoms_state(1));
set(handles.red_on_off, 'Value', SYSPARAMS.aoms_state(2));
set(handles.green_on_off, 'Value', SYSPARAMS.aoms_state(3));
set(handles.blue_on_off, 'Value', SYSPARAMS.aoms_state(4));
set(handles.alignment_panel,'Visible','On');
set(handles.alignmentv_panel,'Visible','On');
set(handles.alignh_slider,'SliderStep', [(1/64),(10/64)]);
set(handles.alignv_slider,'SliderStep', [(1/32),(10/32)]);
set(handles.alignh_slider, 'Value', 32-StimParams.aomoffs(1,2));
set(handles.alignv_slider, 'Value', 16+StimParams.aomoffs(1,1));
set(handles.alignh_val, 'String', num2str(StimParams.aomoffs(1,2)));
set(handles.alignv_val, 'String', num2str(StimParams.aomoffs(1,1)));
StimParams.wavfileplay = 0;
[StimParams.wavfile, Fs] = audioread('breep.wav');
button = questdlg('Are you running on AOSLO?','Select Application mode','Yes', 'No','Yes');
if button(1) == 'Y'
    SYSPARAMS.realsystem = 1; 
    VideoParams.vidrecord = 1;
end
if SYSPARAMS.realsystem == 1
    button = 'FPGA';
    if system == 2
    button = questdlg('Which Imaging Board would you like to use?','Select Imaging Board','Matrox', 'FPGA','FPGA');
    end
    switch button,
        case 'Matrox'
            SYSPARAMS.board = 'm';
            hAomControl = getappdata(0,'hAomControl');
            MATLABAomControl32(['Mode#' num2str(system) '#']);
            MATLABAomControl32('Start#1#');
            MATLABAomControl32('ExtClockOn#');
            set(handles.trackingen, 'Visible','On');
            set(handles.flash_freq_panel, 'Visible','On');
            set(handles.reset_button, 'Visible', 'On');
            MATLABAomControl32(['AlignH#10#']);
            command = ['UpdatePower#0#' num2str(SYSPARAMS.aompowerLvl(1)) '#'];
            MATLABAomControl32(command);            
        case 'FPGA'
            SYSPARAMS.board = 'f';
            h = msgbox('Make sure you have FPGA application running before initiating this mode', 'Warning', 'warn');
            uiwait(h);
            SYSPARAMS.netcommobj = netcomm('REQUEST', '127.0.0.1', 1300, 'timeout', 5000);                        
            aligncommand = ['UpdateOffset#' num2str(StimParams.aomoffs(1, 1)) '#' num2str(StimParams.aomoffs(1, 2)) '#' num2str(StimParams.aomoffs(2, 1)) '#' num2str(StimParams.aomoffs(2, 2)) '#' num2str(StimParams.aomoffs(3, 1)) '#' num2str(StimParams.aomoffs(3, 2)) '#'];   %#ok<NASGU>
            netcomm('write',SYSPARAMS.netcommobj,int8(aligncommand));
            pause(0.1);
            command = ['UpdatePower#0#' num2str(SYSPARAMS.aompowerLvl(1)) '#'];            
            netcomm('write',SYSPARAMS.netcommobj,int8(command));
            pause(0.1);
            command = ['UpdatePower#1#' num2str(SYSPARAMS.aompowerLvl(2)) '#'];            
            netcomm('write',SYSPARAMS.netcommobj,int8(command));
            pause(0.1);
            command = ['UpdatePower#2#' num2str(SYSPARAMS.aompowerLvl(3)) '#'];            
            netcomm('write',SYSPARAMS.netcommobj,int8(command));
    end
end

switch SYSPARAMS.aom_pow_sel
    case 0
        aom0_power_radio_Callback();
    case 1
        aom1_power_radio_Callback();
    case 2
        aom2_power_radio_Callback();
    case 3
        aom3_power_radio_Callback();
end

a = imread('on.bmp');
set(handles.aom1_onoff, 'Cdata', a);
set(handles.aom1_state, 'String', 'On');
set(handles.aom_main_figure, 'Name', 'AOSLO AOM Control v3.0 - Multiple Frame Mode');
h = get(handles.im_panel1, 'Child');
frame = uint8(zeros(SYSPARAMS.rasterV,SYSPARAMS.rasterH,3));
frame(:,:,1) = 50;
axes(h); %#ok<MAXES>
h = imshow(frame,'InitialMagnification',100, 'Border', 'tight');
set(handles.raster1, 'NextPlot','replacechildren');
set(h,'ButtonDownFcn',@raster1_ButtonDownFcn);
addpath('Experiments');
ParseExperiments;
set(handles.power_slider, 'Enable','On');
set(handles.aom0_power_radio, 'Enable','On');
set(handles.aom1_power_radio, 'Enable','On');
set(handles.aom2_power_radio, 'Enable','On');
set(handles.aom3_power_radio, 'Enable','On');
set(handles.alignh_slider, 'Enable','Off');
set(handles.alignv_slider, 'Enable','Off');

% --- Outputs from this function are returned to the command line.
function varargout = AOMcontrol_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function ParseExperiments
d=dir('Experiments');
explist={};
index = 1;
for j = 1:size(d,1)
    fname = d(j).name;
    if size(fname,2) > 2
        fext = fname(size(fname,2));
        if strcmp(fext,'m')
            if (isempty(strfind(fname,'config')) && isempty(strfind(fname,'Config')) && isempty(strfind(fname,'Template')))            
                explist(index) = cellstr(fname(1:size(fname,2)-2)); %#ok<AGROW>
                index = index+1;
            end
        end
    end
end
hAomControl = getappdata(0,'hAomControl');
setappdata(hAomControl, 'ExpList', explist);

function menu_quit_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
% hObject    handle to menu_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS VideoParams StimParams; %#ok<NUSED>
save('Initialization.mat', 'SYSPARAMS', 'VideoParams', 'StimParams');
if SYSPARAMS.realsystem == 1
    if SYSPARAMS.board == 'm'
        MATLABAomControl32('Stop#');
        pause(.05);
        MATLABAomControl32('ExtClockOff#');
    else
        netcomm('close',SYSPARAMS.netcommobj);
        rmappdata(0,'hAomControl');
        clear all;
    end
else
    rmappdata(0,'hAomControl');
    clear all;
end
close;

% --- Executes on button press in image_radio1.
function image_radio1_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
global SYSPARAMS;
SYSPARAMS.sysmode = 0;
set(handles.loop_sequence, 'Visible', 'Off');
set(handles.popup_panel1, 'Title', 'Image To Display');
set(handles.im_popup1, 'Value', 1);
hAomControl = getappdata(0,'hAomControl');
list = getappdata(hAomControl, 'ImageList');
set(handles.im_popup1, 'String', list);
set(handles.display_button, 'String', 'Display Image');
set(handles.im_popup1,'Enable', 'on');
set(handles.play_button1, 'Enable', 'off');
set(handles.display_button, 'Enable', 'on');
set(handles.aom1_onoff, 'Enable', 'on');
set(handles.loop_sequence, 'Visible', 'off');
if SYSPARAMS.realsystem == 1 && SYSPARAMS.board == 'm'
    set(handles.trackingen,'Visible','On');
else %
end
list = getappdata(hAomControl, 'BufList');
set(handles.bufferlist, 'Value', 1);
set(handles.bufferlist, 'String', char(list{:,2}));
set(handles.bufferlist, 'Visible', 'On');
%aom1_onoff_Callback;

function seq_radio1_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
global SYSPARAMS;
if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end
SYSPARAMS.sysmode = 2;
set(handles.trackingen, 'Visible', 'Off');
set(handles.seq_radio1, 'Value', 1);
set(handles.im_popup1, 'Enable', 'Off');
set(handles.display_button, 'String', 'Load Image Sequence');
set(handles.display_button, 'Enable', 'On');
set(handles.loop_sequence, 'Visible', 'on');
set(handles.bufferlist, 'Visible', 'Off');

function exp_radio1_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
global SYSPARAMS;
if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end
SYSPARAMS.sysmode = 3;
set(handles.exp_radio1,'Value', 1);
set(handles.im_popup1, 'Value', 1);
set(handles.popup_panel1, 'Title', 'Select an Experiment');
hAomControl = getappdata(0,'hAomControl');
list = getappdata(hAomControl, 'ExpList');
set(handles.trackingen, 'Visible', 'Off');
set(handles.im_popup1, 'String', list);
set(handles.display_button, 'String', 'Config & Start');
set(handles.im_popup1,'Enable', 'on');
set(handles.display_button, 'Enable', 'on');
set(handles.loop_sequence, 'Visible', 'off');
set(handles.bufferlist, 'Visible', 'Off');

% --- Executes on button press in play_button0.
function play_button1_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
global SYSPARAMS;
mmode = get(handles.play_button1, 'String');
set(handles.display_button1, 'Enable', 'Off');
set(handles.aom1_onoff, 'Value', 1);

exp_name = getappdata(getappdata(0,'hAomControl'),'exp');
CFG = getappdata(getappdata(0,'hAomControl'),'CFG'); 
if mmode(1) == 'P';
    if SYSPARAMS.board == 'm' && SYSPARAMS.realsystem == 1
        MATLABAomControl32('Generate#');
    end
    PlayMovie;
elseif mmode(1) == 'S';
    if SYSPARAMS.board == 'm' && SYSPARAMS.realsystem == 1
        MATLABAomControl32('Generate#');
    end
    set(handles.play_button1, 'Enable', 'off');
    %set(handles.aom1_onoff, 'Enable', 'off');
    set(handles.display_button1, 'Enable', 'off');
    set(handles.exp_radio1, 'Enable', 'off');
    run(exp_name);    
end

function avi_file_radio_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
set(handles.display_button0, 'String', 'Load AVI File');

function reset_button_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
global SYSPARAMS;
set(handles.aom0_state, 'String','Resetting...');
pause(.05);
if SYSPARAMS.realsystem == 1 && SYSPARAMS.board == 'm'
    MATLABAomControl32('Start#0#1#');
    pause(0.5);
    MATLABAomControl32('ExtClockOn#');
    pause(0.05);
    MATLABAomControl32('Stop#');
    pause(0.05);
end
set(handles.alignh_slider, 'Enable', 'off');
set(handles.aom1_state, 'String','Off');
aom0_onoff_Callback;
set(handles.aom1_onoff, 'Value', 0);
aom1_onoff_Callback;
clear all;

function LoadImageSequence(aom)
global StimParams SYSPARAMS

if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end
%StimParams.aom = aom;
dirname = uigetdir(pwd,'Select the directory containing the image files');

if dirname == 0;
    set(handles.aom1_state, 'String','Error loading images: No directory selected. Please try again.');
    return
else
    %do nothing
end
StimParams.stimpath = fullfile(dirname);

Parse_Load_Buffers(1);
[seqfname, seqpname,filterindex] = uigetfile('*.SEQ;*.seq', 'Select the sequence file');

if filterindex == 0
    set(handles.aom1_state, 'String','Error - No Sequence File Selected - Please try loading image sequence again.');
    return
elseif filterindex == 1
    %do nothing
end

seq = fopen([seqpname seqfname]);

Mov.seq = '';
while(feof(seq) == 0)
    temp = fgetl(seq);    
    if  ~isempty(temp) && ischar(temp)
        Mov.seq = temp; %#ok<AGROW>    
    end
end
fclose(seq);

if  isempty(Mov.seq) || ~ischar(Mov.seq)
    return;
end

fprefix = StimParams.fprefix;
Mov.dir = fullfile(dirname);
Mov.pfx = fprefix;
Mov.frm = 1;
Mov.msg = 'On - Image Sequence Mode';

hAomControl = getappdata(0,'hAomControl');
setappdata(hAomControl, 'Mov',Mov);

set(handles.aom1_state, 'String','Done Reading Sequence File.  Press Play to Display the Movie.');
set(handles.display_button1, 'Enable', 'off');
set(handles.play_button1, 'Enable', 'on');
set(handles.aom1_onoff, 'Enable', 'on');
set(handles.aom1_onoff, 'Value', 1);
set(handles.display_button, 'String', 'Play');
set(handles.alignh_slider, 'Enable', 'on');

function sequence = GenRandSequence(frames)

framerate = 30; %NOTE: THIS NEEDS TO BE CHANGED IF RUNNING AT 60HZ on AOSLOII
hAomControl = getappdata(0,'hAomControl');
CFG = getappdata(hAomControl, 'CFG');
nruns = CFG.npresent;
presentdur = CFG.presentdur;
sequence = [];

for k = 1:nruns
    seq = frames';
    seq(:,1) = rand(size(frames,2),1);
    [IX, randseq] = sort(seq,1);
    for j = 1:size(frames,2)
        newseq(j) = frames(randseq(j)); %#ok<AGROW>
    end

    sequence = [newseq';sequence]; %#ok<AGROW>
end

durinsecs = presentdur/1000;
nframes = framerate*durinsecs;

for j = 1:nframes
    sequence(:,j) = sequence(:,1); %#ok<AGROW>
end;

ntrials = size(frames,2).*nruns;
blankend = (ones(1,ntrials))';
sequence = [sequence,blankend];
%use the next line if you want to save the sequence or double-check it
%dlmwrite('test.seq', sequence, '\t');

function sys_ai_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
% hObject    handle to sys_ai (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Checked', 'on');
set(handles.sys_aii, 'Checked', 'off');

function sys_aii_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
% hObject    handle to sys_aii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'Checked', 'on');
set(handles.sys_ai, 'Checked', 'off');

function loadBMP(hObject, eventdata, handles)
global SYSPARAMS VideoParams CurFrame OrigFrame StimParams; %#ok<NUSED>

if exist('handles','var') == 0
    handles = guihandles;
else
    %donothing
end

list = get(handles.im_popup1,'String');
value = get(handles.im_popup1, 'Value');
bmp = char(list{value});

switch bmp
    case '<select from disk>'
        bCD = cd;
        if (exist(StimParams.stimpath, 'dir') == 7)
            cd(StimParams.stimpath);
        else
            cd(bCD);
        end
        if strcmp(StimParams.fext, 'bmp') 
        [fname, pname, filter] = uigetfile( ...
            { '*.bmp','Bitmap-files (*.bmp)'; ...
            '*.buf','14-bit files (*.buf)'; ...
            '*.avi','avi files (*.avi)'}, ...
            'Pick a file');
        elseif strcmp(StimParams.fext, 'buf')
            [fname, pname, filter] = uigetfile( ...
            { '*.buf','14-bit files (*.buf)'; ...
            '*.bmp','Bitmap-files (*.bmp)'; ...            
            '*.avi','avi files (*.avi)'}, ...
            'Pick a file');
        elseif strcmp(StimParams.fext, 'avi')
            [fname, pname, filter] = uigetfile( ...
            { '*.avi','avi files (*.avi)'; ...
            '*.bmp','Bitmap-files (*.bmp)'; ...
            '*.buf','14-bit files (*.buf)'}, ...
            'Pick a file');
        end
        cd(bCD);
        if isequal(fname,0) || isequal(pname,0)
            set(handles.aom1_state, 'String','Error loading file.  No file was selected. Please try again.');
            return
        else
            %do nothing
        end 
        fext = fname(size(fname,2)-2:size(fname,2));        
        fprefix = fname(1:size(fname,2)-4);
        
    case 'gridscale 1 degree'
        pname = StimParams.stimpath;
        fprefix = 'gridscale7';
        fext = 'bmp';

    case 'gridscale 0.5 degree'
        pname = StimParams.stimpath;
        fprefix = 'gridscale3';
        fext = 'bmp';

    case 'gridscale 2 degree'
        pname = StimParams.stimpath;
        fprefix = 'gridscale4';
        fext = 'bmp';

    case 'gridscale 2.5 degree'
        pname = StimParams.stimpath;
        fprefix = 'gridscale5';
        fext = 'bmp';

    case 'gridscale 3 degree'
        pname = StimParams.stimpath;
        fprefix = 'gridscale6';
        fext = 'bmp';

    case 'fixation target'
        pname = StimParams.stimpath;
        fprefix = 'fixation2';
        fext = 'bmp';

    case '20/20 E'
        pname = StimParams.stimpath;
        fprefix = 'E2';
        fext = 'bmp';

    case 'Gabor'
        uiwait(GaborTool);
        fprefix = 'frame2';
        fext = 'buf';
        hAomControl = getappdata(0,'hAomControl');
        CFG = getappdata(hAomControl, 'CFG');
        cycles = CFG.cycles;
        contrast = CFG.contrast;
        setappdata(hAomControl, 'CFG',CFG);
        MakeGrating(contrast,cycles);
        pname = fullfile(pwd,'temp');
    case 'calibration frame'
        uiwait(CalibrationTool);
        hAomControl = getappdata(0,'hAomControl');
        CFG = getappdata(hAomControl, 'CFG');
        fprefix = 'frame2';
        fext = 'buf';
        level = CFG.level;
        setappdata(hAomControl, 'CFG',CFG);
        MakeCalib(level);
        pname = fullfile(pwd,'temp');
end

StimParams.stimpath = pname;
StimParams.fprefix = fprefix;
StimParams.fext = fext;

hAomControl = getappdata(0,'hAomControl');
AOMSel.clearbuf = 0;
buflist = getappdata(hAomControl,'BufList');
updatechanir = -2;
updatechan = 0;
if ~strcmp(StimParams.fext, 'avi')
    SYSPARAMS.sysmode = 0;
    set(handles.loop_sequence, 'Visible', 'off');    
    uiwait(AOMselection);
    AOMSel = getappdata(hAomControl, 'AOMSel');
    if AOMSel.clearbuf == 1 && size(buflist,1) > 1
        if AOMSel.loadbuf ~= 0
            updatechanir = 1;
        else
            updatechan = 0;
        end
    else
        updatechan = -2;
    end
else
    SYSPARAMS.sysmode = 1;
    set(handles.loop_sequence, 'Visible', 'on');    
end

if AOMSel.clearbuf == 1 || strcmp(StimParams.fext, 'avi')
        OrigFrame.ir = 0;
        OrigFrame.red = 0;
        OrigFrame.green = 0;
        OrigFrame.blue = 0;
        StimParams.filepath{1} = '-';
        StimParams.filepath{2} = '-';
        StimParams.filepath{3} = '-';
        StimParams.filepath{4} = '-';
end

fullpath = [StimParams.stimpath StimParams.fprefix '.' StimParams.fext];

    if ~strcmp(fext, 'avi') && SYSPARAMS.realsystem == 1 
        commandstring = ['Load#' num2str(AOMSel.clearbuf) '#' StimParams.stimpath '#' StimParams.fprefix '#0#0#' StimParams.fext '#']; %#ok<NASGU> 
        if SYSPARAMS.board == 'm'
            MATLABAomControl32(commandstring);
        else
            netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
        end
        switch AOMSel.loadbuf
            case 0
                commandstring = ['Update#-1#' num2str(updatechan) '#' num2str(updatechan) '#' num2str(updatechan) '#']; % -1 loads the last buffer that has been loaded
            case 1
                commandstring = ['Update#' num2str(updatechanir) '#-1#' num2str(updatechan) '#' num2str(updatechan) '#']; % -1 loads the last buffer that has been loaded
            case 2
                commandstring = ['Update#' num2str(updatechanir) '#' num2str(updatechan) '#-1#' num2str(updatechan) '#']; % -1 loads the last buffer that has been loaded
            case 3
                commandstring = ['Update#' num2str(updatechanir) '#' num2str(updatechan) '#' num2str(updatechan) '#-1#']; % -1 loads the last buffer that has been loaded
        end
        if SYSPARAMS.board == 'm'
            MATLABAomControl32(commandstring);
        else
            netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
        end
    elseif strcmp(fext,'avi')
        OrigFrame.ir = 0;
        OrigFrame.red = 0;
        OrigFrame.green = 0;
        OrigFrame.blue = 0;
        StimParams.filepath{1} = '-';
        StimParams.filepath{2} = '-';
        StimParams.filepath{3} = '-';
        StimParams.filepath{4} = '-';
        if SYSPARAMS.realsystem == 1
            uiwait(AviPlayMode);
            set(handles.loop_sequence,'Value', SYSPARAMS.loop);
            if (VideoParams.vidrecord==1) %send the prefix
                commandstring = ['VP#' VideoParams.vidprefix '#']; %#ok<NASGU>
                if SYSPARAMS.board == 'm'
                    MATLABAomControl32(commandstring);
                else
                    netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
                end
            end
            %set video duration
            tempObj = mmreader(fullpath);
            if (SYSPARAMS.loop == 0)
                replaytimes = 1;
            else
                replaytimes = StimParams.avireplaytimes;
            end
            duration = tempObj.NumberOfFrames*replaytimes;
            clear tempObj;
            if (VideoParams.vidrecord == 1)
                VideoParams.videodur = duration/30;
                commandstring = ['VL#' num2str(VideoParams.videodur+1) '#']; %#ok<NASGU>
                if SYSPARAMS.board == 'm'
                    MATLABAomControl32(commandstring);
                else
                    netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
                end
            end
            if (StimParams.avireplayinfinite == 0)
                commandstring = ['LL#' num2str(duration) '#'];
            else
                commandstring = 'LL#-1#';
            end
            if SYSPARAMS.board == 'm'
                MATLABAomControl32(commandstring);
            else
                netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
            end
            if (VideoParams.vidrecord == 1)
                if SYSPARAMS.board == 'm'
                    MATLABAomControl32('GRVIDT#-#');
                else
                    netcomm('write',SYSPARAMS.netcommobj,int8('GRVIDT#-#'));
                end
            else
                %if not running experiment, just play the movie
                if SYSPARAMS.board == 'm'
                    MATLABAomControl32('Trigger#AVI#');
                else
                    netcomm('write',SYSPARAMS.netcommobj,int8('Trigger#AVI#'));
                end
            end
            commandstring = ['Load#' num2str(AOMSel.clearbuf) '#' StimParams.stimpath '#' StimParams.fprefix '#0#0#' StimParams.fext '#']; %#ok<NASGU>
            if SYSPARAMS.board == 'm'
                MATLABAomControl32(commandstring);
            else
                netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
            end
        else
            StimParams.avireplayinfinite = 1;
        end
        loop_sequence_Callback(hObject, eventdata, handles);
    end

switch bmp
    case '<select from disk>'
        messagetext = ['On - Image Mode - Displaying Image: ',fullpath];        
    case 'gridscale 1 degree'
        messagetext = 'On - Image Mode - Displaying 1 degree Grid Scale';
    case  'gridscale 0.5 degree'
        messagetext = 'On - Image Mode - Displaying 0.5 degree Grid Scale';
    case  'gridscale 2 degree'
        messagetext = 'On - Image Mode - Displaying 2 degree Grid Scale';
    case  'gridscale 2.5 degree'
        messagetext = 'On - Image Mode - Displaying 2.5 degree Grid Scale';
    case  'gridscale 3 degree'
        messagetext = 'On - Image Mode - Displaying 3 degree Grid Scale';
    case 'fixation target'
        messagetext = 'On - Image Mode - Displaying Fixation Target';
    case '20/20 E'
        messagetext = 'On - Image Mode - Displaying 20/20 E';
    case 'Gabor'
        messagetext = ['On - Image Mode - Displaying Gabor Patch of ' num2str(cycles) ' cycles at ' num2str(contrast*100) '%' ' contrast.'];
    case 'calibration frame'
        messagetext = ['On - Image Mode - Displaying Full Frame of ' num2str(level)];
end

%update buffer list
if strcmp(fext,'bmp') || strcmp(fext,'buf')    
    if AOMSel.clearbuf == 1
        buflist = cell(0);
        buflist{1,1}='-';
        buflist{1,2}='-';
        buflist{1,3}='-';
    end
    buflist{size(buflist,1)+1,1} = pname;
    buflist{size(buflist,1),2} = fprefix;
    buflist{size(buflist,1),3} = fext;
    setappdata(hAomControl,'BufList',buflist);        
    set(handles.bufferlist, 'Value', 1);
    set(handles.bufferlist, 'String', char(buflist{:,2}));
    set(handles.bufferlist, 'Visible', 'On');
end

if strcmp(fext,'avi')
    if AOMSel.clearbuf == 1
        buflist = cell(0);
        buflist{1,1}='-';
        buflist{1,2}='-';
        buflist{1,3}='-';
    end    
    setappdata(hAomControl,'BufList',buflist);
    set(handles.bufferlist, 'Value', 1);
    set(handles.bufferlist, 'String', char(buflist{:,2}));
    set(handles.bufferlist, 'Visible', 'Off');
    messagetext = ['On - Movie mode - Playing movie: ' fullpath];
end

set(handles.aom1_state, 'String',messagetext);
set(handles.aom1_onoff, 'Enable', 'on');
set(handles.aom1_onoff, 'Value', 1);
a = imread('on.bmp');
set(handles.aom1_onoff, 'Cdata', a);
if strcmp(fext,'avi')    
    hAomControl = getappdata(0,'hAomControl');
    Mov.avi = fullpath;
    message = 'AVI stimulus file: ';
    Mov.msg = message;        
    setappdata(hAomControl, 'Mov',Mov);    
    PlayMovie;
    return;
end

if SYSPARAMS.aoms_enable(1) == 1
    StimParams.filepath{1} = '-';
end
if SYSPARAMS.aoms_enable(2) == 1
    StimParams.filepath{2} = '-';
end
if SYSPARAMS.aoms_enable(3) == 1
    StimParams.filepath{3} = '-';
end
if SYSPARAMS.aoms_enable(4) == 1
    StimParams.filepath{4} = '-';
end

if SYSPARAMS.aoms_state(1) == 1 %IR
    if AOMSel.loadbuf ==  0
        StimParams.filepath{1} = fullpath;
    end
end

if SYSPARAMS.aoms_state(2) == 1 %Red
    if AOMSel.loadbuf ==  1 %red
        StimParams.filepath{2} = fullpath;
    end
end

if SYSPARAMS.aoms_state(3) == 1 %Green
    if AOMSel.loadbuf == 2 %green
        StimParams.filepath{3} = fullpath;
    end
end

if SYSPARAMS.aoms_state(4) == 1 %Blue
    if AOMSel.loadbuf == 3 %blue
        StimParams.filepath{4} = fullpath;
    end
end

Show_Image(1);

function options_Callback(hObject, eventdata, handles) %#ok<DEFNU>

function MakeCalib(level)
global SYSPARAMS;

frame = ones(SYSPARAMS.rasterV,SYSPARAMS.rasterH);
frame = frame.*level;

if isdir(fullfile(pwd,'temp')) == 0
    mkdir(pwd, 'temp');    
    cd(fullfile(pwd,'temp'));
else
    cd(fullfile(pwd,'temp'));
end

imwrite(frame,'frame2.bmp');
fid = fopen('frame2.buf','w');

%fwrite(fid,[SYSPARAMS.rasterH SYSPARAMS.rasterV],'int16');
frame = frame';
fwrite(fid,SYSPARAMS.rasterH,'int16');
fwrite(fid,SYSPARAMS.rasterV,'int16');
fwrite(fid,frame,'int16');
fclose(fid);

cd ..;

function MakeGrating(contrast,cycles)
global SYSPARAMS;
fps = 30; % need to make this a variable
width = SYSPARAMS.rasterH;
height = SYSPARAMS.rasterV;

orientation = 90; %now hard-coded for horizontal gratings
cycles = height/cycles; %this also is hard-coded for horizontal gratings

if contrast>1 || contrast<0;
    error('contrast must be a value between 0 and 1');
else
end

if fps == 30
    [x,y]=meshgrid(0:width-1,0:height-1);
elseif fps == 60
    [x,y]=meshgrid(0:width,0:height/2);
else
    error('fps must be either 30 or 60');
end

angle=orientation*pi/180;
f=2*pi/cycles;
a=cos(angle)*f;
b=sin(angle)*f;

grating=sin(a*x+b*y);

if fps == 30
    gaussian=exp(-(((x-260)/130).^2)-(((y-240)/120).^2));
elseif fps == 60
    gaussian=exp(-(((x-263)/131).^2)-(((y-128)/64).^2));
end
        
grating=gaussian.*grating;
grating=Scale(grating);
grating=grating.*contrast;
offset = 0.5-mean(mean(grating));
grating = grating+offset;

dacoeff = [9346852.79448745 -41895568.24241997 79504249.96067327 -83044522.43767963 52026750.07637602 -20004605.37173481 4659748.165839 -634660.4543606126 57930.19303583798 -8006.013601828307];

newgrating = reshape(grating, prod(size(grating)),1); %#ok<PSIZE>
hibitgrating = polyval(dacoeff,newgrating);
hibit = mean(hibitgrating);
hibitgrating = reshape(hibitgrating, SYSPARAMS.rasterV, SYSPARAMS.rasterH);

blankbmp = ones(SYSPARAMS.rasterV, SYSPARAMS.rasterH);
%hibit = polyval(dacoeff,contrast);

hibitblank = blankbmp.*hibit;
bmpgrating = grating;

if isdir(fullfile(pwd,'temp')) == 0
    mkdir(pwd,'temp');    
    cd(fullfile(pwd,'temp'));
    blankbmp = ones(height,width).*contrast;
    imwrite(blankbmp,'frame3.bmp');
    fid = fopen('frame3.buf','w');
    fwrite(fid, SYSPARAMS.rasterH, 'int16');
    fwrite(fid, SYSPARAMS.rasterV, 'int16');
    hibitblank = hibitblank';
    fwrite(fid,hibitblank,'int16');
    fclose(fid);
else
    cd(fullfile(pwd,'temp'));
end
imwrite(bmpgrating,'frame2.bmp');
fid = fopen('frame2.buf','w');
fwrite(fid, SYSPARAMS.rasterH, 'int16');
fwrite(fid, SYSPARAMS.rasterV, 'int16');
hibitgrating = hibitgrating';
fwrite(fid,hibitgrating,'int16');
fclose(fid);

cd ..;

function windowfilter = WindowFilter(pname, fname, cutoff, filtersize) %#ok<STOUT>

rawimage = imread([pname fname]);
rawimage = rawimage(:, :, 1);
rawimage= ~rawimage;
rawimage = double(rawimage);
% SYSPARAMS.rasterH = size(rawimage,2);
imagesizeV = size(rawimage,1);
% maxfreq = imagesizeV/2;

%create ideal frequency response (the cylinder)
[f1 f2] = freqspace(imagesizeV, 'meshgrid');
r = sqrt(f1.^2 + f2.^2);
H = ones(imagesizeV);
H(r> cutoff/(imagesizeV/2)) = 0; %60 cyc/deg cutoff frequency

window = fspecial('disk', filtersize); %doesn't have to be 20, can make filter bigger or smaller
window = window./max(window(:));
h = fwind2(H, window);

g = imfilter(rawimage, h, 'replicate', 'same');
g = 1 - abs(g);

if isdir(fullfile(pwd,'temp')) == 0
    mkdir(pwd,'temp');    
    blankframe = ones(imagesizeV,imagesizeH)*8191;
    cd(fullfile(pwd,'temp'));
    blankbmp = ones(imagesizeV,imagesizeH);
    imwrite(blankbmp,'frame0.bmp');
    fid = fopen('frame0.buf','w');
    blankframe = blankframe';
    fwrite(fid,blankframe,'int16');
    fclose(fid);
else
    cd(fullfile(pwd,'temp'));
end
bufname = [fname(1:end-4) '.buf'];
imwrite(g,fname);

fid = fopen(bufname,'w');
fwrite(fid,g'*8191,'int16');
fclose(fid);

cd ..;         

function idealfilter = IdealFilter(pname, fname, cutoff) %#ok<STOUT>

rawimage = imread([pname fname]);
rawimage = rawimage(:, :, 1);
rawimage = ~rawimage;
% SYSPARAMS.rasterH = size(rawimage,2);
imagesizeV = size(rawimage,1); 
% maxsf = SYSPARAMS.rasterH/2;

filter = zeros(imagesizeV,imagesizeH);
center = size(filter)./2;

X = ones(imagesizeV,1)*[center(2)-center(2)*2:center(2)-1];  %#ok<NBRAK>
Y = [center(1)-center(1)*2:center(1)-1]'*ones(1,imagesizeH); %#ok<NBRAK>
Z = X.^2 + Y.^2;
filter(find(Z <= (cutoff)^2))=1; %#ok<FNDSB>


fft2dim = fft2(rawimage);
shiftedim = fftshift(fft2dim);

multim = shiftedim.*filter;
filteredimage = 1-abs(ifft2(multim));

if isdir(fullfile(pwd,'temp')) == 0
    mkdir(pwd,'temp');    
    blankframe = ones(imagesizeV,imagesizeH)*8191;
    cd(fullfile(pwd,'temp'));
    blankbmp = ones(imagesizeV,imagesizeH);
    imwrite(blankbmp,'frame0.bmp');
    fid = fopen('frame0.buf','w');
    blankframe = blankframe';
    fwrite(fid,blankframe,'int16');
    fclose(fid);
else
    cd(fullfile(pwd,'temp'));
end
bufname = [fname(1:end-4) '.buf'];
imwrite(filteredimage,fname);

fid = fopen(bufname,'w');
filteredimage = scale(filteredimage);
fwrite(fid,filteredimage*8191,'int16');
fclose(fid);

cd ..;

% --- Executes on selection change in im_popup1.
function im_popup1_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to im_popup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns im_popup1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from im_popup1

% --- Executes during object creation, after setting all properties.
function im_popup1_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to im_popup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in display_button0.
function pushbutton10_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to display_button0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in aom1_onoff.
function aom1_onoff_Callback(hObject, eventdata, handles)
global SYSPARAMS CurFrame OrigFrame; %#ok<NUSED>

if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end
hAomControl = getappdata(0,'hAomControl');
button_state = get(handles.aom1_onoff,'Value');
if button_state == get(handles.aom1_onoff,'Min')
    % toggle button is pressed SYSPARAMS.aoms_state
    if SYSPARAMS.realsystem == 1
        if SYSPARAMS.aoms_state(1) == 1
            aom0=0;
        else
            aom0=-2;
        end
        if SYSPARAMS.aoms_state(2) == 1
            aom1=0;
        else
            aom1=-2;
        end
        if SYSPARAMS.aoms_state(3) == 1
            aom2=0;
        else
            aom2=-2;
        end
        if SYSPARAMS.aoms_state(4) == 1
            aom3=0;
        else
            aom3=-2;
        end
        commandstring = ['Update#' num2str(aom0) '#' num2str(aom1) '#' num2str(aom2) '#' num2str(aom3) '#']; %#ok<NASGU>
        if SYSPARAMS.board == 'm'
            MATLABAomControl32(commandstring);
        else
            netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
        end
    end
    set(handles.aom1_state,'String','Off');
    a = imread('off.bmp');
    set(handles.aom1_onoff, 'Cdata', a);    
    h = get(handles.im_panel1, 'Child');
    set(h,'Visible', 'on');
    axes(h); %#ok<MAXES>
    if SYSPARAMS.aoms_state(1) == 1        
        CurFrame(:,:,1) = uint8(0);
        OrigFrame.ir = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
    end
    if SYSPARAMS.aoms_state(2) == 1        
        CurFrame(:,:,1) = uint8(0);
        OrigFrame.red = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
    end
    if SYSPARAMS.aoms_state(3) == 1        
        CurFrame(:,:,2) = uint8(0);
        OrigFrame.green = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
    end
    if SYSPARAMS.aoms_state(4) == 1        
        CurFrame(:,:,3) = uint8(0);
        OrigFrame.blue = uint8(zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
    end    
    imshow(CurFrame,'InitialMagnification',100, 'Border', 'tight');

else
    % toggle button is pressed SYSPARAMS.aoms_state
    if SYSPARAMS.realsystem == 1
        if SYSPARAMS.aoms_state(1) == 1
            aom0=1;
        else
            aom0=-2;
        end
        if SYSPARAMS.aoms_state(2) == 1
            aom1=1; 
        else
            aom1=-2;
        end
        if SYSPARAMS.aoms_state(3) == 1
            aom2=1;                        
        else
            aom2=-2;
        end
        if SYSPARAMS.aoms_state(4) == 1
            aom3=1;
        else
            aom3=-2;
        end
        commandstring = ['Update#' num2str(aom0) '#' num2str(aom1) '#' num2str(aom2) '#' num2str(aom3) '#']; %#ok<NASGU>
        if SYSPARAMS.board == 'm'
            MATLABAomControl32(commandstring);
        else
            netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
        end
    end
    set(handles.aom1_state,'String','On');
    a = imread('on.bmp');
    set(handles.aom1_onoff, 'Cdata', a);    
    h = get(handles.im_panel1, 'Child');
    set(h,'Visible', 'on');
    axes(h); %#ok<MAXES>
    if SYSPARAMS.aoms_state(1) == 1
        OrigFrame.ir = uint8(50*ones(SYSPARAMS.rasterH, SYSPARAMS.rasterV));  
        CurFrame(:,:,1) = uint8(50*SYSPARAMS.aompowerLvl(1));
    end
    if SYSPARAMS.aoms_state(2) == 1 
        OrigFrame.red = uint8(205*ones(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
        CurFrame(:,:,1) = CurFrame(:,:,1)+uint8(205*SYSPARAMS.aompowerLvl(2));
    end
    if SYSPARAMS.aoms_state(3) == 1       
        OrigFrame.green = uint8(255*ones(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
        CurFrame(:,:,2) = uint8(255*SYSPARAMS.aompowerLvl(3));
    end
    if SYSPARAMS.aoms_state(4) == 1        
        OrigFrame.blue = uint8(255*ones(SYSPARAMS.rasterH, SYSPARAMS.rasterV));
        CurFrame(:,:,3) = uint8(255*SYSPARAMS.aompowerLvl(4));
    end    
    imshow(CurFrame,'InitialMagnification',100, 'Border', 'tight');
end

% --- Executes on button press in horiz_align.
function horiz_align_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to horiz_align (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS;
if SYSPARAMS.realsystem == 1
    %setup the keyboard constants and response mappings from config
    kb_AbortConst = 27; %abort constant - Esc Key
    
    kb_LeftConst2 = 28; %ascii code for left arrow
    kb_RightConst2 = 29; %ascii code for right arrow
    kb_UpConst2 = 30; %ascii code for up arrow
    kb_DownConst2 = 31; %ascii code for down arrow
    
    [y,Fs,bits] = wavread('beep'); %#ok<NASGU>
    % for the subject to align two wavelength images to measure transverse chromatic
    % aberration. Needs to call new alignment commands (vertical and
    % horizontal).
    %
    set(handles.alignh_slider, 'Enable', 'off');
    set(handles.reset_button, 'Enable', 'off');
    set(handles.horiz_align, 'Enable', 'off');
    message = ['Starting User Alignment- AOM1 Hor:' num2str(handles.alignValH1) ' Ver:' num2str(handles.alignValV1) '  AOM2 Hor:' num2str(handles.alignValH2) ' Ver:' num2str(handles.alignValV1)];
    set(handles.aom_state, 'String',message);
    alignloop = 1;
    alignValH1 = handles.alignValH1;
    alignValH2 = handles.alignValH2;
    alignValV1 = handles.alignValV1;
    
    while(alignloop == 1)
        moveresponse = getkey;
        if moveresponse == kb_AbortConst
            alignloop = 0;
            uiresume;
            clear y Fs bits;
            guidata(hObject,handles);
            set(handles.horiz_align, 'Enable', 'on');
            set(handles.reset_button, 'Enable', 'on');
            set(handles.alignh_slider, 'Enable', 'on');
            set(handles.alignh_slider, 'Value', handles.alignValV1);
            message = ['AOM1 Hor:' num2str(handles.alignValH1) ' Diff:' num2str(alignValH1-handles.alignValH1) ' Ver:' num2str(handles.alignValV1) ' Diff:' num2str(alignValV1-handles.alignValV1) '  AOM2 Hor:' num2str(handles.alignValH2) ' Diff:' num2str(alignValH2-handles.alignValH2) ' Ver:' num2str(handles.alignValV1) ' Diff:' num2str(alignValV1-handles.alignValV1)];
            clear alignValH1 alignValH2 alignValV1;
            set(handles.aom_state, 'String',message);
            
            %right arrow
        elseif moveresponse == kb_RightConst2
            handles.alignValH2 = handles.alignValH2+1;
            if (handles.alignValH2 > 590)
                handles.alignValH1 = handles.alignValH1 + 1;
                horizontalaligncommand = ['AllignH#' num2str(handles.alignValH1) '#' num2str(handles.alignValH2-handles.alignValH1) '#']; %#ok<NASGU>
                MATLABAomControl32(horizontalaligncommand);
                if (handles.alignValH1 == 0)
                    message = ['Left AOM Hor:' num2str(handles.alignValH1) ' Ver:' num2str(handles.alignValV1) ' Diff: ' num2str(handles.alignValH1)];
                else
                    message = ['Left AOM Hor:' num2str(handles.alignValH1) ' Ver:' num2str(handles.alignValV1) ' Diff: +' num2str(handles.alignValH1)];
                end
                set(handles.aom_state, 'String',message);
            else
                horizontalaligncommand = ['AllignH#' num2str(handles.alignValH1) '#' num2str(handles.alignValH2) '#']; %#ok<NASGU>
                MATLABAomControl32(horizontalaligncommand);
                if (590-handles.alignValH2) == 0
                    message = ['Right AOM Hor:' num2str(handles.alignValH2) ' Ver:' num2str(handles.alignValV1) ' Diff: ' num2str(590-handles.alignValH2)];
                else
                    message = ['Right AOM Hor:' num2str(handles.alignValH2) ' Ver:' num2str(handles.alignValV1) ' Diff: -' num2str(590-handles.alignValH2)];
                end
                set(handles.aom_state, 'String',message);
            end
            
            %left arrow
        elseif moveresponse == kb_LeftConst2
            handles.alignValH2 = handles.alignValH2-1;
            if (handles.alignValH2 >= 590)
                handles.alignValH1 = handles.alignValH1 - 1;
                horizontalaligncommand = ['AllignH#' num2str(handles.alignValH1) '#' num2str(handles.alignValH2-handles.alignValH1) '#']; %#ok<NASGU>
                MATLABAomControl32(horizontalaligncommand);
                if (handles.alignValH1 == 0)
                    message = ['Left AOM Hor:' num2str(handles.alignValH1) ' Ver:' num2str(handles.alignValV1) ' Diff: ' num2str(handles.alignValH1)];
                else
                    message = ['Left AOM Hor:' num2str(handles.alignValH1) ' Ver:' num2str(handles.alignValV1) ' Diff: +' num2str(handles.alignValH1)];
                end
                set(handles.aom_state, 'String',message);
            else
                horizontalaligncommand = ['AllignH#' num2str(handles.alignValH1) '#' num2str(handles.alignValH2) '#']; %#ok<NASGU>
                MATLABAomControl32(horizontalaligncommand);
                if (590-handles.alignValH2) == 0
                    message = ['Right AOM Hor:' num2str(handles.alignValH2) ' Ver:' num2str(handles.alignValV1) ' Diff: ' num2str(590-handles.alignValH2)];
                else
                    message = ['Right AOM Hor:' num2str(handles.alignValH2) ' Ver:' num2str(handles.alignValV1) ' Diff: -' num2str(590-handles.alignValH2)];
                end
                set(handles.aom_state, 'String',message);
            end
            
            %up arrow
        elseif moveresponse == kb_UpConst2
            verticalaligncommand = ['AllignV#' num2str(handles.alignValV1+1) '#']; %#ok<NASGU>
            MATLABAomControl32(verticalaligncommand);
            handles.alignValV1 = handles.alignValV1+1;
            message = ['Right AOM Hor:' num2str(handles.alignValH2) ' Ver:' num2str(handles.alignValV1)];
            set(handles.aom_state, 'String',message);
            
            %down arrow
        elseif moveresponse == kb_DownConst2
            handles.alignValV1 = handles.alignValV1-1;
            if handles.alignValV1<0
                wavplay(y,Fs,'sync');
                handles.alignValV1 = 0;
            else
                verticalaligncommand = ['AllignV#' num2str(handles.alignValV1) '#']; %#ok<NASGU>
                MATLABAomControl32(verticalaligncommand);
            end
            message = ['Right AOM Hor:' num2str(handles.alignValH2) ' Ver:' num2str(handles.alignValV1)];
            set(handles.aom_state, 'String',message);
        end
    end
end

% --- Executes during object creation, after setting all properties.
function aom1_onoff_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to aom1_onoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
a = imread('off.bmp');
set(hObject, 'Cdata', a);

% --- Executes on key press over aom_main_figure with no controls selected.
function aom_main_figure_KeyPressFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to aom_main_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in loop_sequence.
function loop_sequence_Callback(hObject, eventdata, handles)
% hObject    handle to loop_sequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS;
if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end
if get(handles.loop_sequence, 'Value') == 1
    SYSPARAMS.loop = 1;
else
    SYSPARAMS.loop = 0;
end
if SYSPARAMS.realsystem == 1
    command = ['Loop#' num2str(SYSPARAMS.loop) '#'];
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(command);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(command));
    end
end
% Hint: get(hObject,'Value') returns toggle state of loop_sequence

% --- Executes on slider movement.
function power_slider_Callback(hObject, eventdata, handles) %#ok<DEFNU>
global SYSPARAMS;

if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end

hAomControl = getappdata(0,'hAomControl');
handles = guihandles;
powerLvl = get(handles.power_slider, 'Value');
percent = num2str(round(powerLvl*100));
switch SYSPARAMS.aom_pow_sel
    case 0
        SYSPARAMS.aompowerLvl(1) = powerLvl;
        set(handles.aom1_state, 'String',['Power level set at ' num2str(SYSPARAMS.aomuWPower(1).*powerLvl, '%3.2f') char(181) 'W (' percent '%)']);
        set(handles.power_uW,'String',num2str(SYSPARAMS.aomuWPower(1)*powerLvl, '%3.2f'));
    case 1
        SYSPARAMS.aompowerLvl(2) = powerLvl;
        set(handles.aom1_state, 'String',['Power level set at ' num2str(SYSPARAMS.aomuWPower(2).*powerLvl, '%3.2f') char(181) 'W (' percent '%)']);
        set(handles.power_uW,'String',num2str(SYSPARAMS.aomuWPower(2)*powerLvl, '%3.2f'));
    case 2
        SYSPARAMS.aompowerLvl(3) = powerLvl;
        set(handles.aom1_state, 'String',['Power level set at ' num2str(SYSPARAMS.aomuWPower(3).*powerLvl, '%3.2f') char(181) 'W (' percent '%)']);
        set(handles.power_uW,'String',num2str(SYSPARAMS.aomuWPower(3)*powerLvl, '%3.2f'));
    case 3
        SYSPARAMS.aompowerLvl(4) = powerLvl;
        set(handles.aom1_state, 'String',['Power level set at ' num2str(SYSPARAMS.aomuWPower(4).*powerLvl, '%3.2f') char(181) 'W (' percent '%)']);
        set(handles.power_uW,'String',num2str(SYSPARAMS.aomuWPower(4)*powerLvl, '%3.2f'));
    otherwise
end
if SYSPARAMS.realsystem == 1
    command = ['UpdatePower#' num2str(SYSPARAMS.aom_pow_sel) '#' num2str(powerLvl) '#'];
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(command);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(command));
    end
end

% --- Executes during object creation, after setting all properties.
function power_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in aom0_power_radio.
function aom0_power_radio_Callback(hObject, eventdata, handles)
global SYSPARAMS;
handles = guihandles;
set(handles.power_slider, 'Value', SYSPARAMS.aompowerLvl(1));

aom0uWset = num2str((SYSPARAMS.aompowerLvl(1)*SYSPARAMS.aomuWPower(1)),'%3.0f');

if isempty(SYSPARAMS.aomuWPower(1)) == 0
    set(handles.power_uW, 'String', aom0uWset);
else
    set(handles.power_uW, 'String', '0');
end
SYSPARAMS.aom_pow_sel = 0;

% --- Executes on button press in aom1_power_radio.
function aom1_power_radio_Callback(hObject, eventdata, handles)
global SYSPARAMS;
handles = guihandles;
set(handles.power_slider, 'Value', SYSPARAMS.aompowerLvl(2));

aom1uWset = num2str((SYSPARAMS.aompowerLvl(2)*SYSPARAMS.aomuWPower(2)),'%3.0f');

if isempty(SYSPARAMS.aomuWPower(2)) == 0
    set(handles.power_uW, 'String', aom1uWset);
else
    set(handles.power_uW, 'String', '0');
end
SYSPARAMS.aom_pow_sel = 1;

% --- Executes on button press in aom2_power_radio.
function aom2_power_radio_Callback(hObject, eventdata, handles)
global SYSPARAMS;
handles = guihandles;
set(handles.power_slider, 'Value', SYSPARAMS.aompowerLvl(3));

aom2uWset = num2str((SYSPARAMS.aompowerLvl(3)*SYSPARAMS.aomuWPower(3)),'%3.0f');

if isempty(SYSPARAMS.aomuWPower(3)) == 0
    set(handles.power_uW, 'String', aom2uWset);
else
    set(handles.power_uW, 'String', '0');
end
SYSPARAMS.aom_pow_sel = 2;

% --- Executes on button press in aom3_power_radio.
function aom3_power_radio_Callback(hObject, eventdata, handles)
global SYSPARAMS;
handles = guihandles;
set(handles.power_slider, 'Value', SYSPARAMS.aompowerLvl(4));

aom3uWset = num2str((SYSPARAMS.aompowerLvl(4)*SYSPARAMS.aomuWPower(4)),'%3.0f');

if isempty(SYSPARAMS.aomuWPower(4)) == 0
    set(handles.power_uW, 'String', aom3uWset);
else
    set(handles.power_uW, 'String', '0');
end
SYSPARAMS.aom_pow_sel = 3;

function power_uW_Callback(hObject, eventdata, handles) %#ok<DEFNU>
user_entry = get(hObject,'string');

if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end

hAomControl = getappdata(0,'hAomControl');
if get(handles.aom0_power_radio, 'Value') == 1
    SYSPARAMS.aomuWPower(1) = str2num(user_entry);
    set(handles.power_slider, 'Enable', 'on');
elseif get(handles.aom1_power_radio, 'Value') == 1
    SYSPARAMS.aomuWPower(2) = str2num(user_entry);
    set(handles.power_slider, 'Enable', 'on');
elseif get(handles.aom2_power_radio, 'Value') == 1
    SYSPARAMS.aomuWPower(3) = str2num(user_entry);
    set(handles.power_slider, 'Enable', 'on');
elseif get(handles.aom3_power_radio, 'Value') == 1
    SYSPARAMS.aomuWPower(4) = str2num(user_entry);
    set(handles.power_slider, 'Enable', 'on');
end

% --- Executes during object creation, after setting all properties.
function power_uW_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to power_uW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in flash_duty.
function flash_duty_Callback(hObject, eventdata, handles)
% hObject    handle to flash_duty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns flash_duty contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        flash_duty

% --- Executes during object creation, after setting all properties.
function flash_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flash_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function flash_duty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flash_duty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in flash_button.
function flash_button_Callback(hObject, eventdata, handles)
% hObject    handle to flash_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list = get(handles.flash_duty,'String');
value = get(handles.flash_duty, 'Value');
flash_duty_string = char(list{value});
if strcmp(flash_duty_string,'-')
    command = ['Flash#30#0#'];
else
    index = findstr(flash_duty_string, ':');
    on_limit = flash_duty_string(1:index-1);
    off_limit = flash_duty_string(index+1:length(flash_duty_string));
    command = ['Flash#' on_limit '#' off_limit '#'];
end
MATLABAomControl32(command);

% --- Executes on selection change in flash_freq.
function flash_freq_Callback(hObject, eventdata, handles)
% hObject    handle to flash_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns flash_freq contents as
% cell array
%        contents{get(hObject,'Value')} returns selected item from
%        flash_freq
list = get(handles.flash_freq,'String');
value = get(handles.flash_freq, 'Value');
freq = char(list{value});

switch freq
    case '1Hz'
        list = cell(0);
        list{1,1} = '1:29';
        list{2,1} = '2:28';
        list{3,1} = '3:27';
        list{4,1} = '4:26';
        list{5,1} = '5:25';
        list{6,1} = '6:24';
        list{7,1} = '7:23';
        list{8,1} = '8:22';
        list{9,1} = '9:21';
        list{10,1} = '10:20';
        list{11,1} = '11:19';
        list{12,1} = '12:18';
        list{13,1} = '13:17';
        list{14,1} = '14:16';
        list{15,1} = '15:15';
        list{16,1} = '16:14';
        list{17,1} = '17:13';
        list{18,1} = '18:12';
        list{19,1} = '19:11';
        list{20,1} = '20:10';
        list{21,1} = '21:9';
        list{22,1} = '22:8';
        list{23,1} = '23:7';
        list{24,1} = '24:6';
        list{25,1} = '25:5';
        list{26,1} = '26:4';
        list{27,1} = '27:3';
        list{27,1} = '28:2';
        list{27,1} = '29:1';
        set(handles.flash_duty, 'String', list);
    case '2Hz'
        list = cell(0);
        list{1,1} = '1:14';
        list{2,1} = '2:13';
        list{3,1} = '3:12';
        list{4,1} = '4:11';
        list{5,1} = '5:10';
        list{6,1} = '6:9';
        list{7,1} = '7:8';
        list{8,1} = '8:7';
        list{9,1} = '9:6';
        list{10,1} = '10:5';
        list{11,1} = '11:4';
        list{12,1} = '12:3';
        list{13,1} = '13:2';
        list{14,1} = '14:1';
        set(handles.flash_duty, 'String', list);
    case '3Hz'
        list = cell(0);
        list{1,1} = '1:9';
        list{2,1} = '2:8';
        list{3,1} = '3:7';
        list{4,1} = '4:6';
        list{5,1} = '5:5';
        list{6,1} = '6:4';
        list{7,1} = '7:3';
        list{8,1} = '8:2';
        list{9,1} = '9:1';
        set(handles.flash_duty, 'String', list);
    case '5Hz'
        list = cell(0);
        list{1,1} = '1:5';
        list{2,1} = '2:4';
        list{3,1} = '3:3';
        list{4,1} = '4:2';
        list{5,1} = '5:1';
        set(handles.flash_duty, 'String', list);
    case '6Hz'
        list = cell(0);
        list{1,1} = '1:4';
        list{2,1} = '2:3';
        list{3,1} = '3:2';
        list{4,1} = '4:1';
        set(handles.flash_duty, 'String', list);
    case '10Hz'
        list = cell(0);
        list{1,1} = '1:2';
        list{2,1} = '2:1';
        set(handles.flash_duty, 'String', list);
    case '15Hz'
        list = cell(0);
        list{1,1} = '1:1';        
        set(handles.flash_duty, 'String', list);
    case '30Hz'
        list = cell(0);
        list{1,1} = '-';        
        set(handles.flash_duty, 'String', list);
end

function linearizeBMP(image) %#ok<DEFNU>
global SYSPARAMS;


hibitiamge = image;
dacoeff = [9346852.79448745 -41895568.24241997 79504249.96067327 -83044522.43767963 52026750.07637602 -20004605.37173481 4659748.165839 -634660.4543606126 57930.19303583798 -8006.013601828307];


newimage = reshape(image, prod(size(image)),1);
hibitimage = polyval(dacoeff,newimage);
hibitimage = reshape(hibitimage, SYSPARAMS.rasterV, SYSPARAMS.rasterH);

if isdir(fullfile(pwd,'temp')) == 0
    mkdir(pwd,'temp');    
    %blankframe = zeros(height,width);
    cd(fullfile(pwd,'temp'));
else
    cd(fullfile(pwd,'temp'));
end

fid = fopen('frame2.buf','w');
fwrite(fid, SYSPARAMS.rasterH, 'int16');
fwrite(fid, SYSPARAMS.rasterV, 'int16');
hibitimage = hibitimage';
fwrite(fid,hibitimage,'int16');
fclose(fid);

cd ..;
hibitimage;

function sequence = makeSaccTumbESequence(numpresent)

rand('state',sum(clock * 100));

numframes = 31;
numlocations = 9;
numorientations = 4;
numframeofstim = 15;
numframesbeforeshift = 15;
frameindexofshift = numframesbeforeshift + 1;


frameindexofonlyfix = (numframeofstim + numframesbeforeshift) + 1;
numframesofonlyfix = numframes - (numframeofstim + numframesbeforeshift);

numpresentperstim = fix(numpresent / numlocations);

whichorientation = repmat(1:numorientations,fix(numpresent / numorientations) + 1,1);
whichorientation = whichorientation(:);
if length(whichorientation) > numpresent
    whichorientation = whichorientation(1:numpresent);
end
temporder = randperm(numpresent);
whichorientation = whichorientation(temporder);

whichlocation = repmat(1:numlocations,numpresentperstim,1);
whichlocation = whichlocation(:);

if length(whichlocation) > numpresent
    whichlocation = whichlocation(1:numpresent);
end
temporder = randperm(numpresent);
whichlocation = whichlocation(temporder);

stimframenumber = (numorientations * (whichlocation - 1)) + whichorientation + 1;
stimframenumber = stimframenumber(:);
fixframenumber = (numlocations * numorientations) + 1 + whichlocation;
fixframenumber = fixframenumber(:);


prefixblock = repmat(fixframenumber(1:end - 1),1,numframesbeforeshift);
stimblock = repmat(stimframenumber,1,numframeofstim);
fixblock = repmat(fixframenumber,1,numframesofonlyfix);


sequence = ones(numpresent,numframes);
sequence(2:end,1:numframesbeforeshift) = prefixblock;
sequence(:,frameindexofshift:frameindexofshift + numframeofstim - 1) = stimblock;
sequence(:,frameindexofonlyfix:frameindexofonlyfix + numframesofonlyfix - 1) = fixblock;

function frame = MakeMinVis(pixelsize)
global SYSPARAMS;

hAomControl = getappdata(0,'hAomControl');
CFG = getappdata(hAomControl, 'CFG');

frame = ones(SYSPARAMS.rasterV,SYSPARAMS.rasterH);
ycenter = SYSPARAMS.rasterV/2;
xcenter = SYSPARAMS.rasterH/2;
stimtype=CFG.stimtype;
if strcmp(stimtype, 'square')
if pixelsize == 1
    frame(ycenter, xcenter) = 0;
elseif pixelsize > 1
    frame(round(ycenter-pixelsize/2):round(ycenter+pixelsize/2),round(xcenter-pixelsize/2):round(xcenter+pixelsize/2)) = 0;
end
elseif strcmp(stimtype, 'circle')
radius = pixelsize/2;
center = size(frame)./2;
X = ones(SYSPARAMS.rasterV,1)*[center(2)-center(2)*2:center(2)-1]; 
Y = [center(1)-center(1)*2:center(1)-1]'*ones(1,SYSPARAMS.rasterH);
Z = X.^2 + Y.^2;
frame(find(Z <= (radius)^2))=0;
frame(frame==0)  = 0; 
frame(frame==1) = 255;
end
if isdir(fullfile(pwd,'temp')) == 0
    mkdir(pwd,'temp');    
    cd(fullfile(pwd,'temp'));
else
    cd(fullfile(pwd,'temp'));
end

imwrite(frame,'analog2.bmp');
imwrite(frame,'digital2.bmp');
if exist('analog2.buf','file') == 2
    delete('analog2.buf');
else
end
if exist('digital2.buf','file') == 2
    delete('digital2.buf');
else
end

% fid = fopen('frame2.buf','w');
% 
% %fwrite(fid,[SYSPARAMS.rasterH SYSPARAMS.rasterV],'int16');
% frame = frame';
% fwrite(fid,SYSPARAMS.rasterH,'int16');
% fwrite(fid,SYSPARAMS.rasterV,'int16');
% fwrite(fid,frame,'int16');
% fclose(fid);

cd ..;
frame;

% --- Executes on button press in ir_on_off.
function ir_on_off_Callback(hObject, eventdata, handles)
% hObject    handle to ir_on_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ir_on_off
global SYSPARAMS;
if exist('handles', 'var') == 0;
    handles = guihandles;
else
    %donothing
end
if get(handles.ir_on_off, 'Value') == 1
    SYSPARAMS.aoms_state(1) = 1;
else
    SYSPARAMS.aoms_state(1) = 0;
end
if SYSPARAMS.realsystem == 1
    commandstring = ['TurnOn#0#' num2str(SYSPARAMS.aoms_state(1)) '#']; 
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(commandstring);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    end
end

% --- Executes on button press in red_on_off.
function red_on_off_Callback(hObject, eventdata, handles)
% hObject    handle to red_on_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of red_on_off
global SYSPARAMS;
if exist('handles', 'var') == 0;
    handles = guihandles;
else
    %donothing
end
if get(handles.red_on_off, 'Value') == 1
    SYSPARAMS.aoms_state(2) = 1;
else
    SYSPARAMS.aoms_state(2) = 0;
end
if SYSPARAMS.realsystem == 1
    commandstring = ['TurnOn#1#' num2str(SYSPARAMS.aoms_state(2)) '#']; 
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(commandstring);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    end
end

% --- Executes on button press in green_on_off.
function green_on_off_Callback(hObject, eventdata, handles)
% hObject    handle to green_on_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of green_on_off
global SYSPARAMS;
if exist('handles', 'var') == 0;
    handles = guihandles;
else
    %donothing
end
if get(handles.green_on_off, 'Value') == 1
    SYSPARAMS.aoms_state(3) = 1;
else
    SYSPARAMS.aoms_state(3) = 0;
end
if SYSPARAMS.realsystem == 1
    commandstring = ['TurnOn#2#' num2str(SYSPARAMS.aoms_state(3)) '#']; 
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(commandstring);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    end
end

% --- Executes on button press in blue_on_off.
function blue_on_off_Callback(hObject, eventdata, handles)
% hObject    handle to blue_on_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of blue_on_off
global SYSPARAMS;
if exist('handles', 'var') == 0;
    handles = guihandles;
else
    %donothing
end
if get(handles.blue_on_off, 'Value') == 1
    SYSPARAMS.aoms_state(4) = 1;    
else
    SYSPARAMS.aoms_state(4) = 0;
end
if SYSPARAMS.realsystem == 1
    commandstring = ['TurnOn#3#' num2str(SYSPARAMS.aoms_state(4)) '#']; 
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(commandstring);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    end
end

% --- Executes on button press in display_button.
function display_button_Callback(hObject, eventdata, handles)
% hObject    handle to display_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global StimParams;
if exist('handles', 'var') == 0;
    handles = guihandles;
else
    %donothing
end
if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end

disp_mode = get(handles.display_button, 'String');
if strcmp(disp_mode, 'Display Image')
    loadBMP(hObject, eventdata, handles);
elseif strcmp(disp_mode, 'Load Image Sequence')
    LoadImageSequence;
elseif strcmp(disp_mode, 'Play')
    PlayMovie;
elseif strcmp(disp_mode, 'Config & Start')
    hAomControl = getappdata(0,'hAomControl');
    stimpath = StimParams.stimpath;
    setappdata(hAomControl, 'stimpath', stimpath);
    exp_name = get(handles.im_popup1, 'String');
    exp_num = get(handles.im_popup1, 'Value');
    exp_name = char(exp_name{exp_num});
    run(exp_name);    
    %prompt user to align raster and press start buttom when ready
    set(handles.aom1_state, 'String', 'On - Experiment Mode - Press Start to Begin Experiment');    
    set(handles.alignh_slider, 'Enable', 'on');    
end

% --- Executes on selection change in bufferlist.
function bufferlist_Callback(hObject, eventdata, handles)
% hObject    handle to bufferlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns bufferlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bufferlist
global SYSPARAMS StimParams;
value = get(handles.bufferlist, 'Value');
if value == 1
    %do nothing
    return;
else
    hAomControl = getappdata(0,'hAomControl');
    uiwait(AOMselection('N'));
    AOMSel = getappdata(hAomControl, 'AOMSel');    
end
if SYSPARAMS.realsystem == 1
    switch AOMSel.loadbuf
        case 0
            commandstring = ['Update#' num2str(value) '#-2#-2#-2#']; % -1 loads the last buffer that has been loaded
        case 1
            commandstring = ['Update#-2#' num2str(value) '#-2#-2#']; % -1 loads the last buffer that has been loaded
        case 2
            commandstring = ['Update#-2#-2#' num2str(value) '#-2#']; % -1 loads the last buffer that has been loaded
        case 3
            commandstring = ['Update#-2#-2#-2#' num2str(value) '#']; % -1 loads the last buffer that has been loaded
    end
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(commandstring);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    end
end
buflist = getappdata(hAomControl, 'BufList');
fullpath = [char(buflist(value,1)) char(buflist(value,2)) '.' char(buflist(value,3))];

if SYSPARAMS.aoms_enable(1) == 1
    StimParams.filepath{1} = '-';
end
if SYSPARAMS.aoms_enable(2) == 1
    StimParams.filepath{2} = '-';
end
if SYSPARAMS.aoms_enable(3) == 1
    StimParams.filepath{3} = '-';
end
if SYSPARAMS.aoms_enable(4) == 1
    StimParams.filepath{4} = '-';
end

if SYSPARAMS.aoms_state(1) == 1 %IR    
    if AOMSel.loadbuf ==  0
        StimParams.filepath{1} = fullpath;
    end
end

if SYSPARAMS.aoms_state(2) == 1 %red
    if AOMSel.loadbuf ==  1 %red
        StimParams.filepath{2} = fullpath;
    end
end

if SYSPARAMS.aoms_state(3) == 1 %green
    if AOMSel.loadbuf == 2 %green
        StimParams.filepath{3} = fullpath;  
    end
end

if SYSPARAMS.aoms_state(4) == 1 %blue
    if AOMSel.loadbuf == 3 %blue
        StimParams.filepath{4} = fullpath;
    end
end

Show_Image(1);
set(handles.bufferlist, 'Value', 1);

% --- Executes during object creation, after setting all properties.
function bufferlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bufferlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in trackingen.
function trackingen_Callback(hObject, eventdata, handles)
% hObject    handle to trackingen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trackingen
global SYSPARAMS;
SYSPARAMS.tracking = get(handles.trackingen, 'Value');

% --- Executes on mouse press over axes background.
function raster1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to raster1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS;
if SYSPARAMS.tracking == 1 && SYSPARAMS.board == 'm'
    cp = get(gca,'currentpoint');
    x = round(cp(1,1)-1);
    y = round((SYSPARAMS.rasterV-cp(1,2))-1);
    if (x>=0 && x<=511 && y>=0 && y<=511)
        command = ['Locate#' num2str(x) '#' num2str(y) '# #'];
        MATLABAomControl32(command);
    end
end

% --- Executes on slider movement.
function alignh_slider_Callback(hObject, eventdata, handles)  %#ok<DEFNU>
global SYSPARAMS StimParams;
alignVal = round(get(hObject, 'Value'));
set(handles.alignh_slider, 'Value', alignVal);
StimParams.aomoffs(SYSPARAMS.aomoffsvsel, 2) = 32-alignVal;
set(handles.alignh_val, 'String', num2str(StimParams.aomoffs(SYSPARAMS.aomoffsvsel, 2)));
if SYSPARAMS.realsystem == 1
    aligncommand = ['UpdateOffset#' num2str(StimParams.aomoffs(1, 1)) '#' num2str(StimParams.aomoffs(1, 2)) '#' num2str(StimParams.aomoffs(2, 1)) '#' num2str(StimParams.aomoffs(2, 2)) '#' num2str(StimParams.aomoffs(3, 1)) '#' num2str(StimParams.aomoffs(3, 2)) '#'];   %#ok<NASGU>
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(aligncommand);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(aligncommand));
    end
end
if SYSPARAMS.sysmode~= 1
    Show_Image(0);
end

% --- Executes during object creation, after setting all properties.
function alignh_slider_CreateFcn(hObject, eventdata, handles)  %#ok<DEFNU>

set(hObject,'BackgroundColor',[.9 .9 .9]);

% --- Executes on button press in aligngrh.
function aligngrh_Callback(hObject, eventdata, handles)
% hObject    handle to aligngrh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of aligngrh
global SYSPARAMS StimParams;
handles = guihandles;
SYSPARAMS.aomoffsvsel = 2;
set(handles.aligngrh,'Value',1);
set(handles.alignredh,'Value',0);
set(handles.alignblueh,'Value',0);
set(handles.alignh_slider, 'Value', 32-StimParams.aomoffs(SYSPARAMS.aomoffsvsel,2));
set(handles.alignh_val, 'String', num2str(StimParams.aomoffs(SYSPARAMS.aomoffsvsel,2)));

% --- Executes on button press in alignredh.
function alignredh_Callback(hObject, eventdata, handles)
% hObject    handle to alignredh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alignredh
global SYSPARAMS StimParams;
handles = guihandles;
SYSPARAMS.aomoffsvsel = 1;
set(handles.alignredh,'Value',1);
set(handles.aligngrh,'Value',0);
set(handles.alignblueh,'Value',0);
set(handles.alignh_slider, 'Value', 32-StimParams.aomoffs(SYSPARAMS.aomoffsvsel,2));
set(handles.alignh_val, 'String', num2str(StimParams.aomoffs(SYSPARAMS.aomoffsvsel,2)));

% --- Executes on button press in alignblueh.
function alignblueh_Callback(hObject, eventdata, handles)
% hObject    handle to alignblueh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alignblueh
global SYSPARAMS StimParams;
handles = guihandles;
SYSPARAMS.aomoffsvsel = 3;
set(handles.alignblueh,'Value',1);
set(handles.aligngrh,'Value',0);
set(handles.alignredh,'Value',0);
set(handles.alignh_slider, 'Value', 32-StimParams.aomoffs(SYSPARAMS.aomoffsvsel,2));
set(handles.alignh_val, 'String', num2str(StimParams.aomoffs(SYSPARAMS.aomoffsvsel,2)));

% --- Executes when user attempts to close aom_main_figure.
%function aom_main_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to aom_main_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function alignv_slider_Callback(hObject, eventdata, handles)
% hObject    handle to alignv_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SYSPARAMS StimParams;
alignVal = round(get(hObject, 'Value'));
set(handles.alignv_slider, 'Value', alignVal);
StimParams.aomoffs(SYSPARAMS.aomoffshsel, 1) = alignVal-16;
set(handles.alignv_val, 'String', num2str(StimParams.aomoffs(SYSPARAMS.aomoffshsel, 1)));
if SYSPARAMS.realsystem == 1
    aligncommand = ['UpdateOffset#' num2str(StimParams.aomoffs(1, 1)) '#' num2str(StimParams.aomoffs(1, 2)) '#' num2str(StimParams.aomoffs(2, 1)) '#' num2str(StimParams.aomoffs(2, 2)) '#' num2str(StimParams.aomoffs(3, 1)) '#' num2str(StimParams.aomoffs(3, 2)) '#'];   %#ok<NASGU>
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(aligncommand);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(aligncommand));
    end
end
if SYSPARAMS.sysmode~= 1
    Show_Image(0);
end


% --- Executes during object creation, after setting all properties.
function alignv_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alignv_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in alignredv.
function alignredv_Callback(hObject, eventdata, handles)
% hObject    handle to alignredv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alignredv
global SYSPARAMS StimParams;
handles = guihandles;
SYSPARAMS.aomoffshsel = 1;
set(handles.alignredv,'Value',1);
set(handles.aligngrv,'Value',0);
set(handles.alignbluev,'Value',0);
set(handles.alignv_slider, 'Value', StimParams.aomoffs(1,1)+16);
set(handles.alignv_val, 'String', num2str(StimParams.aomoffs(1,1)));


% --- Executes on button press in aligngrv.
function aligngrv_Callback(hObject, eventdata, handles)
% hObject    handle to aligngrv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of aligngrv
global SYSPARAMS StimParams;
handles = guihandles;
SYSPARAMS.aomoffshsel = 2;
set(handles.aligngrv,'Value',1);
set(handles.alignredv,'Value',0);
set(handles.alignbluev,'Value',0);
set(handles.alignv_slider, 'Value', StimParams.aomoffs(2,1)+16);
set(handles.alignv_val, 'String', num2str(StimParams.aomoffs(2,1)));


% --- Executes on button press in alignbluev.
function alignbluev_Callback(hObject, eventdata, handles)
% hObject    handle to alignbluev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alignbluev
global SYSPARAMS StimParams;
handles = guihandles;
SYSPARAMS.aomoffshsel = 3;
set(handles.alignbluev,'Value',1);
set(handles.aligngrv,'Value',0);
set(handles.alignredv,'Value',0);
set(handles.alignv_slider, 'Value', StimParams.aomoffs(3,1)+16);
set(handles.alignv_val, 'String', num2str(StimParams.aomoffs(3,1)));



function alignh_val_Callback(hObject, eventdata, handles)
% hObject    handle to alignh_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alignh_val as text
%        str2double(get(hObject,'String')) returns contents of alignh_val as a double


% --- Executes during object creation, after setting all properties.
function alignh_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alignh_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function alignv_val_Callback(hObject, eventdata, handles)
% hObject    handle to alignv_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alignv_val as text
%        str2double(get(hObject,'String')) returns contents of alignv_val as a double


% --- Executes during object creation, after setting all properties.
function alignv_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alignv_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on alignh_val and none of its controls.
function alignh_val_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to alignh_val (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS StimParams;
if strcmp(eventdata.Key, 'return') == 1
    alignVal = str2num(get(handles.alignh_val, 'String'));
    if alignVal < -32
        alignVal = -32;
    elseif alignVal > 32        
        alignVal = 32;
    end 
    set(handles.alignh_val, 'String', num2str(alignVal));
    StimParams.aomoffs(SYSPARAMS.aomoffsvsel, 2) = alignVal;
end
if SYSPARAMS.sysmode~= 1
    Show_Image(0);
end

% --- Executes on key press with focus on alignv_val and none of its controls.
function alignv_val_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to alignv_val (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS StimParams;
if strcmp(eventdata.Key, 'return') == 1
    alignVal = str2num(get(handles.alignv_val, 'String'));
    if alignVal < -16
        alignVal = -16;
    elseif alignVal > 16        
        alignVal = 16;
    end 
    set(handles.alignv_val, 'String', num2str(alignVal));
    StimParams.aomoffs(SYSPARAMS.aomoffshsel, 1) = alignVal;
end
if SYSPARAMS.sysmode~= 1
    Show_Image(0);
end


% --- Executes on button press in load_default_stimulus.
function load_default_stimulus_Callback(hObject, eventdata, handles)
% hObject    handle to load_default_stimulus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS OrigFrame;
OrigFrame.ir = zeros(16,16);
OrigFrame.red = ones(16,16)*255;
OrigFrame.green = ones(16,16)*255;
OrigFrame.blue = ones(16,16)*255;
if SYSPARAMS.realsystem == 1
    aligncommand = ['LoadDefaults#0#'];   %#ok<NASGU>
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(aligncommand);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(aligncommand));
    end
end
Show_Image(0);


% --- Executes on button press in turn_on_tca.
function turn_on_tca_Callback(hObject, eventdata, handles)
% hObject    handle to turn_on_tca (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS StimParams OrigFrame;
SYSPARAMS.sysmode = 0;
OrigFrame.ir = 0;
OrigFrame.red = 0;
OrigFrame.green = 0;
OrigFrame.blue = 0;
StimParams.filepath{4} = '-';
currentpath = cd;
StimParams.stimpath = [fullfile(currentpath, 'BMP_Files', 'TCA') filesep];
if SYSPARAMS.realsystem == 1
    %set gain to zero
    commandstring = ['Gain#0#']; %gain=0
    netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    %set flash frequency to 30Hz
    %load tca bitmaps
    commandstring = ['Load#1#' StimParams.stimpath '#TCA256x128IR#0#0#bmp#']; %IR
    netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    pause(0.1);
    commandstring = ['Load#0#' StimParams.stimpath '#TCA256x128R#0#0#bmp#']; %Red
    netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    pause(0.1);
    commandstring = ['Load#0#' StimParams.stimpath '#TCA256x128G#0#0#bmp#']; %Green
    netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
    pause(0.1);
    %update stimuli patterns
    commandstring = ['Update#2#3#4#-1#']; % -1 loads the last buffer that has been loaded
    netcomm('write',SYSPARAMS.netcommobj,int8(commandstring));
end
StimParams.filepath{2} = '-';
StimParams.filepath{3} = '-';
StimParams.filepath{1} = fullfile(currentpath, 'BMP_Files', 'TCA', 'TCA256x128IR.bmp');
Show_Image(1);
StimParams.filepath{1} = '-';
StimParams.filepath{3} = '-';
StimParams.filepath{2} = fullfile(currentpath, 'BMP_Files', 'TCA', 'TCA256x128R.bmp');
Show_Image(1);
StimParams.filepath{1} = '-';
StimParams.filepath{2} = '-';
StimParams.filepath{3} = fullfile(currentpath, 'BMP_Files', 'TCA', 'TCA256x128G.bmp');
Show_Image(1);

% --- Executes on button press in pupiltracking.
function pupiltracking_Callback(hObject, eventdata, handles)
% hObject    handle to pupiltracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SYSPARAMS
if SYSPARAMS.PupilTracker==0 %%CMP
    SYSPARAMS.PupilTracker=1;
    PupilVideoTracking;
end


% --- Executes during object deletion, before destroying properties.
function aom_main_figure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to aom_main_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% make sure that AOMcontrol is in the directory where AOMcontrol.m
% lives
cd(fileparts(which(mfilename)));

global SYSPARAMS VideoParams StimParams; %#ok<NUSED>


if SYSPARAMS.realsystem == 1
    if SYSPARAMS.board == 'm'
        MATLABAomControl32('Stop#');
        pause(.05);
        MATLABAomControl32('ExtClockOff#');
    else
        netcomm('close',SYSPARAMS.netcommobj);
        clear SYSPARAMS.netcommobj;
        SYSPARAMS.netcommobj = 0;
    end
end
try
    save('Initialization.mat', 'SYSPARAMS', 'VideoParams', 'StimParams');    
    rmappdata(0,'hAomControl');
    delete(hObject);
catch ME
    disp(ME)
    close all; 
    clearvars();
    clc;

end
close all;
clearvars();
clc;

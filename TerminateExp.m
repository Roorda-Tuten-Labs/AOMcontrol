function TerminateExp
% 
%

if exist('handles','var') == 0
    handles = guihandles;
    set(handles.aom1_state, 'String', '..Experiment Aborted!..');
    set(handles.display_button, 'Enable', 'on');
    set(handles.display_button, 'String', 'Config & Start');
    set(handles.play_button1, 'Enable', 'off');
    set(handles.image_radio1, 'Enable', 'on');
    set(handles.seq_radio1, 'Enable', 'on');
    set(handles.exp_radio1, 'Enable', 'on');
    set(handles.im_popup1, 'Enable', 'on');
    set(handles.aom1_onoff, 'Enable', 'on');
    set(handles.aom1_onoff, 'Value', 0);
end
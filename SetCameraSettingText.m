function SetCameraSettingText(handles,CameraSetting)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
set(handles.text11,'String',['Brightness ',num2str(CameraSetting.Brightness)]);
set(handles.text12,'String',['Gamma ',num2str(CameraSetting.Iris)]);
set(handles.text13,'String',['Exposure ',num2str(CameraSetting.Exposure)]);
set(handles.text14,'String',['Gain ',num2str(CameraSetting.Gain)]);

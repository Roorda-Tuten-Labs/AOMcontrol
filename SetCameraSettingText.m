function SetCameraSettingText(handles,CameraSetting)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
set(handles.text11,'String',['Brightness ',num2str(CameraSetting.Brightness)]);
set(handles.text12,'String',['Contrast ',num2str(CameraSetting.Contrast)]);
set(handles.text13,'String',['Exposure ',num2str(CameraSetting.Exposure)]);
set(handles.text14,'String',['Gain ',num2str(CameraSetting.Gain)]);
set(handles.text15,'String',['Gamma ',num2str(CameraSetting.Gamma)]);
set(handles.text16,'String',['Hue ',num2str(CameraSetting.Hue)]);
set(handles.text17,'String',['Saturation ',num2str(CameraSetting.Saturation)]);
set(handles.text18,'String',['Sharpness ',num2str(CameraSetting.Sharpness)]); 

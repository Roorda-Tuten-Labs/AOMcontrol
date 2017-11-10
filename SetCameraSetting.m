function SetCameraSetting(handles,CameraSetting)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
set(handles.slider3,'SliderStep',[0.01 0.10]); set(handles.slider3,'Min',-10); set(handles.slider3,'Max',30); set(handles.slider3,'Value',CameraSetting.Brightness); set(handles.text11,'String',['Brightness ',num2str(CameraSetting.Brightness)]);
set(handles.slider4,'SliderStep',[0.01 0.10]); set(handles.slider4,'Min',-10); set(handles.slider4,'Max',30); set(handles.slider4,'Value',CameraSetting.Contrast); set(handles.text12,'String',['Contrast ',num2str(CameraSetting.Contrast)]);
set(handles.slider5,'SliderStep',[0.01 0.10]); set(handles.slider5,'Min',-13); set(handles.slider5,'Max',-2); set(handles.slider5,'Value',CameraSetting.Exposure); set(handles.text13,'String',['Exposure ',num2str(CameraSetting.Exposure)]);
set(handles.slider6,'SliderStep',[0.01 0.10]); set(handles.slider6,'Min',8); set(handles.slider6,'Max',31); set(handles.slider6,'Value',CameraSetting.Gain); set(handles.text14,'String',['Gain ',num2str(CameraSetting.Gain)]);
set(handles.slider7,'SliderStep',[0.01 0.10]); set(handles.slider7,'Min',1); set(handles.slider7,'Max',500); set(handles.slider7,'Value',CameraSetting.Gamma); set(handles.text15,'String',['Gamma ',num2str(CameraSetting.Gamma)]);
set(handles.slider8,'SliderStep',[0.01 0.10]); set(handles.slider8,'Min',-180); set(handles.slider8,'Max',180); set(handles.slider8,'Value',CameraSetting.Hue); set(handles.text16,'String',['Hue ',num2str(CameraSetting.Hue)]);
set(handles.slider9,'SliderStep',[0.01 0.10]); set(handles.slider9,'Min',0); set(handles.slider9,'Max',255); set(handles.slider9,'Value',CameraSetting.Saturation); set(handles.text17,'String',['Saturation ',num2str(CameraSetting.Saturation)]);
set(handles.slider10,'SliderStep',[0.01 0.10]); set(handles.slider10,'Min',0); set(handles.slider10,'Max',14); set(handles.slider10,'Value',CameraSetting.Sharpness); set(handles.text18,'String',['Sharpness ',num2str(CameraSetting.Sharpness)]);

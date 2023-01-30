function SetCameraSetting(handles,CameraSetting)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
set(handles.slider3,'SliderStep',[0.1 0.1]); set(handles.slider3,'Min',0); set(handles.slider3,'Max',4095); set(handles.slider3,'Value',CameraSetting.Brightness); set(handles.text11,'String',['Brightness ',num2str(CameraSetting.Brightness)]);
set(handles.slider4,'SliderStep',[0.1 0.1]); set(handles.slider4,'Min',0.0100); set(handles.slider4,'Max',5); set(handles.slider4,'Value',CameraSetting.Iris); set(handles.text12,'String',['Gamma ',num2str(CameraSetting.Iris)]);
set(handles.slider5,'SliderStep',[0.0005 0.0005]); set(handles.slider5,'Min',0.0001); set(handles.slider5,'Max',4); set(handles.slider5,'Value',CameraSetting.Exposure); set(handles.text13,'String',['Exposure ',num2str(CameraSetting.Exposure)]);
set(handles.slider6,'SliderStep',[0.01 0.01]); set(handles.slider6,'Min',0); set(handles.slider6,'Max',48); set(handles.slider6,'Value',CameraSetting.Gain); set(handles.text14,'String',['Gain ',num2str(CameraSetting.Gain)]);



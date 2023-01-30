function SetCameraValues(Vid,CameraSetting)
src_obj = getselectedsource(Vid);

set(src_obj,'Brightness',CameraSetting.Brightness)
set(src_obj,'Gamma',CameraSetting.Iris)
set(src_obj,'Exposure',CameraSetting.Exposure)
set(src_obj,'Gain',CameraSetting.Gain)



if CameraSetting.ExposureMode==1,
    set(src_obj,'ExposureAuto','On')
    set(src_obj,'GainAuto','On')
else
    set(src_obj,'ExposureAuto','Off')
    set(src_obj,'GainAuto','Off')
end

set(src_obj,'Brightness',CameraSetting.Brightness)
set(src_obj,'Gamma',CameraSetting.Iris)
set(src_obj,'Exposure',CameraSetting.Exposure)
set(src_obj,'Gain',CameraSetting.Gain)

Vid.ROIPosition=CameraSetting.ROI;

fprintf('Frame Rate:\t%f\n',src_obj.FrameRate)
fprintf('Exposure:\t%f\n',src_obj.Exposure)
fprintf('Gain:\t\t%f\n',src_obj.Gain)
fprintf('Gamma:\t\t%f\n',src_obj.Gamma)
fprintf('ExposureAuto:\t%s\n',src_obj.ExposureAuto)
fprintf('GainAuto:\t\t%s\n',src_obj.GainAuto)


function SetCameraValues(Vid,CameraSetting)
src_obj = getselectedsource(Vid);

set(src_obj,'Brightness',CameraSetting.Brightness)
set(src_obj,'Contrast',CameraSetting.Contrast)
set(src_obj,'Exposure',CameraSetting.Exposure)
set(src_obj,'Gain',CameraSetting.Gain)
set(src_obj,'Brightness',CameraSetting.Brightness)
set(src_obj,'Gamma',CameraSetting.Gamma)
set(src_obj,'Hue',CameraSetting.Hue)
set(src_obj,'Saturation',CameraSetting.Saturation)
set(src_obj,'Sharpness',CameraSetting.Sharpness)


if CameraSetting.ExposureMode==1,
    set(src_obj,'ExposureMode','auto')
    set(src_obj,'GainMode','auto')
else
    set(src_obj,'ExposureMode','manual')
    set(src_obj,'GainMode','manual')
end

Vid.ROIPosition=CameraSetting.ROI;


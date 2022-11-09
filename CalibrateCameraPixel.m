hwInfo = imaqhwinfo('winvideo',1); % get info and formats
%obj=videoinput('winvideo', 3,'RGB24_1024x768');
obj= videoinput('winvideo', 1,'RGB24_1024x768');
vidRes = obj.VideoResolution; 
nBands = obj.NumberOfBands;
hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
preview(obj, hImage);
src_obj = getselectedsource(obj);
set(src_obj,'ExposureMode','manual');
set(src_obj,'GainMode','manual');
propinfo(src_obj,'Gain');
set(src_obj,'Gain',31);
set(src_obj,'Exposure',-3);
DistanceMM = input('Enter distance in mm : ');
fprintf('Click on the two mark for %f mm\n',DistanceMM);
[X,Y]=ginput(2);
load CalibrationSetting
CalibrationSetting(1)=sqrt(diff(X).^2 + diff(Y).^2)/DistanceMM;
save CalibrationSetting CalibrationSetting
closepreview(obj);

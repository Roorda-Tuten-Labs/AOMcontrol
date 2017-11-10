clear all
close all
start_path='C:\Programs\AOMcontrol_V3_2_cleaned\VideoAndRef';
[filename, pathname] = uigetfile(start_path);
eval(['load ',pathname,filename])
vformat=size(VideoToSave); vformat=vformat(2);
I1=size(VideoToSave,1)/vformat;
for f=1:I1
    V=VideoToSave((f-1)*vformat+1:f*vformat,:,:)+0; V1=(V(:,:,1) + V(:,:,2) + V(:,:,3))./3;
    s=size(V);
    AvoidedBorder=1;
    Vt=V(AvoidedBorder:s(1)-AvoidedBorder+1,AvoidedBorder:s(2)-AvoidedBorder+1);
    image(Vt);  colormap(gray); axis image; 
    pause(0.5); %ginput(1);
end

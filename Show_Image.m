function Show_Image(loadon)
% USAGE
% Show_Image(loadon)
%
% INPUT
% loadon    if set to 1, the image file specified in StimParams.filepath
%           will be read. Otherwise, assumes that OrigFrame structure
%           already has image matrix in OrigFrame.ir, OrigFrame.red, etc.
%
% OUTPUT
% none      gui window is updated.
%
% DESCRIPTION
% Function called by AOMcontrol.m for display in gui window.

global SYSPARAMS CurFrame OrigFrame StimParams;
if exist('handles','var') == 0
    handles = get_aom_gui_handle();
end
h = get(handles.im_panel1, 'Child');
set(h,'Visible', 'on');
axes(h); %#ok<MAXES> %#ok<MAXES>
curframe = zeros(SYSPARAMS.rasterV,SYSPARAMS.rasterH,3);
if loadon == 1 
    if StimParams.filepath{1} ~= '-'
        OrigFrame.ir = imageread(StimParams.filepath{1});       
    elseif StimParams.filepath{2} ~= '-'
        OrigFrame.red = imageread(StimParams.filepath{2});         
    elseif StimParams.filepath{3} ~= '-'
        OrigFrame.green = imageread(StimParams.filepath{3});
    elseif StimParams.filepath{4} ~= '-'
        OrigFrame.blue = imageread(StimParams.filepath{4});
    end
end
if SYSPARAMS.aoms_state(1) == 1 %IR
    curframe(:,:,1) = 50*SYSPARAMS.aompowerLvl(1);
    if  max(max(OrigFrame.ir)) ~= 50 % || StimParams.filepath{1} ~= '-'        
        temp_im_d = double(OrigFrame.ir);
        temp_im = uint8(((temp_im_d-min(min(temp_im_d)))*(50/((max(max(temp_im_d))-min(min(temp_im_d)))+1)))*SYSPARAMS.aompowerLvl(1));
        temp_im_dim = size(temp_im);
        curframe(floor(256-temp_im_dim(1)/2)+1:floor(256-temp_im_dim(1)/2)+temp_im_dim(1),floor(256-temp_im_dim(2)/2)+1:floor(256-temp_im_dim(2)/2)+temp_im_dim(2),1) = double(temp_im);
    end
end

if SYSPARAMS.aoms_state(2) == 1 
    if max(max(OrigFrame.red))>0%Red
        if min(min(OrigFrame.red)) ~= 255 && min(min(OrigFrame.red)) ~= 255
            temp_im_d = double(temp_im);
            temp_im = uint8(((temp_im_d-min(min(temp_im_d)))*((255-51)/((max(max(temp_im_d))-min(min(temp_im_d)))+1)))*SYSPARAMS.aompowerLvl(2));
        else
            temp_im = OrigFrame.red;
        end
        temp_im_dim = size(temp_im);
        curframe(floor(256+StimParams.aomoffs(1,2)-temp_im_dim(1)/2)+1:floor(256+StimParams.aomoffs(1,2)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+StimParams.aomoffs(1,1)-temp_im_dim(2)/2)+1:floor(256+StimParams.aomoffs(1,1)-temp_im_dim(2)/2)+temp_im_dim(2),1) = curframe(floor(256-temp_im_dim(1)/2)+1:floor(256-temp_im_dim(1)/2)+temp_im_dim(1),floor(256-temp_im_dim(2)/2)+1:floor(256-temp_im_dim(2)/2)+temp_im_dim(2),1)+double(temp_im);
    end
end

if SYSPARAMS.aoms_state(3) == 1 
    if max(max(OrigFrame.green))>0%Green
        temp_im = OrigFrame.green;
        temp_im_dim = size(temp_im);
        curframe(floor(256+StimParams.aomoffs(2,2)-temp_im_dim(1)/2)+1:floor(256+StimParams.aomoffs(2,2)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+StimParams.aomoffs(2,1)-temp_im_dim(2)/2)+1:floor(256+StimParams.aomoffs(2,1)-temp_im_dim(2)/2)+temp_im_dim(2),2) = double(temp_im);
    end
end

if SYSPARAMS.aoms_state(4) == 1 
    if max(max(OrigFrame.blue))>0%Blue
        temp_im = OrigFrame.green;
        temp_im_dim = size(temp_im);
        curframe(floor(256+StimParams.aomoffs(3,2)-temp_im_dim(1)/2)+1:floor(256+StimParams.aomoffs(3,2)-temp_im_dim(1)/2)+temp_im_dim(1),floor(256+StimParams.aomoffs(3,1)-temp_im_dim(2)/2)+1:floor(256+StimParams.aomoffs(3,1)-temp_im_dim(2)/2)+temp_im_dim(2),3) = double(temp_im);
    end
end

imshow(uint8(curframe),'InitialMagnification',100, 'Border', 'tight');
CurFrame = uint8(curframe);
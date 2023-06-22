% finds and sets the stimulus location in the new reference frame
% from a master image / x,y coordinate
% Basically a more advanced stimulus location recovery (SLR)
% AE Boehm 6-29-21
% for use with staircase_unique_yellow_stabilied.m experiment
global SYSPARAMS StimParams VideoParams;

cdir = pwd;


if strcmp(cdir(18:22), 'bT470') % Working on AEB laptop
    dataFilePath = 'C:\Users\RoordaLabT470s\Box Sync\AOVis\AOMcontrol\Experiments\AllyData\';
else % Working on AO Vis computer
    dataFilePath = 'C:\Programs\AOMcontrol\Experiments\AllyData\';
end


subjectId = input('Input subject ID   ','s')
    
masterFilePath = [dataFilePath,'UniqueYellowStabilized\' subjectId '\']
if ~exist(masterFilePath)
    mkdir(masterFilePath);
end
masterRefName = [subjectId,'_MasterRef.tif'];

display('Select current reference file')
[filename, pathname] = uigetfile('*.avi;*.tif;*.tiff', ...
    'Select current reference (avi, tif or tiff)');

if strmatch(filename(end-3:end),'.avi') ==1  
    [currentRef] = sumframe_from_stabilized_movie(pathname, filename, [masterFilePath,filesep,'ReferenceFrames']);
else
    currentRef =imread([pathname,filename]);
end

if exist([masterFilePath masterRefName])
    display(['Master image found:   ' masterFilePath masterRefName])
    % load and crop the master img to cross corr with curr ref
    masterRef = imread([masterFilePath masterRefName]);
    load([masterFilePath,subjectId,'_MasterCoords']);
    searchRectLength = 300;
    f1 = figure;
    set(gcf,'Position',[573.0000-400  437.6667  560.0000  420.0000])
    imshow(masterRef)
    h = imrect(gca,[10 10 searchRectLength searchRectLength]);
    addNewPositionCallback(h,@(p) title(mat2str(p,3)));
    refRect = wait(h);
    pos1 = getPosition(h);
    masterCropped = imcrop(masterRef,pos1);
    croppedCrossCoords = [xCrossLoc-pos1(1)+1 yCrossLoc-pos1(2)+1];
    
    % load and crop the current ref
    f2 = figure;
    set(gcf,'Position',[573.0000-400  437.6667  560.0000  420.0000])
    imshow(currentRef)
    h = imrect(gca,[10 10 searchRectLength searchRectLength]);
    addNewPositionCallback(h,@(p) title(mat2str(p,3)));
    refRect = wait(h);
    pos2 = getPosition(h);
    currentCropped = imcrop(currentRef,pos2);
    
    [output Greg] = img.dftregistration(fft2(masterCropped),fft2(currentCropped));
 
    newCrossCoords = croppedCrossCoords - [output(4) output(3)] ;
    
    f3=figure;
    subplot(1,2,1);
    imshow(masterCropped); title('Master ref')
    hold on; plot(croppedCrossCoords(1),croppedCrossCoords(2),'y*');
    subplot(1,2,2);
    imshow(currentCropped); title('Current ref')
    hold on; plot(newCrossCoords(1),newCrossCoords(2),'ys')
    set(gcf,'position',[165 338 1339 575])

    
    choice = questdlg('Manually select point in current ref?', ...
        '', ...
        'Yes','No','Yes');
    if strmatch(choice,'Yes')
        [newCrossCoords(1) newCrossCoords(2)] = getpts(f3);
    end

    xCrossLoc = round(newCrossCoords(1) + pos2(1) - 1);
    yCrossLoc = round(newCrossCoords(2) + pos2(2) - 1);
    

else
    display(['Saving current reference as master reference for ' subjectId ': ' masterFilePath masterRefName]) 
    display('User selection will be saved as master coordinates') 
    
    % select a position on the current ref,
    % make this the master img / ref coordinates for future runs.
        f1 = figure; set(gcf,'position',1.0e+03 *[ 0.1123    0.2083    1.0180    0.4633]); subplot(1,2,1); imshow(currentRef); hold on; 
    plot([712/2-200,712/2-200],[712/2-200 712/2+200],'y-');
    plot([712/2+200,712/2+200],[712/2-200 712/2+200],'y-');
    plot([712/2-200 712/2+200],[712/2+200,712/2+200],'y-');
    plot([712/2-200 712/2+200],[712/2-200,712/2-200],'y-');
    

    subplot(1,2,2); imshow(currentRef); set(gca,'xlim',[712/2-200,712/2+200],'ylim',[712/2-200,712/2+200])
    [xCrossLoc,yCrossLoc] = getpts(f1);
    xCrossLoc = round(xCrossLoc);
    yCrossLoc = round(yCrossLoc);
    close(f1);
    save([masterFilePath,subjectId,'_MasterCoords.mat'], 'xCrossLoc', 'yCrossLoc');
    imwrite(currentRef,[masterFilePath masterRefName])

end

if ~exist([masterFilePath, 'experimentRefFrames'])
    mkdir([masterFilePath, 'experimentRefFrames'])
end

refStr = strrep(strrep(strrep(datestr(now),'-',''),' ','x'),':','');
imwrite(currentRef,[masterFilePath, 'experimentRefFrames', filesep, 'expRef_' refStr,'.tif'])
save([masterFilePath,'experimentRefFrames', filesep, refStr,'.mat'],'xCrossLoc','yCrossLoc')

save([masterFilePath,'currentCrossLoc.mat'],'xCrossLoc','yCrossLoc','refStr')

xCrossLoc = xCrossLoc - 100;
yCrossLoc = yCrossLoc - 100; 

choice = questdlg('Update cross location in ICANDI?', ...
    '', ...
    'Yes','No','Yes');
if strmatch(choice,'Yes')
        command=['LocUser#',num2str(xCrossLoc),'#',num2str(yCrossLoc),'#'];
        netcomm('write',SYSPARAMS.netcommobj,int8(command));
end

display(['Cross pixel location (x,y): ' num2str(xCrossLoc), ', ' num2str(yCrossLoc) ])




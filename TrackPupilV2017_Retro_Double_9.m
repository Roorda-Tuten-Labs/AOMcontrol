function [x1,x2,y1,y2,Error]=TrackPupilV2017_Retro_Double_9(A,Graphic)
% TrackPupilV2016_6_ExtQuarter_WhiteP - looking bottom part of the pupil
% and fit an ellipse (circle)
% TrackPupilV2016_6_1_ExtQuarter_WhiteP - puah lowewr the definition of
% bottom part
% TrackPupilV2016_6_2_ExtQuarter_WhiteP - better definition of x0 and y0
% TrackPupilV2016_6_3_ExtQuarter_WhiteP - better anchoring the max grdient

% TrackPupilV2016_6_5_ExtQuarter_WhiteP - trying to fit ellipse

% TrackPupilV2016_6_6_ExtQuarter_WhiteP - trying to fit ellipse

% TrackPupilV2017_Retro_Double_1 - changing for the double image
% TrackPupilV2017_Retro_Double_3 - changing the range for detecting the max
% of the gradient
% TrackPupilV2017_Retro_Double_4 - changing threshold for grandient due to
% dimmer videos
% TrackPupilV2017_Retro_Double_6 - error when no pupil is found close to
% the edge
% TrackPupilV2017_Retro_Double_7 - bug introduced above 
% TrackPupilV2017_Retro_Double_8 - improved tracking in case of poor IR
% TrackPupilV2017_Retro_Double_9 - reduce complexity for edge detection
Error=0;
x1=-1; x2=-1; y1=-1; y2=-1;
VALUE_PLUS_MIN=30;
MIN_WHITE_ACCEPT_FOR_PUPIL=100;
MIN_PUPIL_SIZE=20;
DEFINE_SQUARE=0.75; % define the "squarity" of the tracking ROI

if Graphic==1,figure(30); image(A./2); colormap(gray); axis image; hold on; end

s=size(A);

[MaxGrad,IndexMin]=max(A(:)); MinValueUp=MaxGrad-VALUE_PLUS_MIN;            % look for min
IndexPupil=find(A(:)>MinValueUp);  [y,x] = ind2sub(s,IndexPupil);           % look for everyhting below min
x0=round(median(x)); y0=round(median(y));
if MaxGrad < MIN_WHITE_ACCEPT_FOR_PUPIL, Error=-1; return; end

        
%*************** look for edge going outwards in the 360 directions
NUM_OF_FSS_POINTS=360;  % defining the no. of radii for flying spot alg
ANG_OF_SECTOR=20;       % defining the angle for gradient analysis
Angles=[0:2*pi/NUM_OF_FSS_POINTS:2*pi-2*pi/NUM_OF_FSS_POINTS];
sine=sin(Angles);
cosine=cos(Angles);

StartRadius=100;;
MaxNominalR=min([x0,y0,s(2)-x0,s(1)-y0])-1;

if MaxNominalR<=(StartRadius+10); Error=-22; return; end
R=StartRadius:MaxNominalR;
if isempty(R), Error=-5; return; end
Rdix=round(R'*cosine)+x0;
Rdiy=round(R'*sine)+y0;
IndexRadii=sub2ind(s,Rdiy,Rdix);
ListOfRadiiInGrayScale=reshape(A(IndexRadii(:)),size(Rdix)); % list of all radii
dAngle=floor(ANG_OF_SECTOR/2); 
CurIdx=0;
ThDer=-0.25;


for a=0:ANG_OF_SECTOR:NUM_OF_FSS_POINTS-ANG_OF_SECTOR
    if (a+dAngle) > 190 & (a+dAngle) < 350, continue; end
    CurIdx=CurIdx+1;
    CurRadius=mean(ListOfRadiiInGrayScale(:,a+1:a+ANG_OF_SECTOR)');
    if length(CurRadius)<2 Error=-21; return; end
    CurrGradient=diff(CurRadius); CurrGradient=[CurrGradient(1) CurrGradient];
    CurrGradient = RunningAverage(CurrGradient,5);
    
    [MinDriver,IndexMax]=min(CurrGradient);                         
  
    if MinDriver>ThDer, Error=-20; return; end 
    xr(CurIdx)=round((IndexMax+StartRadius).*cosine(a+dAngle))+x0;
    yr(CurIdx)=round((IndexMax+StartRadius).*sine(a+dAngle))+y0;
    

    if Graphic==1 
        p=plot(xr(CurIdx),yr(CurIdx),'b.'); set(p,'Color',[0 0.75 0]);
        l=line([x0 xr(CurIdx)],[y0,yr(CurIdx)]); set(l,'Color',[0 0 0.75]);
        %disp(a+dAngle);
        fig4=figure(4); set(fig4,'Position',[1446 919 560 420]); 
        plot(CurRadius); hold on; plot(CurrGradient*20+median(CurRadius),'r');
        line([1 length(CurRadius)],[ThDer*20+median(CurRadius) ThDer*20+median(CurRadius)]); set(l,'Color',[0.75 0 0]);
        
        l=line([IndexMax IndexMax],[min(CurrGradient*20+median(CurRadius)) max(CurrGradient*20+median(CurRadius))]); set(l,'Color',[0.75 0 0]);  set(l,'LineStyle',':'); set(l,'LineWidth',3);
        %keyboard
        close(fig4);
        
    end;
end

x=xr(:); y=yr(:);
a=[x y ones(size(x))]\[-(x.^2+y.^2)];
xc = -.5*a(1);
yc = -.5*a(2);
R  =  sqrt((a(1)^2+a(2)^2)/4-a(3));
   
x1=xc-R; x2=xc+R; y1=yc-R; y2=yc+R;
if x2-x1<MIN_PUPIL_SIZE, Error=-2; return; end
if min([x2-x1,y2-y1])/max([x2-x1,y2-y1])<DEFINE_SQUARE, Error=-3; return; end

if Graphic==1,
    xe=xc+R*cosine; ye=yc+R*sine;
    l=plot(xe,ye); set(l,'LineWidth',2); %set(l,'Color',[0.85 0.33 0.1]);  
    l=line([x1 x1],[y1 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x2 x2],[y1 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x1 x2],[y1 y1]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x1 x2],[y2 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
end

function Output = RunningAverage(InputVector,ORDER)
for i=1:length(InputVector)
    Output(i)=mean(InputVector(max(1,i-ORDER):min(length(InputVector),i+ORDER)));
end

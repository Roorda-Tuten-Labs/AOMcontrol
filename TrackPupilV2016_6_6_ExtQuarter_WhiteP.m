function [x1,x2,y1,y2,Error]=TrackPupilV2016_6_6_ExtQuarter_WhiteP(A,Graphic)
% TrackPupilV2016_6_ExtQuarter_WhiteP - looking bottom part of the pupil
% and fit an ellipse (circle)
% TrackPupilV2016_6_1_ExtQuarter_WhiteP - puah lowewr the definition of
% bottom part
% TrackPupilV2016_6_2_ExtQuarter_WhiteP - better definition of x0 and y0
% TrackPupilV2016_6_3_ExtQuarter_WhiteP - better anchoring the max grdient

% TrackPupilV2016_6_5_ExtQuarter_WhiteP - trying to fit ellipse

% TrackPupilV2016_6_6_ExtQuarter_WhiteP - trying to fit ellipse
Error=0;
x1=-1; x2=-1; y1=-1; y2=-1;
VALUE_PLUS_MIN=30;
MIN_WHITE_ACCEPT_FOR_PUPIL=100;
MIN_PUPIL_SIZE=20;
DEFINE_SQUARE=0.75; % define the "squarity" of the tracking ROI

if Graphic==1,figure(30); image(A./4); colormap(gray); axis image; hold on; end

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

MaxNominalR=min([x0,y0,s(2)-x0,s(1)-y0])-1;
StartRadius=15;
R=StartRadius:MaxNominalR;
if isempty(R), Error-5; return; end
Rdix=round(R'*cosine)+x0;
Rdiy=round(R'*sine)+y0;
IndexRadii=sub2ind(s,Rdiy,Rdix);
ListOfRadiiInGrayScale=reshape(A(IndexRadii(:)),size(Rdix)); % list of all radii
dAngle=floor(ANG_OF_SECTOR/2); 
CurIdx=0;
ThDer=-2.5;
TolleranceGradientLocation=15;

for a=0:ANG_OF_SECTOR:NUM_OF_FSS_POINTS-ANG_OF_SECTOR
    if (a+dAngle) > 190 & (a+dAngle) < 350, continue; end
    CurIdx=CurIdx+1;
    CurRadius=mean(ListOfRadiiInGrayScale(:,a+1:a+ANG_OF_SECTOR)');
    if length(CurRadius)<2 Error=-2; return; end
    CurrGradient=diff(CurRadius); CurrGradient=[CurrGradient(1) CurrGradient];
    IndexMaxT=find(CurrGradient<ThDer); 
    if isempty(IndexMaxT) Error=-2; return; end
    IndexMaxT=IndexMaxT(end);
    if IndexMaxT<=TolleranceGradientLocation, Error=-3; return; end
    [MinDriver, IndexMax]=min(CurrGradient(IndexMaxT-TolleranceGradientLocation:IndexMaxT));
    IndexMax=IndexMax+IndexMaxT-TolleranceGradientLocation-1;
    xr(CurIdx)=round((IndexMax+StartRadius).*cosine(a+dAngle))+x0;
    yr(CurIdx)=round((IndexMax+StartRadius).*sine(a+dAngle))+y0;
    if Graphic==1 
        p=plot(xr(CurIdx),yr(CurIdx),'b.'); set(p,'Color',[0 0.75 0]);
        l=line([x0 xr(CurIdx)],[y0,yr(CurIdx)]); set(l,'Color',[0 0 0.75]);
        %disp(a+dAngle);  
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
    l=plot(xe,ye); set(l,'LineWidth',2);
    l=line([x1 x1],[y1 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x2 x2],[y1 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x1 x2],[y1 y1]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x1 x2],[y2 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
end


function [xc,yc,Error]=TrackPupilV2020_ExtQuarter_Reflection(Vt,Graphic)
% TrackPupilV2016_6_ExtQuarter_WhiteP - looking bottom part of the pupil
% and fit an ellipse (circle)
% TrackPupilV2016_6_1_ExtQuarter_WhiteP - puah lowewr the definition of
% bottom part
% TrackPupilV2016_6_2_ExtQuarter_WhiteP - better definition of x0 and y0
% TrackPupilV2016_6_3_ExtQuarter_WhiteP - better anchoring the max grdient

% TrackPupilV2016_6_5_ExtQuarter_WhiteP - trying to fit ellipse

% TrackPupilV2016_6_6_ExtQuarter_WhiteP - trying to fit ellipse
% TrackPupilV2020_ExtQuarter_Reflection - tracking just the center of the
% reflections
Error=0; xc=-1; yc=-1; Error=-1; 
if Graphic==1, figure(30); image(Vt); colormap(gray); axis image; hold on; end


TH_255=10;
S=size(Vt);
idx255_v=find(sum(Vt'==255)>TH_255);
if isempty(idx255_v), return; end

idx255_h=find(sum(Vt==255)>TH_255);
idx255_h=mean(idx255_h);
h0=round(max(1,idx255_h-50)); h1=round(min(idx255_h+50,S(2)));


ver=sum(Vt(:,h0:h1)'==255);
if sum(ver)==0, return; end
    
R0=10; R1=30;
for v=idx255_v
    if v>(R1+1) & v<(S(1)-R1)
        v0=mean(ver(v-R0+1:v+R0-1));
        vl=mean(ver(v-R1:v-R0));
        vr=mean(ver(v+R0:v+R1));
        if v0 >  vl &  v0 > vr, 
            break; end;
    end
end
    
h=find(Vt(v,:)==255); 

R=30;
x1=h(1); x2=h(end);
y1=v-R; y2=v+R;
xc=x1*0.5 + x2*0.5;
yc=v;
x1=xc-R; x2=xc+R;

if Graphic==1,
    l=line([x1 x1],[y1 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x2 x2],[y1 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x1 x2],[y1 y1]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
    l=line([x1 x2],[y2 y2]); set(l,'LineWidth',2); set(l,'Color',[0.75 0 0]);
end


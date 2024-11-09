function ConvCylDL = mlglConvexCyl(Bot,Top,Ht,RadiansCurv,Layers)

% Usage: TaperedCylinderDL = mlglTaperedCyl(BottomRadius, TopRadius, Height,RadiansCurv,Layers)
% 
% Draws a tapered cylinder w/ convex (positive curvature values) or
% concave (negative curvature values) sides.
% 
% Created by ML 5.31.08


global GL;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Checking the Computer's Configuration: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AssertOpenGL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Default Vaules for parameters: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('Bot', 'var')
    Bot = 1.5;
end
if ~exist('Top', 'var')
    Top = 1;
end
if ~exist('Ht', 'var')
    Ht = 3;
end
if ~exist('RadiansCurv','var')
    RadiansCurv = 0;
end

if RadiansCurv ==0
    F.StraightSides = 1;
elseif RadiansCurv < 0
    F.NegCurv = 1;
    RadiansCurv = abs(RadiansCurv);
else
    F.StraightSides = 0; F.NegCurv = 0;
end
    

try

ConvCylDL = glGenLists(1);
glNewList(ConvCylDL,GL.COMPILE);
%glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);
glPushMatrix; 
    glTranslated(0,-Ht/2,0);                
    %%% Bottom of Tapered Cylinder (Big):
    glPushMatrix;
        glRotated(90,1,0,0);
        MacTop = gluNewQuadric;
        inner = 0;
        outer = Top;
        slices = 20;
        stacks = 1;
        loops = 1;
        gluDisk( MacTop, inner, outer, slices, loops)
        gluDeleteQuadric(MacTop);
    glPopMatrix;
    %%% Body of Tapered Cylinder:
    cRadius = 1;
    nPos = pi*Layers/RadiansCurv;
    x_center = 0;
    iPos = 1;
    Pos = zeros(1,180/nPos);
    for tt = 0:180/nPos:180-180/nPos;
        Pos(iPos,1) = cRadius*sind(tt) + x_center;
        %Pos(iPos,2) = -radius*cosd(tt) + y_center;
        iPos = iPos+1;
    end; clear tt; clear iPos;
    Rads = Pos(length(Pos)/2-ceil(Layers/2)+1:length(Pos)/2+ceil(Layers/2)+1);
    if F.NegCurv
        Rads = 1-(Rads-min(Rads));
    else
        Rads = Rads-min(Rads)+1;
    end
    % We're going to draw from bottom to top
    if Top==Bot
        R = Top*ones(Layers+1,1);
    else
        R = Bot:(Top-Bot)/(Layers):Top;
    end
    for i = 1:Layers
        sBot = Rads(i)*R(i);
        sTop = Rads(i+1)*R(i+1);
        sHt  = Ht/Layers;
        Mv   = Ht-sHt*(i-1);
        glPushMatrix;
            glTranslated(0,Mv,0);
            glRotated(90,1,0,0);
            CylBod = gluNewQuadric;
            CylParams = {[sBot] [sTop] [sHt] [slices] [10]};
            gluCylinder(CylBod, CylParams{:});
            gluDeleteQuadric(CylBod);
        glPopMatrix;
    end
    %%% Top of Tapered Cylinder (Small):
    glPushMatrix;
        glTranslated(0, Ht, 0);
        glRotated(-90,1,0,0);
        MacBottom = gluNewQuadric;
        outer = Bot;
        gluDisk(MacBottom, inner, outer, slices, loops);
        gluDeleteQuadric(MacBottom);
    glPopMatrix;
glPopMatrix;   

glEndList;
save mlglConvexCylDebugVars.mat
catch
    save mlglConvexCylDebugVars.mat
    rethrow(lasterror)
end

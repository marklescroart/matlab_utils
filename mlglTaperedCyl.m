function TapCylDL = mlglTaperedCyl(Bot,Top,Ht)

% Usage: TaperedCylinderDL = mlglTaperedCyl(BottomRadius, TopRadius, Height)
% 
% Draws a tapered cylinder.

global GL;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Checking the Computer's Configuration: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    AssertOpenGL
catch
    disp([mfilename ' regrets to inform you that your computer sucks, in that it is not running an OpenGL version of Matlab.']);
    return
end

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


TapCylDL = glGenLists(1);
glNewList(TapCylDL,GL.COMPILE);
%glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);
glPushMatrix; 
    glTranslated(0,-Ht/2,0);                
    %%% Bottom of Tapered Cylinder (Big):
    glPushMatrix;
        glRotated(90,1,0,0);
        MacTop = gluNewQuadric;
        inner = 0;
        outer = Bot;
        slices = 20;
        stacks = 1;
        loops = 1;
        gluDisk( MacTop, inner, outer, slices, loops)
        gluDeleteQuadric(MacTop);
    glPopMatrix;
    %%% Body of Tapered Cylinder:
    glPushMatrix;
        glRotated(-90,1,0,0);
        CylBod = gluNewQuadric;
        CylParams = {[Bot] [Top] [Ht] [slices] [10]};
        gluCylinder(CylBod, CylParams{:});
        gluDeleteQuadric(CylBod);
    glPopMatrix;
    %%% Top of Tapered Cylinder (Small):
    glPushMatrix;
        glTranslated(0, Ht, 0);
        glRotated(-90,1,0,0);
        MacBottom = gluNewQuadric;
        outer = Top;
        gluDisk(MacBottom, inner, outer, slices, loops);
        gluDeleteQuadric(MacBottom);
    glPopMatrix;
glPopMatrix;   

glEndList;

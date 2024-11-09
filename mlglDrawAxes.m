function AxesDL = mlglDrawAxes(Ticks,TickMax)

% Usage: AxesDL = mlglDrawAxes
% 
% Creates a drawing list for x-y-z axes. The sphere marks up on the z axis.
%
% Created by ML (??/??/07)
% Modified by ML 1.08.07

global GL;
win = min(Screen('Windows'));
load MLColorsOpenGL;
Screen('BeginOpenGL',win);

AxesDL = glGenLists(1);
glNewList(AxesDL, GL.COMPILE);

DifCol  = glGetMaterialfv(GL.FRONT,GL.DIFFUSE);
SpecCol = glGetMaterialfv(GL.FRONT,GL.SPECULAR);
AmbCol  = glGetMaterialfv(GL.FRONT,GL.AMBIENT);
Shine   = glGetMaterialfv(GL.FRONT,GL.SHININESS);

Xaxis = gluNewQuadric;
Yaxis = gluNewQuadric;
Zaxis = gluNewQuadric;
axParams = {[.1] [.1] [40] [10] [10]};

if ~exist('Ticks','var')
    Ticks = 1;
end
if ~exist('TickMax','var')
    TickMax = 10;
end
   
% Z (in/out of plane) axis
glPushMatrix;
    glTranslated(0,0,-axParams{3}/2);
    glMaterialfv(GL.FRONT,GL.DIFFUSE, GLCol.Cherry);
    glMaterialfv(GL.FRONT,GL.SPECULAR,GLCol.Cherry);
    glMaterialfv(GL.FRONT,GL.AMBIENT, GLCol.Cherry);
    gluCylinder(Zaxis, axParams{:});
    gluDeleteQuadric(Zaxis);
glPopMatrix;
% X (horizontal) axis
glPushMatrix;
    glRotated(90,0,1,0);
    glTranslated(0,0,-axParams{3}/2);
    glMaterialfv(GL.FRONT,GL.DIFFUSE, GLCol.Blue);
    glMaterialfv(GL.FRONT,GL.SPECULAR,GLCol.Blue);
    glMaterialfv(GL.FRONT,GL.AMBIENT, GLCol.Blue);
    gluCylinder(Xaxis, axParams{:});
    gluDeleteQuadric(Xaxis);
glPopMatrix;
% Y (vertical) axis
glPushMatrix;
    glRotated(90,1,0,0);
    glTranslated(0,0,-axParams{3}/2);
    glMaterialfv(GL.FRONT,GL.DIFFUSE, GLCol.Yellow);
    glMaterialfv(GL.FRONT,GL.SPECULAR,GLCol.Yellow);
    glMaterialfv(GL.FRONT,GL.AMBIENT, GLCol.Yellow);
    gluCylinder(Yaxis, axParams{:});
    gluDeleteQuadric(Yaxis);
glPopMatrix;
% Show which way is up:
glPushMatrix;
    glTranslated(0,axParams{3}/2,0);
    glutSolidSphere(.3,10,10);
glPopMatrix;

glMaterialfv(GL.FRONT,GL.DIFFUSE, GLCol.White);
glMaterialfv(GL.FRONT,GL.SPECULAR,GLCol.White);
glMaterialfv(GL.FRONT,GL.AMBIENT, GLCol.White);
Ax = [1 0 0; 0 1 0; 0 0 1];
for i = 1:TickMax/Ticks
    for j = 1:3;
        Cp = Ticks*i*Ax(j,:);
        Cn = Ticks*-i*Ax(j,:);
        glPushMatrix;
            glTranslated(Cp(1),Cp(2),Cp(3))
            glutSolidSphere(.2,10,10);
        glPopMatrix;
        glPushMatrix;
            glTranslated(Cn(1),Cn(2),Cn(3));
            glutSolidSphere(.2,10,10);
        glPopMatrix;
    end
end

glMaterialfv(GL.FRONT,GL.DIFFUSE, DifCol);
glMaterialfv(GL.FRONT,GL.SPECULAR,SpecCol);
glMaterialfv(GL.FRONT,GL.AMBIENT, AmbCol);
glMaterialfv(GL.FRONT,GL.SHININESS, Shine);
    
glEndList;

Screen('EndOpenGL',win)
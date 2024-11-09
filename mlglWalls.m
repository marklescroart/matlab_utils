function WallDL = mlglWalls(Walls,TexF,nReps)

% Usage: WallDL = mlglWalls(Walls,TexF,nReps)
% 
% Inputs: Walls is a struct array with the following fields: 
%               L
%               R
%               Top
%               Bot
%               Near
%               Far
%
%         TexF is a string for the image you want to use as a texture for
%         the floor 
%         nReps is the number of times you want to tile the floor with your
%         texture (only square tiling for now)
% 
% Designed for use with mlOpenGLSetup_ScreenSizeRendering. By default,
% draws floor, back wall, and right wall.
% 
% Created by ML on 1.7.08
% Modified by ML on 6.16.08

AssertOpenGL
load MLColorsOpenGL;
global GL;

if ~exist('Walls','var') || isempty(Walls)
    Walls.L = -40;
    Walls.R = 20;
    Walls.Bot = 0;
    Walls.Top = 30;
    Walls.Far = -20;
    Walls.Near = 100;
end
if ~exist('TexF','var')
    F.Tex1 = 0;
    F.Tex2 = 0;
else
    F.Tex1 = 1;
    if iscell(TexF)
        F.Tex2 = 1;
    else
        F.Tex2 = 0;
    end
end


if ~exist('nReps','var')
    nReps = 10;
end

win = min(Screen('Windows'));

if F.Tex1 && ~F.Tex2
    Im1 = imread(TexF);
    Tex1 = Screen('MakeTexture', win, Im1,[],1);
    [TexID1, gltextarget] = Screen('GetOpenGLTexture', win, Tex1);
elseif F.Tex1 && F.Tex2
    Im1 = imread(TexF{1});
    Tex1 = Screen('MakeTexture', win, Im1,[],1);
    [TexID1, gltextarget] = Screen('GetOpenGLTexture', win, Tex1);
    Im2 = imread(TexF{2});
    Tex2 = Screen('MakeTexture', win, Im2,[],1);
    [TexID2, gltextarget] = Screen('GetOpenGLTexture', win, Tex2);
end

Screen('BeginOpenGL',win);

WallDL = glGenLists(1);
glNewList(WallDL,GL.COMPILE);

Mc = mlglGetMaterialColors;

if F.Tex1
    %%% Create drawing list for foreground shape:
    glEnable(GL.TEXTURE_2D);

    % Getting values for all material parameters we'll change:



    % NOTE: The order of these calls matters! This order works, don't mess
    % with it!
    glBindTexture(GL.TEXTURE_2D, TexID1);

    glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
    % % Unnecessary for now:
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);

    %glMaterialfv(GL.FRONT_AND_BACK,GL.SHININESS, 128);
end

glBegin(GL.QUADS);

% Floor:
%glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Red)
% Back Left
glNormal3d(0.0, 1.0, 0.0);
if F.Tex1; glTexCoord2dv([ nReps 0 ]); end
glVertex3d(Walls.L, Walls.Bot, Walls.Far);
% Front Left
glNormal3d(0.0, 1.0, 0.0);
if F.Tex1; glTexCoord2dv([ nReps nReps ]); end
glVertex3d(Walls.L, Walls.Bot, Walls.Near);
% Front Right
glNormal3d(0.0, 1.0, 0.0);
if F.Tex1; glTexCoord2dv([ 0 nReps ]); end
glVertex3d(Walls.R, Walls.Bot, Walls.Near);
% Back Right
glNormal3d(0.0, 1.0, 0.0);
if F.Tex1; glTexCoord2dv([ 0 0 ]); end
glVertex3d(Walls.R, Walls.Bot, Walls.Far);

glEnd();

if ~F.Tex2; 
    glDisable(GL.TEXTURE_2D); 
else
    glBindTexture(GL.TEXTURE_2D,TexID2);
    glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
end

%glMaterialfv(GL.FRONT_AND_BACK,GL.SHININESS, 128);

glBegin(GL.QUADS);

% Left Wall:
% glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Blue)
glNormal3d(1.0, 0.0, 0.0);
% Vertex 1
glNormal3d(1.0, 0.0, 0.0);
if F.Tex2; glTexCoord2dv([ 0 1 ]); end
glVertex3d(Walls.L, Walls.Top, Walls.Near);
% Vertex 2
glNormal3d(1.0, 0.0, 0.0);
if F.Tex2; glTexCoord2dv([ 0 0 ]); end
glVertex3d(Walls.L, Walls.Bot, Walls.Near);
% Vertex 3
glNormal3d(1.0, 0.0, 0.0);
if F.Tex2; glTexCoord2dv([ 1 0 ]); end
glVertex3d(Walls.L, Walls.Bot, Walls.Far);
% Vertex 4
glNormal3d(1.0, 0.0, 0.0);
if F.Tex2; glTexCoord2dv([ 1 1 ]); end
glVertex3d(Walls.L, Walls.Top, Walls.Far);

% Back Wall:
% glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Yellow)
% Vertex 1
glNormal3d(0.0, 0.0, 1.0);
if F.Tex2; glTexCoord2dv([ 0 1 ]); end
glVertex3d(Walls.L, Walls.Top, Walls.Far);
% Vertex 2
glNormal3d(0.0, 0.0, 1.0);
if F.Tex2; glTexCoord2dv([ 0 0 ]); end
glVertex3d(Walls.L, Walls.Bot, Walls.Far);
% Vertex 3
glNormal3d(0.0, 0.0, 1.0);
if F.Tex2; glTexCoord2dv([ 1 0 ]); end
glVertex3d(Walls.R, Walls.Bot, Walls.Far);
% Vertex 4
glNormal3d(0.0, 0.0, 1.0);
if F.Tex2; glTexCoord2dv([ 1 1 ]); end
glVertex3d(Walls.R, Walls.Top, Walls.Far);

% Right Wall:
% glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Cyan)
% Top Back R
glNormal3d(-1.0, 0.0, 0.0);
if F.Tex2; glTexCoord2dv([ 1 0 ]); end
glVertex3d(Walls.R, Walls.Top, Walls.Far);
% Bot Back R
glNormal3d(-1.0, 0.0, 0.0);
if F.Tex2; glTexCoord2dv([ 1 1 ]);
glVertex3d(Walls.R, Walls.Bot, Walls.Far); end
% Front Back R
glNormal3d(-1.0, 0.0, 0.0);
if F.Tex2; glTexCoord2dv([ 0 1 ]); end
glVertex3d(Walls.R, Walls.Bot, Walls.Near);
% Front Top R
glNormal3d(-1.0, 0.0, 0.0);
if F.Tex2; glTexCoord2dv([ 0 0 ]); end
glVertex3d(Walls.R, Walls.Top, Walls.Near);

glEnd;

glBegin(GL.QUADS);
% Ceiling:
% glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Red)
% Top Front L
glNormal3d(0.0, -1.0, 0.0);
if F.Tex2; glTexCoord2dv([ 1 0 ]); end
glVertex3d(Walls.L, Walls.Top, Walls.Near);
% Top Back L
glNormal3d(0.0, -1.0, 0.0);
if F.Tex2; glTexCoord2dv([ 1 1 ]); end
glVertex3d(Walls.L, Walls.Top, Walls.Far);
% Top Back R
glNormal3d(0.0, -1.0, 0.0);
if F.Tex2; glTexCoord2dv([ 0 1 ]); end
glVertex3d(Walls.R, Walls.Top, Walls.Far);
% Top Front R
glNormal3d(0.0, -1.0, 0.0);
if F.Tex2; glTexCoord2dv([ 0 0 ]); end
glVertex3d(Walls.R, Walls.Top, Walls.Near);

% % and back wall, to wall us in: 
% % Ceiling:
% glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Beige)
% % Top Front L
% glNormal3d(0.0, 0.0, -1.0);
% if F.Tex2; glTexCoord2dv([ 1 0 ]); end
% glVertex3d(Walls.R, Walls.Top, Walls.Near);
% % Top Back L
% glNormal3d(0.0, 0.0, -1.0);
% if F.Tex2; glTexCoord2dv([ 1 1 ]); end
% glVertex3d(Walls.R, Walls.Bot, Walls.Near);
% % Top Back R
% glNormal3d(0.0, 0.0, -1.0);
% if F.Tex2; glTexCoord2dv([ 0 1 ]); end
% glVertex3d(Walls.L, Walls.Bot, Walls.Near);
% % Top Front R
% glNormal3d(0.0, 0.0, -1.0);
% if F.Tex2; glTexCoord2dv([ 0 0 ]); end
% glVertex3d(Walls.L, Walls.Top, Walls.Near);

glEnd();

if F.Tex1 && F.Tex2
    glDisable(GL.TEXTURE_2D)
end

mlglResetMaterialColors(Mc);


glEndList;
Screen('EndOpenGL',win);
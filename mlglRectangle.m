function RectDL = mlglRectangle(X,Y,TexF)

% Usage: PrismDL = mlglRectangle(X,Y,TexF)
%
% Draws a Rectangular prism.

global GL;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Checking the Computer's Configuration: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AssertOpenGL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Default Vaules for parameters: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('X', 'var')
    X = 2;
end
if ~exist('Y', 'var')
    Y = 3;
end

if ~exist('TexF','var')
    F.Tex = 0;
else
    F.Tex = 1;
    Im = imread(TexF);
    win = min(Screen('Windows'));
    Tex = Screen('MakeTexture', win, Im,[],1);
    [TexID, gltextarget] = Screen('GetOpenGLTexture', win, Tex);
end

Winding = glGetIntegerv(GL.FRONT_FACE);

%%% Compensating for offset of prism vertices
xx = X/2; yy = Y/2;
RectDL = glGenLists(1);
glNewList(RectDL,GL.COMPILE);
glFrontFace(GL.CW);
if F.Tex;
    glEnable(GL.TEXTURE_2D);
    % Bind our texture, so it gets applied to all following objects:
    glBindTexture(gltextarget, TexID);

    % Textures color texel values shall modulate the color computed by lighting model:
    glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);

    % Clamping behaviour shall be a cyclic repeat:
    glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
    glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);

    % Set up minification and magnification filters. This is crucial for the thing to work!
    glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

    % Set basic "color" of object to white to get a nice interaction between the texture
    % and the objects lighting:
    %glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 1 1 1 1 ]);
    %glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1 1 1 1 ]);

    %%% !!!

    %%% IF YOU WANT TO SHADE OVER TEXTURES, YOU'LL NEED TO CHANGE THE ABOVE
    %%% LINES!!!

    %%% !!!
end
%%% Compensating for offset of prism vertices
%glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);


% Draw the Rectangle:
glBegin(GL.QUADS);
    %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Yellow)
    % Normal A
    

    glNormal3d(0.0, 0.0, 1.0);
    % Vertex 1
    glTexCoord2d(0,1);
    glVertex3d(xx, yy, 0);
    % Vertex 2
    glTexCoord2d(1,1);
    glVertex3d(xx, -yy, 0);
    % Vertex 3
    glTexCoord2d(1,0);
    glVertex3d(-xx, -yy, 0);
    % Vertex 4
    glTexCoord2d(0,0);
    glVertex3d(-xx, yy, 0);
glEnd();

glFrontFace(Winding);
glEndList;


% NOTE: this is OLD! See mlglSetup - better function.

% Open GL Setup
% 
% Initializes OpenGL for matlab with the following parameters:
%
% Clear Color [.502 .502 .502 1] (Black, Alpha = 1)
% 
% Light0:
% 	diffuse light of freq. [.6 .6 .6]   (Specified by GLst.Light0Color)
% 	ambient light of freq. [.1 .1 .1]   (Specified by GLst.Light0AmbColor)
%   XYZ position [10 10 30]             (Specified by GLst.Light0Pos)
% 
% White Specular highlights of .75      (Specified by GLst.SpecVal)
% Drawing (material) color of Gray      (Specified by GLst.WhichStartColor)
% Clipping Planes at z =.1 and 200      (Specified by GLst.zNear and GLst.zFar)
% Fov in Y direction of +/-8.97 degrees (Specified by GLst.fovY) (=total
%                                        screen of 17.94?, which is what the 
%                                        USC MRI Screen spans)
% 
% Enables depth buffer and face culling
% 
% Created 10.10.06 by MDL
% Modified 10.30.08 by MDL

% Need: yfov of 17.944 units
%       xfov of 23.925 units (for 23.9? of vis angle in magnet screen)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% First OpenGL stuff: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('GL','var')
    error('Please initialize OpenGL before calling OpenGLSetup!')
end

Screen('BeginOpenGL', win);

load MLColorsOpenGL;
glClearColor(0,0,0,0);
glClear(GL.COLOR_BUFFER_BIT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Variable parameters for script: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Lighting:
GLst.Light0Pos = [50,20,100,0];
GLst.Light0Color = .6.* GLCol.White;
GLst.Light0AmbColor = [.1 .1 .1 1];

%%% Perspective:
GLst.fovY = 8.97;  % Field of view is +/- 32 degrees from line of sight.
GLst.zNear = .1; % Clipping Planes
GLst.zFar = 200;

%%% Materials (for front only):
GLst.WhichStartColor = GLCol.Gray200;
GLst.SpecVal = .5; % How strong the specular highlights are 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actually setting parameters: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Lighting:
    glEnable(GL.LIGHTING);
    glEnable(GL.LIGHT0);
    glLightModelfv(GL.LIGHT_MODEL_TWO_SIDE,GL.TRUE);

    %%% Light 1
    glLightfv(GL.LIGHT0,GL.POSITION,GLst.Light0Pos);
    % Defines how much diffuse light of color "GLst.Light0Color" is emitted:
    glLightfv(GL.LIGHT0,GL.DIFFUSE, GLst.Light0Color);
    % Defines how much ambient light of color "GLst.Light0AmbColor" is emitted:
    glLightfv(GL.LIGHT0,GL.AMBIENT, GLst.Light0AmbColor);
    
    %%% Light 2, etc... (not currently provided)
    
%%% Depth buffer & perspective: 
    glEnable(GL.DEPTH_TEST);
    glEnable(GL.CULL_FACE);

    glMatrixMode(GL.PROJECTION);
    glLoadIdentity;
    % aspect ratio is adapted to the monitor's aspect ratio
    gluPerspective(GLst.fovY,ScrVars.AspectRatio,GLst.zNear,GLst.zFar);

    glMatrixMode(GL.MODELVIEW); % puts us back to Modelview (default)
    glLoadIdentity;
    % Camera Position:
    % Positive x-Axis points horizontally to the right.
    % Positive y-Axis points vertically upwards.
    % Positive z-Axis points to the observer, perpendicular to the display
    % screens surface.
    % gluLookAt([pos] x y z, [looks at] x y z, [which way is up] x y z)
    gluLookAt(0,0,85,  0,0,0,  0,1,0);

%%% Material properties: 
    % Define the light reflection properties by setting up reflection
    % coefficients for ambient, diffuse and specular reflection:
    
    %glMaterialfv(GL.FRONT,GL.AMBIENT, GLst.WhichStartColor);
    glMaterialfv(GL.FRONT,GL.DIFFUSE, GLst.WhichStartColor); 
    %glMaterialfv(GL.FRONT,GL.SPECULAR, GLst.SpecVal .* [ 1 1 1 1 ]);
    %glMaterialfv(GL.FRONT,GL.SHININESS, 128);

Screen('EndOpenGL', win); % for now - 'Begin...' must be called again before rendering to screen in experiment


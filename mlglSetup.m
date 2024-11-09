function varargout = mlglSetup(View,GLSt)

% Usage: [win,ScrVars,GLCol,GLst,View] = mlOpenGLSetup([View],[GLst])
% 
% Standard ML OpenGL Setup. Params read out (obviously) in GLst (for
% lighting and clear color) and View (for perspective). 
% 
% Enables two lights; params stored in GLst
% 
% Sets glClearColor; value stored in GLst
% 
% Enables GL.CULL_FACE, GL.DEPTH_TEST, GL.NORMALIZE 
% 
% Sets up perspective and first call of gluLookAt; values stored in View
% 
% Created by ML 06.16.08

global GL
load MLColorsOpenGL;

mlScreenSetup; % Sets "win" and "ScrVars" struct

Screen('BeginOpenGL', win);

%%% GLst variable (holds useful GL parameters):
if ~exist('Glst','var') || isempty(GLst)
    %%% Clear Color:
    GLst.ClearColor     = {.5 .5 .5 0}; % {1 1 1 1}; %
    %%% Lighting:
    % Ambient first: 
    GLst.AmbientLight   = .2 * GLCol.White; % usually .2
    
    % Light 1: 
    GLst.Light(1).Pos      = [0,0,10,1];
    GLst.Light(1).Color    = 1 * GLCol.White;
    GLst.Light(1).SpotExp = 64; % Default is 0 - that is, diffuse, not focused
    GLst.Light(1).SpotCut = 60; % Default is 180 - that is, pointed every which-way
    GLst.Light(1).SpotDir = [0,0,-1]; %/norm([0 -1 -1]);
    
%     % Light 2: 
%     GLst.Light(2).Pos      = [ 1,0,.2,0];
%     GLst.Light(2).Color    = .7 * GLCol.White;
%     GLst.Light(2).SpotExp = 64;

%     % Light 3: 
%     GLst.Light(3).Pos      = [0,.3,1,0];
%     GLst.Light(3).Color    = .7 * GLCol.White;
%     GLst.Light(2).SpotExp = 64;

    %%% Perspective:
    GLst.fovY = 45;  % Field of view is +/- 45 degrees from line of sight.
    GLst.zNear = .1; % Clipping Planes
    GLst.zFar = 200;
end

%%% View Variable (passed to other functions) - used to determine gluLookAt
if ~exist('View','var')
    View.Xang = 0;
    View.Yang = 5.74;
    View.vRad = 30;
    View.XRad = View.vRad*cosd(View.Yang);
    View.YY = View.vRad*sind(View.Yang);
    View.XX = View.XRad*sind(View.Xang);
    View.ZZ = View.XRad*cosd(View.Xang);
    View.Target = {0 3 0};
    View.Up = {0 1 0};
end

%%% Setting Parameters: 
    glEnable(GL.DEPTH_TEST);
    glEnable(GL.CULL_FACE);
    %glEnable(GL.NORMALIZE);

    glClearColor(GLst.ClearColor{:}); 
    glClear(GL.COLOR_BUFFER_BIT);
    glClear(GL.DEPTH_BUFFER_BIT);

%%% Lighting:
    glEnable(GL.LIGHTING);
    
    glLightModelfv(GL.LIGHT_MODEL_AMBIENT, GLst.AmbientLight);
    glLightModelfv(GL.LIGHT_MODEL_TWO_SIDE,GL.TRUE);

    for i = 1:length(GLst.Light)
        % Turn light (i) on:
        L = GL.(['LIGHT' num2str(i-1)]);
        glEnable(L);
        glLightfv(L,GL.POSITION,GLst.Light(i).Pos);
        % Defines how much diffuse light of color "GLst.Light0Color" is emitted:
        glLightfv(L,GL.DIFFUSE, GLst.Light(i).Color);
        glLightfv(L,GL.SPECULAR,GLst.Light(i).Color);
        if isfield(GLst.Light(i),'SpotExp');
            glLightfv(L,GL.SPOT_EXPONENT,GLst.Light(i).SpotExp);
        end
        if isfield(GLst.Light(i),'SpotCut');
            disp('yes I got to SpotCut')
            glLightfv(L,GL.SPOT_CUTOFF,GLst.Light(i).SpotCut);
        end
        if isfield(GLst.Light(i),'SpotDir');
            disp('yes I got to SpotDir')
            glLightfv(L,GL.SPOT_DIRECTION,GLst.Light(i).SpotDir);
        end
        
    end
    
%%% Perspective: 
    glMatrixMode(GL.PROJECTION);
    glLoadIdentity;
    % aspect ratio is adapted to the monitor's aspect ratio
    gluPerspective(GLst.fovY,ScrVars.AspectRatio,GLst.zNear,GLst.zFar);

    glMatrixMode(GL.MODELVIEW); % puts us back to Modelview (default)
    glLoadIdentity;

gluLookAt(View.XX,View.YY,View.ZZ,View.Target{:},View.Up{:});


Screen('EndOpenGL',win);

if nargout
    varargout{1} = win;
    varargout{2} = ScrVars;
    varargout{3} = GLCol;
    varargout{4} = GLst;
    varargout{5} = View;
end
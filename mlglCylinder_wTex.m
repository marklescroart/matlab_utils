function CylDL = mlglCylinder_wTex(Bot,Top,Ht,RadiansCurv,Layers,TexF)

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
if ~exist('Layers','var')
    Layers = 1;
end

win = min(Screen('Windows'));

if ~exist('TexF','var')
    F.Tex = 0;
else
    F.Tex = 1;
    disp(TexF);
    Im = imread(TexF);
    Tex = Screen('MakeTexture', win, Im,[],1);
    [TexID, gltextarget] = Screen('GetOpenGLTexture', win, Tex);
end
Screen('BeginOpenGL',win);


if RadiansCurv ==0
    F.StraightSides = 1;
    RadiansCurv = 1; % This is just to prevent later computations from messing up; this won't be used.
    F.NegCurv   = 0;
elseif RadiansCurv < 0
    F.NegCurv = 1;
    F.StraightSides = 0;
    RadiansCurv = abs(RadiansCurv);
else
    F.StraightSides = 0; 
    F.NegCurv = 0;
end
    

try

CylDL = glGenLists(1);
glNewList(CylDL,GL.COMPILE);

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
    glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 1 1 1 1 ]);
    glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1 1 1 1 ]);
    
    %%% !!!
    
    %%% IF YOU WANT TO SHADE OVER TEXTURES, YOU'LL NEED TO CHANGE THE ABOVE
    %%% LINES!!!
    
    %%% !!!
end

glPushMatrix; 
    %glTranslated(0,-Ht/2,0);                
    %%% Bottom of Tapered Cylinder (Big):
    glPushMatrix;
        glRotated(90,1,0,0);
        MacTop = gluNewQuadric;
        if F.Tex; gluQuadricTexture(MacTop, GL.TRUE); end % Apply Texture
        inner = 0;
        outer = Top;
        slices = 20;
        loops = 1;
        gluDisk( MacTop, inner, outer, slices, loops)
        gluDeleteQuadric(MacTop);
    glPopMatrix;
    %%% Body of Tapered Cylinder:
    cRadius = 1;
    nPos = pi*Layers/RadiansCurv;
    x_center = 0;
    iPos = 1;
    Pos = zeros(1,round(180/nPos));
    for tt = 0:180/nPos:180-180/nPos;
        Pos(iPos,1) = cRadius*sind(tt) + x_center;
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
        if F.StraightSides
            sBot = R(i);
            sTop = R(i+1);
        else
            sBot = Rads(i)*R(i);
            sTop = Rads(i+1)*R(i+1);
        end
        sHt  = Ht/Layers;
        Mv   = Ht-sHt*(i-1);
        glPushMatrix;
            glTranslated(0,Mv,0);
            glRotated(90,1,0,0);
            CylBod = gluNewQuadric;
            if F.Tex; gluQuadricTexture(CylBod, GL.TRUE); end % Apply texture
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
        if F.Tex; gluQuadricTexture(MacBottom, GL.TRUE); end % Apply texture
        outer = Bot;
        gluDisk(MacBottom, inner, outer, slices, loops);
        gluDeleteQuadric(MacBottom);
    glPopMatrix;
glPopMatrix;   

if F.Tex; glDisable(GL.TEXTURE_2D); end
glEndList;
save mlglConvexCylDebugVars.mat
catch
    save mlglConvexCylDebugVars.mat
    rethrow(lasterror)
end

Screen('EndOpenGL',win);
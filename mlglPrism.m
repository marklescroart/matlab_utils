function PrismDL = mlglPrism(Ht,X,Z,tap,rCurv,Layers,TexF)

% Usage: PrismDL = mlglPrism(Ht,X,Z,tap,rCurv,Layers,TexF)
% 
% Draws a Rectangular prism, of volume X x Y x Z, with taper factor (ratio
% of top side length to bottom side length) "tap"
% 
% Created by ML 2008/05/23

    
global GL;

try
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
if ~exist('Ht', 'var')
    Y = 3;
else
    Y = Ht;
end
if ~exist('Z', 'var')
    Z = 2;
end
if ~exist('tap','var')
    tap = 1;
end
if ~exist('rCurv','var')
    rCurv = 0;
end
if ~exist('Layers','var')
    Layers = 40;
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


if rCurv ==0
    F.StraightSides = 1;
    rCurv = 1; % This is just to prevent later computations from messing up; this won't be used.
    F.NegCurv   = 0;
elseif rCurv < 0
    F.NegCurv = 1;
    F.StraightSides = 0;
    rCurv = abs(rCurv);
else
    F.StraightSides = 0; 
    F.NegCurv = 0;
end


%%% Compensating for offset of prism vertices
%glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);
Xhalf = X/2; Zhalf = Z/2;
load MLColorsOpenGL.mat;
PrismDL = glGenLists(1);
glNewList(PrismDL,GL.COMPILE);
%glMaterialfv(GL.FRONT,GL.EMISSION,[.21 .21 .21]);
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

    cRadius = 1; % For normalization purposes
    nPos = Layers*2*pi/rCurv;
    Pos = round(mlCirclePos(cRadius,nPos,0,0));
    Start = round(((pi-rCurv)/2)/(2*pi)*nPos+1);
    rPos = Pos(Start:Start+Layers,:);
    Sc = max(rPos(:,2))-min(rPos(:,2));
    rPos = Y*[rPos(:,1)/Sc,rPos(:,2)/Sc+.5];

    Rads = rPos(:,1)-min(rPos(:,1)); %Pos(length(Pos)/2-ceil(Layers/2)+1:length(Pos)/2+ceil(Layers/2)+1);

    %error('Poopy');
    if F.NegCurv
        Rads = -Rads;
    end
    if tap == 1;
        Rx = Xhalf*ones(Layers+1,1);
        Rz = Zhalf*ones(Layers+1,1);
    else
        Rx = Xhalf:-(Xhalf-tap*Xhalf)/(Layers):tap*Xhalf;
        Rz = Zhalf:-(Zhalf-tap*Zhalf)/(Layers):tap*Zhalf;
    end

    sY  = Y/(Layers); % divide height by nLayers - useful below
    
    TCxL = -Rx/Xhalf/2 + .5; % (Layers+1) long
    TCxR = Rx/Xhalf/2 + .5;
    TCzL = -Rz/Zhalf/2 + .5; % (Layers+1) long
    TCzR = Rz/Zhalf/2 + .5; % (Layers+1) long
    
    yT = 1/Layers;
    TCyT = 0:yT:1-yT;
    TCyB = yT:yT:1;       % (Layers) long vector
    
    % Draw the sides. We should be going from the bottom UP. 
    glBegin(GL.QUADS);
    for i = 1:Layers;
        % s(XYZ)(tb) is Section | X,Y,orZ | Top or Bottom
        if F.StraightSides
            sXb = Rx(i);
            sXt = Rx(i+1);
            sZb = Rz(i);
            sZt = Rz(i+1);
        else
            sXb = Rads(i)  + Rx(i);
            sXt = Rads(i+1)+ Rx(i+1);
            sZb = Rads(i)  + Rz(i);
            sZt = Rads(i+1)+ Rz(i+1);
        end
        
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Yellow)
        % BACK:
        % Calculate Normal:
        VbotR = [-sXb, (sY*(i-1)), -sZb];
        VtopR = [-sXt, sY*i, -sZt];
        VbotL = [sXb, (sY*(i-1)), -sZb];
        VupR      = VtopR - VbotR;
        VcrossBot = VbotL - VbotR;
        Nback = cross(VupR,VcrossBot);
        Nback = Nback/norm(Nback);
        % Top L - Facing the BACK
        glNormal3dv(Nback);
        glTexCoord2d(TCyB(i),TCxL(i+1));
        glVertex3d(sXt, sY*i, -sZt);
        % Bot L
        glNormal3dv(Nback);
        glTexCoord2d(TCyT(i),TCxL(i));
        glVertex3d(sXb, (sY*(i-1)), -sZb);
        % Bot R
        glNormal3dv(Nback);
        glTexCoord2d(TCyT(i),TCxR(i));
        glVertex3d(-sXb, (sY*(i-1)), -sZb);
        % Top R
        glNormal3dv(Nback);
        glTexCoord2d(TCyB(i),TCxR(i+1));
        glVertex3d(-sXt, sY*i, -sZt);

        % LEFT
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Blue)
        % Calculate Normal:
        VbotR = [-sXb, (sY*(i-1)), sZb];
        VtopR = [-sXt,  sY*i, sZt];
        VbotL = [-sXb, (sY*(i-1)), -sZb];
        VupR      = VtopR - VbotR;
        VcrossBot = VbotL - VbotR;
        Nleft = cross(VupR,VcrossBot);
        Nleft = Nleft/norm(Nleft);
        %glNormal3d(-1.0, 0.0, 0.0);
        % Top L
        glNormal3dv(Nleft);
        glTexCoord2d(TCyB(i),TCxL(i+1));
        glVertex3d(-sXt,  sY*i, -sZt);
        % Bot L
        glNormal3dv(Nleft);
        glTexCoord2d(TCyT(i),TCxL(i));
        glVertex3d(-sXb, (sY*(i-1)), -sZb);
        % Bot R
        glNormal3dv(Nleft);
        glTexCoord2d(TCyT(i),TCxR(i));
        glVertex3d(-sXb, (sY*(i-1)), sZb);
        % Top R
        glNormal3dv(Nleft);
        glTexCoord2d(TCyB(i),TCxR(i+1));
        glVertex3d(-sXt,  sY*i, sZt); 

        % FRONT
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Red)
        % Calculate Normal:
        VbotR = [sXb,  (sY*(i-1)), sZb];
        VtopR = [sXt,  sY*i, sZt];
        VbotL = [-sXb, (sY*(i-1)), sZb];
        VupR      = VtopR - VbotR;
        VcrossBot = VbotL - VbotR;
        Nfront = cross(VupR,VcrossBot);
        Nfront = Nfront/norm(Nfront);
        % Top L
        glNormal3dv(Nfront);
        glTexCoord2d(TCyB(i),TCxL(i+1));
        glVertex3d(-sXt, sY*i, sZt);
        % Bot L
        glNormal3dv(Nfront);
        glTexCoord2d(TCyT(i),TCxL(i));
        glVertex3d(-sXb, (sY*(i-1)), sZb);
        % Bot R
        glNormal3dv(Nfront);
        glTexCoord2d(TCyT(i),TCxR(i));
        glVertex3d(sXb,  (sY*(i-1)), sZb);
        % Top R
        glNormal3dv(Nfront);
        glTexCoord2d(TCyB(i),TCxR(i+1));
        glVertex3d(sXt,  sY*i, sZt);

        % RIGHT
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Green)
        % Calculate Normal:
        VbotR = [sXb, (sY*(i-1)), -sZb];
        VtopR = [sXt, sY*i,  -sZt];
        VbotL = [sXb, (sY*(i-1)), sZb];
        VupR      = VtopR - VbotR;
        VcrossBot = VbotL - VbotR;
        Nright = cross(VupR,VcrossBot);
        Nright = Nright/norm(Nright);
        % Top L
        glNormal3dv(Nright);
        glTexCoord2d(TCyB(i),TCxL(i+1));
        glVertex3d(sXt, sY*i,  sZt);
        % Bot L
        glNormal3dv(Nright);
        glTexCoord2d(TCyT(i),TCxL(i));
        glVertex3d(sXb, (sY*(i-1)), sZb);
        % Bot R
        glNormal3dv(Nright);
        glTexCoord2d(TCyT(i),TCxR(i));
        glVertex3d(sXb, (sY*(i-1)), -sZb);
        % Top R
        glNormal3dv(Nright);
        glTexCoord2d(TCyB(i),TCxR(i+1));
        glVertex3d(sXt, sY*i,  -sZt)

    end
    glEnd;
    % Draw the top and bottom of the cube
    glBegin(GL.QUADS);
        % Bottom
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.White)
        glNormal3d(0.0, -1.0, 0.0);
        glTexCoord2d(1,0);
        glVertex3d(-Xhalf,0, -Zhalf);
        glTexCoord2d(1,1);
        glVertex3d(Xhalf, 0, -Zhalf);
        glTexCoord2d(0,1);
        glVertex3d(Xhalf, 0, Zhalf);
        glTexCoord2d(0,0);
        glVertex3d(-Xhalf,0, Zhalf);

        % Top
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Gray111)
        glNormal3d(0.0, 1.0, 0.0);
        % Top L - from perspective above prism 
        glTexCoord2d(0,0);
        glVertex3d(tap*-Xhalf, Y, tap*-Zhalf);
        % Bot L
        glTexCoord2d(1,0);
        glVertex3d(tap*-Xhalf, Y, tap* Zhalf);
        % Bot R
        glTexCoord2d(1,1);
        glVertex3d(tap* Xhalf, Y, tap* Zhalf);
        % Top R
        glTexCoord2d(0,1);
        glVertex3d(tap* Xhalf, Y, tap*-Zhalf);
    glEnd();
    
    if F.Tex; glDisable(GL.TEXTURE_2D); end
%glMaterialfv(GL.FRONT,GL.EMISSION,[0 0 0]);
glEndList;

%save mlglPrismWCurvDebugVars.mat

catch
    save mlglPrismDebugVars.mat
    rethrow(lasterror)
end
function PartialTorusDL = mlglDrawPartialTorus_Test(Ht, RadiansCurv, TubeRadius, Slices, Stacks, TexF)

% Dummy code - trying to put spheres at the ends of the macaroni

% usage: PartialTorusDL = mlglDrawPartialTorus2(Ht, RadiansCurv, TubeRadius, Slices, Stacks, TexF)
% 
% Inputs: TorusFract - what fraction of the torus to draw (default = .25) 
%         TubeRadius - thickness of torus (default = 2)
%         Radius - radius of curvature of the torus (default = 6)
%         Slices  (default = 20)
%         Stacks  (default = 30)
%
% NOTE 6.5.08: modified to stand at 0,0 rather than 
% 
% Returns an Open GL Drawing List ("PartialTorusDL")

%%% Checking the Computer's Configuration:
AssertOpenGL

%%% Checking on OpenGL state:
global GL;
if isempty(GL)
    error([mfilename ':OpenGLInit'],'OpenGL was not initialized before calling mlglDrawPartialTorus.');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Default Vaules for parameters: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('Ht','var')
    Ht = 3;
end
if ~exist('RadiansCurv','var')
    RadiansCurv = pi/3;
end
if ~exist('TubeRadius', 'var')
    TubeRadius = 2;
end
if ~exist('Slices', 'var')
    Slices = 20;
end
if ~exist('Stacks', 'var')
    Stacks = 30;
end
if ~exist('TexF','var')
    F.Tex = 0;
else
    F.Tex = 1;
    win = min(Screen('Windows'));
    Im = imread(TexF);
    Tex = Screen('MakeTexture', win, Im,[],1);
    [TexID, gltextarget] = Screen('GetOpenGLTexture', win, Tex);
end
    
%%% Drawing a Partial Torus
nVerts = 0;
Radius = Ht/RadiansCurv;
Sides = Slices;
Rings = Stacks;
sideDelta = 2.0 * pi / Sides;
ringDelta = RadiansCurv / Rings;
theta1 = 0.0;
cosTheta = 1.0;
sinTheta = 0.0;
ArcLength = convert2deg((Rings) * ringDelta);

%%% GL List for Macaroni Generation:
PartialTorusDL = glGenLists(1);
glNewList(PartialTorusDL, GL.COMPILE);

if F.Tex;
    nXTexRepeats = 1;
    nYTexRepeats = 1;
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
    
    TCx = 0:nXTexRepeats/(Slices):nXTexRepeats;% x Texture Coordinates
    TCy = 0:nYTexRepeats/(Stacks):nYTexRepeats;% y Texture Coordinates
    
    save DebugVars;
    %%% !!!
    
    %%% IF YOU WANT TO SHADE OVER TEXTURES, YOU'LL NEED TO CHANGE THE ABOVE
    %%% LINES!!!
    
    %%% !!!
end

    glPushMatrix; 
        glPushMatrix; 
            glTranslated(-Radius,0,0);                
            %%% Top of Macaroni:
            TopStart = GetSecs;
            glPushMatrix;
                glRotated(ArcLength,0,0,1);
                glRotated(-90,1,0,0);
                glTranslated(Radius, 0, 0);
                MacTop = gluNewQuadric;
                if F.Tex; gluQuadricTexture(MacTop, GL.TRUE); end % Apply texture
                %inner = 0;
                %outer = TubeRadius;
                %slices = 20;
                %stacks = 1;
                %loops = 1;
                %gluDisk( MacTop, inner, outer, slices, loops )
                %gluDeleteQuadric(MacTop);
                gluSphere(MacTop,TubeRadius, Slices, Rings)
                gluDeleteQuadric(MacTop);
            glPopMatrix;
            TopFinish = GetSecs;
            %%% Body of Macaroni:
            glPushMatrix;
                %glRotated(ArcLength,0,0,1);
                for ii = 1:Rings
                    theta1 = theta1 + ringDelta;
                    cosTheta1 = cos(theta1);
                    sinTheta1 = sin(theta1);
                    glBegin(GL.QUAD_STRIP);
                    phi = 0.0;
                    for jj = 1:Sides+1
                        phi = phi + sideDelta;
                        cosPhi = cos(phi);
                        sinPhi = sin(phi);
                        dist = Radius + (TubeRadius * cosPhi);

                        glNormal3f(cosTheta * cosPhi, sinTheta * cosPhi, sinPhi);
                        if F.Tex; glTexCoord2d(TCy(Rings+1-ii+1),TCx(jj)); end
                        glVertex3f(cosTheta * dist, sinTheta * dist, TubeRadius * sinPhi);

                        glNormal3f(cosTheta1 * cosPhi, sinTheta1 * cosPhi, sinPhi);
                        if F.Tex; glTexCoord2d(TCy(Rings+1-ii),TCx(jj)); end
                        glVertex3f(cosTheta1 * dist, sinTheta1 * dist, TubeRadius * sinPhi);
                        nVerts = nVerts+1;
                        nVerts = nVerts+1;
                    end
                    glEnd;
                    theta = theta1;
                    cosTheta = cosTheta1;
                    sinTheta = sinTheta1;
                end
            glPopMatrix;
            BodyFinish = GetSecs;
            %%% Bottom of Macaroni:
            glPushMatrix;
                %glRotated(-.5*ArcLength,0,0,1);
                glRotated(90,1,0,0);
                glTranslated(Radius, 0, 0);
                MacBottom = gluNewQuadric;
                if F.Tex; gluQuadricTexture(MacBottom, GL.TRUE); end % Apply texture
                %gluDisk( MacBottom, inner, outer, slices, loops )
                gluSphere(MacBottom,TubeRadius, Slices, Rings)
                gluDeleteQuadric(MacBottom);
            glPopMatrix;
            BottomFinish = GetSecs;
        glPopMatrix;
    glPopMatrix;    
if F.Tex; glDisable(GL.TEXTURE_2D); end;
glEndList;
%%% End of OpenGL Drawing List

% %%% De-bugging timing code:
% TopTime = TopFinish - TopStart
% MiddleTime = BodyFinish-TopFinish
% BottomTime = BottomFinish-BodyFinish
save xxDebugVars.mat
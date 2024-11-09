function CylDL = mlglCylinder(Ht,Bot,Top,RadiansCurv,Layers,TexF)

% Usage: CylDL = mlglCylinder(Ht,Bot,Top,RadiansCurv,Layers,TexF)
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
if ~exist('Top', 'var')
    Top = 1.5;
end
if ~exist('Bot', 'var')
    Bot = 1;
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

Slices = 40;
sideDelta = 2.0 * pi / Slices;
lHt = Ht / Layers;
ySpot = 0;


try

    CylDL = glGenLists(1);
    glNewList(CylDL,GL.COMPILE);

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

        TCx = 0:nXTexRepeats/(Slices):nXTexRepeats;% x Texture Coordinates
        TCy = 0:nYTexRepeats/(Layers):nYTexRepeats;% y Texture Coordinates

    end


    glPushMatrix; 
        %%% Bottom of Tapered Cylinder (Big):
        glPushMatrix;
            glRotated(90,1,0,0);
            MacTop = gluNewQuadric;
            if F.Tex; gluQuadricTexture(MacTop, GL.TRUE); end % Apply Texture
            inner = 0;
            outer = Bot;
            loops = 1;
            gluDisk( MacTop, inner, outer, Slices, loops)
            gluDeleteQuadric(MacTop);
        glPopMatrix;

        %%% Body of Tapered Cylinder:
        glPushMatrix;
%             cRadius = 1;
%             nPos = pi*Layers/RadiansCurv;
%             x_center = 0;
%             iPos = 1;
%             Pos = zeros(1,round(180/nPos));
%             for tt = 0:180/nPos:180-180/nPos;
%                 Pos(iPos,1) = cRadius*sind(tt) + x_center;
%                 iPos = iPos+1;
%             end; clear tt; clear iPos;
%             Rads = Pos(length(Pos)/2-ceil(Layers/2)+1:length(Pos)/2+ceil(Layers/2)+1);
%             if F.NegCurv
%                 Rads = 1-(Rads-min(Rads));
%             else
%                 Rads = Rads-min(Rads)+1;
%             end
        
            %tRads = linspace(Bot,Top,Layers+1);
            SideLength = norm([(Top-Bot),Ht]);
            
            Theta = atan((Top-Bot)/Ht);  %maybe Bot-Top?

            if ~F.StraightSides;
                Rads = mlCurveLine_UseRadius(SideLength/2,Layers+1,RadiansCurv);
            else
                Rads = ones(1,Layers);
            end
            
            
            
            
            % We're going to draw from bottom to top
            if Bot==Top
                R = Bot*ones(Layers+1,1);
            else
                R = Bot:-(Bot-Top)/(Layers):Top;
            end
            %disp(R)
            for i = 1:Layers
                if F.StraightSides
                    lBot = R(i);
                    lTop = R(i+1);
                else
                    % Add [Rads(i)/cos(Theta)] to radius to account for curvature: 
                    if F.NegCurv
                        lBot = -Rads(i)/cos(Theta)+R(i);
                        lTop = -Rads(i+1)/cos(Theta)+R(i+1);
                    else
                        lBot = Rads(i)/cos(Theta)+R(i);
                        lTop = Rads(i+1)/cos(Theta)+R(i+1);
                    end
                end

                glBegin(GL.QUAD_STRIP);
                phi = 0.0;
                for j = 1:Slices+1
                    phi = phi + sideDelta;
                    cosPhi = cos(phi);
                    sinPhi = sin(phi);
                    sinAlpha = (lBot-lTop)/sqrt(lHt^2+(lBot-lTop)^2);
                    %if lBot-lTop <0; sinAlpha = -sinAlpha; end

                    glNormal3f(cosPhi, sinAlpha, sinPhi);
                    if F.Tex; glTexCoord2d(TCy(Layers+1-i+1),TCx(j)); end
                    glVertex3f(lBot * cosPhi, ySpot, lBot * sinPhi);

                    glNormal3f(cosPhi, sinAlpha, sinPhi);
                    if F.Tex; glTexCoord2d(TCy(Layers+1-i),TCx(j)); end
                    glVertex3f(lTop * cosPhi, ySpot+lHt, lTop * sinPhi);
                end
                glEnd;
                ySpot = ySpot + lHt;
            end
        glPopMatrix;

        %%% Bot of Tapered Cylinder (Small):
        glPushMatrix;
            glTranslated(0, Ht, 0);
            glRotated(-90,1,0,0);
            MacBottom = gluNewQuadric;
            if F.Tex; gluQuadricTexture(MacBottom, GL.TRUE); end % Apply texture
            outer = Top;
            gluDisk(MacBottom, inner, outer, Slices, loops);
            gluDeleteQuadric(MacBottom);
        glPopMatrix;
    glPopMatrix;   

    if F.Tex; glDisable(GL.TEXTURE_2D); end
    glEndList;
    %save mlglConvexCylDebugVars.mat
catch
    save mlglConvexCylDebugVars.mat
    rethrow(lasterror)
end

Screen('EndOpenGL',win);
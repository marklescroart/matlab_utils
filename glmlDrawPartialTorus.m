function PartialTorusDL = glmlDrawPartialTorus(TorusFract, TubeRadius, Radius, Slices, Stacks)

% usage: PartialTorusDL = DrawPartialTorus([TubeRadius,] [Radius,] [Slices],[Stacks])
% 
% Inputs: TorusFract - what fraction of the torus to draw (default = .25) 
%         TubeRadius - thickness of torus (default = 2)
%         Radius - radius of curvature of the torus (default = 6)
%         Slices
%         Stacks
%
% Returns an Open GL Drawing List ("PartialTorusDL")

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
if ~exist('TorusFract', 'var')
    TorusFract = .25;
end
if ~exist('TubeRadius', 'var')
    TubeRadius = 2;
end
if ~exist('Radius', 'var')
    Radius = 6;
end
if ~exist('Slices', 'var')
    Slices = 20;
end
if ~exist('Stacks', 'var')
    Stacks = 30;
end
    %%% Drawing a Partial Torus
    Sides = Slices;
    Rings = Stacks;
    sideDelta = 2.0 * pi / Sides;
    ringDelta = TorusFract * 2 * pi / Rings;
    theta1 = 0.0;
    cosTheta = 1.0;
    sinTheta = 0.0;
    ArcLength = convert2deg((Rings+1) * ringDelta);

    %%% GL List for Macaroni Generation:
        PartialTorusDL = glGenLists(1);
        glNewList(PartialTorusDL, GL.COMPILE);
        glPushMatrix; 
            glPushMatrix; 
                glTranslated(-Radius,0,0);                
                %%% Top of Macaroni:
                TopStart = GetSecs;
                glPushMatrix;
                    glRotated(.5*ArcLength,0,0,1);
                    glRotated(-90,1,0,0);
                    glTranslated(Radius, 0, 0);
                    MacTop = gluNewQuadric;
                    inner = 0;
                    outer = TubeRadius;
                    slices = 20;
                    stacks = 1;
                    loops = 1;
                    gluDisk( MacTop, inner, outer, slices, loops )
                    gluDeleteQuadric(MacTop);
                glPopMatrix;
                TopFinish = GetSecs;
                %%% Body of Macaroni:
                glPushMatrix;
                    glRotated(.5*ArcLength,0,0,1);
                    for ii = (Rings + 1):-1:1
                        theta1 = theta1 + ringDelta;
                        cosTheta1 = cos(theta1);
                        sinTheta1 = sin(theta1);
                        glBegin(GL.QUAD_STRIP);
                        phi = 0.0;
                        for jj = (Sides+1):-1:1
                            phi = phi + sideDelta;
                            cosPhi = cos(phi);
                            sinPhi = sin(phi);
                            dist = Radius + (TubeRadius * cosPhi);

                            glNormal3f(cosTheta1 * cosPhi, -sinTheta1 * cosPhi, sinPhi);
                            glVertex3f(cosTheta1 * dist, -sinTheta1 * dist, TubeRadius * sinPhi);

                            glNormal3f(cosTheta * cosPhi, -sinTheta * cosPhi, sinPhi);
                            glVertex3f(cosTheta * dist, -sinTheta * dist, TubeRadius * sinPhi);
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
                    glRotated(-.5*ArcLength,0,0,1);
                    glRotated(90,1,0,0);
                    glTranslated(Radius, 0, 0);
                    MacBottom = gluNewQuadric;
                    gluDisk( MacBottom, inner, outer, slices, loops )
                    gluDeleteQuadric(MacBottom);
                glPopMatrix;
                BottomFinish = GetSecs;
            glPopMatrix;
        glPopMatrix;    

        glEndList;
    %%% End of OpenGL Drawing List

% %%% De-bugging timing code:
% TopTime = TopFinish - TopStart
% MiddleTime = BodyFinish-TopFinish
% BottomTime = BottomFinish-BodyFinish
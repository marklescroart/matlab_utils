function TriPrismDL = mlglTriPrism(Ht, X, Z, Shift) % To Add: Texture!

% Usage: TriPrismDL = mlglTriPrism(Ht, X, Z, Shift)
% 
% Draws a Rectangular prism.
% 
% Call glEnable(GL.NORMALIZE) before calling this list!

global GL;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Checking the Computer's Configuration: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AssertOpenGL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Default Vaules for parameters: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('X', 'var')
    X = 3;
end
if ~exist('Ht', 'var')
    Ht = 1;
end
if ~exist('Z', 'var')
    Z = 2;
end
if ~exist('Shift','var')
    Shift = 0;
end

%%% Compensating for offset of prism vertices
%glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);
Lhalf = X/2; Z = Z/2; %Ht = Ht/2; 
load MLColorsOpenGL.mat;
TriPrismDL = glGenLists(1);
glNewList(TriPrismDL,GL.COMPILE);
	%glTranslated(0,Ht/2,0);
    % Draw the sides of the prism --- CCW winding (NOT Clockwise)
    glBegin(GL.TRIANGLES);
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Yellow)
        % Back
        glNormal3d(0.0, 0.0, -1.0);
        % Rt Top Back
        glVertex3d(Lhalf-Shift, Ht, -Z);
        % Rt Bot Back
        glVertex3d(Lhalf, 0 , -Z);
        % Lf Bot Back
        glVertex3d(-Lhalf, 0 , -Z);
        
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Blue)
        % Front
        glNormal3d(0.0, 0.0, 1.0);
        % Rt Top
        glVertex3d(Lhalf-Shift, Ht, Z);
        % Lf Bot
        glVertex3d(-Lhalf, 0 , Z);
        % Rt Bot
        glVertex3d(Lhalf, 0 , Z);
    glEnd;
    glBegin(GL.QUADS);
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Red)
        % Top - Lf
        glNormal3d(-1, (X-Shift)/Ht, 0); % X = Y tan (theta) --- Set Y==1, so X = tan(theta) = Ht/X
        % Back Bot/Lf
        glVertex3d(-Lhalf, 0 , -Z);
        % Front Bot/Lf
        glVertex3d(-Lhalf, 0 , Z);
        % Front Top/R
        glVertex3d(Lhalf-Shift, Ht, Z);
        % Back Top/R
        glVertex3d(Lhalf-Shift, Ht, -Z);
        
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Green)
        % Top - Rt
        glNormal3d(1.0, Shift/Ht, 0.0);
        % Back Top/Lf
        glVertex3d(Lhalf-Shift, Ht, -Z);
        % Front Top/Lf
        glVertex3d(Lhalf-Shift, Ht,  Z);
        % Front Bot/R
        glVertex3d(Lhalf, 0 ,  Z);
        % Back Bot/R
        glVertex3d(Lhalf, 0 , -Z);
        
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Gray111)
        glNormal3d(0.0, -1.0, 0.0);
        glVertex3d(-Lhalf, 0 , -Z);
        glVertex3d(Lhalf, 0 , -Z);
        glVertex3d(Lhalf, 0 , Z);
        glVertex3d(-Lhalf, 0 , Z);        
    glEnd();
    
glEndList;

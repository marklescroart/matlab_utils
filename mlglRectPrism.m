function PrismDL = mlglRectPrism(xx,yy,zz)

% Usage: RectPrismDL = mlglRectPrism(xx,yy,zz)
% 
% Draws a Rectangular prism.

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
if ~exist('xx', 'var')
    xx = 3;
end
if ~exist('yy', 'var')
    yy = 1;
end
if ~exist('zz', 'var')
    zz = 2;
end
%%% Compensating for offset of prism vertices
%glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);
xx = xx/2; yy = yy/2; zz = zz/2;
load MLColorsOpenGL.mat;
PrismDL = glGenLists(1);
glNewList(PrismDL,GL.COMPILE);
	
    % Draw the sides of the cube
    glBegin(GL.QUAD_STRIP);
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Yellow)
        % Normal A
        glNormal3d(0.0, 0.0, -1.0);
        % Vertex 1
        glVertex3d(xx, yy, -zz);
        % Vertex 2
        glVertex3d(xx, -yy, -zz);
        % Vertex 3
        glVertex3d(-xx, yy, -zz);
        % Vertex 4
        glVertex3d(-xx, -yy, -zz);
        
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Blue)
        % Normal B
        glNormal3d(-1.0, 0.0, 0.0);
        % Vertex 5
        glVertex3d(-xx, yy, zz);
        % Vertex 6
        glVertex3d(-xx, -yy, zz);
        
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Red)
        % Normal C
        glNormal3d(0.0, 0.0, 1.0);
        % Vertex 7
        glVertex3d(xx, yy, zz);
        % Vertex 8
        glVertex3d(xx, -yy, zz);
        
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Green)
        % Normal D
        glNormal3d(1.0, 0.0, 0.0);
        % Vertex 9
        glVertex3d(xx, yy, -zz);
        % Vertex 10
        glVertex3d(xx, -yy, -zz);
    glEnd();
    % Draw the top and bottom of the cube
    glBegin(GL.POLYGON);
        % Top
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.White)
        glNormal3d(0.0, -1.0, 0.0);
        glVertex3d(-xx, -yy, -zz);
        glVertex3d(xx, -yy, -zz);
        glVertex3d(xx, -yy, zz);
        glVertex3d(-xx, -yy, zz);
    glEnd;
        %Bottom
    glBegin(GL.POLYGON)
        %glMaterialfv(GL.FRONT,GL.DIFFUSE,GLCol.Gray111)
        glNormal3d(0.0, 1.0, 0.0);
        glVertex3d(-xx, yy, -zz);
        glVertex3d(-xx, yy, zz);
        glVertex3d(xx, yy, zz);
        glVertex3d(xx, yy, -zz);
    glEnd();
glEndList;

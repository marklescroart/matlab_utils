function mlglSimpleDraw(ShapeFunction, Color, SavePic)

% Usage: mlOpenGLDraw(ShapeFunction [,Color] [,SavePic]);
% 
% Inputs: WhichShape is a string that names a shape-creating function and
%               its parameters
%         Color specifies one of the color names in MLColorsOpenGL
%         SavePic determines whether a screen shot of the shape will be
%               taken or not
% e.g.: mlOpenGLDraw('DL = mlglDrawPartialTorus(2,3.5,20); glCallList(DL);', 'Mustard',1)
% 
% Designed to test new drawing routines.
% 
% Modified 1.05.07 by ML

if ~exist('ShapeFunction', 'var')|~isstr(ShapeFunction)|isempty(ShapeFunction)
    error('Please input a shape-drawing function and its parameters as a string');
end
if ~exist('Color','var')
    Color = 'Gray200';
end
if ~exist('SavePic','var')
    SavePic = 0;
end

try
    AssertOpenGL;
    KillUpdateProcess;
    AbsStart = GetSecs;
    InitializeMatlabOpenGL;
    MLScreenSetup;
    OpenGLSetup;
    Screen('BeginOpenGL',win);
    %%% TEMPORARY: ??? %%%
    glLoadIdentity;
    gluLookAt(-8,4,25,0,0,0,0,1,0);
    
    glClear;
    glMaterialfv(GL.FRONT,GL.DIFFUSE, GLCol.(Color)); 
    eval(ShapeFunction);
    %%% OpenGL wrap-up
    glFlush();
    Screen('EndOpenGL', win);
    Screen('Flip', win);
    
    ScreenPic = Screen('GetImage', win);
    OS = 128; 
    ScreenPicChop = ScreenPic(ScrVars.y_center-OS:ScrVars.y_center+OS,ScrVars.x_center-OS:ScrVars.x_center+OS,:);
    Root = pwd;
    if SavePic;
        imwrite(ScreenPicChop, [Root filesep 'Image1.png'], 'png');
    end

    %%% Closing:
    KbWait;
    
    Screen('CloseAll');
catch
    c;
    Priority(0);
    StartUpdateProcess;
    ShowCursor
    rethrow(lasterror);
    return
end
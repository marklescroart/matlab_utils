function NewDL = mlDLFromParams(Params,TexF)

% Usage: NewDL = mlDLFromParams(Params);
% 
% Params should be a struct array in the form: 
% 
% Params.(ShapeName). - fname
%                   . -Inpt
%                   . -fin (should = 1 for all shapes you want drawn)
%                   . -Rot1 (Xrot,1,0,0)
%                   . -Rot2 (Yrot,0,1,0)
%                   . -Rot3 (Zrot,0,0,1)
%                   . -Trans (x,y,z)
%                   . -Color (R G B) *Values must be 0-1, openGL convention
% 

global GL;
if isempty(GL)
    error([mfilename ':OpenGLInit'],['Please initialize OpenGL before calling ' mfilename]);
end
if ~exist('TexF','var')
    F.Tex = 0;
else
    F.Tex = 1;
end

Shapes = fieldnames(Params);


Count.DLtot = 0;
%%% Creating DLs for individual shapes based on Params.().Inpt
%%% parameters:
for iLists = 1:length(Shapes);
    for iShapeX = 1:length(Params.(Shapes{iLists}))
        if Params.(Shapes{iLists})(iShapeX).fin
            fcn = Params.(Shapes{iLists})(iShapeX).fname;
            inpt = Params.(Shapes{iLists})(iShapeX).Inpt; %#ok<NASGU> Called below in eval
            if F.Tex; inpt = {inpt{:} TexF}; end;
            glPushMatrix;
                Count.DLtot = Count.DLtot +1;
                if strcmp(fcn,'mlglPrism');
                    0;
                end
                DL(Count.DLtot) = eval([fcn '(inpt{:})']);
            glPopMatrix;
        else
            continue
        end
    end; clear iShapeX;
end; clear iLists; %end of individual DL creation

NewDL = glGenLists(1);
glNewList(NewDL,GL.COMPILE);
    Mc = mlglGetMaterialColors;
    Count.DLdraw = 0;
    for iLists = 1:length(Shapes);
        for iShapeX = 1:length(Params.(Shapes{iLists}))
            if Params.(Shapes{iLists})(iShapeX).fin
                %fcn = Params.(Shapes{iLists})(iShapeX).fname;
                %inpt = Params.(Shapes{iLists})(iShapeX).Inpt;
                glPushMatrix;
                glTranslated(Params.(Shapes{iLists})(iShapeX).Trans{:});
                glRotated(Params.(Shapes{iLists})(iShapeX).Rot1{:});
                glRotated(Params.(Shapes{iLists})(iShapeX).Rot2{:});
                glRotated(Params.(Shapes{iLists})(iShapeX).Rot3{:});
                Count.DLdraw = Count.DLdraw +1;
                if isfield(Params.(Shapes{iLists})(iShapeX),'Color');
                    glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, Params.(Shapes{iLists})(iShapeX).Color)
                    glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, Params.(Shapes{iLists})(iShapeX).Color)
                    glMaterialfv(GL.FRONT_AND_BACK,GL.SPECULAR, .2*[1 1 1 1]);
                end
                glCallList(DL(Count.DLdraw));
                glPopMatrix;
            else
                continue
            end
        end; clear iShapeX;
    end; clear iLists;
    mlglResetMaterialColors(Mc);
glEndList; %end of big DL creation

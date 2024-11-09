function mlBV_ShowFMRActivity(fName,Slice,TwoDThreeD)

% Usage: mlBV_ShowFMRActivity(fName,Slice,TwoDThreeD)
% 
% Two ways to dispay the activity of a single slice in plots - the 3d one
% gives a perspetive as to where the variance in teh data is occurring (all
% in the eyeballs...)


% Handling inputs:
Inputs      = {'fName','Slice','TwoDThreeD'};
InptValues = {'YouForgotTheFMRFileDumbass',10,3};
mlDefaultInputs

AllData = mlBV_GetFMRDataKH(fName);
nSlices = size(AllData.STC,2);
nVolumes = size(AllData.STC(Slice).data,3);

%a = reshape(AllData.STC(Slice).data,[64*64,nVolumes]);
a = AllData.STC(Slice).data;
% STD = std(double(a'));


switch TwoDThreeD
    case 2


        for i = 1:207;
            figure(1);
            plot(find(STD<20),a(find(STD<20),i),'b.');
            hold on;
            plot(find(STD>20),a(find(STD>20),i),'r.');
            hold off;
            ylim([0,1200]);
            drawnow;
            WaitSecs(.05);
        end

    case 3

        [x,y] = meshgrid(1:64,1:64);
        %x = x(:);
        %y = y(:);

        for i = 1:nVolumes;

            %plot3(x(find(STD<20)),y(find(STD<20)),a(find(STD<20),i),'k.');
            mesh(x,y,double(a(:,:,i)));
            %hold on;
            %plot3(x(find(STD>20)),y(find(STD>20)),a(find(STD>20),i),'r.');
            %hold off;
            zlim([0 1200]);
            WaitSecs(.05);
            drawnow;
        end
    case 33
        for iSl = 1:nSlices
            0; % this is not worth doing - remind yourself of that next time you're tempted, bozo.
        end
end


return

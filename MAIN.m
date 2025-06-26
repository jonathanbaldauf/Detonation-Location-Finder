classdef MAIN < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        ShowDiagonalCurvesCheckBox  matlab.ui.control.CheckBox
        YLabel                      matlab.ui.control.Label
        XLabel                      matlab.ui.control.Label
        DimensionsDiagram           matlab.ui.control.Image
        VelocityLabel               matlab.ui.control.Label
        WidthLabel                  matlab.ui.control.Label
        HeightLabel                 matlab.ui.control.Label
        ShotLabel                   matlab.ui.control.Label
        Pin4EditFieldLabel          matlab.ui.control.Label
        Pin3EditFieldLabel          matlab.ui.control.Label
        Pin2TimeLabel               matlab.ui.control.Label
        PinLocationsLabel           matlab.ui.control.Label
        PinTimesLabel               matlab.ui.control.Label
        Pin4_UpDownArrows           matlab.ui.container.ButtonGroup
        Pin4_Up                     matlab.ui.control.ToggleButton
        Pin4_Down                   matlab.ui.control.ToggleButton
        Pin3_UpDownArrows           matlab.ui.container.ButtonGroup
        Pin3_Up                     matlab.ui.control.ToggleButton
        Pin3_Down                   matlab.ui.control.ToggleButton
        Pin2_UpDownArrows           matlab.ui.container.ButtonGroup
        Pin2_Up                     matlab.ui.control.ToggleButton
        Pin2_Down                   matlab.ui.control.ToggleButton
        Pin1_UpDownArrows           matlab.ui.container.ButtonGroup
        Pin1_Up                     matlab.ui.control.ToggleButton
        Pin1_Down                   matlab.ui.control.ToggleButton
        Pin4_SideArrows             matlab.ui.container.ButtonGroup
        Pin4_Right                  matlab.ui.control.ToggleButton
        Pin4_Left                   matlab.ui.control.ToggleButton
        Pin3_SideArrows             matlab.ui.container.ButtonGroup
        Pin3_Right                  matlab.ui.control.ToggleButton
        Pin3_Left                   matlab.ui.control.ToggleButton
        Pin2_SideArrows             matlab.ui.container.ButtonGroup
        Pin2_Right                  matlab.ui.control.ToggleButton
        Pin2_Left                   matlab.ui.control.ToggleButton
        Pin1_SideArrows             matlab.ui.container.ButtonGroup
        Pin1_Right                  matlab.ui.control.ToggleButton
        Pin1_Left                   matlab.ui.control.ToggleButton
        DetLocLabel                 matlab.ui.control.Label
        SaveButton                  matlab.ui.control.Button
        RunButton                   matlab.ui.control.Button
        Pin4_Y_EditField            matlab.ui.control.NumericEditField
        Pin3_Y_EditField            matlab.ui.control.NumericEditField
        Pin2_Y_EditField            matlab.ui.control.NumericEditField
        Pin1_Y_EditField            matlab.ui.control.NumericEditField
        Pin4_X_EditField            matlab.ui.control.NumericEditField
        Pin3_X_EditField            matlab.ui.control.NumericEditField
        Pin2_X_EditField            matlab.ui.control.NumericEditField
        Pin1_X_EditField            matlab.ui.control.NumericEditField
        Pin4EditField               matlab.ui.control.NumericEditField
        Pin3EditField               matlab.ui.control.NumericEditField
        Pin2EditField               matlab.ui.control.NumericEditField
        Pin1EditField               matlab.ui.control.NumericEditField
        Pin1EditFieldLabel          matlab.ui.control.Label
        VelocityField               matlab.ui.control.NumericEditField
        WidthField                  matlab.ui.control.NumericEditField
        HeightField                 matlab.ui.control.NumericEditField
        ShotNumberField             matlab.ui.control.NumericEditField
        VelocityContextMenu         matlab.ui.container.ContextMenu
        ChangeHEVelocityMenu        matlab.ui.container.Menu
    end

    
    properties (Access = private)
        ShotNumber
        wd  % window dimensions
        diagonal_flag % flag is 1 when you want to display diagonal lines
    end
    
    %define my functions here
    methods (Access = private)
        
        function B = RemoveOutliers(app, x, y)
            %Remove all data points outside the window dimensions
            B = transpose([x; y]);
            [i,~] = find(B(:,1) < app.wd(1) | B(:,1) > app.wd(2) | B(:,2) < app.wd(3) | B(:,2) > app.wd(4));
            B(i,:) = [];
        end
        
        function [detx, dety] = FindIntersections(~, B21, B13, B34, B42, B14, B23)
            [inter2113x, inter2113y] = intersections(B21(:,1), B21(:,2), B13(:,1), B13(:,2));
            [inter2142x, inter2142y] = intersections(B21(:,1), B21(:,2), B42(:,1), B42(:,2));
            [inter3413x, inter3413y] = intersections(B34(:,1), B34(:,2), B13(:,1), B13(:,2));
            [inter3442x, inter3442y] = intersections(B34(:,1), B34(:,2), B42(:,1), B42(:,2));
            [inter1423x, inter1423y] = intersections(B14(:,1), B14(:,2), B23(:,1), B23(:,2));
            
            detx = mean([inter2113x inter2142x inter3413x inter3442x inter1423x]);
            dety = mean([inter2113y inter2142y inter3413y inter3442y inter1423y]);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            app.ShotNumber = app.ShotNumberField.Value;
            Theta = -20:1:110;
            v = app.VelocityField.Value;
            
            Pins = struct(...
                'Left',     {app.Pin1_Left.Value, app.Pin2_Left.Value, app.Pin3_Left.Value, app.Pin4_Left.Value},...
                'Down',     {app.Pin1_Down.Value, app.Pin2_Down.Value, app.Pin3_Down.Value, app.Pin4_Down.Value},...
                'Xoffset',  {app.Pin1_X_EditField.Value, app.Pin2_X_EditField.Value, app.Pin3_X_EditField.Value, app.Pin4_X_EditField.Value},...
                'Yoffset',  {app.Pin1_Y_EditField.Value, app.Pin2_Y_EditField.Value, app.Pin3_Y_EditField.Value, app.Pin4_Y_EditField.Value},...
                'Time',     {app.Pin1EditField.Value, app.Pin2EditField.Value, app.Pin3EditField.Value, app.Pin4EditField.Value},...
                'X',        {NaN, NaN, NaN, NaN},...
                'Y',        {NaN, NaN, NaN, NaN});

            % Update pin locations relative to user inputted arrow directions
            for n = 1:4
                if Pins(n).Left == 1
                    Pins(n).X = (app.WidthField.Value/2) - Pins(n).Xoffset;
                else
                    Pins(n).X = -(app.WidthField.Value/2) + Pins(n).Xoffset;
                end
                if Pins(n).Down == 1
                    Pins(n).Y = (app.HeightField.Value/2) - Pins(n).Yoffset;
                else
                    Pins(n).Y = -(app.HeightField.Value/2) + Pins(n).Yoffset;
                end
                if isequal(Pins(n).Time, 0)
                    Pins(n).Time = NaN;     %N/A time values should be NaN
                end
            end

            max_x = max([Pins(1).X, Pins(2).X, Pins(3).X, Pins(4).X])+15;
            min_x = min([Pins(1).X, Pins(2).X, Pins(3).X, Pins(4).X])-15;
            max_y = max([Pins(1).Y, Pins(2).Y, Pins(3).Y, Pins(4).Y])+20;
            min_y = min([Pins(1).Y, Pins(2).Y, Pins(3).Y, Pins(4).Y])-20;
            app.wd = [min_x max_x min_y max_y]; %set window dimensions

            K21 = v * (Pins(2).Time - Pins(1).Time);
            D21 = sqrt((Pins(2).X - Pins(1).X)^2 + (Pins(2).Y - Pins(1).Y)^2);
            a21 = (D21^2 - K21^2) ./ (2 * (D21 * cosd(Theta) - K21));
            phi21 = atand((Pins(2).Y-Pins(1).Y)/(Pins(2).X-Pins(1).X));
            x21 = Pins(2).X - (a21 .* cosd(Theta + phi21));
            y21 = Pins(2).Y - (a21 .* sind(Theta + phi21));
            B21 = RemoveOutliers(app, x21, y21);
            %-------------------------------------------------------------
            K13 = v * (Pins(1).Time - Pins(3).Time);
            D13 = sqrt((Pins(1).X - Pins(3).X)^2 + (Pins(1).Y - Pins(3).Y)^2);
            a13 = (D13^2 - K13^2) ./ (2 * (D13 * cosd(Theta) - K13));
            phi13 = -atand((Pins(1).X-Pins(3).X)/(Pins(1).Y-Pins(3).Y));
            x13 = Pins(1).X + (a13 .* sind(Theta + phi13));
            y13 = Pins(1).Y - (a13 .* cosd(Theta + phi13));
            B13 = RemoveOutliers(app, x13, y13);
            %-------------------------------------------------------------
            K34 = v * (Pins(3).Time - Pins(4).Time);
            D34 = sqrt((Pins(3).X - Pins(4).X)^2 + (Pins(3).Y - Pins(4).Y)^2);
            a34 = (D34^2 - K34^2) ./ (2 * (D34 * cosd(Theta) - K34));
            phi34 = atand((Pins(3).Y-Pins(4).Y)/(Pins(3).X-Pins(4).X));
            x34 = Pins(3).X + (a34 .* cosd(Theta + phi34));
            y34 = Pins(3).Y + (a34 .* sind(Theta + phi34));
            B34 = RemoveOutliers(app, x34, y34);
            %-------------------------------------------------------------
            K42 = v * (Pins(4).Time - Pins(2).Time);
            D42 = sqrt((Pins(4).X - Pins(2).X)^2 + (Pins(4).Y - Pins(2).Y)^2);
            a42 = (D42^2 - K42^2) ./ (2 * (D42 * cosd(Theta) - K42));
            phi42 = -atand((Pins(4).X-Pins(2).X)/(Pins(4).Y-Pins(2).Y));
            x42 = Pins(4).X - (a42 .* sind(Theta + phi42));
            y42 = Pins(4).Y + (a42 .* cosd(Theta + phi42));
            B42 = RemoveOutliers(app, x42, y42);
            %-------------------------------------------------------------
            Theta2 = -70:1:70;  %readjusted theta range since Θ=0 is roughly centered
            K14 = v * (Pins(1).Time - Pins(4).Time);
            D14 = sqrt((Pins(1).X - Pins(4).X)^2 + (Pins(1).Y - Pins(4).Y)^2);
            a14 = (D14^2 - K14^2) ./ (2 * (D14 * cosd(Theta2) - K14));
            phi14 = acosd((Pins(4).X - Pins(1).X) / D14);  %always positive
            x14 = Pins(1).X + (a14 .* cosd(Theta2 + phi14));
            y14 = Pins(1).Y - (a14 .* sind(Theta2 + phi14));
            B14 = RemoveOutliers(app, x14, y14);
            %-------------------------------------------------------------
            K23 = v * (Pins(2).Time - Pins(3).Time);
            D23 = sqrt((Pins(2).X - Pins(3).X)^2 + (Pins(2).Y - Pins(3).Y)^2);
            a23 = (D23^2 - K23^2) ./ (2 * (D23 * cosd(Theta2) - K23));
            phi23 = acosd((Pins(2).X - Pins(3).X) / D23);  %always positive
            x23 = Pins(2).X - (a23 .* cosd(Theta2 + phi23));
            y23 = Pins(2).Y - (a23 .* sind(Theta2 + phi23));
            B23 = RemoveOutliers(app, x23, y23);


            %Calculate Average between Intersection Points
            [detx, dety] = FindIntersections(app, B21, B13, B34, B42, B14, B23);
            app.DetLocLabel.Text = sprintf("Detonation Location: \n (%4.3f,  %4.3f)",detx,dety);

            figure;
            p1 = plot(B21(:,1), B21(:,2), 'k');
                hold on
            if app.diagonal_flag == 1
                p7 = plot(B14(:,1), B14(:,2), 'b');
                p8 = plot(B23(:,1), B23(:,2), 'b');
                set([p7, p8], 'LineStyle', '--', 'LineWidth', 2)
            end
            p2 = plot(B13(:,1), B13(:,2), 'r');
            p3 = plot(B34(:,1), B34(:,2), Color=[.4 .8 0]);
            p4 = plot(B42(:,1), B42(:,2), Color=[1 1 .4]);
            x = [Pins(1).X Pins(2).X Pins(3).X Pins(4).X];
            y = [Pins(1).Y Pins(2).Y Pins(3).Y Pins(4).Y];
            plot(x, y,'square',MarkerFaceColor='k',MarkerEdgeColor='k');
            text(x+5, y, {1,2,3,4})     %add data labels for the pins
            plot(detx, dety,'r*');   %plot the estimate det location
            %plot(4.5, 28, 'p', 'MarkerFaceColor', [.56 .33 .18], 'MarkerEdgeColor', [.56 .33 .18], 'MarkerSize', 15);    %plot the actual det location
                hold off
            set([p1, p2, p3, p4], 'LineStyle', '-', 'LineWidth', 4)   %plot lines
            %set([p1, p2, p3, p4], 'LineStyle', 'none', 'Marker', '*')   %plot markers
            set(gcf, 'Position',  [500 300 500 500])
            title(sprintf('Shot %5u', app.ShotNumber))
            xlabel('x (mm)')
            ylabel('y (mm)')
            xticks(-125:25:125)
            axis(app.wd)
            grid on
            grid minor
            legend_names = ["pins 1 & 4", "pins 2 & 3", "pins 2 & 1", "pins 1 & 3", "pins 3 & 4", "pins 4 & 2"];
            legend(legend_names,'Location','best')
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            [file, path] = uiputfile({'*.png';'*.jpg';'*.pdf'}, 'Save As',"shot"+string(app.ShotNumber));
            if isequal(file,0) || isequal(path,0)   %if user hit cancel
                return;
            else
                fullname = fullfile(path,file);
                exportgraphics(gcf, fullname,'Resolution',300);
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            close all
        end

        % Menu selected function: ChangeHEVelocityMenu
        function ChangeHEVelocityMenuSelected(app, event)
            app.VelocityLabel.Enable = 'on';
            app.VelocityField.Enable = 'on';
        end

        % Value changed function: ShowDiagonalCurvesCheckBox
        function ShowDiagonalCurvesCheckBoxValueChanged(app, event)
            app.diagonal_flag = app.ShowDiagonalCurvesCheckBox.Value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 496 596];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create ShotNumberField
            app.ShotNumberField = uieditfield(app.UIFigure, 'numeric');
            app.ShotNumberField.Tooltip = {'Enter the shot number'};
            app.ShotNumberField.Position = [377 538 60 32];
            app.ShotNumberField.Value = 4611;

            % Create HeightField
            app.HeightField = uieditfield(app.UIFigure, 'numeric');
            app.HeightField.Tooltip = {'Enter height of the HE sheet (mm)'};
            app.HeightField.Position = [377 489 60 32];
            app.HeightField.Value = 214;

            % Create WidthField
            app.WidthField = uieditfield(app.UIFigure, 'numeric');
            app.WidthField.Tooltip = {'Enter width of the HE sheet (mm)'};
            app.WidthField.Position = [377 438 60 32];
            app.WidthField.Value = 170;

            % Create VelocityField
            app.VelocityField = uieditfield(app.UIFigure, 'numeric');
            app.VelocityField.Enable = 'off';
            app.VelocityField.Tooltip = {'Enter the HE velocity. Default is 6.85 km/s'};
            app.VelocityField.Position = [378 388 60 32];
            app.VelocityField.Value = 6.85;

            % Create Pin1EditFieldLabel
            app.Pin1EditFieldLabel = uilabel(app.UIFigure);
            app.Pin1EditFieldLabel.HorizontalAlignment = 'right';
            app.Pin1EditFieldLabel.FontSize = 16;
            app.Pin1EditFieldLabel.FontWeight = 'bold';
            app.Pin1EditFieldLabel.Tooltip = {'Pin 1 Time (µs)'};
            app.Pin1EditFieldLabel.Position = [32 254 43 22];
            app.Pin1EditFieldLabel.Text = 'Pin 1';

            % Create Pin1EditField
            app.Pin1EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin1EditField.Tooltip = {'Pin 1 Time (µs)'};
            app.Pin1EditField.Position = [90 249 60 32];
            app.Pin1EditField.Value = 11.6402;

            % Create Pin2EditField
            app.Pin2EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin2EditField.Tooltip = {'Pin 2 Time (µs)'};
            app.Pin2EditField.Position = [91 200 60 32];
            app.Pin2EditField.Value = 11.8632;

            % Create Pin3EditField
            app.Pin3EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin3EditField.Tooltip = {'Pin 3 Time (µs)'};
            app.Pin3EditField.Position = [91 147 60 32];
            app.Pin3EditField.Value = 27.9494;

            % Create Pin4EditField
            app.Pin4EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin4EditField.Tooltip = {'Pin 4 Time (µs)'};
            app.Pin4EditField.Position = [91 95 60 32];
            app.Pin4EditField.Value = 28.2202;

            % Create Pin1_X_EditField
            app.Pin1_X_EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin1_X_EditField.Tag = 'Pin 1 Field';
            app.Pin1_X_EditField.Tooltip = {'Pin 1 is located this distance from edge of HE in the x-direction (mm)'};
            app.Pin1_X_EditField.Position = [187 252 45 30];
            app.Pin1_X_EditField.Value = 38;

            % Create Pin2_X_EditField
            app.Pin2_X_EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin2_X_EditField.Tag = 'Pin 1 Field';
            app.Pin2_X_EditField.Tooltip = {'Pin 2 is located this distance from edge of HE in the x-direction (mm)'};
            app.Pin2_X_EditField.Position = [187 200 45 30];
            app.Pin2_X_EditField.Value = 38;

            % Create Pin3_X_EditField
            app.Pin3_X_EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin3_X_EditField.Tag = 'Pin 1 Field';
            app.Pin3_X_EditField.Tooltip = {'Pin 3 is located this distance from edge of HE in the x-direction (mm)'};
            app.Pin3_X_EditField.Position = [187 149 45 30];
            app.Pin3_X_EditField.Value = 38;

            % Create Pin4_X_EditField
            app.Pin4_X_EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin4_X_EditField.Tag = 'Pin 1 Field';
            app.Pin4_X_EditField.Tooltip = {'Pin 4 is located this distance from edge of HE in the x-direction (mm)'};
            app.Pin4_X_EditField.Position = [187 97 45 30];
            app.Pin4_X_EditField.Value = 38;

            % Create Pin1_Y_EditField
            app.Pin1_Y_EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin1_Y_EditField.Tag = 'Pin 1 Field';
            app.Pin1_Y_EditField.Tooltip = {'Pin 1 is located this distance from edge of HE in the y-direction (mm)'};
            app.Pin1_Y_EditField.Position = [338 252 45 30];
            app.Pin1_Y_EditField.Value = 30;

            % Create Pin2_Y_EditField
            app.Pin2_Y_EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin2_Y_EditField.Tag = 'Pin 1 Field';
            app.Pin2_Y_EditField.Tooltip = {'Pin 2 is located this distance from edge of HE in the y-direction (mm)'};
            app.Pin2_Y_EditField.Position = [338 200 45 30];
            app.Pin2_Y_EditField.Value = 30;

            % Create Pin3_Y_EditField
            app.Pin3_Y_EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin3_Y_EditField.Tag = 'Pin 1 Field';
            app.Pin3_Y_EditField.Tooltip = {'Pin 3 is located this distance from edge of HE in the y-direction (mm)'};
            app.Pin3_Y_EditField.Position = [338 149 45 30];
            app.Pin3_Y_EditField.Value = 30;

            % Create Pin4_Y_EditField
            app.Pin4_Y_EditField = uieditfield(app.UIFigure, 'numeric');
            app.Pin4_Y_EditField.Tag = 'Pin 1 Field';
            app.Pin4_Y_EditField.Tooltip = {'Pin 4 is located this distance from edge of HE in the y-direction (mm)'};
            app.Pin4_Y_EditField.Position = [338 97 45 30];
            app.Pin4_Y_EditField.Value = 30;

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.902 0.902 0.902];
            app.RunButton.FontSize = 14;
            app.RunButton.Tooltip = {'Run program to create a plot and estimate detonation location'};
            app.RunButton.Position = [35 24 115 45];
            app.RunButton.Text = 'Run';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.902 0.902 0.902];
            app.SaveButton.FontSize = 14;
            app.SaveButton.Tooltip = {'Save the results graph'};
            app.SaveButton.Position = [181 24 115 45];
            app.SaveButton.Text = 'Save';

            % Create DetLocLabel
            app.DetLocLabel = uilabel(app.UIFigure);
            app.DetLocLabel.HorizontalAlignment = 'center';
            app.DetLocLabel.VerticalAlignment = 'top';
            app.DetLocLabel.FontSize = 14;
            app.DetLocLabel.FontWeight = 'bold';
            app.DetLocLabel.Tooltip = {'The program''s estimated location will appear here after running'};
            app.DetLocLabel.Position = [327 32 145 40];
            app.DetLocLabel.Text = 'Detonation Location:';

            % Create Pin1_SideArrows
            app.Pin1_SideArrows = uibuttongroup(app.UIFigure);
            app.Pin1_SideArrows.AutoResizeChildren = 'off';
            app.Pin1_SideArrows.Tooltip = {'Right arrow = pin inserted from the left edge of the HE, going rightward'; 'Left arrow = pin was inserted from the right edge of HE, going leftward'};
            app.Pin1_SideArrows.BorderType = 'none';
            app.Pin1_SideArrows.TitlePosition = 'centertop';
            app.Pin1_SideArrows.Position = [245 251 70 31];

            % Create Pin1_Left
            app.Pin1_Left = uitogglebutton(app.Pin1_SideArrows);
            app.Pin1_Left.Icon = fullfile(pathToMLAPP, 'left arrow icon.png');
            app.Pin1_Left.IconAlignment = 'center';
            app.Pin1_Left.Text = '';
            app.Pin1_Left.Position = [1 1 30 30];

            % Create Pin1_Right
            app.Pin1_Right = uitogglebutton(app.Pin1_SideArrows);
            app.Pin1_Right.Icon = fullfile(pathToMLAPP, 'right arrow icon.png');
            app.Pin1_Right.IconAlignment = 'center';
            app.Pin1_Right.Text = '';
            app.Pin1_Right.Position = [37 1 30 30];
            app.Pin1_Right.Value = true;

            % Create Pin2_SideArrows
            app.Pin2_SideArrows = uibuttongroup(app.UIFigure);
            app.Pin2_SideArrows.AutoResizeChildren = 'off';
            app.Pin2_SideArrows.Tooltip = {'Right arrow = pin inserted from the left edge of the HE, going rightward'; 'Left arrow = pin was inserted from the right edge of HE, going leftward'};
            app.Pin2_SideArrows.BorderType = 'none';
            app.Pin2_SideArrows.TitlePosition = 'centertop';
            app.Pin2_SideArrows.Position = [245 199 70 30];

            % Create Pin2_Left
            app.Pin2_Left = uitogglebutton(app.Pin2_SideArrows);
            app.Pin2_Left.Icon = fullfile(pathToMLAPP, 'left arrow icon.png');
            app.Pin2_Left.IconAlignment = 'center';
            app.Pin2_Left.Text = '';
            app.Pin2_Left.Position = [1 1 30 30];
            app.Pin2_Left.Value = true;

            % Create Pin2_Right
            app.Pin2_Right = uitogglebutton(app.Pin2_SideArrows);
            app.Pin2_Right.Icon = fullfile(pathToMLAPP, 'right arrow icon.png');
            app.Pin2_Right.IconAlignment = 'center';
            app.Pin2_Right.Text = '';
            app.Pin2_Right.Position = [37 1 30 30];

            % Create Pin3_SideArrows
            app.Pin3_SideArrows = uibuttongroup(app.UIFigure);
            app.Pin3_SideArrows.AutoResizeChildren = 'off';
            app.Pin3_SideArrows.Tooltip = {'Right arrow = pin inserted from the left edge of the HE, going rightward'; 'Left arrow = pin was inserted from the right edge of HE, going leftward'};
            app.Pin3_SideArrows.BorderType = 'none';
            app.Pin3_SideArrows.TitlePosition = 'centertop';
            app.Pin3_SideArrows.Position = [245 148 70 30];

            % Create Pin3_Left
            app.Pin3_Left = uitogglebutton(app.Pin3_SideArrows);
            app.Pin3_Left.Icon = fullfile(pathToMLAPP, 'left arrow icon.png');
            app.Pin3_Left.IconAlignment = 'center';
            app.Pin3_Left.Text = '';
            app.Pin3_Left.Position = [1 1 30 30];

            % Create Pin3_Right
            app.Pin3_Right = uitogglebutton(app.Pin3_SideArrows);
            app.Pin3_Right.Icon = fullfile(pathToMLAPP, 'right arrow icon.png');
            app.Pin3_Right.IconAlignment = 'center';
            app.Pin3_Right.Text = '';
            app.Pin3_Right.Position = [37 1 30 30];
            app.Pin3_Right.Value = true;

            % Create Pin4_SideArrows
            app.Pin4_SideArrows = uibuttongroup(app.UIFigure);
            app.Pin4_SideArrows.AutoResizeChildren = 'off';
            app.Pin4_SideArrows.Tooltip = {'Right arrow = pin inserted from the left edge of the HE, going rightward'; 'Left arrow = pin was inserted from the right edge of HE, going leftward'};
            app.Pin4_SideArrows.BorderType = 'none';
            app.Pin4_SideArrows.TitlePosition = 'centertop';
            app.Pin4_SideArrows.Position = [245 96 70 30];

            % Create Pin4_Left
            app.Pin4_Left = uitogglebutton(app.Pin4_SideArrows);
            app.Pin4_Left.Icon = fullfile(pathToMLAPP, 'left arrow icon.png');
            app.Pin4_Left.IconAlignment = 'center';
            app.Pin4_Left.Text = '';
            app.Pin4_Left.Position = [1 1 30 30];
            app.Pin4_Left.Value = true;

            % Create Pin4_Right
            app.Pin4_Right = uitogglebutton(app.Pin4_SideArrows);
            app.Pin4_Right.Icon = fullfile(pathToMLAPP, 'right arrow icon.png');
            app.Pin4_Right.IconAlignment = 'center';
            app.Pin4_Right.Text = '';
            app.Pin4_Right.Position = [37 1 30 30];

            % Create Pin1_UpDownArrows
            app.Pin1_UpDownArrows = uibuttongroup(app.UIFigure);
            app.Pin1_UpDownArrows.AutoResizeChildren = 'off';
            app.Pin1_UpDownArrows.Tooltip = {'Up arrow = pin inserted from the bottom edge of the HE, going upward'; 'Down arrow = pin was inserted from the top edge of HE, going downward'};
            app.Pin1_UpDownArrows.BorderType = 'none';
            app.Pin1_UpDownArrows.TitlePosition = 'centertop';
            app.Pin1_UpDownArrows.Position = [397 251 70 30];

            % Create Pin1_Down
            app.Pin1_Down = uitogglebutton(app.Pin1_UpDownArrows);
            app.Pin1_Down.Icon = fullfile(pathToMLAPP, 'down arrow icon.png');
            app.Pin1_Down.IconAlignment = 'center';
            app.Pin1_Down.Text = '';
            app.Pin1_Down.Position = [1 1 30 30];
            app.Pin1_Down.Value = true;

            % Create Pin1_Up
            app.Pin1_Up = uitogglebutton(app.Pin1_UpDownArrows);
            app.Pin1_Up.Icon = fullfile(pathToMLAPP, 'up arrow icon.png');
            app.Pin1_Up.IconAlignment = 'center';
            app.Pin1_Up.Text = '';
            app.Pin1_Up.Position = [37 1 30 30];

            % Create Pin2_UpDownArrows
            app.Pin2_UpDownArrows = uibuttongroup(app.UIFigure);
            app.Pin2_UpDownArrows.AutoResizeChildren = 'off';
            app.Pin2_UpDownArrows.Tooltip = {'Up arrow = pin inserted from the bottom edge of the HE, going upward'; 'Down arrow = pin was inserted from the top edge of HE, going downward'};
            app.Pin2_UpDownArrows.BorderType = 'none';
            app.Pin2_UpDownArrows.TitlePosition = 'centertop';
            app.Pin2_UpDownArrows.Position = [397 200 70 30];

            % Create Pin2_Down
            app.Pin2_Down = uitogglebutton(app.Pin2_UpDownArrows);
            app.Pin2_Down.Icon = fullfile(pathToMLAPP, 'down arrow icon.png');
            app.Pin2_Down.IconAlignment = 'center';
            app.Pin2_Down.Text = '';
            app.Pin2_Down.Position = [1 1 30 30];
            app.Pin2_Down.Value = true;

            % Create Pin2_Up
            app.Pin2_Up = uitogglebutton(app.Pin2_UpDownArrows);
            app.Pin2_Up.Icon = fullfile(pathToMLAPP, 'up arrow icon.png');
            app.Pin2_Up.IconAlignment = 'center';
            app.Pin2_Up.Text = '';
            app.Pin2_Up.Position = [37 1 30 30];

            % Create Pin3_UpDownArrows
            app.Pin3_UpDownArrows = uibuttongroup(app.UIFigure);
            app.Pin3_UpDownArrows.AutoResizeChildren = 'off';
            app.Pin3_UpDownArrows.Tooltip = {'Up arrow = pin inserted from the bottom edge of the HE, going upward'; 'Down arrow = pin was inserted from the top edge of HE, going downward'};
            app.Pin3_UpDownArrows.BorderType = 'none';
            app.Pin3_UpDownArrows.TitlePosition = 'centertop';
            app.Pin3_UpDownArrows.Position = [397 148 70 30];

            % Create Pin3_Down
            app.Pin3_Down = uitogglebutton(app.Pin3_UpDownArrows);
            app.Pin3_Down.Icon = fullfile(pathToMLAPP, 'down arrow icon.png');
            app.Pin3_Down.IconAlignment = 'center';
            app.Pin3_Down.Text = '';
            app.Pin3_Down.Position = [1 1 30 30];

            % Create Pin3_Up
            app.Pin3_Up = uitogglebutton(app.Pin3_UpDownArrows);
            app.Pin3_Up.Icon = fullfile(pathToMLAPP, 'up arrow icon.png');
            app.Pin3_Up.IconAlignment = 'center';
            app.Pin3_Up.Text = '';
            app.Pin3_Up.Position = [37 1 30 30];
            app.Pin3_Up.Value = true;

            % Create Pin4_UpDownArrows
            app.Pin4_UpDownArrows = uibuttongroup(app.UIFigure);
            app.Pin4_UpDownArrows.AutoResizeChildren = 'off';
            app.Pin4_UpDownArrows.Tooltip = {'Up arrow = pin inserted from the bottom edge of the HE, going upward'; 'Down arrow = pin was inserted from the top edge of HE, going downward'};
            app.Pin4_UpDownArrows.BorderType = 'none';
            app.Pin4_UpDownArrows.TitlePosition = 'centertop';
            app.Pin4_UpDownArrows.Position = [397 96 70 30];

            % Create Pin4_Down
            app.Pin4_Down = uitogglebutton(app.Pin4_UpDownArrows);
            app.Pin4_Down.Icon = fullfile(pathToMLAPP, 'down arrow icon.png');
            app.Pin4_Down.IconAlignment = 'center';
            app.Pin4_Down.Text = '';
            app.Pin4_Down.Position = [1 1 30 30];

            % Create Pin4_Up
            app.Pin4_Up = uitogglebutton(app.Pin4_UpDownArrows);
            app.Pin4_Up.Icon = fullfile(pathToMLAPP, 'up arrow icon.png');
            app.Pin4_Up.IconAlignment = 'center';
            app.Pin4_Up.Text = '';
            app.Pin4_Up.Position = [37 1 30 30];
            app.Pin4_Up.Value = true;

            % Create PinTimesLabel
            app.PinTimesLabel = uilabel(app.UIFigure);
            app.PinTimesLabel.HorizontalAlignment = 'center';
            app.PinTimesLabel.FontSize = 16;
            app.PinTimesLabel.FontWeight = 'bold';
            app.PinTimesLabel.Position = [30 302 171 36];
            app.PinTimesLabel.Text = 'Pin Times';

            % Create PinLocationsLabel
            app.PinLocationsLabel = uilabel(app.UIFigure);
            app.PinLocationsLabel.HorizontalAlignment = 'center';
            app.PinLocationsLabel.FontSize = 16;
            app.PinLocationsLabel.FontWeight = 'bold';
            app.PinLocationsLabel.Position = [187 302 281 36];
            app.PinLocationsLabel.Text = 'Pin Locations';

            % Create Pin2TimeLabel
            app.Pin2TimeLabel = uilabel(app.UIFigure);
            app.Pin2TimeLabel.HorizontalAlignment = 'right';
            app.Pin2TimeLabel.FontSize = 16;
            app.Pin2TimeLabel.FontWeight = 'bold';
            app.Pin2TimeLabel.Tooltip = {'Pin 2 Time (µs)'};
            app.Pin2TimeLabel.Position = [33 205 43 22];
            app.Pin2TimeLabel.Text = 'Pin 2';

            % Create Pin3EditFieldLabel
            app.Pin3EditFieldLabel = uilabel(app.UIFigure);
            app.Pin3EditFieldLabel.HorizontalAlignment = 'right';
            app.Pin3EditFieldLabel.FontSize = 16;
            app.Pin3EditFieldLabel.FontWeight = 'bold';
            app.Pin3EditFieldLabel.Tooltip = {'Pin 3 Time (µs)'};
            app.Pin3EditFieldLabel.Position = [33 152 43 22];
            app.Pin3EditFieldLabel.Text = 'Pin 3';

            % Create Pin4EditFieldLabel
            app.Pin4EditFieldLabel = uilabel(app.UIFigure);
            app.Pin4EditFieldLabel.HorizontalAlignment = 'right';
            app.Pin4EditFieldLabel.FontSize = 16;
            app.Pin4EditFieldLabel.FontWeight = 'bold';
            app.Pin4EditFieldLabel.Tooltip = {'Pin 4 Time (µs)'};
            app.Pin4EditFieldLabel.Position = [33 100 43 22];
            app.Pin4EditFieldLabel.Text = 'Pin 4';

            % Create ShotLabel
            app.ShotLabel = uilabel(app.UIFigure);
            app.ShotLabel.HorizontalAlignment = 'right';
            app.ShotLabel.FontSize = 16;
            app.ShotLabel.FontWeight = 'bold';
            app.ShotLabel.Tooltip = {'Enter the shot number'};
            app.ShotLabel.Position = [303 543 59 22];
            app.ShotLabel.Text = 'Shot #:';

            % Create HeightLabel
            app.HeightLabel = uilabel(app.UIFigure);
            app.HeightLabel.HorizontalAlignment = 'right';
            app.HeightLabel.FontSize = 16;
            app.HeightLabel.FontWeight = 'bold';
            app.HeightLabel.Tooltip = {'Enter height of the HE sheet (mm)'};
            app.HeightLabel.Position = [302 494 60 22];
            app.HeightLabel.Text = 'Height:';

            % Create WidthLabel
            app.WidthLabel = uilabel(app.UIFigure);
            app.WidthLabel.HorizontalAlignment = 'right';
            app.WidthLabel.FontSize = 16;
            app.WidthLabel.FontWeight = 'bold';
            app.WidthLabel.Tooltip = {'Enter width of the HE sheet (mm)'};
            app.WidthLabel.Position = [307 443 55 22];
            app.WidthLabel.Text = 'Width:';

            % Create VelocityLabel
            app.VelocityLabel = uilabel(app.UIFigure);
            app.VelocityLabel.HorizontalAlignment = 'right';
            app.VelocityLabel.FontSize = 16;
            app.VelocityLabel.FontWeight = 'bold';
            app.VelocityLabel.Enable = 'off';
            app.VelocityLabel.Tooltip = {'Enter the HE velocity. Default is 6.85 km/s'};
            app.VelocityLabel.Position = [292 393 71 22];
            app.VelocityLabel.Text = 'Velocity:';

            % Create DimensionsDiagram
            app.DimensionsDiagram = uiimage(app.UIFigure);
            app.DimensionsDiagram.Tooltip = {'Diagram of HE dimensions and typical pin arrangement'};
            app.DimensionsDiagram.Position = [55 344 215 236];
            app.DimensionsDiagram.ImageSource = fullfile(pathToMLAPP, 'HE dimensions diagram 2.png');

            % Create XLabel
            app.XLabel = uilabel(app.UIFigure);
            app.XLabel.HorizontalAlignment = 'center';
            app.XLabel.FontWeight = 'bold';
            app.XLabel.Tooltip = {'The distance between the pin and edge of the HE in the x-direction (mm)'};
            app.XLabel.Position = [197 285 26 22];
            app.XLabel.Text = 'X';

            % Create YLabel
            app.YLabel = uilabel(app.UIFigure);
            app.YLabel.HorizontalAlignment = 'center';
            app.YLabel.FontWeight = 'bold';
            app.YLabel.Position = [347 285 26 22];
            app.YLabel.Text = 'Y';

            % Create ShowDiagonalCurvesCheckBox
            app.ShowDiagonalCurvesCheckBox = uicheckbox(app.UIFigure);
            app.ShowDiagonalCurvesCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShowDiagonalCurvesCheckBoxValueChanged, true);
            app.ShowDiagonalCurvesCheckBox.Tooltip = {'Display the solution curves from diagonal pairs of pins on the same graph'};
            app.ShowDiagonalCurvesCheckBox.Text = 'Show Diagonal Curves';
            app.ShowDiagonalCurvesCheckBox.FontSize = 14;
            app.ShowDiagonalCurvesCheckBox.Position = [290 348 174 29];

            % Create VelocityContextMenu
            app.VelocityContextMenu = uicontextmenu(app.UIFigure);

            % Create ChangeHEVelocityMenu
            app.ChangeHEVelocityMenu = uimenu(app.VelocityContextMenu);
            app.ChangeHEVelocityMenu.MenuSelectedFcn = createCallbackFcn(app, @ChangeHEVelocityMenuSelected, true);
            app.ChangeHEVelocityMenu.Text = 'Change HE Velocity';
            
            % Assign app.VelocityContextMenu
            app.VelocityField.ContextMenu = app.VelocityContextMenu;
            app.VelocityLabel.ContextMenu = app.VelocityContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MAIN

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
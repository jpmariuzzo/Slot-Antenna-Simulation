classdef slot_antenna_simulation_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        LeftPanel                matlab.ui.container.Panel
        AboutThissimulationispartofaScientificResearchProjectdevelopedin2013SlotAntennaStudyandCharacterizationComputerModelingandSimulationonMATLABapplyingatwodimensionalFouriertransformtotheradiatedfieldsoverasingleslottedmetallicsurfaceLabel  matlab.ui.control.Label
        AuthorJooPauloMariuzzoBScinElectronicsEngineeringLinkedInwwwlinkedincominjpmariuzzoLabel  matlab.ui.control.Label
        EditField                matlab.ui.control.NumericEditField
        GraphicDropDown          matlab.ui.control.DropDown
        GraphicDropDownLabel     matlab.ui.control.Label
        FrequencyMHzSlider       matlab.ui.control.Slider
        FrequencyMHzSliderLabel  matlab.ui.control.Label
        RightPanel               matlab.ui.container.Panel
        UIAxes                   matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    properties (Access = private)
        Pax matlab.graphics.axis.PolarAxes % Description
    end  
    
    methods (Access = private)
        
        function [vx, vy, E, E0, E90, theta] = calculateFields(app, currentSlider) % Calculation function
            a = (0.201 * currentSlider) / 300; 
            b = (0.012 * currentSlider) / 300;

            [theta, phi] = meshgrid(0:0.5:360, 0:0.5:360);
            theta = deg2rad(theta);
            phi = deg2rad(phi);

            vx = a * sin(theta) .* cos(phi);
            vy = b * sin(theta) .* sin(phi);
            
            E = abs((1 + cos(theta)) / 2 .* sinc(vx) .* sinc(vy));
            E0 = abs((1 + cos(theta))/2 .*sinc(a*sin(theta)));
            E90 = abs((1 + cos(theta))/2 .*sinc(b*sin(theta)));

        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.Pax = polaraxes(app.RightPanel); % Defining the object on the right panel           
            app.Pax.Visible = false; % Polar Axes initially invisible         

        end

        % Value changing function: FrequencyMHzSlider
        function FrequencyMHzSliderValueChanging(app, event)
            global currentSlider;            
            currentSlider = event.Value;
            app.EditField.Value = currentSlider;


            selectedOp = app.GraphicDropDown.Value;
            GraphicDropDownValueChanged(app, struct('Value', selectedOp));
            
        end

        % Value changed function: GraphicDropDown
        function GraphicDropDownValueChanged(app, event)
            selectedOp = app.GraphicDropDown.Value;

            global currentSlider;
            currentSlider = app.FrequencyMHzSlider.Value;          
            [vx, vy, E, E0, E90, theta] = calculateFields(app, currentSlider);
                                                                
            switch selectedOp
                case 'Radiation Pattern'                    
                    cla(app.UIAxes);
                    cla(app.Pax);
                    app.UIAxes.Visible = true;
                    app.Pax.Visible = false;

                    cb = findall(app.UIFigure, 'Type', 'ColorBar'); % Removing the colorbar bug
                    delete(cb);

                    surfl(app.UIAxes, vx(:,1:181), vy(:,1:181), E(:,1:181));
                    xlabel(app.UIAxes, 'vx');
                    ylabel(app.UIAxes, 'vy');
                    zlabel(app.UIAxes, 'Field Amplitude (normalized)');
                    title(app.UIAxes, 'Figure 1.0: Radiation Pattern to a Slot Antenna.');
                    shading(app.UIAxes, 'interp');
                    colormap(app.UIAxes, gray);                    
                    
                case 'Contour Diagram'                   
                    cla(app.UIAxes);
                    cla(app.Pax);              
                    app.UIAxes.Visible = true;
                    app.Pax.Visible = false;
                    view(app.UIAxes, 2);
                    contour(app.UIAxes, vx(:,1:181), vy(:,1:181), E(:,1:181), 10);
                    xlabel(app.UIAxes, 'vx');
                    ylabel(app.UIAxes, 'vy');
                    title(app.UIAxes, 'Figure 1.1: Contour Diagram of Radiation Pattern.');
                    colorbar(app.UIAxes);
                    grid(app.UIAxes, 'on');               

                case 'Polar Diagram - Plan xz'
                    cla(app.UIAxes);
                    cla(app.Pax);
                    app.UIAxes.Visible = false;
                    app.Pax.Visible = true;
                    
                    cb = findall(app.UIFigure, 'Type', 'ColorBar'); % Removing the colorbar bug
                    delete(cb);

                    polarplot(app.Pax, theta(1,:),E0(1,:),'r', 'LineWidth', 1.5);
                    title(app.Pax, 'Figure 2.0: Radiation Pattern Polar Diagram - Plan xz.');
                    app.Pax.ThetaAxis.Label.String = 'Angle \theta (degrees)';
                    app.Pax.RAxis.Label.String = 'Field Amplitude (normalized)';
                    app.Pax.RAxis.Label.HorizontalAlignment = 'right';
                    app.Pax.RAxis.Label.VerticalAlignment = 'top';               
                                                    
                case 'Polar Diagram - Plan yz'
                    cla(app.UIAxes);
                    cla(app.Pax);
                    app.UIAxes.Visible = false;
                    app.Pax.Visible = true;                    

                    cb = findall(app.UIFigure, 'Type', 'ColorBar'); % Removing the colorbar bug
                    delete(cb);

                    polarplot(app.Pax, theta(1,:),E90(1,:),'b', 'LineWidth', 1.5);
                    title(app.Pax, 'Figure 2.1: Radiation Pattern Polar Diagram - Plan yz.');
                    app.Pax.ThetaAxis.Label.String = 'Angle \theta (degrees)';
                    app.Pax.RAxis.Label.String = 'Field Amplitude (normalized)';
                    app.Pax.RAxis.Label.HorizontalAlignment = 'right';
                    app.Pax.RAxis.Label.VerticalAlignment = 'top';                    

                case 'Radiation Pattern - Plan xz, phi = 0°'
                    cla(app.UIAxes);
                    cla(app.Pax);
                    app.UIAxes.Visible = true;
                    app.Pax.Visible = false;

                    cb = findall(app.UIFigure, 'Type', 'ColorBar'); % Removing the colorbar bug
                    delete(cb);

                    view(app.UIAxes, 2);
                    plot(app.UIAxes,((180/pi)*theta(1,(1:181))), E0(1,(1:181)),'r');
                    xlabel(app.UIAxes, '\theta (degrees)');
                    ylabel(app.UIAxes, 'Field Amplitude (normalized)');
                    title(app.UIAxes, 'Figure 3.0: Plan xz - Radiation Pattern, \phi = 0°.');
                    shading(app.UIAxes, 'interp');
                    colormap(app.UIAxes, gray);

                case 'Radiation Pattern - Plan yz, phi = 90°'
                    cla(app.UIAxes);
                    cla(app.Pax);
                    app.UIAxes.Visible = true;
                    app.Pax.Visible = false;

                    cb = findall(app.UIFigure, 'Type', 'ColorBar'); % Removing the colorbar bug
                    delete(cb);

                    view(app.UIAxes, 2);                    
                    plot(app.UIAxes, ((180/pi)*theta(1,(1:181))), E90(1,(1:181)),'b');
                    xlabel(app.UIAxes, '\theta (degrees)');
                    ylabel(app.UIAxes, 'Field Amplitude (normalized)');
                    title(app.UIAxes, 'Figure 3.1: Plan yz - Radiation Pattern, \phi = 90°.');
                    shading(app.UIAxes, 'interp');
                    colormap(app.UIAxes, gray);                    
            
            end
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {641, 641};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {421, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1241 641];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {421, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create FrequencyMHzSliderLabel
            app.FrequencyMHzSliderLabel = uilabel(app.LeftPanel);
            app.FrequencyMHzSliderLabel.HorizontalAlignment = 'right';
            app.FrequencyMHzSliderLabel.Position = [19 431 98 22];
            app.FrequencyMHzSliderLabel.Text = 'Frequency (MHz)';

            % Create FrequencyMHzSlider
            app.FrequencyMHzSlider = uislider(app.LeftPanel);
            app.FrequencyMHzSlider.Limits = [500 5000];
            app.FrequencyMHzSlider.ValueChangingFcn = createCallbackFcn(app, @FrequencyMHzSliderValueChanging, true);
            app.FrequencyMHzSlider.Position = [139 440 232 3];
            app.FrequencyMHzSlider.Value = 500;

            % Create GraphicDropDownLabel
            app.GraphicDropDownLabel = uilabel(app.LeftPanel);
            app.GraphicDropDownLabel.HorizontalAlignment = 'right';
            app.GraphicDropDownLabel.Position = [35 335 47 22];
            app.GraphicDropDownLabel.Text = 'Graphic';

            % Create GraphicDropDown
            app.GraphicDropDown = uidropdown(app.LeftPanel);
            app.GraphicDropDown.Items = {'Radiation Pattern', 'Contour Diagram', 'Polar Diagram - Plan xz', 'Polar Diagram - Plan yz', 'Radiation Pattern - Plan xz, phi = 0°', 'Radiation Pattern - Plan yz, phi = 90°'};
            app.GraphicDropDown.ValueChangedFcn = createCallbackFcn(app, @GraphicDropDownValueChanged, true);
            app.GraphicDropDown.Position = [97 335 270 22];
            app.GraphicDropDown.Value = 'Radiation Pattern';

            % Create EditField
            app.EditField = uieditfield(app.LeftPanel, 'numeric');
            app.EditField.Position = [46 410 50 22];
            app.EditField.Value = 500;

            % Create AuthorJooPauloMariuzzoBScinElectronicsEngineeringLinkedInwwwlinkedincominjpmariuzzoLabel
            app.AuthorJooPauloMariuzzoBScinElectronicsEngineeringLinkedInwwwlinkedincominjpmariuzzoLabel = uilabel(app.LeftPanel);
            app.AuthorJooPauloMariuzzoBScinElectronicsEngineeringLinkedInwwwlinkedincominjpmariuzzoLabel.Position = [47 126 298 44];
            app.AuthorJooPauloMariuzzoBScinElectronicsEngineeringLinkedInwwwlinkedincominjpmariuzzoLabel.Text = {'Author:'; 'João Paulo Mariuzzo, B.Sc. in Electronics Engineering'; 'LinkedIn: www.linkedin.com/in/jpmariuzzo/'};

            % Create AboutThissimulationispartofaScientificResearchProjectdevelopedin2013SlotAntennaStudyandCharacterizationComputerModelingandSimulationonMATLABapplyingatwodimensionalFouriertransformtotheradiatedfieldsoverasingleslottedmetallicsurfaceLabel
            app.AboutThissimulationispartofaScientificResearchProjectdevelopedin2013SlotAntennaStudyandCharacterizationComputerModelingandSimulationonMATLABapplyingatwodimensionalFouriertransformtotheradiatedfieldsoverasingleslottedmetallicsurfaceLabel = uilabel(app.LeftPanel);
            app.AboutThissimulationispartofaScientificResearchProjectdevelopedin2013SlotAntennaStudyandCharacterizationComputerModelingandSimulationonMATLABapplyingatwodimensionalFouriertransformtotheradiatedfieldsoverasingleslottedmetallicsurfaceLabel.Position = [19 504 396 105];
            app.AboutThissimulationispartofaScientificResearchProjectdevelopedin2013SlotAntennaStudyandCharacterizationComputerModelingandSimulationonMATLABapplyingatwodimensionalFouriertransformtotheradiatedfieldsoverasingleslottedmetallicsurfaceLabel.Text = {'About:'; 'This simulation is part of a Scientific Research Project developed'; 'in 2013.'; 'Slot Antenna Study and Characterization (Computer Modeling and '; 'Simulation on MATLAB, applying a two-dimensional Fourier transform '; 'to the radiated fields over a single slotted metallic surface).'};

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.ZGrid = 'on';
            app.UIAxes.Position = [38 19 773 576];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = slot_antenna_simulation_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

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
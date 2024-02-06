function hToolbar = addToolbar(hFig)

%% toolbar          
hToolbar = uitoolbar ('parent', hFig);

% standard
uitoolfactory(hToolbar,'Exploration.ZoomIn');
uitoolfactory(hToolbar,'Exploration.ZoomOut');
uitoolfactory(hToolbar,'Exploration.Pan');                
uitoolfactory(hToolbar,'Exploration.DataCursor');                
uitoolfactory(hToolbar, 'Exploration.Rotate');

tb_distance = uipushtool(hToolbar, 'TooltipString', 'Measure Distance', 'ClickedCallback', @hToolbarItem_Distance_Callback);
[img,map] = imread('tool_double_arrow.gif');
icon = ind2rgb(img,map);
tb_distance.CData = icon;

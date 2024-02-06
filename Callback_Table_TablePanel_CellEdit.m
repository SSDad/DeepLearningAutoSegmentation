function Callback_Table_TablePanel_CellEdit(src, evnt)

gFig = ancestor(src, 'Figure');
gData = guidata(gFig);

idx_new = evnt.Indices(1);

T = gData.Panel.STTable.hTable.Data;
idx_old = find(cellfun(@(x) all(x), T.O));

if ~isempty(idx_old)
    if isequal(idx_old, idx_new)
        gData.Panel.STTable.hTable.Data.O{idx_new} = true;
    else
        idx = idx_old(find(idx_old ~= idx_new));
        gData.Panel.STTable.hTable.Data.O{idx} = false;
    end
else
    idx_new = [];
end

if ~isempty(idx_new)
    updateContour(gData, idx_new);
end

% gData.Panel.STTable.hTable.Data = T;
% T.O{idx} = false;


% gData.OT.Data{idx_new, 2} = true;

% 
% gData.OT.Data{} = OData;
% 
% drawnow

% if ~isempty(idcs)
%     oldIdx = selected.idxSS;
%     newIdx = idcs(1);
%     selected.idxSS = newIdx;
%     src.Data{newIdx, 1} = true;
% %     if idcs(1) == selected.idxSS
% %         set(data_main.hPlotObj.SS.z, 'visible', 'off')
% %         set(data_main.hPlotObj.SS.x, 'visible', 'off')
% %         set(data_main.hPlotObj.SS.y, 'visible', 'off')
% %     else
% 
%     if newIdx ~= oldIdx
%         src.Data{oldIdx, 1} = false;
% %         selected.idxSS = idcs(1);
% %         src.Data{selected.idxSS, 1} = true; 
% 
%         data_main.selected = selected;
%         guidata(hFig_main, data_main);
% 
%         set(data_main.hPlotObj.SS.z, 'visible', 'on')
%         set(data_main.hPlotObj.SS.x, 'visible', 'on')
%         set(data_main.hPlotObj.SS.y, 'visible', 'on')
% 
%         updateSS(hFig_main, '1', selected.iSlice.z);
%         updateSS(hFig_main, '2', selected.iSlice.x);
%         updateSS(hFig_main, '3', selected.iSlice.y);
% 
%         if strcmp(data_main.hMenuItem.AnalysisZ.Checked, 'on')
%             data_main = guidata(hFig_main);
%             updatePDF_zTime(data_main);
%             updateStat_zTime2d(data_main);
%             initializeStat_zTime3d(data_main);
%             updateStat_zTime3d(data_main);
%         elseif strcmp(data_main.hMenuItem.AnalysisZ_CBCT.Checked, 'on')
%             updatePDF_CBCT_zTime(data_main);            
%         end
% 
%         set(data_main.hMenuItem.jhZ, 'Checked', 'off')
%         set(data_main.hMenuItem.miZ, 'Checked', 'off')
%         for iSub = 1:4
%             set(data_main.hPlotObj.jhSub(iSub), 'CData', []); 
%         end
%         set(data_main.hPlotObj.Stat_zTime2d(7), 'xdata', [], 'ydata', [])
%         set(data_main.hPlotObj.StatSub_zTime2d(7), 'xdata', [], 'ydata', [])
% 
%     end
% end
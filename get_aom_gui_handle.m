function handle = get_aom_gui_handle()
% Return handle to aom gui. Will sort through open figures.

figHandles = get(groot, 'Children');

fnum = 0;
for f = 1:length(figHandles)
   
    if length(figHandles(f).Name) > 5
        if strcmpi(figHandles(f).Name(1:5), 'aoslo')
            fnum = f;
        end
    end
end

if fnum ~= 0
    handle = guihandles(figHandles(fnum));
else
    error('AOMcontrol gui window was not found. Is it open?')
end

end

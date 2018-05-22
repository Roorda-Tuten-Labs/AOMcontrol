function handle = get_aom_gui_handle()
% Return handle to AOMcontrol gui. 
%
% USAGE
% handle = get_aom_gui_handle()
%
% OUTPUT
% This routine will sort through open figures to find AOMcontrol and return
% a handle to it.

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

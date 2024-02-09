local source_menu
local source_list = {}
local refresh_timer = nil
local refresh_interval = 30000

local function update_source_menu()
    obs.obs_property_list_clear(source_menu)
    local scene = obs.obs_frontend_get_current_scene()
    if scene ~= nil then
        local sources = obs.obs_scene_enum_items(scene)
        if sources ~= nil then
            for _, source in ipairs(sources) do
                local source_id = obs.obs_source_get_unversioned_id(source)
                local source_name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(source_menu, source_name, source_name)
                source_list[source_name] = source_id
            end
            obs.sceneitem_list_release(sources)
        end
        obs.obs_scene_release(scene)
    end
end

local function refresh_selected_source()
    local selected_source = obs.obs_property_list_get_string(source_menu)
    if selected_source ~= nil and selected_source ~= "" then
        local source_id = source_list[selected_source]
        if source_id ~= nil then
            local source = obs.obs_get_source_by_name(selected_source)
            if source ~= nil then
                obs.obs_source_update(source)
                obs.obs_source_release(source)
            end
        end
    end
end

local function start_refresh_timer()
    stop_refresh_timer()
    refresh_timer = obs.timer_add(refresh_selected_source, refresh_interval)
end

local function stop_refresh_timer()
    if refresh_timer ~= nil then
        obs.timer_remove(refresh_timer)
        refresh_timer = nil
    end
end

function script_load(settings)
    source_menu = obs.obs_properties_add_list(settings, "source_menu", "Source à rafraîchir", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    update_source_menu()
    start_refresh_timer()
end

function script_update(settings)
    update_source_menu()
end

function script_description()
    return "Ce script permet de rafraîchir une source sélectionnée dans OBS Studio avec un intervalle de 30 secondes."
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_button(props, "button", "Rafraîchir la source sélectionnée", refresh_selected_source)
    obs.obs_properties_add_int(props, "refresh_interval", "Intervalle de rafraîchissement (ms)", 1000, 60000, 1000)
    return props
end

function script_save(settings)
    refresh_interval = obs.obs_data_get_int(settings, "refresh_interval")
    stop_refresh_timer()
    start_refresh_timer()
end

local common = {}

function common.is_completed(id)
	return get_int_value(id.."_completed")
end

function common.set_completed(id)
	print('Marking '..id..' as completed')
	set_int_value(id.."_completed", 1)
	send_mission_complete_analytics(id)
end

function common.set_progress(id, value)
	set_int_value(id.."_value", value)
end

function common.get_progress(id)
	return get_int_value(id.."_value")
end

function common.set_max_progress(id, value)
	set_int_value(id.."_max_value", value)
end

function common.get_max_progress(id)
	return get_int_value(id.."_max_value")
end

function common.set_mission_description(id, value)
	set_string_value(id.."_description", value)
end

function common.get_mission_description(id)
	return get_string_value(id.."_description")
end

return common
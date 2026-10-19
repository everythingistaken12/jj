Log("TurtleSleigh Lua script started")

function MakeTurtleSleigh()
	local skin = "TurtleSleigh"
	local TurtleSleigh = MakeGingerbreadSleigh(skin)

	local SoundLand = "sleigh_turtle_land"

	TurtleSleigh.Sounds = {}
	TurtleSleigh.Sounds.FootStep = nil
	TurtleSleigh.Sounds.Sliding = Sound.new("sleigh_turtle_slide_lp", true, 1.0)
	TurtleSleigh.Sounds.Flying = Sound.new("sleigh_turtle_fly_lp", true, 1.0)
	TurtleSleigh.Sounds.AmbientLoop = nil --Sound.new("sleigh_gingerbread_fly_lp", true, 1.0)
	TurtleSleigh.Sounds.AfterburnerLoop = Sound.new("sleigh_turtle_afterburner_lp", true, 1.0)
	TurtleSleigh.Sounds.SoundLand = Sound.new("sleigh_turtle_land", false, 1.0)
	TurtleSleigh.Sounds.Destroy = Sound.new("sleigh_turtle_explode", false, 1.0)

	TurtleSleigh.Sounds.FootStepCaveLeft = { "sleigh_turtle_step_left_1", "sleigh_turtle_step_left_2", "sleigh_turtle_step_left_3", "sleigh_turtle_step_left_4" }
	TurtleSleigh.Sounds.FootStepCaveRight = { "sleigh_turtle_step_right_1", "sleigh_turtle_step_right_2", "sleigh_turtle_step_right_3", "sleigh_turtle_step_right_4" }

	TurtleSleigh.Sounds.FootStepLeft = {
		"sleigh_turtle_step_left_1",
		"sleigh_turtle_step_left_2",
		"sleigh_turtle_step_left_3",
		"sleigh_turtle_step_left_4"
	}

	TurtleSleigh.Sounds.FootStepRight = {
		"sleigh_turtle_step_right_1",
		"sleigh_turtle_step_right_2",
		"sleigh_turtle_step_right_3",
		"sleigh_turtle_step_right_4"
	}

	local baseOnInit = TurtleSleigh.OnInit
	function TurtleSleigh:OnInit(info)
		baseOnInit(self, info)
		SetSleighFlameEnabled(false)
		DisableSledSnow()
	end

	local baseOnDestroy = TurtleSleigh.OnDestroy
	function TurtleSleigh:OnDestroy()
		self.Sounds.Destroy:Play()
		baseOnDestroy(self)
	end

	return TurtleSleigh
end

RegisterVehicle("TurtleSleigh", "Sled", MakeTurtleSleigh())
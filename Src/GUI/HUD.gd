extends Control


func _ready():
	call_deferred("set_skill_icons")

const skill_to_container = {
	Payloads.PayloadType.Dash: preload("res://Src/GUI/DashSkillContainer.tscn"),
	Payloads.PayloadType.Shield: preload("res://Src/GUI/ShieldSkillContainer.tscn"),
	Payloads.PayloadType.Laser: preload("res://Src/GUI/LaserSkillContainer.tscn"),
	Payloads.PayloadType.HomingMissiles: preload("res://Src/GUI/MissilSkillContainer.tscn"),
}

func set_health(h, max_h):
	var h_percent = (float(h)/float(max_h))*100 
	$HBoxContainer/Label.text ="%d%%" % h_percent


func set_boss_health(boss_name, current, max_health):
	$BossHealthBar.show()
	$BossHealthBar/TextureProgress.value = current
	$BossHealthBar/TextureProgress.max_value = max_health
	$BossHealthBar/Label.text = boss_name

func hide_boss():
	$BossHealthBar.hide()

func set_time():
	$Timer/Label.text = GameData.get_formatted_time()

func _process(_delta):
	
	set_time()


func activate_skill(payload):
	for c in $Skills.get_children():
		if c.payload == payload and c.ready:
			c.set_ready(false)

func set_skill_icons():
	for c in $Skills.get_children():
		$Skills.remove_child(c)
		c.queue_free()
	for k in GameData.actions_mapping:
		var payload = GameData.actions_mapping[k]
		var icon = skill_to_container[payload].instance()
		print(icon)
		$Skills.add_child(icon)

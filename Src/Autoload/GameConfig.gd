extends Node


var camera_shake = true
var enemy_fast_bullet_speed = 1.0


enum BulletType {
	Fast,
	Slow,
	Medium,
	Player,
	Rocket
}

func get_bullet_speed(type) -> float:
	match type:
		BulletType.Fast:
			return 3.0
		BulletType.Medium:
			return 1.5
		BulletType.Slow:
			return 0.5
		BulletType.Rocket:
			return 0.5
		BulletType.Player:
			return 10.0
	return 1.0

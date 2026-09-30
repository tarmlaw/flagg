extends Node3D


var goblin = preload("res://classes/goblin/goblin.tscn")
var players: Array[BaseClass]


func _ready() -> void:
	Net.host_created.connect(on_host_created)


func on_host_created() -> void:
	spawn_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(peer_id: int):
	var new_player = goblin.instantiate() as BaseClass
	new_player.name = str(peer_id)
	add_child(new_player)
	init_player(new_player)

func init_player(player: BaseClass):
	player.global_position = Vector3(0, 0, 0)
	for p in players:
		player.add_collision_exception_with(p)
	players.append(player)

func _on_host_pressed() -> void:
	Net.host_lobby()

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is BaseClass:
		init_player(node)

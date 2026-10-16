extends Node

var mp_spawner: MultiplayerSpawner
var auto_spawn_list: Array[String]

var spawning: bool = false

# L: local, R: remote
# when L walks onto an item
	# L despawns old item, synced to R
	# L tells LR Game to spawn new item
		# LR Game updates spawner to sync tree
		# item data is synced by L Game, synced to R on spawn
		# item is spawned by L Game, synced to R
	# once item item is spawned
		# LR item syncs position, rotation... through sync

@rpc("any_peer", "call_local", "unreliable")
func spawn_item(item_file_data: String, item_data: Dictionary, destination: NodePath, player_path: NodePath, item_pos: Vector3 = Vector3.ZERO, item_rot: Vector3 = Vector3.ZERO, throw_item: bool = false, throw_force: Vector3 = Vector3.ZERO):
	if !mp_spawner: return
	if get_tree().current_scene is not Map: return
	
	await !spawning
	spawning = true
	
	# get auto spawn list
	auto_spawn_list.clear()
	for i in mp_spawner.get_spawnable_scene_count() - 1:
		auto_spawn_list.append(mp_spawner.get_spawnable_scene(i))
	if !auto_spawn_list.has(item_file_data): mp_spawner.add_spawnable_scene(item_file_data)
	
	# destination
	var old_spawn_path = mp_spawner.spawn_path
	mp_spawner.spawn_path = destination
	
	# spawn
	var item: BaseItem
	item = load(item_file_data).instantiate() as BaseItem
	if is_multiplayer_authority():
		item.i_data = item_data
		item.name = item.item_name
		if get_node_or_null(player_path) != null: item.item_holder = get_node_or_null(player_path)
		item.position = item_pos
		item.rotation = item_rot
		get_tree().current_scene.get_node(destination).add_child(item, true)
	print_rich("[color=blue][GAME][/color] spawned %s" % item.item_name)
	
	if get_node_or_null(player_path) != null: get_node_or_null(player_path).item = item
	mp_spawner.spawn_path = old_spawn_path
	
	## throw
	#if throw_item:
		#item.throw(throw_force)

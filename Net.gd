extends Node

var lobby_id: int = 0
var lobby_invite_id: int = 0
var lobby_type = Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
var max_members: int = 8
var lobby_members: Array
var peer: SteamMultiplayerPeer

const packet_read_limit: int = 32

signal host_created


func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_join_requested)
	
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	Steam.p2p_session_connect_fail.connect(_on_p2p_session_connect_fail)
	check_command_line()

func _process(delta: float) -> void:
	Steam.run_callbacks()
	
	if lobby_id > 0:
		read_packets()

#region LOBBY
func host_lobby():
	Steam.createLobby(lobby_type, max_members)

func _on_lobby_created(connect: int, id: int) -> void:
	if connect == Steam.RESULT_OK:
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()
		
		lobby_id = id

func _on_lobby_joined(id: int, permissions: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if Steam.getLobbyOwner(id) == Steam.getSteamID(): return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(id))
		multiplayer.multiplayer_peer = peer
		lobby_id = id
		
		update_lobby_members()
		handshake()

func _on_join_requested(id: int, steam_id: int) -> void:
	var friend_user_name: String = Steam.getFriendPersonaName(steam_id)
	print_rich("[color=green][NET][/color] joining lobby with %s" % friend_user_name)
	Steam.joinLobby(id)
	lobby_id = id

func update_lobby_members():
	lobby_members.clear()
	var amount: int = Steam.getNumLobbyMembers(lobby_id)
	
	for member in range(0, amount):
		var steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, member)
		var steam_name: String = Steam.getFriendPersonaName(steam_id)
		
		lobby_members.append({"user_id": steam_id, "user_name": steam_name})

func check_command_line():
	var cmdline_args: Array = OS.get_cmdline_args()
	if cmdline_args.size() == 0: return
	if cmdline_args[0] != "+connect_lobby": return
	if int(cmdline_args[1]) > 0:
		lobby_invite_id = lobby_id
		get_tree().change_scene_to_file("res://lobby_list.tscn")
		#Steam.joinLobby(int(cmdline_args[1]))
#endregion

#region PACKETS
func handshake():
	send_packet(0, {"message": "handshake", "user_id": Global.steam_id, "user_name": Global.steam_name})

func read_packets(read_count: int = 0):
	if read_count >= packet_read_limit: return
	
	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_packet()
		read_packets(read_count + 1)

func read_packet():
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	
	if packet_size > 0:
		var packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		
		if packet.is_empty() or packet == null:
			print("WARNING: read an empty packet with non-zero size!")
		
		var packet_sender: int = packet["remote_steam_id"]
		
		var packet_code: PackedByteArray = packet["data"]
		var r_data: Dictionary = bytes_to_var(packet_code.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
		
		print("Packet: %s" % r_data)
		
		# actually dealing with the data
		if r_data.has("message"):
			match r_data["message"]:
				"handshake":
					print_rich("[color=green][NET][/color] ", r_data["user_name"], " joined.")
					update_lobby_members()
				"kick":
					if lobby_id > 0:
						get_tree().current_scene.kick_player(r_data["user_id"])
				"promote":
					if lobby_id > 0:
						get_tree().current_scene.promote_player(r_data["user_id"])
				#"update_avatar":
					#if get_tree().current_scene is Lobby:
						## cycle through all player scenes in the lobby until we find one that matches the user id
						#var member_to_update: PlayerScene = null
						#for i in get_tree().current_scene.players_v_box.get_children():
							#print("1 %s" % i)
							#if i is PlayerScene:
								#print("2 %s" % i.steam_id, " ", r_data["id"])
								#if i.steam_id == r_data["id"]: 
									#member_to_update = i
						#
						#if member_to_update:
							#get_tree().current_scene.update_lobby_member_avatar(member_to_update, r_data["id"], r_data["new_avatar"])
						#
						##print("AAAAAAA %s" % r_data["lobby_member"].object_id)
						##if r_data["lobby_member"] is EncodedObjectAsID:
							##var new_lobby_member = instance_from_id(r_data["lobby_member"].object_id)
							##get_tree().current_scene.update_lobby_member_avatar(new_lobby_member, r_data["id"], r_data["new_avatar"])
						##elif r_data["lobby_member"] is PlayerScene:
							##get_tree().current_scene.update_lobby_member_avatar(r_data["lobby_member"], r_data["id"], r_data["new_avatar"])
						##else:
							##print("couldn't get the lobby member :(")
				
				"startgame":
					Global.start_game(r_data["map"])

func send_packet(target: int, packet_data: Dictionary):
	var send_type: int = Steam.P2P_SEND_RELIABLE
	var channel: int = 0
	
	print("sent packet: %s" % packet_data)
	
	var data: PackedByteArray
	var c_data: PackedByteArray = var_to_bytes(packet_data).compress(FileAccess.COMPRESSION_GZIP)
	data.append_array(c_data)
	
	if target == 0:
		if lobby_members.size() > 1:
			for member in lobby_members:
				if member["user_id"] != Global.steam_id:
					Steam.sendP2PPacket(member["user_id"], data, send_type, channel)
	else: Steam.sendP2PPacket(target, data, send_type, channel)

func _on_p2p_session_request(remote_id: int) -> void:
	var requester: String = Steam.getFriendPersonaName(remote_id)
	print("%s is requesting a P2P session" % requester)
	Steam.acceptP2PSessionWithUser(remote_id)
	handshake()

func _on_p2p_session_connect_fail(steam_id: int, session_error: int) -> void:
	if session_error == 0: print("WARNING: Session failure with %s: no error given" % steam_id)
	elif session_error == 1: print("WARNING: Session failure with %s: target user not running the same game" % steam_id)
	elif session_error == 2: print("WARNING: Session failure with %s: local user doesn't own app / game" % steam_id)
	elif session_error == 3: print("WARNING: Session failure with %s: target user isn't connected to Steam" % steam_id)
	elif session_error == 4: print("WARNING: Session failure with %s: connection timed out" % steam_id)
	elif session_error == 5: print("WARNING: Session failure with %s: unused" % steam_id)
	else: print("WARNING: Session failure with %s: unknown error %s" % [steam_id, session_error])
#endregion PACKETS

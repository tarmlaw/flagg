extends Node


var lobby_type = Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
var max_members: int = 8
var peer: SteamMultiplayerPeer

signal host_created


func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.join_requested.connect(on_join_requested)

func _process(delta: float) -> void:
	Steam.run_callbacks()

func host_lobby():
	Steam.createLobby(lobby_type, max_members)

func on_lobby_created(connect: int, id: int) -> void:
	if connect == Steam.RESULT_OK:
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()

func on_lobby_joined(id: int, permissions: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if Steam.getLobbyOwner(id) == Steam.getSteamID(): return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(id))
		multiplayer.multiplayer_peer = peer

func on_join_requested(id: int, steam_id: int) -> void:
	Steam.joinLobby(id)

func create_host():
	pass

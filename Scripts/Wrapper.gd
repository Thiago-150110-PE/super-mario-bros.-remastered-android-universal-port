extends Node

@onready var game_viewport = $CenterContainer/SubViewportContainer/SubViewport
@onready var center_container = $CenterContainer

var thread : Thread

func _ready() -> void:
	await get_tree().process_frame
	await change_scene_to("res://Scenes/Levels/Disclaimer.tscn")

func change_scene_to(path) -> void:
	for child in game_viewport.get_children():
		if child.name != "Global":
			child.queue_free()
			await child.tree_exited
	
	# Carga en segundo plano: en vez de load(path) (que bloquea todo
	# el hilo principal hasta terminar), pedimos la carga en un hilo
	# aparte y vamos revisando el progreso una vez por frame, así el
	# juego no se congela mientras el nivel se lee de disco.
	var err := ResourceLoader.load_threaded_request(path)
	if err != OK:
		push_error("No se pudo iniciar la carga en segundo plano de: " + path)
		# Fallback: cargar de forma síncrona como antes, para no romper el juego
		var fallback_scene = load(path).instantiate()
		game_viewport.add_child(fallback_scene)
		await fallback_scene.ready
		return

	var status := ResourceLoader.load_threaded_get_status(path)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(path)

	if status != ResourceLoader.THREAD_LOAD_LOADED:
		push_error("Fallo al cargar en segundo plano: " + path)
		return

	var new_scene = ResourceLoader.load_threaded_get(path).instantiate()
	game_viewport.add_child(new_scene)
	
	await new_scene.ready

func get_game_viewport() -> SubViewport:
	return game_viewport

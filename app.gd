extends CanvasGroup

@export var configWindow : Panel
@export var pickerPanel : Panel

# File path for save data
const SAVE_FILE_PATH = "user://savegame.save"

# Called when the node enters the scene tree for the first time
func _ready():
	# Optional: Auto-load on startup
	# loadData()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta):
	pass

func _on_exit_button_pressed():
	get_tree().quit()

# Save function for this node specifically (not currently used but kept for compatibility)
func save():
	var save_classList = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path()
	}
	return save_classList

# Main save function that saves all nodes in the Persist group
func saveData():
	print("Starting save process...")
	
	# Create or open the save file
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		print("Error: Could not open save file for writing")
		return
	
	# Get all nodes in the Persist group
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	var saved_count = 0
	
	for node in save_nodes:
		# Check if the node has a save function
		if !node.has_method("save"):
			print("Persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		# Call the node's save function
		var node_data = node.call("save")
		
		# Add node type information for easier loading
		node_data["node_type"] = node.get_class()
		
		# Convert to JSON and save
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)
		saved_count += 1
		
		print("Saved node: %s" % node.name)
	
	# Close the file
	save_file.close()
	print("Save complete! Saved %d nodes." % saved_count)

# Main load function that loads all saved data
func loadData(custom_path = ""):
	print("Starting load process...")
	
	# Use custom path if provided, otherwise use default
	var file_path = custom_path if custom_path != "" else SAVE_FILE_PATH
	
	# Check if save file exists
	if not FileAccess.file_exists(file_path):
		print("No save file found at: %s" % file_path)
		return
	
	# Open the save file
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	if save_file == null:
		print("Error: Could not open save file for reading")
		return
	
	var loaded_count = 0
	
	# Read each line (each saved node)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		
		# Skip empty lines
		if json_string.is_empty():
			continue
		
		# Parse the JSON
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result != OK:
			print("Error parsing JSON on line %d: %s" % [
				save_file.get_position(), 
				json.get_error_message()
			])
			continue
		
		# Get the parsed data
		var node_data = json.data
		
		# Find the node by name and parent path
		if node_data.has("name") and node_data.has("parent"):
			var parent_node = get_node_or_null(node_data.parent)
			if parent_node:
				var target_node = parent_node.get_node_or_null(node_data.name)
				
				if target_node and target_node.has_method("load_data"):
					# Load the data into the node
					target_node.call("load_data", node_data)
					loaded_count += 1
					print("Loaded data for node: %s" % target_node.name)
				else:
					print("Warning: Could not find node or load_data method for: %s" % node_data.name)
			else:
				print("Warning: Could not find parent node: %s" % node_data.parent)
	
	# Close the file
	save_file.close()
	print("Load complete! Loaded data for %d nodes." % loaded_count)

# Helper function to get list of saved classes
func get_saved_classes():
	var saved_classes = []  # Array of String values
	var dir = DirAccess.open("user://")
	
	if dir:
		# In Godot 4.x, list_dir_begin() might need to be called without capturing the return
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.begins_with("class_") and file_name.ends_with(".save"):
				# Extract the class name from the file name
				var course_name = file_name.trim_prefix("class_").trim_suffix(".save")
				course_name = course_name.replace("_", " ")
				saved_classes.append(course_name)
			file_name = dir.get_next()
		
		# Important: Always call list_dir_end() when done
		dir.list_dir_end()
	else:
		print("Could not open user directory")
	
	return saved_classes

# Helper function to save a specific class list by name
func save_class_list(course_name):
	print("Saving class list: %s" % course_name)
	
	# Create a separate save file for this class
	var file_path = "user://class_%s.save" % course_name.to_lower().replace(" ", "_")
	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if save_file == null:
		print("Error: Could not create save file for class: %s" % course_name)
		return
	
	# Save only the StudentList nodes
	var student_lists = get_tree().get_nodes_in_group("Persist")
	for node in student_lists:
		if node is ItemList and node.has_method("save"):
			var node_data = node.call("save")
			node_data["class_name"] = course_name
			var json_string = JSON.stringify(node_data)
			save_file.store_line(json_string)
	
	save_file.close()
	print("Class list saved successfully!")

# Load a specific class list by name
func load_class_list(course_name):
	var file_path = "user://class_%s.save" % course_name.to_lower().replace(" ", "_")
	
	if not FileAccess.file_exists(file_path):
		print("No save file found for class: %s" % course_name)
		return
	
	# Clear current lists first
	var student_lists = get_tree().get_nodes_in_group("Persist")
	for node in student_lists:
		if node is ItemList and node.has_method("clear"):
			node.clear()
	
	# Now load the specific class data using the custom path
	loadData(file_path)

# UI callback functions
func _on_config_button_pressed():
	configWindow.show()
	pickerPanel.hide()

func _on_save_class_button_pressed():
	# You could show a dialog here to get the class name
	# For now, just save with default behavior
	saveData()
	
	# todo: Save as a named class
	# var course_name = "Spring 2025 - CS101"  # This should come from user input
	# save_class_list(course_name)


func _on_load_class_button_pressed() -> void:
	loadData()


func _on_class_name_edit_text_set() -> void:
	pass # Replace with function body.

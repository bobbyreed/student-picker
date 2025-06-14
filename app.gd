extends CanvasGroup

# Export variables for connecting nodes from the editor
@export var configWindow : Panel
@export var pickerPanel : Panel
@export var taskPromptPanel : PopupMenu

# Constants for file paths
const SAVE_FILE_PATH = "user://savegame.save"

# Variables for our popup dialog system
var current_course_name: String = ""
var save_dialog: AcceptDialog
var course_name_input: LineEdit
var load_dialog: AcceptDialog
var course_list: ItemList

# New variables for copy/delete functionality
var copy_button: Button
var delete_button: Button
var selected_course_index: int = -1
var confirm_delete_dialog: ConfirmationDialog
var copy_name_dialog: AcceptDialog
var copy_name_input: LineEdit

# Called when the node enters the scene tree for the first time
func _ready():
	setup_save_dialog()
	setup_load_dialog()
	setup_confirm_delete_dialog()
	setup_copy_name_dialog()
	print("StudentPicker application initialized successfully")

# Called every frame
func _process(delta):
	pass

# Creates the popup dialog for saving courses
func setup_save_dialog():
	# Create the main dialog container
	save_dialog = AcceptDialog.new()
	save_dialog.title = "Save Course List"
	save_dialog.size = Vector2(350, 120)
	
	# Create a vertical container for organization
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	# Add explanatory label
	var label = Label.new()
	label.text = "Enter a name for this course:"
	label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(label)
	
	# Create text input field
	course_name_input = LineEdit.new()
	course_name_input.placeholder_text = "e.g., Spring 2025 - Biology 101"
	course_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(course_name_input)
	
	# Add help text
	var help_label = Label.new()
	help_label.text = "Tip: Use descriptive names to easily find your courses later"
	help_label.add_theme_font_size_override("font_size", 10)
	help_label.modulate = Color.GRAY
	vbox.add_child(help_label)
	
	# Attach container to dialog
	save_dialog.add_child(vbox)
	
	# Connect signals
	save_dialog.confirmed.connect(_on_save_dialog_confirmed)
	course_name_input.text_submitted.connect(_on_course_name_submitted)
	
	# Add to scene tree
	add_child(save_dialog)
	
	print("Save dialog system initialized")

# Creates the popup dialog for loading courses
func setup_load_dialog():
	# Create the main dialog container with larger size to accommodate buttons
	load_dialog = AcceptDialog.new()
	load_dialog.title = "Load Course List"
	load_dialog.size = Vector2(450, 350)
	
	# Create a vertical container for organization
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	# Add explanatory label
	var label = Label.new()
	label.text = "Select a course to load, copy, or delete:"
	label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(label)
	
	# Create the course list widget
	course_list = ItemList.new()
	course_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	course_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(course_list)
	
	# Create horizontal container for action buttons
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 10)
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Create Copy button
	copy_button = Button.new()
	copy_button.text = "Copy Course"
	copy_button.custom_minimum_size = Vector2(100, 30)
	copy_button.disabled = true  # Start disabled until selection
	copy_button.pressed.connect(_on_copy_button_pressed)
	button_container.add_child(copy_button)
	
	# Create Delete button
	delete_button = Button.new()
	delete_button.text = "Delete Course"
	delete_button.custom_minimum_size = Vector2(100, 30)
	delete_button.disabled = true  # Start disabled until selection
	delete_button.modulate = Color(1.0, 0.8, 0.8)  # Slight red tint for delete
	delete_button.pressed.connect(_on_delete_button_pressed)
	button_container.add_child(delete_button)
	
	vbox.add_child(button_container)
	
	# Add helpful instruction text
	var help_label = Label.new()
	help_label.text = "Double-click to load, or select and use buttons above"
	help_label.add_theme_font_size_override("font_size", 10)
	help_label.modulate = Color.GRAY
	vbox.add_child(help_label)
	
	# Attach container to dialog
	load_dialog.add_child(vbox)
	
	# Connect signals for user interactions
	load_dialog.confirmed.connect(_on_load_dialog_confirmed)
	course_list.item_selected.connect(_on_course_selected)
	course_list.item_activated.connect(_on_course_activated)
	# Note: ItemList doesn't have a nothing_selected signal
	# We'll handle deselection through other means
	
	# Optional: Connect to empty_clicked if you want to detect clicks on empty space
	course_list.empty_clicked.connect(_on_course_list_empty_clicked)
	
	# Add to scene tree
	add_child(load_dialog)
	
	print("Load dialog system initialized with copy/delete functionality")

# Creates confirmation dialog for delete operations
func setup_confirm_delete_dialog():
	confirm_delete_dialog = ConfirmationDialog.new()
	confirm_delete_dialog.title = "Confirm Delete"
	confirm_delete_dialog.dialog_text = "Are you sure you want to delete this course?\nThis action cannot be undone."
	confirm_delete_dialog.size = Vector2(300, 150)
	
	# Connect the confirmation signal
	confirm_delete_dialog.confirmed.connect(_on_delete_confirmed)
	
	# Add to scene tree
	add_child(confirm_delete_dialog)
	
	print("Delete confirmation dialog initialized")

# Creates dialog for entering copy name
func setup_copy_name_dialog():
	copy_name_dialog = AcceptDialog.new()
	copy_name_dialog.title = "Copy Course"
	copy_name_dialog.size = Vector2(350, 120)
	
	# Create a vertical container
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	# Add label
	var label = Label.new()
	label.text = "Enter a name for the copied course:"
	label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(label)
	
	# Create text input
	copy_name_input = LineEdit.new()
	copy_name_input.placeholder_text = "e.g., Spring 2025 - Biology 101 (Copy)"
	copy_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(copy_name_input)
	
	# Add to dialog
	copy_name_dialog.add_child(vbox)
	
	# Connect signals
	copy_name_dialog.confirmed.connect(_on_copy_name_confirmed)
	copy_name_input.text_submitted.connect(_on_copy_name_submitted)
	
	# Add to scene tree
	add_child(copy_name_dialog)
	
	print("Copy name dialog initialized")

# New handler for Copy button
func _on_copy_button_pressed():
	if selected_course_index < 0 or selected_course_index >= course_list.item_count:
		print("No valid course selected for copying")
		return
	
	# Get the original course name
	var original_name = course_list.get_item_text(selected_course_index)
	
	# Pre-populate the copy dialog with a suggested name
	copy_name_input.text = original_name + " (Copy)"
	copy_name_input.select_all()  # Select all text for easy replacement
	
	# Show the copy name dialog
	copy_name_dialog.popup_centered()
	copy_name_input.grab_focus()

# New handler for Delete button
func _on_delete_button_pressed():
	if selected_course_index < 0 or selected_course_index >= course_list.item_count:
		print("No valid course selected for deletion")
		return
	
	# Get the course name for the confirmation message
	var course_name = course_list.get_item_text(selected_course_index)
	confirm_delete_dialog.dialog_text = "Are you sure you want to delete:\n\n\"" + course_name + "\"?\n\nThis action cannot be undone."
	
	# Show confirmation dialog
	confirm_delete_dialog.popup_centered()

# Handler for delete confirmation
func _on_delete_confirmed():
	if selected_course_index < 0 or selected_course_index >= course_list.item_count:
		return
	
	var course_name = course_list.get_item_text(selected_course_index)
	
	# Delete the course file
	if delete_course(course_name):
		print("Successfully deleted course: " + course_name)
		# Refresh the list to show the deletion
		refresh_course_list()
		# Reset selection
		selected_course_index = -1
		copy_button.disabled = true
		delete_button.disabled = true
	else:
		print("Failed to delete course: " + course_name)

# Handler for copy name confirmation
func _on_copy_name_confirmed():
	var new_name = copy_name_input.text.strip_edges()
	if new_name.is_empty():
		print("Copy name cannot be empty")
		return
	
	perform_course_copy(new_name)

func _on_copy_name_submitted(text: String):
	copy_name_dialog.hide()
	var new_name = text.strip_edges()
	if not new_name.is_empty():
		perform_course_copy(new_name)

# Performs the actual course copy operation
func perform_course_copy(new_course_name: String):
	if selected_course_index < 0 or selected_course_index >= course_list.item_count:
		return
	
	var original_name = course_list.get_item_text(selected_course_index)
	
	# Check if a course with the new name already exists
	var existing_courses = get_saved_courses()
	if new_course_name in existing_courses:
		print("A course with the name '" + new_course_name + "' already exists")
		# You might want to show an error dialog here
		return
	
	# Copy the course
	if copy_course(original_name, new_course_name):
		print("Successfully copied course from '" + original_name + "' to '" + new_course_name + "'")
		# Refresh the list to show the new copy
		refresh_course_list()
	else:
		print("Failed to copy course")

# Function to copy a course save file
func copy_course(original_name: String, new_name: String) -> bool:
	# Create safe filenames
	var original_safe = original_name.to_lower().replace(" ", "_").replace("/", "_")
	var new_safe = new_name.to_lower().replace(" ", "_").replace("/", "_")
	
	var original_path = "user://course_" + original_safe + ".save"
	var new_path = "user://course_" + new_safe + ".save"
	
	# Check if original file exists
	if not FileAccess.file_exists(original_path):
		print("Original course file not found: " + original_path)
		return false
	
	# Read the original file
	var original_file = FileAccess.open(original_path, FileAccess.READ)
	if original_file == null:
		print("Could not open original file for reading")
		return false
	
	# Create the new file
	var new_file = FileAccess.open(new_path, FileAccess.WRITE)
	if new_file == null:
		print("Could not create new file for writing")
		original_file.close()
		return false
	
	# Copy contents line by line, updating the course name
	while original_file.get_position() < original_file.get_length():
		var line = original_file.get_line()
		
		# Parse and update the course name in the JSON data
		var json = JSON.new()
		var parse_result = json.parse(line)
		
		if parse_result == OK and json.data is Dictionary:
			var data = json.data
			# Update the course name in the saved data
			if data.has("course_name"):
				data["course_name"] = new_name
			# Update timestamp to current time
			data["save_timestamp"] = Time.get_unix_time_from_system()
			
			# Write updated data
			new_file.store_line(JSON.stringify(data))
		else:
			# If parsing fails, just copy the line as-is
			new_file.store_line(line)
	
	# Close both files
	original_file.close()
	new_file.close()
	
	return true

# Function to delete a course save file
func delete_course(course_name: String) -> bool:
	var safe_name = course_name.to_lower().replace(" ", "_").replace("/", "_")
	var file_path = "user://course_" + safe_name + ".save"
	
	if not FileAccess.file_exists(file_path):
		print("Course file not found: " + file_path)
		return false
	
	# Delete the file
	var dir = DirAccess.open("user://")
	if dir == null:
		print("Could not access user directory")
		return false
	
	var error = dir.remove(file_path)
	if error != OK:
		print("Failed to delete file: " + file_path + " (Error: " + str(error) + ")")
		return false
	
	return true

# Update course selection handler to enable/disable buttons
func _on_course_selected(index: int):
	selected_course_index = index
	
	# Enable action buttons when a course is selected
	copy_button.disabled = false
	delete_button.disabled = false
	
	if index >= 0 and index < course_list.item_count:
		var selected_course = course_list.get_item_text(index)
		print("Course selected: " + selected_course)

# Handler for when empty space is clicked in the course list
func _on_course_list_empty_clicked(position: Vector2, mouse_button_index: int):
	# This is called when the user clicks on empty space in the ItemList
	# We can use this to deselect items and disable buttons
	course_list.deselect_all()
	selected_course_index = -1
	copy_button.disabled = true
	delete_button.disabled = true
	print("Course list deselected")

# Signal handlers for save dialog
func _on_save_class_button_pressed():
	course_name_input.clear()
	course_name_input.grab_focus()
	save_dialog.popup_centered()
	print("Save dialog opened")

func _on_course_name_submitted(text: String):
	current_course_name = text.strip_edges()
	save_dialog.hide()
	perform_course_save()

func _on_save_dialog_confirmed():
	current_course_name = course_name_input.text.strip_edges()
	perform_course_save()

# Signal handlers for load dialog
func _on_load_class_button_pressed():
	# Populate the course list with current available courses
	refresh_course_list()
	
	# Reset button states
	selected_course_index = -1
	copy_button.disabled = true
	delete_button.disabled = true
	
	# Show the load dialog
	load_dialog.popup_centered()
	print("Load dialog opened")

func _on_course_activated(index: int):
	# This fires when user double-clicks a course in the list
	# Double-clicking should immediately load the course
	if index >= 0 and index < course_list.item_count:
		var selected_course = course_list.get_item_text(index)
		current_course_name = selected_course
		load_dialog.hide()
		perform_course_load()

func _on_load_dialog_confirmed():
	# This fires when user clicks OK with a course selected
	var selected_items = course_list.get_selected_items()
	
	if selected_items.size() == 0:
		print("No course selected for loading")
		return
	
	# Get the selected course name and load it
	var selected_index = selected_items[0]
	var selected_course = course_list.get_item_text(selected_index)
	current_course_name = selected_course
	perform_course_load()

func refresh_course_list():
	# Clear the existing list
	course_list.clear()
	
	# Get all available courses from the file system
	var available_courses = get_saved_courses()
	
	# Sort courses alphabetically for better organization
	available_courses.sort()
	
	# Add each course to the list widget
	for course_name in available_courses:
		course_list.add_item(course_name)
	
	print("Course list refreshed with " + str(available_courses.size()) + " courses")

func perform_course_load():
	# Validate that we have a course to load
	if current_course_name.is_empty():
		print("Error: No course selected for loading")
		return
	
	# Attempt to load the selected course
	var success = load_course_list(current_course_name)
	
	if success:
		print("Successfully loaded course: " + current_course_name)
	else:
		print("Failed to load course: " + current_course_name)
	
	# Reset our state
	current_course_name = ""

func perform_course_save():
	# Validate input
	if current_course_name.is_empty():
		print("Error: Course name cannot be empty")
		return
	
	# Check for students to save
	var student_lists = get_tree().get_nodes_in_group("Persist")
	var has_students = false
	var total_students = 0
	
	for node in student_lists:
		if node is ItemList and node.item_count > 0:
			has_students = true
			total_students += node.item_count
	
	if not has_students:
		print("Warning: No students found to save for course: " + current_course_name)
		print("Add some students before saving a course list")
		return
	
	# Perform the save
	save_course_list(current_course_name)
	print("Successfully saved course '" + current_course_name + "' with " + str(total_students) + " students")
	
	# Reset state
	current_course_name = ""

# File system operations
func save_course_list(course_name: String):
	print("Saving course list: " + course_name)
	
	# Create filesystem-safe filename
	var safe_name = course_name.to_lower().replace(" ", "_").replace("/", "_")
	var file_path = "user://course_" + safe_name + ".save"
	
	# Open file for writing
	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if save_file == null:
		print("Error: Could not create save file for course: " + course_name)
		print("Check file permissions and disk space")
		return
	
	# Save all persistent nodes
	var student_lists = get_tree().get_nodes_in_group("Persist")
	var saved_count = 0
	
	for node in student_lists:
		if node is ItemList and node.has_method("save"):
			var node_data = node.call("save")
			node_data["course_name"] = course_name
			node_data["save_timestamp"] = Time.get_unix_time_from_system()
			
			var json_string = JSON.stringify(node_data)
			save_file.store_line(json_string)
			saved_count += 1
	
	save_file.close()
	print("Successfully saved " + str(saved_count) + " lists for course '" + course_name + "'")

func load_course_list(course_name: String):
	var safe_name = course_name.to_lower().replace(" ", "_").replace("/", "_")
	var file_path = "user://course_" + safe_name + ".save"
	
	if not FileAccess.file_exists(file_path):
		print("No save file found for course: " + course_name)
		return false
	
	# Clear current lists before loading
	var student_lists = get_tree().get_nodes_in_group("Persist")
	for node in student_lists:
		if node is ItemList and node.has_method("clear"):
			node.clear()
	
	# Load the specific course data
	var success = loadData(file_path)
	if success:
		print("Successfully loaded course: " + course_name)
	return success

func get_saved_courses():
	var saved_courses = []
	var dir = DirAccess.open("user://")
	
	if not dir:
		print("Could not access user directory for saved courses")
		return saved_courses
	
	# Scan directory for course save files
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.begins_with("course_") and file_name.ends_with(".save"):
			# Extract course name from filename
			var course_name = file_name.trim_prefix("course_").trim_suffix(".save")
			course_name = course_name.replace("_", " ")
			saved_courses.append(course_name)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	print("Found " + str(saved_courses.size()) + " saved courses")
	return saved_courses

# General save/load system
func saveData():
	print("Starting general save process...")
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		print("Error: Could not open save file for writing")
		return
	
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	var saved_count = 0
	
	for node in save_nodes:
		if not node.has_method("save"):
			print("Persistent node '" + node.name + "' is missing a save() function, skipped")
			continue
		
		var node_data = node.call("save")
		node_data["node_type"] = node.get_class()
		
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)
		saved_count += 1
	
	save_file.close()
	print("General save complete! Saved " + str(saved_count) + " nodes.")

func loadData(custom_path: String = ""):
	print("Starting load process...")
	
	var file_path = custom_path if custom_path != "" else SAVE_FILE_PATH
	
	if not FileAccess.file_exists(file_path):
		print("No save file found at: " + file_path)
		return false
	
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	if save_file == null:
		print("Error: Could not open save file for reading")
		return false
	
	var loaded_count = 0
	var errors = 0
	
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		
		if json_string.is_empty():
			continue
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result != OK:
			print("Error parsing JSON: " + json.get_error_message())
			errors += 1
			continue
		
		var node_data = json.data
		
		if node_data.has("name") and node_data.has("parent"):
			var parent_node = get_node_or_null(node_data.parent)
			if parent_node:
				var target_node = parent_node.get_node_or_null(node_data.name)
				
				if target_node and target_node.has_method("load_data"):
					target_node.call("load_data", node_data)
					loaded_count += 1
				else:
					print("Warning: Could not find node or load_data method for: " + node_data.name)
					errors += 1
			else:
				print("Warning: Could not find parent node: " + node_data.parent)
				errors += 1
	
	save_file.close()
	print("Load complete! Loaded " + str(loaded_count) + " nodes with " + str(errors) + " errors.")
	return errors == 0

# UI callback methods
func _on_exit_button_pressed():
	print("Shutting down StudentPicker application")
	get_tree().quit()

func _on_config_button_pressed():
	configWindow.show()
	pickerPanel.hide()
	print("Switched to configuration mode")

func _on_load_default_save_pressed():
	# This function loads the general application save file
	# It's kept for potential future use but not currently connected to any UI element
	var success = loadData()
	if success:
		print("Successfully loaded default save data")
	else:
		print("Failed to load default save data")

# Placeholder method for compatibility
func _on_class_name_edit_text_set():
	pass

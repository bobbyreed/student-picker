extends ItemList

# This script should be attached to each StudentList ItemList node
# It provides save and load functionality for persisting student data

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Add this node to the Persist group if not already added
	# (though your scene file shows it's already in the group)
	if not is_in_group("Persist"):
		add_to_group("Persist")

# Save function called by the save system
# Returns a dictionary containing all data needed to recreate this ItemList's state
func save() -> Dictionary:
	var save_dict = {
		# Store the scene file path so we can recreate it
		"filename": get_scene_file_path(),
		# Store the parent path so we know where to add it back
		"parent": get_parent().get_path(),
		# Store our node name to find it again
		"name": name,
		# Store the actual student data
		"students": [],
		# Store any metadata if needed
		"metadata": {}
	}
	
	# Extract all items from the ItemList
	for i in range(item_count):
		var student_data = {
			"text": get_item_text(i),
			"disabled": is_item_disabled(i),
			"selectable": is_item_selectable(i),
			# You can add more properties here if needed
			# "icon": get_item_icon(i), # if using icons
			# "metadata": get_item_metadata(i), # if using metadata
		}
		save_dict.students.append(student_data)
	
	# Store the current selection if any
	var selected_items = get_selected_items()
	if selected_items.size() > 0:
		save_dict.metadata["selected_indices"] = selected_items
	
	print("Saving %d students from %s" % [save_dict.students.size(), name])
	return save_dict

# Load function to restore the ItemList state from saved data
func load_data(save_dict: Dictionary) -> void:
	# Clear existing items first
	clear()
	
	# Restore all students
	if save_dict.has("students"):
		for student_data in save_dict.students:
			# Add the item with its text
			add_item(student_data.text)
			
			# Get the index of the item we just added
			var idx = item_count - 1
			
			# Restore item properties
			if student_data.has("disabled"):
				set_item_disabled(idx, student_data.disabled)
			
			if student_data.has("selectable"):
				set_item_selectable(idx, student_data.selectable)
			
			# Restore other properties if you saved them
			# if student_data.has("icon"):
			#     set_item_icon(idx, student_data.icon)
			# if student_data.has("metadata"):
			#     set_item_metadata(idx, student_data.metadata)
	
	# Restore selection if it was saved
	if save_dict.has("metadata") and save_dict.metadata.has("selected_indices"):
		for idx in save_dict.metadata.selected_indices:
			if idx < item_count:  # Make sure the index is valid
				select(idx)
	
	print("Loaded %d students into %s" % [item_count, name])

# Optional: Helper function to get all student names as an array
func get_all_students() -> Array[String]:
	var students: Array[String] = []
	for i in range(item_count):
		students.append(get_item_text(i))
	return students

# Optional: Helper function to set students from an array of names
func set_students(student_names: Array[String]) -> void:
	clear()
	for student_name in student_names:
		add_item(student_name)

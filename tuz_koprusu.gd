extends CharacterBody2D

var dragging := false
var popup
var offset = Vector2.ZERO
var solution_type_dialog
var solution_type := "KNO3"
var molarity := 1.0

func _ready():
	collision_layer = 1
	collision_mask = 1
	
	# Area2D input event
	$UI.connect("input_event",_on_interaction_input)
	$Cozelti.text = "KNO3"
	# Popup
	popup = PopupMenu.new()
	popup.add_item("Nesneyi Sil", 0)
	popup.add_item("Çözelti Seç", 1)
	popup.connect("id_pressed",_on_popup_item_selected)
	add_child(popup)
	
	# Çözelti tipi için OptionButton
	solution_type_dialog = AcceptDialog.new()
	var option_button = OptionButton.new()
	option_button.add_item("KNO3")
	solution_type_dialog.add_child(option_button)
	solution_type_dialog.connect("confirmed",_on_solution_type_selected.bind(option_button))
	add_child(solution_type_dialog)



func _on_interaction_input(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			# sadece sol tuş ile drag başlasın
			dragging = true
			offset = get_global_mouse_position() - global_position
		else:
			if dragging:
				dragging = false
				# sağ tıklama veya sol tıklama bırakmada popup aç
				popup.position = event.global_position
				popup.popup()


func _physics_process(delta):
	if dragging:
		var target = get_global_mouse_position() - offset
		var motion = target - global_position
		move_and_collide(motion)



func _on_popup_item_selected(id):
	match id:
		0:
			queue_free()  # nesneyi sil
		1:
			solution_type_dialog.popup_centered()  # Çözelti tipi



func _on_solution_type_selected(option_button):
	solution_type = option_button.get_item_text(option_button.get_selected())
	print("Çözelti tipi seçildi:", solution_type)
	$Cozelti.text = solution_type


func diger_beheri_ara(cb):
	for i in $Object_Interact.get_overlapping_areas():
		if i.get_parent().is_in_group("Beher") and i.get_parent() != cb:
			return i.get_parent()
			

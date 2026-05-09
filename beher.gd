extends CharacterBody2D

var dragging := false
var popup
var offset = Vector2.ZERO
var solution_type_dialog
var molarity_dialog
var solution_type := "H2O"
var molarity := 1.0




func setup_solution_dialog(list: Array) -> void:
	solution_type_dialog = AcceptDialog.new()
	solution_type_dialog.title = "Çözelti Seç"

	var option_button := OptionButton.new()

	for s in list:
		option_button.add_item(s)

	solution_type_dialog.add_child(option_button)
	solution_type_dialog.confirmed.connect(
		_on_solution_type_selected.bind(option_button)
	)

	add_child(solution_type_dialog)
	
func _ready():
	collision_layer = 1
	collision_mask = 1
	
	# Area2D input event
	$UI.connect("input_event",_on_interaction_input)
	
	# Popup
	popup = PopupMenu.new()
	popup.add_item("Nesneyi Sil", 0)
	popup.add_item("Çözelti Seç", 1)
	popup.add_item("Molarite Yaz", 2)
	popup.connect("id_pressed",_on_popup_item_selected)
	add_child(popup)
	
	# Çözelti tipi için OptionButton
	
	# Molarite için LineEdit
	molarity_dialog = AcceptDialog.new()
	var line_edit = LineEdit.new()
	line_edit.text = str(molarity)
	molarity_dialog.add_child(line_edit)
	molarity_dialog.connect("confirmed",_on_molarity_entered.bind(line_edit))
	add_child(molarity_dialog)




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
		# offset’i çıkar

		var target = get_global_mouse_position() - offset
		var motion = target - global_position
		move_and_collide(motion)



func _on_popup_item_selected(id):
	match id:
		0:
			queue_free()  # nesneyi sil
		1:
			solution_type_dialog.popup_centered()  # Çözelti tipi
		2:
			molarity_dialog.popup_centered()  # Molarite gir


func _on_solution_type_selected(option_button):
	solution_type = option_button.get_item_text(option_button.get_selected())
	print("Çözelti tipi seçildi:", solution_type)
	$Cozelti.text = solution_type


func _on_molarity_entered(line_edit):
	var value = float(line_edit.text)
	molarity = value
	print("Molarite:", molarity)
	$Molarite.text = line_edit.text + "M"

func tuz_koprusu_varmi():
	var kopru = null
	for i in $Object_Interact.get_overlapping_areas():
		if i.get_parent().is_in_group("Tuz_Koprusu"):
			assert(kopru == null,"Behere birden fazla tuz köprüsü koyma")
			kopru = i.get_parent()
	
	return kopru
	
func elektrot_varmi():
	var elek = null
	for i in $Object_Interact.get_overlapping_areas():
		if i.get_parent().is_in_group("Elektrot"):
			assert(elek == null,"Behere birden fazla elektrot koyma")
			elek = i.get_parent()
	
	return elek
			

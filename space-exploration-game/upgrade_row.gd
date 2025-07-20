# upgrade_row.gd
extends PanelContainer

signal buy_pressed(upgrade_id)

@onready var icon_rect: TextureRect = $HBoxContainer/IconRect
@onready var name_label: Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var desc_label: Label = $HBoxContainer/VBoxContainer/DescLabel
@onready var buy_button: Button = $HBoxContainer/BuyButton

var upgrade_id: String

func _ready():
	buy_button.pressed.connect(on_buy_pressed)

func set_data(upgrade_data: UpgradeData, can_afford: bool):
	self.upgrade_id = upgrade_data.id
	
	icon_rect.texture = upgrade_data.icon
	name_label.text = upgrade_data.display_name
	desc_label.text = upgrade_data.description
	
	buy_button.text = "Buy (%.1f RP)" % upgrade_data.cost
	buy_button.disabled = not can_afford

func on_buy_pressed():
	emit_signal("buy_pressed", self.upgrade_id)

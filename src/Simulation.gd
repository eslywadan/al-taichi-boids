extends Node2D

const BOIDS_COUNT = 384
const BOIDS_SPEED = 35
const NEIGHBOR_DIST = 80

onready var boid_scene = preload("res://src/Boid.tscn")
onready var boids_container = $Boids
onready var water = $Water

var boids = []

func _ready():
	
	for i in BOIDS_COUNT:
		var boid = boid_scene.instance()
		boid.move_speed = $HUD/VBoxContainer/MoveSlider/HSlider.value
		#boid.neighbor_distance = $HUD/VBoxContainer/NeighborDistanceSlider/HSlider.value
		boid.steer_force = $HUD/VBoxContainer/TurnSlider/HSlider.value
		boid.alignment_force = $HUD/VBoxContainer/AlignSlider/HSlider.value
		boid.cohesion_force = $HUD/VBoxContainer/CohesionSlider/HSlider.value
		boid.seperation_force = $HUD/VBoxContainer/AlignSlider/HSlider.value
		boids_container.add_child(boid)
		boids.push_back(boid)
		
	
	for boid in boids_container.get_children():
		boid.boids = boids
	

func _on_MoveSlider_value_changed(value):
	for boid in boids:
		boid.move_speed = value


func _on_TurnSlider_value_changed(value):
	for boid in boids:
		boid.steer_force = value


func _on_AlignSlider_value_changed(value):
	for boid in boids:
		boid.alignment_force = value


func _on_CohesionSlider_value_changed(value):
	for boid in boids:
		boid.cohesion_force = value


func _on_SeperationSlider_value_changed(value):
	for boid in boids:
		boid.seperation_force = value

func _on_NeighborDistanceSlider_value_changed(value):
	for boid in boids:
		boid.neighbor_distance = value

func _on_DistortionSlider_value_changed(value):
	water.material.set_shader_param("distortion_amount", value)


func _on_RigidBody2D_input_event(viewport, event, shape_idx):
	pass # Replace with function body.



func _on_RigidBody2D_sleeping_state_changed():
	for boid in boids:
		boid.move_speed = BOIDS_SPEED 


func _on_RigidBody2D_visibility_changed():
	for boid in boids:
		boid.move_speed = 300

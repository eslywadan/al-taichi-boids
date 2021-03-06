extends Node2D
class_name Boid

onready var detectors = $ObsticleDetectors
onready var sensors = $ObsticleSensors

var boids = []
var move_speed = 200
var perception_radius = 35
var velocity = Vector2()
var acceleration = Vector2()
var steer_force = 30.0
var alignment_force = 0.6
var cohesion_force = 0.6
var seperation_force = 0.6
var avoidance_force = 3.0
var neighbor_num = 5.0 
var adj_rate = 10.0
#var neighbor_num = 5000
#var adj_rate = 1


export (Array, Color) var colors 

func _ready():
	randomize()
	
	position = Vector2(rand_range(0, get_viewport().size.x), rand_range(0, get_viewport().size.y))
	velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * move_speed
	modulate = colors[rand_range(0, colors.size())]


func _process(delta):
	
	var neighbors = get_neighbors(perception_radius)
	
	var alignments = process_alignments(neighbors)
	var cohesion = process_cohesion(neighbors) 
	var seperation = process_seperation(neighbors)
	
	var adj_cohesion_force = cohesion_force
	var adj_seperation_force = seperation_force
	
	if neighbors.size() > neighbor_num:
		adj_seperation_force *= adj_rate
	
	if neighbors.size() < neighbor_num:
		adj_cohesion_force *= adj_rate
	
	acceleration += alignments * alignment_force
	acceleration += cohesion * adj_cohesion_force
	acceleration += seperation * adj_seperation_force

	if is_obsticle_ahead():
		acceleration += process_obsticle_avoidance() * avoidance_force
		
	velocity += acceleration * delta
	velocity = velocity.clamped(move_speed)
	rotation = velocity.angle()
	
	translate(velocity * delta)
	
	position.x = wrapf(position.x, -32, get_viewport().size.x + 32)
	position.y = wrapf(position.y, -32, get_viewport().size.y + 32)

func process_cohesion(neighbors):
	var vector = Vector2()
	if neighbors.empty():
		return vector
	for boid in neighbors:
		vector += boid.position
	vector /= neighbors.size()
	return steer((vector - position).normalized() * move_speed)
		

func process_alignments(neighbors):
	var vector = Vector2()
	if neighbors.empty():
		return vector
		
	for boid in neighbors:
		vector += boid.velocity
	vector /= neighbors.size()
	return steer(vector.normalized() * move_speed)

func process_seperation(neighbors):
	var vector = Vector2()
	var close_neighbors = []
	for boid in neighbors:
		if position.distance_to(boid.position) < perception_radius / 2:
			close_neighbors.push_back(boid)
	if close_neighbors.empty():
		return vector
	
	for boid in close_neighbors:
		var difference = position - boid.position
		vector += difference.normalized() / difference.length()
	
	vector /= close_neighbors.size()
	return steer(vector.normalized() * move_speed)
	

func steer(var target):
	var steer = target - velocity
	steer = steer.normalized() * steer_force
	return steer
	
func is_obsticle_ahead():
	for ray in detectors.get_children():
		if ray.is_colliding():
			return true
	return false

func process_obsticle_avoidance():
	for ray in sensors.get_children():
		if not ray.is_colliding():
			return steer( (ray.cast_to.rotated(ray.rotation + rotation)).normalized() * move_speed )
			
	return Vector2.ZERO

func get_neighbors(view_radius):
	var neighbors = []

	for boid in boids:
		if position.distance_to(boid.position) <= view_radius and not boid == self:
		# if position.distance_to(boid.position) <= boid.neighbor_distance and not boid == self:
			neighbors.push_back(boid)
	return neighbors
			
	


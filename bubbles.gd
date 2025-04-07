extends Node2D

func _ready():
	%CPUParticles2D_2.emitting = true

func _on_cpu_particles_2d_2_finished():
	queue_free()

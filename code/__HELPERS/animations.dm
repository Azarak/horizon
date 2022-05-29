#define SHAKE_ANIMATION_OFFSET 4

/// Shakes an atom left and right
/proc/shake_animation(atom/atom_to_shake, offset = SHAKE_ANIMATION_OFFSET)
	var/direction = prob(50) ? -1 : 1
	animate(atom_to_shake, pixel_x = atom_to_shake.pixel_x + offset * direction, time = 1, easing = QUAD_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_x = atom_to_shake.pixel_x - (offset * 2 * direction), time = 1)
	animate(pixel_x = atom_to_shake.pixel_x + offset * direction, time = 1, easing = QUAD_EASING | EASE_IN)

#undef SHAKE_ANIMATION_OFFSET

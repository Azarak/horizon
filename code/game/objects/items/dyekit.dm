/obj/item/dyespray
	name = "hair dye spray"
	desc = "A spray to dye your hair any gradients you'd like. Includes a bleaching agent to remove it as well."
	icon = 'icons/obj/dyespray.dmi'
	icon_state = "dyespray"

/obj/item/dyespray/attack_self(mob/user)
	dye(user)

/obj/item/dyespray/attack_self_secondary(mob/user, modifiers)
	bleach(user)

/obj/item/dyespray/pre_attack(atom/target, mob/living/user, params)
	if(ishuman(target))
		dye(target)
		// Cancel attack chain so we don't bop ourselves/others with the spray
		return TRUE
	// Else just call the parent so we can do other things
	return ..()

/obj/item/dyespray/pre_attack_secondary(atom/target, mob/living/user, params)
	if(ishuman(target))
		bleach(target)
		// Cancel attack chain so we don't call pre_attack().
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/**
 * Applies a gradient and a gradient color to a mob.
 *
 * Arguments:
 * * target - The mob who we will apply the gradient and gradient color to.
 */

/obj/item/dyespray/proc/dye(mob/target)
	if(!ishuman(target))
		return

/**
 * Removes a gradient and a gradient color from a mob.
 *
 * Arguments:
 * * target - The mob who we will remove the gradient and gradient color from.
 */

/obj/item/dyespray/proc/bleach(mob/target)
	if(!ishuman(target))
		return

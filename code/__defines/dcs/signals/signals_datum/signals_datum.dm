/// Sent when the amount of materials in material_container changes
#define COMSIG_MATERIAL_CONTAINER_CHANGED "material_container_changed"

/// Called when a buffer tries to send some stored data to something (datum/source, mob/user, datum/buffer, obj/item/buffer_parent) (buffer item may be null)
#define COMSIG_PARENT_RECEIVE_BUFFER "receive_buffer"
	#define COMPONENT_BUFFER_RECEIVED (1 << 0)

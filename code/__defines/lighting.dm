///Object doesn't use any of the light systems. Should be changed to add a light source to the object.
#define NO_LIGHT_SUPPORT 0
///Light made with the lighting datums, applying a matrix.
#define STATIC_LIGHT 1
///Light made by masking the lighting darkness plane.
#define MOVABLE_LIGHT 2
///Light made by masking the lighting darkness plane, and is directional.
#define MOVABLE_LIGHT_DIRECTIONAL 3

///Is a movable light source attached to another movable (its loc), meaning that the lighting component should go one level deeper.
#define LIGHT_ATTACHED (1<<0)

//Bay lighting engine shit, not in /code/modules/lighting because BYOND is being shit about it
/// frequency, in 1/10ths of a second, of the lighting process
#define LIGHTING_INTERVAL       5

#define MINIMUM_USEFUL_LIGHT_RANGE 1.4

/// type of falloff to use for lighting; 1 for circular, 2 for square
#define LIGHTING_FALLOFF        1
/// use lambertian shading for light sources
#define LIGHTING_LAMBERTIAN     0
/// height off the ground of light sources on the pseudo-z-axis, you should probably leave this alone
#define LIGHTING_HEIGHT         1
/// Value used to round lumcounts, values smaller than 1/129 don't matter (if they do, thanks sinking points), greater values will make lighting less precise, but in turn increase performance, VERY SLIGHTLY.
#define LIGHTING_ROUND_VALUE    (1 / 64)

/// icon used for lighting shading effects
#define LIGHTING_ICON 'icons/effects/lighting_object.dmi'

/// If the max of the lighting lumcounts of each spectrum drops below this, disable luminosity on the lighting objects.
/// Set to zero to disable soft lighting. Luminosity changes then work if it's lit at all.
#define LIGHTING_SOFT_THRESHOLD 0

/// If I were you I'd leave this alone.
#define LIGHTING_BASE_MATRIX \
	list                     \
	(                        \
		1, 1, 1, 0, \
		1, 1, 1, 0, \
		1, 1, 1, 0, \
		1, 1, 1, 0, \
		0, 0, 0, 1           \
	)                        \

///How many tiles standard fires glow.
#define LIGHT_RANGE_FIRE 3

#define LIGHTING_PLANE_ALPHA_VISIBLE 255
#define LIGHTING_PLANE_ALPHA_NV_TRAIT 245
#define LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE 192
/// For lighting alpha, small amounts lead to big changes. even at 128 its hard to figure out what is dark and what is light, at 64 you almost can't even tell.
#define LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE 128
#define LIGHTING_PLANE_ALPHA_INVISIBLE 0

//lighting area defines
/// dynamic lighting disabled (area stays at full brightness)
#define DYNAMIC_LIGHTING_DISABLED 0
/// dynamic lighting enabled
#define DYNAMIC_LIGHTING_ENABLED 1
/// dynamic lighting enabled even if the area doesn't require power
#define DYNAMIC_LIGHTING_FORCED 2
#define IS_DYNAMIC_LIGHTING(A) A.dynamic_lighting


//code assumes higher numbers override lower numbers.
#define LIGHTING_NO_UPDATE 0
#define LIGHTING_VIS_UPDATE 1
#define LIGHTING_CHECK_UPDATE 2
#define LIGHTING_FORCE_UPDATE 3

#define FLASH_LIGHT_DURATION 2
#define FLASH_LIGHT_POWER 3
#define FLASH_LIGHT_RANGE 3.8

// Emissive blocking.
/// Uses vis_overlays to leverage caching so that very few new items need to be made for the overlay. For anything that doesn't change outline or opaque area much or at all.
#define EMISSIVE_BLOCK_GENERIC 1
/// Uses a dedicated render_target object to copy the entire appearance in real time to the blocking layer. For things that can change in appearance a lot from the base state, like humans.
#define EMISSIVE_BLOCK_UNIQUE 2

/// The color matrix applied to all emissive overlays. Should be solely dependent on alpha and not have RGB overlap with [EM_BLOCK_COLOR].
#define EMISSIVE_COLOR list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 1,1,1,0)
/// A globaly cached version of [EMISSIVE_COLOR] for quick access.
GLOBAL_LIST_INIT(emissive_color, EMISSIVE_COLOR)
/// The color matrix applied to all emissive blockers. Should be solely dependent on alpha and not have RGB overlap with [EMISSIVE_COLOR].
#define EM_BLOCK_COLOR list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
/// A globaly cached version of [EM_BLOCK_COLOR] for quick access.
GLOBAL_LIST_INIT(em_block_color, EM_BLOCK_COLOR)
/// The color matrix used to mask out emissive blockers on the emissive plane. Alpha should default to zero, be solely dependent on the RGB value of [EMISSIVE_COLOR], and be independant of the RGB value of [EM_BLOCK_COLOR].
#define EM_MASK_MATRIX list(0,0,0,1/3, 0,0,0,1/3, 0,0,0,1/3, 0,0,0,0, 1,1,1,0)
/// A globaly cached version of [EM_MASK_MATRIX] for quick access.
GLOBAL_LIST_INIT(em_mask_matrix, EM_MASK_MATRIX)

/// Returns the red part of a #RRGGBB hex sequence as number
#define GETREDPART(hexa) hex2num(copytext(hexa, 2, 4))

/// Returns the green part of a #RRGGBB hex sequence as number
#define GETGREENPART(hexa) hex2num(copytext(hexa, 4, 6))

/// Returns the blue part of a #RRGGBB hex sequence as number
#define GETBLUEPART(hexa) hex2num(copytext(hexa, 6, 8))

/// Parse the hexadecimal color into lumcounts of each perspective.
#define PARSE_LIGHT_COLOR(source) \
do { \
	if (source.light_color != COLOR_WHITE) { \
		var/__light_color = source.light_color; \
		source.lum_r = GETREDPART(__light_color) / 255; \
		source.lum_g = GETGREENPART(__light_color) / 255; \
		source.lum_b = GETBLUEPART(__light_color) / 255; \
	} else { \
		source.lum_r = 1; \
		source.lum_g = 1; \
		source.lum_b = 1; \
	}; \
} while (FALSE)

//Fake ambient occlusion filter
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

#define SUNLIGHT_RADIUS 9 //Tiles that sunlight penetrates into shade
#define SUNLIGHT_NONE 0
#define SUNLIGHT_POSSIBLE 1
#define SUNLIGHT_CURRENT 2
#define SUNLIGHT_OVERHEAD 3
#define SUNLIGHT_ONLY 4
#define SUNLIGHT_ONLY_SHADE 5

// Keep in mind. Lighting corners accept the bottom left (northwest) set of cords to them as input
// Handles dynamic light
#define GENERATE_MISSING_CORNERS(gen_for) \
	if (!gen_for.lighting_corner_NE) { \
		gen_for.lighting_corner_NE = new /datum/lighting_corner(gen_for.x, gen_for.y, gen_for.z, gen_for.has_dynamic_lighting()); \
	} \
	if (!gen_for.lighting_corner_SE) { \
		gen_for.lighting_corner_SE = new /datum/lighting_corner(gen_for.x, gen_for.y - 1, gen_for.z, gen_for.has_dynamic_lighting()); \
	} \
	if (!gen_for.lighting_corner_SW) { \
		gen_for.lighting_corner_SW = new /datum/lighting_corner(gen_for.x - 1, gen_for.y - 1, gen_for.z, gen_for.has_dynamic_lighting()); \
	} \
	if (!gen_for.lighting_corner_NW) { \
		gen_for.lighting_corner_NW = new /datum/lighting_corner(gen_for.x - 1, gen_for.y, gen_for.z, gen_for.has_dynamic_lighting()); \
	} \
	gen_for.lighting_corners_initialised = TRUE;

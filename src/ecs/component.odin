package ecs

import "base:runtime"
import "core:reflect"

Component :: union {
	EntityRef,
	Transform,
	Sprite,
}

ComponentMask :: [4]u64

ComponentMeta :: struct {
	size: int,
	bit:  int,
}

@(private)
isMaskEmpty :: proc(mask: ^ComponentMask) -> bool {
	for i in mask {
		if i != 0 do return false
	}

	return true
}

@(private)
maskAdd :: proc(mask: ^ComponentMask, idx: int) {
	word := idx / 64
	bit := uint(idx % 64)
	mask[word] |= (u64(1) << bit)
}

@(private)
maskIncludes :: proc(mask: ^ComponentMask, required: ^ComponentMask) -> bool {
	for i in 0 ..< len(ComponentMask) {
		if (mask[i] & required[i] != required[i]) {
			return false
		}
	}
	return true
}

@(private)
maskIncludesOne :: proc(mask: ^ComponentMask, idx: int) -> bool {
	word := idx / 64
	bit := uint(idx % 64)
	return (mask[word] & (u64(1) << bit)) != 0
}

@(private)
maskCombine :: proc(m1: ^ComponentMask, m2: ^ComponentMask) -> ComponentMask {
	res: [4]u64 = {}
	for i in 0 ..< len(ComponentMask) {
		res[i] = m1[i] | m2[i]
	}
	return res
}

@(private)
getComponentsFromMask :: proc(mask: ^ComponentMask) -> [dynamic]typeid {
	tids := make([dynamic]typeid, context.temp_allocator)
	info := type_info_of(Component)

	#partial switch variant in info.variant.(runtime.Type_Info_Named).base.variant {
	case runtime.Type_Info_Union:
		for variantInfo, idx in variant.variants {
			if !maskIncludesOne(mask, idx) do continue
			append(&tids, variantInfo.id)
		}
	}
	return tids
}

testMaskIncludesOne :: proc() {
	mask: ComponentMask
	word: u64 = 0b11101101100010
	mask[0] = word
	bit := 10

	assert(maskIncludesOne(&mask, bit), "MASK TEST FAILED")
}

@(private)
computeMask :: proc {
	computeMaskComponent,
	computeMaskTid,
}

@(private)
computeMaskComponent :: proc(world: ^World, components: []Component) -> ComponentMask {
	mask: ComponentMask
	for component in components {
		tid := reflect.union_variant_typeid(component)
		maskAdd(&mask, world.meta[tid].bit)
	}
	return mask
}

@(private)
computeMaskTid :: proc(world: ^World, components: []typeid) -> ComponentMask {
	mask: ComponentMask
	for component in components {
		maskAdd(&mask, world.meta[component].bit)
	}
	return mask
}

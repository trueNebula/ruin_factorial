package structure

MakeStack :: proc {
	stackMakeEmpty,
	stackMakeFromSlice,
}

MakeQueue :: proc {
	queueMakeEmpty,
	queueMakeFromSlice,
}

MakeSet :: proc {
	setMakeEmpty,
	setMakeFromSlice,
}

Delete :: proc {
	stackDelete,
	queueDelete,
	setDelete,
}

Push :: proc {
	stackPush,
	queuePush,
}

Add :: proc {
	setAdd,
}

Pop :: proc {
	stackPop,
	queuePop,
}

Remove :: proc {
	setRemove,
}

RemoveAt :: proc {
	setRemoveAt,
}

Peek :: proc {
	stackPeek,
}

Get :: proc {
	setGet,
}

Includes :: proc {
	stackIncludes,
	queueIncludes,
	arrayIncludes,
	dynamicArrayIncludes,
	setIncludes,
}

Empty :: proc {
	stackEmpty,
	queueEmpty,
	setEmpty,
}

Length :: proc {
	stackLength,
	queueLength,
	setLength,
}

Front :: proc {
	queueFront,
}

Back :: proc {
	queueBack,
}

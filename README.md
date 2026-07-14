# Odin Archetype-based ECS

v1.0.0

## Usage

Simply clone this repo or drag-and-drop the contents of this repo into your source folder to install. Configure your ols.json and odin build/run commands to see the ecs package.

Public functions are available in ecs.odin and system.odin.

### 1. Create a World

```odin
import ecs "src:ecs"
world := ecs.CreateWorld()
```

### 2. Create a component

A component can be just about any data structure. Once created, add it to the Component union in component.odin to register it. This way, you also get proper Intelli-Sense when writing code.

```odin
Transform :: struct  {
  x, y: f32,
  rotation: f32,
}

Component :: union {
  Transform,
}
```

### 3. Register a system

Systems are procs that take in a pointer to a World as their single parameter.

There are three types of systems:

1. Setup systems are meant to be ran once, before the game loop;
2. Tick systems that are meant to be ran during the game loop;
3. Render systems that are meant to be ran during the rendering code.

```odin
InitEntitiesSystem :: proc(world: ^World) {
  ecs.Add(world,
    ecs.Transform{x = 10, y = 5, rot = 0}
  )
}

ecs.RegisterSetupSystem(world, InitEntitiesSystem)
```

### 4. Use Queries and Views

A Query is a procedure that takes in a number of component pointers as parameters (up to 5), and runs over every entity containing all of those components.

A View takes in a number of component types as parameters (up to 5), and returns a list of every entity that contains all of those components, including the entities' ids and the values for each component.

For getting the components of a single entity, you can use a SingleView.

The API for these is as follows:

```odin
Query<N>(world, proc(c1: ^C1, c2: ^C2, ...c<N>: ^C<N>)) {
  ...
}

view := View<N>(world, C1, C2, ...C<N>)

for entity in view {
  entity.id ...
  entity.c1 ...
  ...
}

view := SingleView<N>(world, entityId, C1, C2, ...C<N>)
view.c1 ...
view.c2 ...
...
```

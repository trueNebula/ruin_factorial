package ui

import "src:neb_structures"
Layer :: struct {
	/**
    Do I need this?

    One idea is to have a list of components and a map of states,
    and updating a UI means calling its function with the state.
    Maybe base the map on some sort of ID, to pass the proper state to 
    proper UI component.

    Idk how necessary this is, since I could also just do it manually.
    Pros:
    - it's pretty nice
    - automatically update then render all UI components in a specific layer
    - determine if a layer should block propagating inputs downwards or not
    Cons:
    - solving for the generic case
    - gonna have to find a proper proc definition to cover everything
    - feels like im overcomplicating things
  */
	components:      neb_structures.Pair(Component, State),
	propagateInputs: bool,
}

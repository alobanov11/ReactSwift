//
//  Created by Антон Лобанов on 30.03.2021.
//

open class Reducer<Component: IComponent>
{
    public typealias State = Component.State
    public typealias Effect = Component.Effect

    public init() {}

    open func reduce(state: State, effect: Effect) -> State {
        print("Should override in subclass")
        return state
    }
}

//
//  Created by Антон Лобанов on 30.03.2021.
//

open class Reducer<Module: IModule>
{
    public typealias State = Module.State
    public typealias Effect = Module.Effect

    public init() {}

    open func reduce(state: State, effect: Effect) -> State {
        print("Should override in subclass")
        return state
    }
}

package loom.utils;

typedef UpdateableEntities = Map<String, Entity>;
typedef UpdateableComponents = Map<String, Component>;

interface Updateable {
    public var enabled: Bool;
    public function update(dt:Float): Void;
}


class UpdateUtils{
    /**
        Updates a Room's entities or an Entity's components if they are enabled.
    
        @param dt Delta Time.
        @param updateables Either an UpdateableEntities or UpdateableComponents. List of Updateables to update.
        @param updateOrder IDs of elements to be updated in specific order. If none, updates in order fed by the Updateable iterator.
    **/
    static public function updateAll<T: Updateable>(dt:Float, updateables: Map<String, T>, ?updateOrder: Array<String>){
        if(updateOrder != null){
            // TODO: Add update order
        }
        else{
            for (upd in updateables.iterator()){
                if(upd.enabled){
                    upd.update(dt);
                }
            }
        }
    }
}


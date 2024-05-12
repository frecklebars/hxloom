package loom;

typedef ActorConfig = {
    > loom.Object.ObjectConfig,

    var ?isPlayer: Bool;
}

// enum ActorFacing {
//     FacingUp;
//     FacingDown;
//     FacingLeft;
//     FacingRight;
// }

class Actor extends loom.Object{

    public var isPlayer: Bool = false;

    public function new(config: ActorConfig){
        if(config.isPlayer) setAsPlayer();

        super(config);
    }

    // TODO untested
    public function setAsPlayer(){
        if(room == null){
            trace('${this.name} does not belong in a room: can\'t set as player.');
            return;
        }

        room.game.changePlayer(this); // TODO finish game.changePlayer
    }

}
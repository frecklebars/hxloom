package loom;

import loom.graphic.Background;

class Room extends h2d.Scene {

    private var background: Background;
    
    public function new(backgroundPath: String){
        super();

        background = Background.fromPng(this, backgroundPath);
    }

    public function init(){}
    public function update(dt: Float){}

}
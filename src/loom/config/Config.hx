package loom.config;

import haxe.Json;

@:generic
class Config {

    public static function loadConfig<T>(configPath: String): T {
        var configText: String = hxd.Res.loader.load(configPath).toText();
        return Json.parse(configText);
    }

}
import os, argparse
import yaml, json


def find_configs(path):
    confs = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(".yml") or file.endswith(".yaml"):
                confs.append(os.path.join(root, file))
    return confs

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("res_path", nargs='?', type=str, default="res", help="path to resources folder")
    parser.add_argument("-i", "--indent", action="store_true")
    
    args = parser.parse_args()

    path = args.res_path
    indent = args.indent

    confs = find_configs(path)
    for conf in confs:
        with open(conf, 'r') as f:
            yml_config = yaml.safe_load(f)

        json_config_filename = conf.replace(".yaml", ".json").replace(".yml", ".json")

        with open(json_config_filename, 'w') as f:
            json.dump(yml_config, f,
                indent=4 if indent else None,
                separators=(', ', ': ') if indent else (',', ':')
            )

if __name__ == "__main__":
    main()
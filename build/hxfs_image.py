import sys, json


configJson = sys.argv[-1]
outputFile = sys.argv[-2]


def load_config(jsonPath: str) -> dict[str,object]:
    with open(jsonPath) as f:
        return json.load(f)


def fread(path: str, mode = "rb") -> bytes:
    with open(path, mode) as f:
        return f.read()


def fwrite(path: str, data: bytes, mode = "wb") -> None:
    with open(path, mode) as f:
        f.write(data)


def create_fs_metadata(root_dir_offset, sector_using_table) -> bytes:
    metadata = root_dir_offset.to_bytes(4, byteorder="little")
    metadata += b"\0\0\0\0"
    metadata += sector_using_table.to_bytes(4, byteorder="little")
    return metadata


class Node(list):
    def __init__(self, name: str, type: str, children: list) -> None:
        self.name = name
        self.type = type
        self.data = 0  # data offset value, zero by default
        
        for i in children:
            self.append(i)

    def __str__(self) -> str:
        return f"{self.name} ({self.type})"
    
    def __repr__(self) -> str:
        return f"Node({self.name}, {self.type}, [{', '.join([repr(i) for i in self])}])"


def create_tree(tree: list[dict[str,object]], name = "::", type_ = "dir") -> Node[Node]:
    root = Node(name, type_, [])
    
    for i in tree:
        if i["type"] == "dir":
            root.append(create_tree(i["children"], i["name"], i["type"]))
        elif i["type"] == "file":
            root.append(Node(i["name"], i["type"], [fread(i["source"])]))
        else:
            raise Exception(f"Unknown type: {i['type']}")

    return root


def add_aligned(dest: bytes, src: bytes, align: int = 512) -> bytes:
    if len(src) % align != 0:
        src += b"\0" * (align - len(src) % align)
    return dest + src

def create_data_section(tree: Node[Node]) -> bytes:
    data = b""
    sectors_using_table = [b"\0\0\0\0"] * (round(config["size"] / 512))

    for i in tree:
        if i.type == "dir":
            sectors = round(len(create_data_section(i)) / 512)
            for j in range(sectors):
                sectors_using_table[round(len(data) / 512) + j] = (round(len(data) / 512) + j + 1).to_bytes(4, byteorder="little")
            i.data = len(data) + data_offset
            data = add_aligned(data, create_data_section(i))
        elif i.type == "file":
            sectors = round(len(i[0]) / 512)
            for j in range(sectors):
                sectors_using_table[round(len(data) / 512) + j] = (round(len(data) / 512) + j + 1).to_bytes(4, byteorder="little")
            i.data = len(data) + data_offset
            data = add_aligned(data, i[0]);
        else:
            raise TypeError(f"Unknown type: {i.type}")

    return add_aligned(b"".join(tuple(sectors_using_table)), data)

config = load_config(configJson)

bootsect = fread(config[":"][0])
hxldr = fread(config[":"][1])

data_offset = len(bootsect) + len(hxldr)

tree = create_tree(config["::"])

data = create_data_section(tree)

metadata = create_fs_metadata(len(data), len(tree) * 4)

fs = add_aligned(bootsect[:2] + metadata + bootsect[16:], data)

fwrite(outputFile, bootsect + hxldr + fs)

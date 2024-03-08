import os, sys, json


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


def create_fs_metadata(root_dir_offset, root_dir_backup_offset, sector_using_table) -> bytes:
    metadata = b"\u05eb\u4890\u4658\ub853"
    metadata += root_dir_offset.to_bytes(4, byteorder="little")
    metadata += root_dir_backup_offset.to_bytes(4, byteorder="little")
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

    glob_ofs = len(tree.children) * 4

    for i in tree:
        if i.type == "dir":
            i.data = len(data)
            data = add_aligned(data, create_data_section(i))
        elif i.type == "file":
            i.data = len(data)
            data = add_aligned(data, i.data);
        else:
            raise Exception(f"Unknown type: {i.type}")

    return data


def compile_tree(tree: Node[Node]) -> bytes:
    data = b""

    for i in tree:
        if i.type == "dir":
            data += i.data.to_bytes(4, byteorder="little")
        elif i.type == "file":
            data += i.data.to_bytes(4, byteorder="little")
        else:
            raise Exception(f"Unknown type: {i.type}")
    
    for i in tree:
        if i.type == "dir":
            data += compile_tree(i)
        elif i.type == "file":
            data += i.children[0]
        else:
            raise Exception(f"Unknown type: {i.type}")
    
    return add_aligned("", data)

config = load_config(configJson)

bootsect = config[":"][0]
hxldr = config[":"][1]

tree = create_tree(config["::"])

data = create_data_section(tree)

metadata = create_fs_metadata(len(data), len(data), len(tree.children) * 4)

fs = add_aligned(metadata + bootsect[16:], data)

fwrite(outputFile, bootsect + hxldr + fs)

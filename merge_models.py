from pathlib import Path

import numpy as np
from gensim.models.keyedvectors import KeyedVectors


def load_model(path):
    kv = {}
    with open(path, "r") as f:
        for line in f:
            key, vec = line.split(" ", 1)
            kv[key] = np.array(vec.split(), dtype=float)
    return kv


root_dir = Path("models")
models = {}
for model in root_dir.glob("**/vectors.txt"):
    kv = load_model(model)
    models[model.parent.name] = kv

order = ("inFlows", "outFlows", "controls", "controlledBy", "siblingUsage")
all_keys = set(k for kv in models.values() for k in kv.keys())
merged = {}
for i, typ in enumerate(order):
    model = models[typ]
    for key in all_keys:
        if key in model:
            if key not in merged:
                merged[key] = [np.zeros(len(model[key]))] * len(order)
            merged[key][i] = model[key]


keys, vectors = [], []
for key in merged.keys():
    if key.startswith("field:"):
        keys.append(key[len("field:"):])
        vectors.append(np.concatenate(merged[key], axis=0))

vector_size = vectors[0].shape[0]
out_file = Path(root_dir) / f"structs-glove-{vector_size}.kv"
kv = KeyedVectors(vector_size=vector_size)
kv.add_vectors(keys, vectors)
kv.save(str(out_file))

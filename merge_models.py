from pathlib import Path

import typer
import numpy as np
from gensim.models.keyedvectors import KeyedVectors
from typing import Optional



def load_model(path: Path) -> dict:
    """Load vectors from a text file into a dictionary."""
    kv = {}
    with open(path, "r") as f:
        for line in f:
            key, vec = line.split(" ", 1)
            kv[key] = np.array(vec.split(), dtype=float)
    return kv


def merge_models(model_dir: Path = typer.Argument(
    ...,
    exists=True,
    file_okay=False,
    dir_okay=True,
    help="Directory containing the model vectors to merge"
), vector_size: int = typer.Option(
    ...,
    help="The size of the vectors to merge"
)) -> None:
    """
    Merge multiple vector models into a single KeyedVectors model.
    
    The input directory should contain subdirectories with vectors.txt files.
    The merged model will be saved in the input directory.
    """
    # Load all models
    models = {}
    for model in model_dir.glob("**/vectors-*.txt"):
        try:
            kv = load_model(model)
            models[model.parent.name] = kv
        except Exception as e:
            typer.echo(f"Error loading model {model}: {e}", err=True)
            raise typer.Exit(1)

    # Define order and merge
    order = ("inFlows", "outFlows", "controls", "controlledBy", "siblingUsage")
    all_keys = set(k for kv in models.values() for k in kv.keys())
    
    # Verify all expected models exist
    missing_models = set(order) - set(models.keys())
    if missing_models:
        typer.echo(f"Missing required models: {missing_models}", err=True)
        raise typer.Exit(1)

    merged = {}
    shapes = {}
    for i, typ in enumerate(order):
        model = models[typ]
        for key in all_keys:
            if key in model:
                if key not in merged:
                    merged[key] = [None] * len(order)
                merged[key][i] = model[key]
                shapes[i] = model[key].shape

    # Process and save merged vectors
    keys, vectors = [], []
    for key in merged.keys():
        if key.startswith("field:"):
            keys.append(key[len("field:"):])
            vecs = [v if v is not None else np.zeros(shapes[i]) for i, v in enumerate(merged[key])]
            vectors.append(np.concatenate(vecs, axis=0))

    if not keys:
        typer.echo("No field vectors found to merge", err=True)
        raise typer.Exit(1)

    out_file = model_dir / f"structs-glove-{vector_size}.kv"
    kv = KeyedVectors(vector_size=vector_size)
    kv.add_vectors(keys, vectors)
    kv.save(str(out_file))

    typer.echo(f"Successfully merged {len(keys)} vectors into {out_file}")


def main():
    typer.run(merge_models)


if __name__ == "__main__":
    main()

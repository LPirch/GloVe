#!/bin/bash
set -eu

if [ $# -ne 3 ]
then
    echo "Usage: $0 <corpus> <out_root> <vector_size>"
    exit 1
fi

corpus=$1
out_root=$2
vector_size=$3
VOCAB_FILE=$out_root/vocab.txt
COOCCURRENCE_FILE=$out_root/cooccurrence.bin
COOCCURRENCE_SHUF_FILE=$out_root/cooccurrence.shuf.bin
BUILDDIR=build
SAVE_FILE=$out_root/vectors-$vector_size
VERBOSE=2
MEMORY=256.0
VOCAB_MIN_COUNT=2
MAX_ITER=200
WINDOW_SIZE=15
BINARY=0  # save as text
NUM_THREADS=128
X_MAX=100

PYTHON=python3

rm -rf $out_root
mkdir -p $out_root

echo
echo "$ $BUILDDIR/vocab_count -min-count $VOCAB_MIN_COUNT -verbose $VERBOSE < $corpus > $VOCAB_FILE"
$BUILDDIR/vocab_count -min-count $VOCAB_MIN_COUNT -verbose $VERBOSE < $corpus > $VOCAB_FILE
echo "$ $BUILDDIR/cooccur -memory $MEMORY -vocab-file $VOCAB_FILE -verbose $VERBOSE -window-size $WINDOW_SIZE < $corpus > $COOCCURRENCE_FILE"
$BUILDDIR/cooccur -memory $MEMORY -vocab-file $VOCAB_FILE -verbose $VERBOSE -window-size $WINDOW_SIZE < $corpus > $COOCCURRENCE_FILE
echo "$ $BUILDDIR/shuffle -memory $MEMORY -verbose $VERBOSE < $COOCCURRENCE_FILE > $COOCCURRENCE_SHUF_FILE"
$BUILDDIR/shuffle -memory $MEMORY -verbose $VERBOSE < $COOCCURRENCE_FILE > $COOCCURRENCE_SHUF_FILE
echo "$ $BUILDDIR/glove -save-file $SAVE_FILE -threads $NUM_THREADS -input-file $COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $vector_size -binary $BINARY -vocab-file $VOCAB_FILE -verbose $VERBOSE"
$BUILDDIR/glove -save-file $SAVE_FILE -threads $NUM_THREADS -input-file $COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $vector_size -binary $BINARY -vocab-file $VOCAB_FILE -verbose $VERBOSE

#!/usr/bin/env bash
set -e
# Reproduce experiments from the paper:
# @InProceedings{hershcovich2017a,
#   author    = {Hershcovich, Daniel  and  Abend, Omri  and  Rappoport, Ari},
#   title     = {A Transition-Based Directed Acyclic Graph Parser for UCCA},
#   booktitle = {Proc. of ACL},
#   year      = {2017},
#   pages     = {1127--1138},
#   url       = {http://aclweb.org/anthology/P17-1104}
# }

mkdir -p data_size_impact
cd data_size_impact

pip install --user virtualenv
python -m virtualenv --python=/anaconda3/bin/python datasizevenv
. datasizevenv/bin/activate              # on bash
pip install git+https://github.com/adishalev/ucca --upgrade
pip install git+https://github.com/adishalev/tupa --upgrade

git clone https://github.com/huji-nlp/ucca-corpora --branch v1.2
mkdir -p models wiki-sentences
python -m scripts.standard_to_sentences ucca-corpora/wiki/xml -o wiki-sentences
for SAMPLE_SIZE in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    mkdir -p wiki-sentences-$SAMPLE_SIZE
    cp wiki-sentences/*.xml wiki-sentences-$SAMPLE_SIZE/
    python -m scripts.split_corpus wiki-sentences-$SAMPLE_SIZE -t 0.81 -d 0.09 -total $SAMPLE_SIZE -l --shuffle
    python -m tupa.parse -t wiki-sentences-$SAMPLE_SIZE/train -d wiki-sentences-$SAMPLE_SIZE/dev -c bilstm -m models/sample-$SAMPLE_SIZE -I 25
    python -m tupa.parse -We wiki-sentences-$SAMPLE_SIZE/test -c bilstm -m models/sample-$SAMPLE_SIZE
done

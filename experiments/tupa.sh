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

# create enviroment
mkdir -p ashalev2019
cd ashalev2019
pip install --user virtualenv
python -m virtualenv --python=/anaconda3/bin/python venv
. venv/bin/activate              # on bash

# install relevant packages
pip install git+https://github.com/adishalev/ucca --upgrade
pip install git+https://github.com/adishalev/tupa --upgrade

# get ucca-snacs data
git clone https://github.com/adishalev/UCCA-SNACS

# create ucca-snacs train/dev/test splits
mkdir -p models wiki-snacs-sentences-sample
python -m scripts.standard_to_sentences UCCA-SNACS/data/UCCA_SNACS_wiki_sample/xmls -o wiki-snacs-sentences-sample
python -m scripts.split_corpus wiki-snacs-sentences-sample -t 0.8 -d 0.1 -l

# create ucca train/dev/test splits
mkdir -p models wiki-sentences-sample
python -m scripts.standard_to_sentences UCCA-SNACS/data/UCCA_wiki_sample/xmls -o wiki-sentences-sample
python -m scripts.split_corpus wiki-sentences-sample -t 0.8 -d 0.1 -l

# create ucca train/dev/test splits
mkdir -p models wiki-sentences-full
python -m scripts.standard_to_sentences UCCA-SNACS/data/UCCA_wiki_full/xmls -o wiki-sentences-full
python -m scripts.split_corpus wiki-sentences-full -t 0.8 -d 0.1 -l

#instead of pre-trained models, train.
#python -m tupa.parse -t data/delete_me/wiki-sentences-participants/train -d wiki-snacs-sentences/dev -c bilstm -m models/no-gold-ucca-bilstm --max-action-labels 500 --max-edge-labels=50
#python -m tupa.parse -t data/delete_me/wiki-sentences-participants/train -d wiki-snacs-sentences/dev -c bilstm -m models/no-gold-ucca-bilstm --max-action-labels 500 --max-edge-labels=50 -use-gold-action-labels
#python -m tupa.parse -t data/delete_me/wiki-sentences-participants/train -d wiki-snacs-sentences/dev -c bilstm -m models/no-gold-ucca-bilstm --max-action-labels 500 --max-edge-labels=50 -use-gold-action-labels

#python -m tupa.parse -t data/delete_me/wiki-sentences-participants/train -d wiki-snacs-sentences/dev -c bilstm -m models/no-refinement-ucca-bilstm --max-action-labels 500 --max-edge-labels=50 --no-refinement_labels
#python -m tupa.parse -t data/delete_me/wiki-sentences-participants/train -d wiki-snacs-sentences/dev -c bilstm -m models/no-gold-ucca-bilstm --max-action-labels 500 --max-edge-labels=50 --no-use-gold-action-labels
#python -m tupa.parse -t data/delete_me/wiki-sentences-participants/train -d wiki-snacs-sentences/dev -c bilstm -m models/no-gold-ucca-bilstm --max-action-labels 500 --max-edge-labels=50 --no-use-gold-action-labels
#python -m tupa.parse -t data/delete_me/wiki-sentences-participants/train -d wiki-snacs-sentences/dev -c bilstm -m models/no-gold-ucca-bilstm --max-action-labels 500 --max-edge-labels=50 --no-use-gold-action-labels

#python -m spacy download en_core_web_lg
#for TEST_SET in wiki-snacs-sentences/test 20k-sentences; do
#    for MODEL in sparse mlp bilstm; do
#        python -m tupa.parse -c $MODEL -m models/ucca-$MODEL -We $TEST_SET
#    done
#done
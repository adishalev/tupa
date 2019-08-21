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


# test with new code

python -m virtualenv --python=/anaconda3/bin/python snacsvenv
. snacsvenv/bin/activate              # on bash

# install relevant packages
pip install git+https://github.com/adishalev/ucca
pip install git+https://github.com/adishalev/tupa --upgrade



# get ucca-snacs data
git clone https://github.com/adishalev/UCCA-SNACS

# create ucca-snacs train/dev/test splits
mkdir -p models wiki-snacs-sentence54-sample
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




python -m spacy download en_core_web_lg


# train foundational + refinement, test mutual learning, with refinement feature
python -m tupa.parse -t wiki-snacs-sentences-sample/train -d wiki-snacs-sentences-sample/dev -c bilstm -m models/snacs --max-action-labels 500 --max-edge-labels=50 --I 25
python -m tupa.parse -We wiki-snacs-sentences-sample/test -c bilstm -m models/snacs --max-action-labels 500 --max-edge-labels=50

# train foundational + refinement, test only foundational layer, with refinement feature
python -m tupa.parse -t wiki-snacs-sentences-sample/train -d wiki-snacs-sentences-sample/dev -c bilstm -m models/snacs_foundational --max-action-labels 500 --max-edge-labels=50 --I 25 --no-eval-refinement
python -m tupa.parse -We wiki-snacs-sentences-sample/test -c bilstm -m models/snacs_foundational --max-action-labels 500 --max-edge-labels=50 --no-eval-refinement

# train foundational + refinement, test only refinement layer, with refinement feature
python -m tupa.parse -t wiki-snacs-sentences-sample/train -d wiki-snacs-sentences-sample/dev -c bilstm -m models/snacs_refinement --max-action-labels 500 --max-edge-labels=50 --constructions primary_refinements remote_refinements --I 25 --use-gold-action-labels
python -m tupa.parse -We wiki-snacs-sentences-sample/test -c bilstm -m models/snacs_refinement --max-action-labels 500 --max-edge-labels=50 --constructions primary_refinements remote_refinements --use-gold-action-labels



# train foundational + refinement, test mutual learning, without refinement feature
python -m tupa.parse -t wiki-snacs-sentences-sample/train -d wiki-snacs-sentences-sample/dev -c bilstm -m models/snacs_no_feature --max-action-labels 500 --max-edge-labels=50 --I 25 --omit-features "f"
python -m tupa.parse -We wiki-snacs-sentences-sample/test -c bilstm -m models/snacs_no_feature --max-action-labels 500 --max-edge-labels=50 --omit-features "f"

# train foundational + refinement, test only foundational layer, without refinement feature
python -m tupa.parse -t wiki-snacs-sentences-sample/train -d wiki-snacs-sentences-sample/dev -c bilstm -m models/snacs_foundational_no_feature --max-action-labels 500 --max-edge-labels=50 --I 25 --no-eval-refinement --omit-features "f"
python -m tupa.parse -We wiki-snacs-sentences-sample/test -c bilstm -m models/snacs_foundational_no_feature --max-action-labels 500 --max-edge-labels=50 --no-eval-refinement --omit-features "f"

# train foundational + refinement, test only refinement layer, without refinement feature
python -m tupa.parse -t wiki-snacs-sentences-sample/train -d wiki-snacs-sentences-sample/dev -c bilstm -m models/snacs_refinement_no_feature --max-action-labels 500 --max-edge-labels=50 --constructions primary_refinements remote_refinements --I 25 --omit-features "f" --use-gold-action-labels
python -m tupa.parse -We wiki-snacs-sentences-sample/test -c bilstm -m models/snacs_refinement_no_feature --max-action-labels 500 --max-edge-labels=50 --constructions primary_refinements remote_refinements --omit-features "f" --use-gold-action-labels



#instead of pre-trained models, train.
python -m tupa.parse -t wiki-snacs-sentences-sample/train -d wiki-snacs-sentences-sample/dev -c bilstm -m models/no_refinement_no_feature --max-action-labels 500 --max-edge-labels=50 --no-refinement-labels --I 25
python -m tupa.parse -We wiki-snacs-sentences-sample/train -c bilstm -m models/no_refinement_no_feature --max-action-labels 500 --max-edge-labels=50 --no-refinement-labels


deactivate



# test with old code

python -m virtualenv --python=/anaconda3/bin/python tupavenv
. tupavenv/bin/activate              # on bash

# install relevant packages
pip install git+https://github.com/adishalev/ucca --upgrade
pip install "tupa==1.3.2"

python -m spacy download en_core_web_lg


python -m tupa.parse -t wiki-sentences-sample/train -d wiki-sentences-sample/dev -c bilstm -m models/wiki-sentences-sample-bilstm --I 25
python -m tupa.parse -t wiki-sentences-full/train -d wiki-sentences-full/dev -c bilstm -m models/wiki-sentences-full-bilstm --I 25


for TEST_SET in wiki-sentences-sample/test wiki-sentences-full/test; do
    for MODEL in wiki-sentences-sample-bilstm wiki-sentences-full-bilstm; do
        python -m tupa.parse -c $MODEL -m models/ucca-$MODEL -We $TEST_SET
    done
done

deactivate

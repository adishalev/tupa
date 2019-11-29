#This script is testing the value of the refinement feature tp the parsing. it seems like there is no value, so probably overfitting?  first row - eval refinement, second row - no eval refinement
#python3 /home/arugga/PycharmProjects/tupa/tupa/parse.py --dynet-gpu -t ../data/wiki-snacs-sentences-sample/pre/train -d ../data/wiki-snacs-sentences-sample/pre/dev -c bilstm -m models/snacs --max-action-labels 500 --max-edge-labels=50 -I 2

#python3 -m tupa.parse -t data/mixed/fold_0/train -d data/mixed/fold_0/dev -c bilstm -m models/snacs_0 --max-action-labels 500 --max-edge-labels=50 -I 30
python3 -m tupa.parse -We data/mixed/fold_0/test -c bilstm -m models/snacs_0 --no-eval-refinement

#python3 -m tupa.parse -t data/mixed/fold_1/train -d data/mixed/fold_1/dev -c bilstm -m models/snacs_1 --max-action-labels 500 --max-edge-labels=50 -I 30
#python3 -m tupa.parse -We data/mixed/fold_1/test -c bilstm -m models/snacs_1

#python3 -m tupa.parse -t data/mixed/fold_2/train -d data/mixed/fold_2/dev -c bilstm -m models/snacs_2 --max-action-labels 500 --max-edge-labels=50 -I 30
#python3 -m tupa.parse -We data/mixed/fold_2/test -c bilstm -m models/snacs_2

#python3 -m tupa.parse -t data/mixed/fold_3/train -d data/mixed/fold_3/dev -c bilstm -m models/snacs_3 --max-action-labels 500 --max-edge-labels=50 -I 30
#python3 -m tupa.parse -We data/mixed/fold_3/test -c bilstm -m models/snacs_3

#python3 -m tupa.parse -t data/mixed/fold_4/train -d data/mixed/fold_4/dev -c bilstm -m models/snacs_4 --max-action-labels 500 --max-edge-labels=50 -I 30
#python3 -m tupa.parse -We data/mixed/fold_4/test -c bilstm -m models/snacs_4
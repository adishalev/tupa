import numpy as np
from ucca.textutil import get_word_vectors

from .feature_extractor import FeatureExtractor
from .feature_params import MISSING_VALUE, NumericFeatureParameters, copy_params
from ..model_util import load_dict, save_dict, UnknownDict, DropoutDict

INDEXED_FEATURES = "W", "w", "t", "d", "T"  # external + learned word embeddings, POS tags, dep rels, entity type
FILENAME_SUFFIX = ".enum"


class FeatureEnumerator(FeatureExtractor):
    """
    Wrapper for DenseFeatureExtractor to replace non-numeric feature values with numbers.
    To be used with NeuralNetwork classifier.
    """

    def __init__(self, feature_extractor, params, indexed):
        super().__init__()
        self.feature_extractor = feature_extractor
        self.params = params
        self.indexed = indexed
        if self.indexed:
            self.collapse_features(INDEXED_FEATURES)
        self.params = {p.suffix: p for p in [self.init_param(p) for p in self.params.values()
                                             if p.effective_suffix in self.feature_extractor] +
                       [NumericFeatureParameters(self.feature_extractor.numeric_num())]}

    @property
    def params(self):
        return self.feature_extractor.params if self.feature_extractor else None

    @params.setter
    def params(self, p):
        if self.feature_extractor:
            self.feature_extractor.params = p

    def collapse_features(self, suffixes):
        self.feature_extractor.collapse_features({p.copy_from if p.external else s for s, p in self.params.items()
                                                  if p.dim and s in suffixes})

    def init_param(self, param):
        param.num = self.feature_extractor.non_numeric_num(param.effective_suffix)
        self.init_data(param)
        if self.indexed and param.suffix in INDEXED_FEATURES:
            param.indexed = True
        return param

    @staticmethod
    def init_data(param):
        if param.data is None:
            keys = ()
            if param.dim and param.external:
                vectors = FeatureEnumerator.get_word_vectors(param)
                keys = vectors.keys()
                param.init = np.array(list(vectors.values()))
            param.data = DropoutDict(size=param.size, keys=keys, dropout=param.dropout, min_count=param.min_count)

    @staticmethod
    def get_word_vectors(param):
        vectors, param.dim = get_word_vectors(param.dim, param.size, param.filename)
        if param.size is not None:
            assert len(vectors) <= param.size, "Loaded more vectors than requested: %d>%d" % (len(vectors), param.size)
        assert vectors, "Cannot load word vectors. Install them using `python -m spacy download en` or choose a file " \
                        "using the --word-vectors option."
        param.size = len(vectors)
        return vectors

    def init_features(self, state, suffix=None):
        features = {}
        for suffix, param in self.params.items():
            if param.indexed and param.enabled:
                values = self.feature_extractor.init_features(state, param.effective_suffix)
                assert MISSING_VALUE not in values, "Missing value occurred in feature initialization: '%s'" % suffix
                features[suffix] = [param.data[v] for v in values]
        return features

    def extract_features(self, state, params=None):
        """
        Calculate feature values according to current state
        :param state: current state of the parser
        :param params: ignored
        :return dict of feature name -> numeric value
        """
        numeric_features, non_numeric_features = self.feature_extractor.extract_features(state)
        features = {NumericFeatureParameters.SUFFIX: numeric_features}
        for suffix, param in self.params.items():
            if param.dim and (param.copy_from is None or not self.params[param.copy_from].dim or not param.indexed):
                values = non_numeric_features.get(param.effective_suffix)
                if values is not None:
                    features[suffix] = values if param.indexed else \
                        [v if v == MISSING_VALUE else param.data[v] for v in values]
                    # assert all(isinstance(f, int) for f in features[suffix]),\
                    #     "Invalid feature numbers for '%s': %s" % (suffix, features[suffix])
        return features

    def finalize(self):
        return FeatureEnumerator(self.feature_extractor, copy_params(self.params, UnknownDict), self.indexed)

    def restore(self):
        """
        Opposite of finalize(): replace each feature parameter's data dict with a DropoutDict again, to keep training
        """
        for param in self.params.values():
            param.data = DropoutDict(param.data, size=param.size, dropout=param.dropout, min_count=param.min_count)

    def save(self, filename):
        save_dict(filename + FILENAME_SUFFIX, copy_params(self.params))

    def load(self, filename):
        self.params = copy_params(load_dict(filename + FILENAME_SUFFIX), UnknownDict)
        if self.indexed:
            self.collapse_features(INDEXED_FEATURES)

    def get_all_features(self, indexed=False):
        return self.feature_extractor.get_all_features(indexed)

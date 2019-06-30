class Labels:
    def __init__(self, size, is_refinement=False):
        self.size = size  # Maximum number of labels, NOT enforced here but by the user
        self.is_refinement = is_refinement # Whether this label is a parent category (has refinement categories) or not.

    @property
    def all(self):
        raise NotImplementedError()

    @all.setter
    def all(self, labels):
        raise NotImplementedError()

    def save(self, skip=False):
        return (None if skip else self.all), self.size, self.is_refinement

    def load(self, all_size_refinement):
        self.all, self.size, self.is_refinement = all_size_refinement

from ..config import Config


class Edge:
    """
    Temporary representation for core.Edge with only relevant information for parsing
    """
    def __init__(self, parent, child, tag, orig_edge, remote=False):
        self.parent = parent  # Node object from which this edge comes
        self.child = child  # Node object to which this edge goes
        self.tag = tag  # String tag
        # List of categories
        self.categories = orig_edge.categories if orig_edge else None
        refinement_l = [c for c in self.categories if c.parent == self.tag] if self.categories else []
        self.refinement = refinement_l[0].tag if len(refinement_l) > 0 else None
        self.remote = remote  # True or False

    def add(self):
        assert self.parent is not self.child, "Trying to create self-loop edge on %s" % self.parent
        if Config().args.verify:
            assert self not in self.parent.outgoing, "Trying to create outgoing edge twice: %s" % self
            assert self not in self.child.incoming, "Trying to create incoming edge twice: %s" % self
            assert self.parent not in self.child.descendants, "Detected cycle created by edge: %s" % self
        self.parent.add_outgoing(self)
        self.child.add_incoming(self)

    def __repr__(self):
        return Edge.__name__ + "(" + self.tag + ", " + repr(self.parent) + ", " + repr(self.child) +\
               ((", " + str(self.remote)) if self.remote else "") + ")"

    def __str__(self):
        if self.refinement:
            return "%s -%s:%s-> %s%s" % (self.parent, self.tag, self.refinement, self.child, " (remote)" if self.remote else "")
        return "%s -%s-> %s%s" % (self.parent, self.tag, self.child, " (remote)" if self.remote else "")

    def __eq__(self, other):
        return other and self.parent.index == other.parent.index and self.child == other.child and \
               self.tag == other.tag and self.refinement == other.refinement and self.remote == other.remote

    def __hash__(self):
        return hash((self.parent.index, self.child.index, self.tag))

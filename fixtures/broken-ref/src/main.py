# @ref LLP 0000#real-section — resolves: doc and anchor both exist
def fine():
    pass


# @ref LLP 0000.000#child-section — resolves: dotted sub-LLP number and anchor
def fine_sub_llp():
    pass


# @ref LLP 0099#anything — broken: LLP 0099 does not exist
def broken_document():
    pass


# @ref LLP 0000#missing-anchor — broken: the anchor is not in LLP 0000
def broken_anchor():
    pass

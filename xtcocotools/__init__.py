"""Compatibility namespace for Python 3.13 Colab runtimes.

MMPose imports xtcocotools, while pycocotools provides the same COCO APIs
needed by MuseTalk inference without the unmaintained native extension.
"""

from .coco import COCO
from .cocoeval import COCOeval

__all__ = ["COCO", "COCOeval"]
